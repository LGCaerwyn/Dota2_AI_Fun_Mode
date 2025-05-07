--[[
--*************************************************************************************************

设计思路：

    官方的游戏机制中，多个生命恢复增强或治疗增强采用类似魔抗的乘法计算，最多叠加到100%，但是

与对应的削弱效果是加减法计算。

    假设英雄A拥有冰眼、冰甲、大骨灰等道具后，他的生命恢复削弱有90%；英雄B拥有三叉戟，他的生命

恢复增强有60%。A攻击B的时候，B的生命恢复降低了30%，所以当AI出到三叉戟+AI神杖之后，大骨灰和冰

眼等道具不能大幅降低它们的生命恢复，需要设计一个能采用乘法计算的针对性道具。

    采用治疗过滤器可以实现，但是过滤器不能修改场景和UI的治疗和生命恢复的数字，治疗数字无法改

变尚能接受，生命恢复则需要靠叠加负的生命恢复实现，但这一步在计算时需要测出散华类道具提供的生

命恢复增强，同时要避免生命恢复为负值时的意外情况。

--*************************************************************************************************
]]
function item_fun_spirit_vessel_OnSpellStart(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local dur = ability:GetSpecialValueFor("duration")
    local hp_cost_pct = ability:GetSpecialValueFor("hp_cost_pct")
    local debuff_name = ""
    local debuff = nil
    local damage_table = {}
    damage_table.victim = caster
    damage_table.attacker = caster
    damage_table.damage = caster:GetHealth() * hp_cost_pct / 100
    damage_table.damage_type = DAMAGE_TYPE_PURE
    damage_table.damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + 
                                DOTA_DAMAGE_FLAG_HPLOSS + 
                                DOTA_DAMAGE_FLAG_NON_LETHAL + 
                                DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + 
                                DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + 
                                DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL
    damage_table.ability = ability
    caster:EmitSound("DOTA_Item.SpiritVessel.Cast")
    
    if caster ~= target then
        ApplyDamage(damage_table)
    end
    if caster:GetTeam() == target:GetTeam() then
        if caster == target then
            ability:RefundManaCost()
        end
        ability:ApplyDataDrivenModifier(caster, target, "modifier_item_fun_spirit_vessel_buff", { duration = dur })
        target:EmitSound("DOTA_Item.SpiritVessel.Target.Ally")
    else
        --target:AddNewModifier(caster, ability, "modifier_item_spirit_vessel_damage", { duration = dur })

        debuff_name_0 = "modifier_item_fun_spirit_vessel_debuff_0"

        debuff_name_1 = "modifier_item_fun_spirit_vessel_debuff_1"

        ability:ApplyDataDrivenModifier(caster, target, debuff_name_0, { duration = dur })
        ability:ApplyDataDrivenModifier(caster, target, debuff_name_1, { duration = dur })
        debuff_0 = target:FindModifierByName(debuff_name_0)
        debuff_1 = target:FindModifierByName(debuff_name_1)
        if debuff_0 then
            debuff_0:SetDuration(dur, true)
        end
        if debuff_1 then
            debuff_1:SetDuration(dur, true)
        end
        target:EmitSound("DOTA_Item.SpiritVessel.Target.Enemy")
    end
end

--祭品光环的添加和移除
function item_fun_spirit_vessel_OnCreated(keys)  
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    caster:RemoveModifierByName("modifier_item_vladmir")
    caster:AddNewModifier(caster, ability, "modifier_item_vladmir", nil)
    
    if caster.vessel_charges ~= nil then
        ability:SetCurrentCharges(caster.vessel_charges)
        caster.vessel_charges = nil

    end


end

function item_fun_spirit_vessel_OnDestroy(keys)  
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    local buffs = caster:FindAllModifiersByName("modifier_item_vladmir")
    for _,v in pairs(buffs) do
        if v:GetAbility() == ability then
            v:Destroy()
            return
        end
    end
end

--持续伤害效果
function item_fun_spirit_vessel_debuff_OnCreated(keys)

    if not IsServer() then return true end

    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    local debuff = target:FindModifierByName("modifier_item_fun_spirit_vessel_debuff_0")

    debuff.soul_damage_amount = ability:GetSpecialValueFor("soul_damage_amount")
    debuff.soul_mp_loss_amount = ability:GetSpecialValueFor("soul_mp_loss_amount")
    debuff.enemy_hp_drain = ability:GetSpecialValueFor("enemy_hp_drain") / 100
    debuff.enemy_mp_drain = ability:GetSpecialValueFor("enemy_mp_drain") / 100
    debuff.hp_regen_reduction_enemy = ability:GetSpecialValueFor("hp_regen_reduction_enemy") / 100

    local damage_table = {}
    damage_table.victim = target
    damage_table.attacker = caster
    --damage_table.damage = debuff.soul_damage_amount + target:GetHealth() * debuff.enemy_hp_drain
    damage_table.damage_type = DAMAGE_TYPE_MAGICAL
    damage_table.ability = ability

    debuff.damage_table = damage_table

end

function item_fun_spirit_vessel_debuff_OnIntervalThink(keys)  

    if not IsServer() then return true end

    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    local debuff = target:FindModifierByName("modifier_item_fun_spirit_vessel_debuff_0")

    local hp_loss = debuff.soul_damage_amount + target:GetHealth() * debuff.enemy_hp_drain
    local mana_loss = debuff.soul_mp_loss_amount + target:GetMana() * debuff.enemy_mp_drain

    local damage_table = debuff.damage_table
    damage_table.damage = hp_loss

    target:Script_ReduceMana(mana_loss, ability)
    ApplyDamage(damage_table)

end

function item_fun_spirit_vessel_debuff_OnDestroy(keys)  

    if not IsServer() then return true end

    local caster = keys.caster
    local target = keys.target

    target:RemoveModifierByName("modifier_item_fun_spirit_vessel_debuff_1")

end

--减恢复叠层
function item_fun_spirit_vessel_debuff_1_OnCreated(keys)  

    if not IsServer() then return true end

    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    local debuff_1 = target:FindModifierByName("modifier_item_fun_spirit_vessel_debuff_1")
    if debuff_1 then
        debuff_1:SetStackCount(1)
        --先测试出单位的生命恢复增强
        local hp_regen_amp = 0
        local hp_regen_1 = target:GetHealthRegen()
        local hp_regen_2 = 0
        local stack = debuff_1:GetStackCount()

        debuff_1:SetStackCount(2)
        hp_regen_2 = target:GetHealthRegen()
        hp_regen_amp = (hp_regen_1 * 1000 - hp_regen_2 * 1000) / 10 - 1
        --print(hp_regen_amp)
        debuff_1.hp_regen_reduction_enemy = ability:GetSpecialValueFor("hp_regen_reduction_enemy")  --没有除以100是因为每层恢复为-0.01点

        if hp_regen_amp <= -1 then
            debuff_1.stack = 1
            debuff_1:SetStackCount(debuff_1.stack)
        else
            debuff_1.stack = math.floor((target:GetHealthRegen() + 0.01*(1+hp_regen_amp)) * debuff_1.hp_regen_reduction_enemy / (1 + hp_regen_amp))
            debuff_1:SetStackCount(debuff_1.stack)
        end      
    end
end

function item_fun_spirit_vessel_debuff_1_OnIntervalThink(keys)  

    if not IsServer() then return true end

    local caster = keys.caster
    local target = keys.target

    local debuff_1 = target:FindModifierByName("modifier_item_fun_spirit_vessel_debuff_1")
    if debuff_1 then

        --先测试出单位的生命恢复增强
        debuff_1:SetStackCount(1)

        local hp_regen_amp = 0
        local hp_regen_1 = target:GetHealthRegen()
        local hp_regen_2 = 0
        local stack = debuff_1:GetStackCount()

        debuff_1:SetStackCount(2)
        hp_regen_2 = target:GetHealthRegen()
        hp_regen_amp = (hp_regen_1 * 1000 - hp_regen_2 * 1000) / 10 - 1
        print(hp_regen_amp)

        if hp_regen_amp <= -1 then
            debuff_1.stack = 1
            debuff_1:SetStackCount(debuff_1.stack)
        else
            debuff_1.stack = math.floor((target:GetHealthRegen() + 0.01*(1+hp_regen_amp)) * debuff_1.hp_regen_reduction_enemy / (1 + hp_regen_amp))
            debuff_1:SetStackCount(debuff_1.stack)
        end 

    end

end

--治疗受到伤害被驱散
function modifier_item_fun_spirit_vessel_buff_OnAttacked(keys)
    if not IsServer() then return true end
    local attacker = keys.attacker
    local target = keys.target
    local buff = target:FindModifierByName("modifier_item_fun_spirit_vessel_buff")
    if attacker:GetTeam() ~= target:GetTeam() and attacker:IsControllableByAnyPlayer() and buff then
        buff:Destroy()
    end
end

function modifier_item_fun_spirit_vessel_buff_OnTakeDamage(keys)
    if not IsServer() then return true end
    local attacker = keys.attacker
    local target = keys.unit
    local buff = target:FindModifierByName("modifier_item_fun_spirit_vessel_buff")
    if attacker:GetTeam() ~= target:GetTeam() and attacker:IsControllableByAnyPlayer() and buff then
        buff:Destroy()
    end
end

--在fun_filter.lua中存在关联过滤器
--CHeroDemo:HealingFilter
function item_fun_spirit_vessel_debuff_HealingFilter(event)

    if IsServer() then 
        
        local target = nil
        local debuff = nil

        if event.entindex_target_const then
            target = EntIndexToHScript(event.entindex_target_const)
        end

        if target then
            debuff = target:FindModifierByName("modifier_item_fun_spirit_vessel_debuff_0")
        end

        if debuff then
        --[[
            if event.entindex_inflictor_const == nil then 
                print("entindex_inflictor_const is nil")
            else
                local inflictor = EntIndexToHScript(event.entindex_inflictor_const)
                if inflictor == nil then 
                    print("inflictor is nil")
                else
                    print(inflictor:GetName())
                end
            end     
 
            if event.entindex_healer_const == nil then 
                print("entindex_healer_const is nil")
            else
                local healer = EntIndexToHScript(event.entindex_healer_const)
                if healer == nil then 
                    print("healer is nil")
                else
                    print(healer:GetName())
                end
            end         
        ]]
            if debuff.hp_regen_reduction_enemy and 
                (event.entindex_inflictor_const ~= nil or 
                 event.entindex_healer_const ~= nil)
            then
                event.heal = event.heal * ( 1 - debuff.hp_regen_reduction_enemy )
            end
        end
    end
    return true     
end

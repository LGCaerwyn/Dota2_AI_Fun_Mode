--哈哈哈

function item_fun_spirit_vessel_OnSpellStart(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local dur = ability:GetSpecialValueFor("duration")
    local hp_cost_pct = ability:GetSpecialValueFor("hp_cost_pct")
    local debuff_name = ""
    local debuff = nil
    local time = math.floor(GameRules:GetDOTATime(false, false)/60)
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
        target:AddNewModifier(caster, ability, "modifier_item_spirit_vessel_heal", { duration = dur })
        ability:ApplyDataDrivenModifier(caster, target, "modifier_item_fun_spirit_vessel_buff", { duration = dur })
        target:EmitSound("DOTA_Item.SpiritVessel.Target.Ally")
    else
        target:AddNewModifier(caster, ability, "modifier_item_spirit_vessel_damage", { duration = dur })
        if time >= 60 then
            debuff_name = "modifier_item_fun_spirit_vessel_debuff_1"
        else 
            debuff_name = "modifier_item_fun_spirit_vessel_debuff_0"
        end
        ability:ApplyDataDrivenModifier(caster, target, debuff_name, { duration = dur })
        debuff = target:FindModifierByName(debuff_name)
        if debuff then
            debuff:SetDuration(dur, true)
        end
        target:EmitSound("DOTA_Item.SpiritVessel.Target.Enemy")
    end
end

function item_fun_spirit_vessel_OnCreated(keys)  
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    caster:AddNewModifier(caster, ability, "modifier_item_vladmir", nil)
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

function item_fun_spirit_vessel_debuff_OnIntervalThink(keys)  
    if not IsServer() then return true end
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local enemy_mp_drain = ability:GetSpecialValueFor("enemy_mp_drain")
    local soul_mp_loss_amount = ability:GetSpecialValueFor("soul_mp_loss_amount")
    local mana_loss = soul_mp_loss_amount + target:GetMana() * enemy_mp_drain / 100
    target:Script_ReduceMana(mana_loss, ability)
end

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
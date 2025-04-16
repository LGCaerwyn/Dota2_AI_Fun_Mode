
function wisp_overcharge_fun_OnCreated(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    ability:SetStealable(false)
end

function wisp_overcharge_fun_OnAbilityExecuted(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster =keys.caster
    local target = keys.target
    local event_ability = keys.event_ability
    local fun_ability = caster:FindAbilityByName("wisp_overcharge_fun")

    if event_ability:GetAbilityName() == "wisp_tether" and fun_ability then
        fun_ability.tether_target = target
    end

end

function wisp_overcharge_fun_OnIntervalThink(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability

    --神杖百分比生命恢复,不可被破坏  
    local hp_regen_pct = ability:GetSpecialValueFor("hp_regen_pct")/100
    local hp_regen_pct_multiplier = ability:GetSpecialValueFor("hp_regen_pct_multiplier")
    local hp_regen = hp_regen_pct * caster:GetMaxHealth()
    local hp_loss_pct = (caster:GetMaxHealth() - caster:GetHealth()) / caster:GetMaxHealth()

    if ability:GetToggleState() == true then
        hp_regen = hp_regen * (1 + (hp_regen_pct_multiplier -1) * hp_loss_pct)  
    end

    local hp_regen_stack = math.floor(hp_regen * 10) --这里的10 = 1 / 0.1，0.1是KV修饰器中的每层回血数值

    local modifier_hp_regen = caster:FindModifierByName("modifier_wisp_overcharge_fun_hp_regen")

    if caster:HasScepter() then
        
        if modifier_hp_regen == nil then
            
            modifier_hp_regen = ability:ApplyDataDrivenModifier(caster, caster, "modifier_wisp_overcharge_fun_hp_regen", nil)  
            
        end
            
        if modifier_hp_regen then

            modifier_hp_regen:SetStackCount(hp_regen_stack)

        end

    else
        
        caster:RemoveModifierByName("modifier_wisp_overcharge_fun_hp_regen")

    end

    --提供艾欧的百分比属性和攻击力，艾欧被破坏时失去所有加成
    local tether_target = ability.tether_target
    if tether_target == nil then return end
    if not tether_target:IsHero() then return end
    
    local modifier_tether = caster:FindModifierByName("modifier_wisp_tether")

    local stack = 0
    local fixed_stack = 0

    local modifier_scepter_str = tether_target:FindModifierByName("modifier_wisp_overcharge_fun_scepter_strength")
    local modifier_scepter_agi = tether_target:FindModifierByName("modifier_wisp_overcharge_fun_scepter_agility")
    local modifier_scepter_int = tether_target:FindModifierByName("modifier_wisp_overcharge_fun_scepter_intellect")
    local modifier_scepter_damage_target = tether_target:FindModifierByName("modifier_wisp_overcharge_fun_scepter_damage_target")
    local modifier_scepter_damage_caster = caster:FindModifierByName("modifier_wisp_overcharge_fun_scepter_damage_caster")
    
    if caster:HasScepter() and not caster:PassivesDisabled() and ability:GetToggleState() and modifier_tether then
        
        --提供力量
        if modifier_scepter_str == nil then 

            modifier_scepter_str = ability:ApplyDataDrivenModifier(caster, tether_target, "modifier_wisp_overcharge_fun_scepter_strength", nil) 
        end
        
        if modifier_scepter_str then

            --如果根据艾欧的属性提供加成，力量、敏捷、智力这一项都改成了0
            --不要让拉比克学习，因为这里省略了艾欧自身层数的判断
            fixed_stack = 0--modifier_scepter_str:GetStackCount()

            if tether_target:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then

                stack = (caster:GetStrength() - fixed_stack  *0.1) * ability:GetSpecialValueFor("bonus_stat_scepter_primary") / 10

            elseif tether_target:GetPrimaryAttribute() == DOTA_ATTRIBUTE_ALL then

                stack = (caster:GetStrength() - fixed_stack  *0.1) * ability:GetSpecialValueFor("bonus_stat_scepter_universal") / 10

            else

                stack = (caster:GetStrength() - fixed_stack  *0.1) * ability:GetSpecialValueFor("bonus_stat_scepter") / 10

            end
            stack = math.floor(stack)
            modifier_scepter_str:SetStackCount(stack)
            stack = 0

        end

        --提供敏捷
        if modifier_scepter_agi == nil then 
            
            modifier_scepter_agi = ability:ApplyDataDrivenModifier(caster, tether_target, "modifier_wisp_overcharge_fun_scepter_agility", nil)         
            
        end

        if modifier_scepter_agi then

            fixed_stack = 0--modifier_scepter_agi:GetStackCount()

            if tether_target:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then

                stack = (caster:GetAgility() - fixed_stack  * 0.1) * ability:GetSpecialValueFor("bonus_stat_scepter_primary") / 10

            elseif tether_target:GetPrimaryAttribute() == DOTA_ATTRIBUTE_ALL then

                stack = (caster:GetAgility() - fixed_stack  * 0.1) * ability:GetSpecialValueFor("bonus_stat_scepter_universal") / 10

            else

                stack = (caster:GetAgility() - fixed_stack  * 0.1) * ability:GetSpecialValueFor("bonus_stat_scepter") / 10

            end
            stack = math.floor(stack)
            modifier_scepter_agi:SetStackCount(stack)
            stack = 0

        end

        --提供智力
        if modifier_scepter_int == nil then 
        
            modifier_scepter_int = ability:ApplyDataDrivenModifier(caster, tether_target, "modifier_wisp_overcharge_fun_scepter_intellect", nil) 

        end
        
        if modifier_scepter_int then

            fixed_stack = 0--modifier_scepter_int:GetStackCount()

            if tether_target:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then

               stack = (caster:GetIntellect(false) - fixed_stack  *0.1) * ability:GetSpecialValueFor("bonus_stat_scepter_primary") / 10

            elseif tether_target:GetPrimaryAttribute() == DOTA_ATTRIBUTE_ALL then

                stack = (caster:GetIntellect(false) - fixed_stack  *0.1) * ability:GetSpecialValueFor("bonus_stat_scepter_universal") / 10

            else

                stack = (caster:GetIntellect(false) - fixed_stack  *0.1)  * ability:GetSpecialValueFor("bonus_stat_scepter") / 10

            end
            stack = math.floor(stack)
            modifier_scepter_int:SetStackCount(stack)
            stack = 0

        end

        --施法者降低攻击力
        if modifier_scepter_damage_caster == nil then 
        
            modifier_scepter_damage_caster = ability:ApplyDataDrivenModifier(caster, caster, "modifier_wisp_overcharge_fun_scepter_damage_caster", nil)            
            
        end

        --链接目标提供攻击力
        if modifier_scepter_damage_target == nil then 
        
            modifier_scepter_damage_target = ability:ApplyDataDrivenModifier(caster, tether_target, "modifier_wisp_overcharge_fun_scepter_damage_target", nil)    

        end
        
    else

        tether_target:RemoveModifierByName("modifier_wisp_overcharge_fun_scepter_strength")
        tether_target:RemoveModifierByName("modifier_wisp_overcharge_fun_scepter_agility")
        tether_target:RemoveModifierByName("modifier_wisp_overcharge_fun_scepter_intellect")
        tether_target:RemoveModifierByName("modifier_wisp_overcharge_fun_scepter_damage_target")
        caster:RemoveModifierByName("modifier_wisp_overcharge_fun_scepter_damage_caster")

    end

end


function wisp_overcharge_fun_DamageFilter(event, original_damage)
    if not IsServer() then return true end
    local damage = event.damage
    if event.entindex_victim_const == nil or
	   event.entindex_attacker_const == nil 
	then
	    return true
	end
    local victim = EntIndexToHScript(event.entindex_victim_const)
	local attacker = EntIndexToHScript(event.entindex_attacker_const)
    local modifier_tether_haste = victim:FindModifierByName("modifier_wisp_tether_haste")  
    if modifier_tether_haste == nil then return true end
    local modifier_caster = modifier_tether_haste:GetCaster()
	local fun_ability = modifier_caster:FindAbilityByName("wisp_overcharge_fun")
    if fun_ability == nil then return true end
    if fun_ability:GetLevel() < 1 then return true end
    local damage_reduction_pct = 0
    if fun_ability:GetToggleState() == true then
        damage_reduction_pct = fun_ability:GetSpecialValueFor("damage_reduction_pct_toggle_on")/100
    else
        damage_reduction_pct = fun_ability:GetSpecialValueFor("damage_reduction_pct_toggle_off")/100
    end

    local modifier_caster_hp = modifier_caster:GetHealth()
    local pre_damage = math.min(damage * damage_reduction_pct, modifier_caster_hp - 1) --承受的伤害有限，以不致死为前提

    event.damage = damage - pre_damage
    local damage_table = {}
    damage_table.victim = modifier_caster
    damage_table.attacker = attacker
    damage_table.damage = pre_damage
    damage_table.damage_type = event.damagetype_const
    damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_BYPASSES_PHYSICAL_BLOCK
    --damage_table.damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
    damage_table.ability = fun_ability
    ApplyDamage(damage_table)

    return true
end

function wisp_overcharge_fun_ModifierGainedFilter(event)
    if not IsServer() then return true end
    if not event.entindex_caster_const then return true end
    if not event.entindex_parent_const then return true end
    if not event.name_const then return true end
    if not event.entindex_ability_const then return end
    local caster = EntIndexToHScript(event.entindex_caster_const)
    local npc = EntIndexToHScript(event.entindex_parent_const)
    local ability = EntIndexToHScript(event.entindex_ability_const)
    local modifier_name = event.name_const
    if caster == nil then return true end
    if npc == nil then return true end
    local modifier_tether_haste = npc:FindModifierByName("modifier_wisp_tether_haste")  
    if modifier_tether_haste == nil then return true end
    local modifier_caster = modifier_tether_haste:GetCaster()
	local fun_ability = modifier_caster:FindAbilityByName("wisp_overcharge_fun")
    if fun_ability == nil then return true end
    if fun_ability:GetLevel() < 1 then return true end 
    if not modifier_caster:HasScepter() then return true end
    if fun_ability:GetToggleState() == false then return true end
    if npc:FindModifierByName("modifier_wisp_tether") and npc:FindAbilityByName("wisp_overcharge_fun") then return true end
    if npc:GetTeam() ~= caster:GetTeam() or event.name_const == "modifier_faceless_void_chronosphere_freeze" then
        local dur = event.duration * (1 - modifier_caster:GetStatusResistance())
        if dur == nil then
            return true
        elseif dur == -1 then
            return true
        else
            local class_name = ability:GetClassname()
            --print(class_name)
            if class_name == "ability_datadriven" or class_name == "item_datadriven" then
                ability:ApplyDataDrivenModifier(caster, modifier_caster, modifier_name, { duration = dur })
            else
                modifier_caster:AddNewModifier(caster, ability, modifier_name, { duration = dur })
            end
            
            return false
        end   
    end
    return true 
end

function item_fun_greater_mango_OnSpellStart(keys)

    local caster = keys.caster
    local ability = keys.ability
    local dur = ability:GetSpecialValueFor("duration_active")
    local _visibility_radius = ability:GetSpecialValueFor("visibility_radius")
    local _bonus_movement_speed = ability:GetSpecialValueFor("bonus_movement_speed")

    caster:EmitSound("DOTA_Item.SmokeOfDeceit.Activate")
    caster:EmitSound("Item.Brooch.Cast")
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_fun_greater_mango_active", { duration = dur })
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_smoke_of_deceit", { duration = dur, visibility_radius = _visibility_radius, bonus_movement_speed = _bonus_movement_speed })
end

--在fun_filter.lua中存在关联过滤器
--CHeroDemo:DamageFilter
function item_fun_greater_mango_DamageFilter(event, original_damage)
    --print("触发芒果")
    if not event.entindex_attacker_const then 
        return true
    end

    local attacker = EntIndexToHScript(event.entindex_attacker_const)
    
    if not attacker then 
        return true
    end

    local victim = EntIndexToHScript(event.entindex_victim_const)

    local buff_amp_mango = attacker:FindModifierByName("modifier_item_fun_greater_mango_active")
    
    if not buff_amp_mango then 
        return true
    end

    local ability = buff_amp_mango:GetAbility()
    local damage_amp = ability:GetSpecialValueFor("resistance_ignore")/100
    local resistance = 0
    local pre_dmg = event.damage

    if event.damagetype_const == DAMAGE_TYPE_MAGICAL then

        resistance = victim:Script_GetMagicalArmorValue(false, nil)
        if resistance >=1 then return true end
        event.damage = pre_dmg * (1 + damage_amp - resistance) / (1 - resistance)

    elseif event.damagetype_const == DAMAGE_TYPE_PHYSICAL then

        local armor = victim:GetPhysicalArmorValue(false)
        resistance = 0.06 * armor/(1 + 0.06 * armor)
        event.damage = pre_dmg * (1 + damage_amp - resistance) / (1 - resistance)

    elseif event.damagetype_const == DAMAGE_TYPE_PURE then

        event.damage = pre_dmg * (1 + damage_amp)

    end
    
    if event.damage < original_damage then
        event.damage = original_damage
    end

    return true 
    
end
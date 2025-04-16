
function dumangguo_fun(keys)
    local caster = keys.caster
    local caster_loc = caster:GetAbsOrigin()
    local ability = keys.ability
    local modifier_active = "modifier_item_毒芒果_active"
    local modifier_active_allies = "modifier_item_毒芒果_active_allies"
    local radius = ability:GetSpecialValueFor("radius")
    local dur = ability:GetSpecialValueFor("duration")
	local target_teams = ability:GetAbilityTargetTeam()
    local target_types = ability:GetAbilityTargetType() 
    local target_flags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE


    units = FindUnitsInRadius(caster:GetTeamNumber(), caster_loc, nil, radius, target_teams, target_types, target_flags, FIND_ANY_ORDER, false)

    for k,unit in pairs(units) do
        if unit == caster then
            ability:ApplyDataDrivenModifier(caster, unit, modifier_active, { duration = dur })
            ability:ApplyDataDrivenModifier(caster, unit, "modifier_smoke_of_deceit", { duration = dur })
        else
            ability:ApplyDataDrivenModifier(caster, unit, modifier_active_allies, { duration = dur })
        end
    end
end

function apply_modifier(keys)
    local caster = keys.caster
    local attacker = keys.attacker
    local ability = keys.ability

    ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_helm_of_the_undying", nil)

end

function remove_modifier(keys)
    local caster = keys.caster
    local attacker = keys.attacker
    local ability = keys.ability

    caster:RemoveModifierByName("modifier_item_helm_of_the_undying")

end
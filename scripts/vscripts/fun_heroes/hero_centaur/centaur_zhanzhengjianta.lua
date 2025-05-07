function hoof_stomp(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    local owner
    local isSecondary = keys.IsSecondary
    if isSecondary == 0 then
        owner = caster
    else 
        owner = keys.target
    end

    owner:EmitSound("Hero_Centaur.HoofStomp")
    local value = owner:GetAbsOrigin()
    value.x = ability:GetSpecialValueFor("radius")
    value.y = 0
    value.z = ability:GetSpecialValueFor("radius")
    local particleName = "particles/econ/items/centaur/centaur_ti6_gold/centaur_ti6_warstomp_gold.vpcf"
    local particle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, owner )
    ParticleManager:SetParticleControl(particle, 1, value)

	local radius = ability:GetSpecialValueFor("radius")
    local stomp_stun_debuff = ability:GetSpecialValueFor("stomp_stun")
    local stomp_stun
    local target_location = owner:GetAbsOrigin()
	local target_teams = ability:GetAbilityTargetTeam() 
	local target_types = ability:GetAbilityTargetType() 
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, radius, target_teams, target_types, target_flags, 0, false)

    for i,unit in ipairs(units) do
        stomp_stun = stomp_stun_debuff * (1 - unit:GetStatusResistance())--两种添加修饰器的函数对状态抗性的反应不同

        damage_table = {}
        damage_table.victim = unit
        damage_table.attacker = caster
        damage_table.damage_type = DAMAGE_TYPE_ABILITY_DEFINED
        damage_table.ability = ability

        if isSecondary == 0 then
            ability:ApplyDataDrivenModifier(caster, unit, "modifier_hoof_stomp", { duration = stomp_stun_debuff }) --两种添加修饰器的函数对状态抗性的反应不同
            local current_health_damage = 0.01 * ability:GetSpecialValueFor("stomp_damage") * unit:GetHealth()
            damage_table.damage = current_health_damage
        else
            damage_table.damage = ability:GetSpecialValueFor("mofa_damage")
        end
        unit:AddNewModifier(caster, ability, "modifier_stunned", { duration = stomp_stun })  --两种添加修饰器的函数对状态抗性的反应不同      
        ApplyDamage(damage_table)
    end

end
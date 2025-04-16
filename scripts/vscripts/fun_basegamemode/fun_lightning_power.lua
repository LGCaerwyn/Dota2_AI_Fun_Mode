
function Lightning_Power(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = keys.caster
    local chance = ability:GetSpecialValueFor("chance")

    if not ability:IsCooldownReady() then return end

    local r = RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_ITEM_MKB, caster)

    if r then
        Lightning_Power_Damage(keys)
    end
end

-----------------------------------------------------------------------------------------------

function Lightning_Power_Damage(keys)
    if not IsServer() then return true end
    local ability = keys.ability
	local caster = keys.caster
	local attacker = keys.attacker
	local target
    
    if not caster:IsAlive() then return end


	if caster == attacker then
        target = keys.target
	else
	    target = attacker
	end

    caster:EmitSound("Ability.LagunaBlade")
    local particleName = "particles/econ/items/lina/lina_ti6/lina_ti6_laguna_blade_2.vpcf" --lina不朽特效的副本，少了难以控制的地面特效
    particle = ParticleManager:CreateParticle(particleName, PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true)
    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)

    local team = caster:GetTeam()
    local location = target:GetAbsOrigin()
    local cacheUnit = nil
    local radius = ability:GetSpecialValueFor("radius")
    local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
    local typeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    local flagFilter = DOTA_UNIT_TARGET_FLAG_NONE
    local order = FIND_ANY_ORDER

    units = FindUnitsInRadius(team, location, cacheUnit, radius, teamFilter, typeFilter, flagFilter, order, false)
    
    for i,unit in ipairs(units) do
        
        local damage_table = {}
        damage_table.victim = unit
        damage_table.attacker = caster
        local AOE_Damage
        if unit:IsHero() then
            AOE_Damage = ability:GetSpecialValueFor("damage_hero")
        else 
            AOE_Damage = ability:GetSpecialValueFor("damage_creep")
        end
		damage_table.damage = AOE_Damage
        damage_table.damage_type = DAMAGE_TYPE_ABILITY_DEFINED
		damage_table.damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
        damage_table.ability = ability
        ApplyDamage(damage_table)
    end

    target:EmitSound("Ability.LagunaBladeImpact")
    local cooldown = ability:GetCooldown(ability:GetLevel())
    ability:EndCooldown()
    ability:StartCooldown(cooldown)

end

function Toggle( keys )
	-- body
	local caster = keys.caster
	local ability = keys.ability
	if not IsServer() then return end

	local damage_per_second = ability:GetSpecialValueFor("damage_per_second") / 10
    local radius = ability:GetSpecialValueFor("radius")
    local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

    for _,unit in pairs(targets) do
        local immolation_modifier = unit:FindModifierByName("modifier_demon_hunter_immolation_debuff") --Make sure only one instance is applied
        if immolation_modifier and immolation_modifier:GetAbility() == ability then
            ApplyDamage({ victim = unit, attacker = caster, damage = damage_per_second, damage_type = DAMAGE_TYPE_MAGICAL })
        end
    end
    local manacost_per_second = ability:GetSpecialValueFor("mana_cost_per_second")

  
    if caster:GetMana() >= manacost_per_second then
        caster:SpendMana(manacost_per_second, ability)
    else
        if ability:GetToggleState() then
            ability:ToggleAbility()
        end
    end

end

function modifier_immolation_aura_OnCreated(keys)
	local caster = keys.caster
	local modifier = caster:FindModifierByName("modifier_demon_hunter_immolation")
	--local x = 1
    if IsServer() then
        local particle = ParticleManager:CreateParticle("particles/custom/nightelf/demon_hunter/flameguard.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
        modifier:AddParticle(particle, false, false, 1, false, false)
 
    end
end

function modifier_immolation_aura_debuff_OnCreated(keys)
	local caster = keys.caster
    local target = keys.target
   -- local unit = keys.unit
    local modifier = target:FindModifierByName("modifier_demon_hunter_immolation_debuff")
    local particle = ParticleManager:CreateParticle("particles/custom/nightelf/demon_hunter/immolation_damage.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    modifier:AddParticle(particle, false, false, 1, false, false)
end
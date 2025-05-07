
function Sunder( event )
    if not IsServer() then return true end
	local ability = event.ability
	local caster = event.caster
	local targetPoint = event.target_points[1]
	local modifier_name  = event.Modifier_name
	local hit_point_minimum_pct = ability:GetLevelSpecialValueFor( "hit_point_minimum_pct", ability:GetLevel() - 1 ) * 0.01
		


units = FindUnitsInRadius(caster:GetTeamNumber(), targetPoint, caster, 450, 
			DOTA_UNIT_TARGET_TEAM_BOTH   , 
			  DOTA_UNIT_TARGET_HERO    , 
			 DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS , FIND_CLOSEST , false)


for k,target in pairs(units) do
	--print(k,target)

		
	if target ~= caster then

		ability:ApplyDataDrivenModifier(caster, caster, modifier_name, {duration = 40})

		cengshu = caster:GetModifierStackCount(modifier_name, caster)

		xiu_cengshu = cengshu + (target:GetHealth() * 0.02 )

		caster:SetModifierStackCount(modifier_name, caster, xiu_cengshu)

		target:SetHealth(target:GetHealth() * 0.5)

	end

	local particleName = "particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_sunder_ti8.vpcf"	
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, target )


	ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(particle, 2, target:GetAbsOrigin())

	local particleName = "particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_sunder_ti8.vpcf"	
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )

	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin())	




		end
end
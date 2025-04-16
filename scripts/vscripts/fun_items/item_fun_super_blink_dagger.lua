
--[[Author: Amused/D3luxe
	Used by: Pizzalol
	Date: 11.07.2015.
	Blinks the target to the target point, if the point is beyond max blink range then blink the maximum range]]
function Blink(keys)
    if not IsServer() then return true end
	local point = keys.target_points[1]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local ability = keys.ability
	local range = ability:GetLevelSpecialValueFor("blink_range", (ability:GetLevel() - 1))

	caster:InterruptMotionControllers(true)

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	local particle_blink_start = ParticleManager:CreateParticle("particles/econ/events/ti10/blink_dagger_start_ti10_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_blink_start, 0, casterPos)
	EmitSoundOnLocationWithCaster(casterPos, "Hero_Antimage.Blink_out", caster) 

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)

	local particle_blink_end = ParticleManager:CreateParticle("particles/econ/events/ti10/blink_dagger_end_ti10_lvl2.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle_blink_end, 0, point)
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Antimage.Blink_in", caster)  

	local duration_active = ability:GetSpecialValueFor("duration")     
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_fun_super_blink_dagger_active", { duration = duration_active })

	

end


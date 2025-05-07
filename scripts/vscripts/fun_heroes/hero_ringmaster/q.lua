
function Hard_Shield_Magic_Defense(keys )
	if not IsServer() then return true end
			print(102)

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local caster_location = caster:GetAbsOrigin()
	local caster_teamnumber = caster:GetTeamNumber()

	local particleName = "particles/units/heroes/hero_alchemist/alchemist_berserk_potion_projectile.vpcf"
	--local particleName = "particles/econ/items/vengeful/vs_ti8_immortal_shoulder/vs_ti8_immortal_magic_missle.vpcf"

	local projectileTable =
	{
		EffectName = particleName,
		Source = caster,
		bProvidesVision = true,
		iVisionRadius = 300,
		iVisionTeamNumber = caster_teamnumber,
		--ExtraData = nil,
		Ability = ability,
		vSourceLoc = caster_location,
		Target = target,
		iMoveSpeed = 850,
		--flExpireTime = ,
		bDodgeable = true,
		bIsAttack = false,
		bReplaceExisting = false,
		bIgnoreObstructions = true,
		--bSuppressTargetCheck = true,
		iSourceAttachment = attach_attack2 ,--attach_finger_index_left_fx,
		bDrawsOnMinimap = false,
		bVisibleToEnemies = true,

	}
	
	ProjectileManager:CreateTrackingProjectile(projectileTable)

end

function HSMD( keys )
	-- body
		print(112)

end

function HSMD_OnProjectileHitUnit(keys)
	print(12)
	if not IsServer() then return true end

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local caster_location = caster:GetAbsOrigin()
	local caster_teamnumber = caster:GetTeamNumber()
	local radius = 450
	local target_location = target:GetAbsOrigin()
	local attacker_teams = attacker:GetTeamNumber()
	local target_teams = target:GetTeamNumber()
	local target_types = DOTA_UNIT_TARGET_HERO
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE 
						+ DOTA_UNIT_TARGET_FLAG_NOT_NIGHTMARED +DOTA_UNIT_TARGET_FLAG_RESPECT_OBSTRUCTIONS 
						+ DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NO_INVIS   --+ DOTA_UNIT_TARGET_FLAG_DEAD
--	local particleName = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_javelin_tgt.vpcf"
--    ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
	local units = FindUnitsInRadius(attacker_teams, target_location, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH , target_types, target_flags, 0, false)

	if  not target:IsRangedAttacker() then
				--print("近战英雄")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_w", {duration = time})
		else
				--print("远程英雄")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_w_2", {duration = time})
	end


end

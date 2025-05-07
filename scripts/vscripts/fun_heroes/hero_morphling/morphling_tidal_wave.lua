require('timers')
require('utils')

function morphling_tidal_wave( keys )
    if not IsServer() then return true end
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local targetPoint = keys.event_ability:GetCursorPosition()

    local vector =  targetPoint - caster:GetAbsOrigin() 
    local vector_direction  = vector:Normalized()
	local vector_direction_start  = Vector( vector_direction.x, vector_direction.y, 0 ) 
	local ability_event = keys.event_ability:GetAbilityName()
	local Distance = vector:Length2D()
	local SpawnOrigin = caster:GetAbsOrigin()
	local backwardVec = (SpawnOrigin - targetPoint):Normalized()
	local spawnPoint = SpawnOrigin + ( 200 * backwardVec )

    if ability_event ~= "morphling_waveform" or caster:PassivesDisabled() then
    	return
	end
    --print(SpawnOrigin)	
    --print(targetPoint)
    local LinearProjectile_table ={
		                           Ability = ability,
		                           EffectName = "particles/units/heroes/hero_kunkka/kunkka_shard_tidal_wave.vpcf",
		                           vSpawnOrigin = spawnPoint ,
		                           vVelocity = vector_direction_start * 1250,
		                           --vAcceleration?: Vector
		                           --fMaxSpeed?: float
		                           fDistance = Distance,
		                           fStartRadius =  400,
		                           fEndRadius = 400,
		                           --fExpireTime = 10,
		                           iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY ,
		                           iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE ,
		                           iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC ,
		                           --bIgnoreSource?: bool
		                           Source = caster,
		                           bHasFrontalCone = true,
		                           bDrawsOnMinimap = false,
		                           bVisibleToEnemies = true,
		                           }
    ProjectileManager:CreateLinearProjectile(LinearProjectile_table)

end

function morphling_tidal_wave_damgage( keys)
    if not IsServer() then return true end
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
 	local damage = ability:GetSpecialValueFor("bouns_damage") 

	caster:PerformAttack(target, true, true, true, true, true, false, false)
	if not target:IsMagicImmune() and  not target:IsInvulnerable() then

	    ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL  })
        
		if caster:HasScepter() then
        
		    Once_more_nTarget(caster, "morphling_adaptive_strike_agi", target)

			Timers:CreateTimer(0.1,function()
			    Once_more_nTarget(caster, "morphling_adaptive_strike_agi", target)
				return nil
			end)

			--[[
			  	 	caster:PerformAttack(target, true, true, true, true, true, false, false)			  	 	
			  	 	caster:PerformAttack(target, true, true, true, true, true, false, false)
					   
					if math.floor(GameRules:GetDOTATime(false, true) / 60) >= 40 then
					    Timers:CreateTimer(0.1,function()
							Once_more_nTarget( caster, "morphling_adaptive_strike_agi" , target )
							return nil
						end)
					end
                    
					if math.floor(GameRules:GetDOTATime(false, true) / 60) >= 50 then
						Timers:CreateTimer(0.15,function()
							Once_more_nTarget( caster, "morphling_adaptive_strike_agi" , target )
							return nil
						end)
					end
			]]
		end
	end

end
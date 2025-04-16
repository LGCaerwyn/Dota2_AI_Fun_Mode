--GetSpellAmplification(baseOnly: bool): float
require('timers')

function blademaster_windwalk( keys )



local  caster =keys.caster
local	 target = keys.target
local	 ability = keys.ability







caster:Stop()
--print("开始攻击")

--print(caster:GetSpellAmplification(false))

--print(caster:GetAttacksPerSecond(false))

caster_attacksper = caster:GetAttacksPerSecond(false)

y = -0.15*caster_attacksper + 1

--print(y)
ability:ApplyDataDrivenModifier(caster, caster, "modifier_blademaster_windwalk_startgesture", {duration = 0.9 * y })

--caster:StartGesture(ACT_DOTA_ATTACK_TAUNT)



caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_TAUNT,1/y)
	-- body


			Timers:CreateTimer(0.9 * y,function()
						--异步攻击，否则一起木大木大会BOOM
						
				if 		target:IsAlive() then
					
				caster:PerformAttack(target, true, true, false, true, true, false, false)

				

					else
				end
					--target damage
					return nil
					end
				)




end


function order( every )
	-- body
	local caster = every.caster
	local target = every.target
	local	 ability = every.ability

	local SpellAmp = caster:GetSpellAmplification(false)
	local talent =  caster:FindAbilityByName("special_bonus_unique_blademaster_windwalk_damage")

    local talent_bonus = 0
    
    if talent ~= nil then 
        talent_bonus = talent:GetSpecialValueFor("value")
    end

	local damage = ability:GetSpecialValueFor("damage") --+ talent_bonus






 ApplyDamage({victim = target, attacker = caster, damage = damage, ability = ability, damage_type = DAMAGE_TYPE_MAGICAL ,damage_flags =  DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION })

 SendOverheadEventMessage(nil, OVERHEAD_ALERT_DEADLY_BLOW, target, damage * (1+SpellAmp), nil) 

		if caster:HasModifier("modifier_blademaster_windwalk_startgesture") then


			 caster:RemoveModifierByName("modifier_blademaster_windwalk_startgesture")

		end
end
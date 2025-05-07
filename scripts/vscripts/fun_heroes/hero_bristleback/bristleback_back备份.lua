
require('timers')

function bristleback_back( keys )
	-- body
	if not IsServer() then return end
	local caster = keys.caster
	local target = keys.caster
	local ability = keys.ability

	local chance = ability:GetSpecialValueFor("trigger_chance")
	local tether = caster:FindAbilityByName("bristleback_quill_spray")
--	local damage = ability:GetAbilityDamage()
--	local damage_type = ability:GetAbilityDamageType()
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1) * caster:GetCooldownReduction() 
	if caster:PassivesDisabled() then return end      --ÐÂÔöÆÆ±»¶¯Ð§¹û
	
	local playerID = caster:GetPlayerID()
	
    if PlayerResource:IsFakeClient(playerID)  then

      chance = 100
  --    cooldown = cooldown * 0.5
      
    end


	if ability:IsCooldownReady() then
	-- If the caster has the helix modifier then do not trigger the counter helix
	-- as its considered to be on cooldown


	
	local r = RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_PHANTOMASSASSIN_CRIT, caster)

     	if not r  then 
      	   return
     	end


     		tether:OnSpellStart()
			ability:StartCooldown(cooldown)
	end

end


function bristleback_back_test( keys )
	-- body

	if not IsServer() then return end
	local caster = keys.caster
--	local target = keys.target
	local ability = keys.ability
	local attacker = keys.attacker
	local ability_ak = attacker:FindAbilityByName("bristleback_back")
	if caster:PassivesDisabled() then return end      --ÐÂÔöÆÆ±»¶¯Ð§¹û
	
	local playerID = caster:GetPlayerID()
	
--	if not	PlayerResource:IsFakeClient(playerID)  then
--	return
--	end

--	local chance = ability:GetSpecialValueFor("trigger_chance")
	local tether = caster:FindAbilityByName("bristleback_quill_spray")
	
	local victim_angle = keys.unit:GetAnglesAsVector().y
	local origin_difference = keys.unit:GetAbsOrigin() - keys.attacker:GetAbsOrigin()
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	origin_difference_radian = origin_difference_radian * 180
	local attacker_angle = origin_difference_radian / math.pi
	attacker_angle = attacker_angle + 180.0
	local result_angle = attacker_angle - victim_angle
	result_angle = math.abs(result_angle)
	
	if result_angle >= (180 - (ability:GetSpecialValueFor("side_angle") / 2)) and result_angle <= (180 + (ability:GetSpecialValueFor("side_angle") / 2)) then 
		
		if result_angle >= (180 - (ability:GetSpecialValueFor("back_angle") / 2)) and result_angle <= (180 + (ability:GetSpecialValueFor("back_angle") / 2)) then 



			
					


												if 	PlayerResource:IsFakeClient(playerID)  then
														if  keys.Damage  >= 50 then
															--print("触发")
															tether:OnSpellStart()	
														end

													if attacker:GetUnitName() == "npc_dota_hero_bristleback" and  ability_ak:GetLevel() >= 1 then

														 Timers:CreateTimer(0.1,    
           															 function()
	           															 	if caster:IsAlive() and attacker:IsAlive() then
	           															 		tether:OnSpellStart()		
		           														 	       return 0.1
		           														 	   			 else
		           														 	   		return nil
																              end

												          end) 

													end	

												end	

												if not PlayerResource:IsFakeClient(playerID) then

													if  keys.Damage  >= 350 then
															--print("触发")
															tether:OnSpellStart()	
													end	

														if attacker:GetUnitName() == "npc_dota_hero_bristleback" and  ability_ak:GetLevel() >= 1 then

														 Timers:CreateTimer(0.1,    
           															 function()
	           															 	if caster:IsAlive() and attacker:IsAlive() then
	           															 		tether:OnSpellStart()	
		           														 	       return 0.1
		           														 	   			 else
		           														 	   		return nil
																              end

												          end) 

													end	
												end
						

						
				
			else

				if keys.Damage  >= 400 then
				--	print("触发")
					tether:OnSpellStart()
				end
		end
	end

	
	
end


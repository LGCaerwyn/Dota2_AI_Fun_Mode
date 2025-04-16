

require('timers')


function ray_storm( keys )
	-- body


	local caster = keys.caster
	local ability = keys.ability



--[[
		units_target  = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, 900, 
			 DOTA_UNIT_TARGET_TEAM_ENEMY  , 
			 DOTA_UNIT_TARGET_HERO  , 
			 DOTA_UNIT_TARGET_FLAG_NO_INVIS , FIND_CLOSEST  , false)

		units_target_hsm  = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, 1500, 
			 DOTA_UNIT_TARGET_TEAM_ENEMY  , 
			 DOTA_UNIT_TARGET_HERO  , 
			 DOTA_UNIT_TARGET_FLAG_NO_INVIS , FIND_CLOSEST  , false)
--]]
					Timers:CreateTimer(function()
						  
							if not caster:HasModifier("modifier_tinker_death_spin") then
							 return nil
							end
							units_target  = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, 900, 
							 DOTA_UNIT_TARGET_TEAM_ENEMY  , 
							 DOTA_UNIT_TARGET_HERO  , 
							 DOTA_UNIT_TARGET_FLAG_NO_INVIS , FIND_CLOSEST  , false)
					 local tether = caster:FindAbilityByName("tinker_laser") 

					for k,v in pairs(units_target) do  

					    if caster ~= v  and  not v:IsMagicImmune() then
					      --   caster:SetCursorPosition(bamian_changdu_spawn)
					    --caster:SetCursorCastTarget
					   	  caster:SetCursorCastTarget(v)
					      tether:OnSpellStart()
						end
					end

							return 2	
						end
					)
			


--	print(k,v)

			Timers:CreateTimer(function()
						  
				if not caster:HasModifier("modifier_tinker_death_spin") then
				return nil
				end
							units_target_hsm  = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, 1500, 
							 DOTA_UNIT_TARGET_TEAM_ENEMY  , 
							 DOTA_UNIT_TARGET_HERO  , 
							 DOTA_UNIT_TARGET_FLAG_NO_INVIS , FIND_CLOSEST  , false)	

						if #units_target_hsm ~= 0 then

				  			    	local tetherv = caster:FindAbilityByName("tinker_heat_seeking_missile")   
					   	 	
							    	tetherv:OnSpellStart()
						end

							return 0.5	
						end
					)



end

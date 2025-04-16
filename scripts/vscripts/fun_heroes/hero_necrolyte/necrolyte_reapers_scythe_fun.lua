
require('timers')

function ReapersScythe( keys )
	local caster = keys.caster
	local casterPoint = caster:GetAbsOrigin()
	local target = keys.target
	local targetPoint = target:GetOrigin()
	local ability = keys.ability
	local target_missing_hp = target:GetMaxHealth() - target:GetHealth()
	local damage_per_health = ability:GetLevelSpecialValueFor("damage_per_health", (ability:GetLevel() - 1))
--	local respawn_time = ability:GetLevelSpecialValueFor("respawn_constant", (ability:GetLevel() - 1))


 local damage_type = ability:GetAbilityDamageType()

 if PlayerResource:GetSteamAccountID(caster:GetMainControllingPlayer()) == 396784731 then

	damage_type = DAMAGE_TYPE_PURE 

 end



if caster:HasScepter() then


		local targetPoint = target:GetOrigin()
			ability:ApplyDataDrivenModifier(caster, target, "modifier_necrolyte_reapers_scythe", {duration = 3.7}) --duration = 3.6
		local b = 0
		local table_unit = {}
			table_name = {45,90,135,180,225,270,315,360}
			for k,v in pairs(table_name) do
			point = RotatePosition(targetPoint, QAngle(0,v,0), casterPoint)
			unit = CreateUnitByName("dummy_unit_vulnerable", point, false, caster, caster, caster:GetTeam())
			local casterAngles = caster:GetAngles()
			unit:SetAngles( casterAngles.x, casterAngles.y + v , casterAngles.z )
			table.insert(table_unit, unit)


			end
					
		local y = 1	
		local Z = 1	
		Timers:CreateTimer(function()


  			 local particle_4 = ParticleManager:CreateParticle("particles/econ/items/necrolyte/necro_sullen_harvest/necro_ti7_immortal_scythe_start.vpcf" ,PATTACH_POINT  , table_unit[y])
			        -- Raise 1000 value if you increase the camera height above 1000
			        --ParticleManager:SetParticleControl(particle_1, 0, Vector(casterPoint.x,casterPoint.y,casterPoint.z))

			    ParticleManager:SetParticleControl(particle_4, 1, Vector(targetPoint.x,targetPoint.y,targetPoint.z))
				--EmitSoundOn("Hero_Necrolyte.ReapersScythe.Cast", caster)
				EmitSoundOn("Hero_Necrolyte.ReapersScythe.Target", target)
				y = y + 1
												if b < 7 then
													b = b+1
													
													
						  		return 0.3
								else

								for k,v in pairs(table_unit) do
									print(k,v)

								table_unit[v]:RemoveSelf()
								end
								return nil
							end
			            
			                    
			      		  end
               			 )


				Timers:CreateTimer( 1.5,function()

			
				local target_missing_hp = target:GetMaxHealth() - target:GetHealth()
				local damage_per_health = ability:GetLevelSpecialValueFor("damage_per_health", (ability:GetLevel() - 1))
				local damage_table = {}
				damage_table.attacker = caster
				damage_table.victim = target
				damage_table.ability = ability
				damage_table.damage_type = DAMAGE_TYPE_MAGICAL
				damage_table.damage = target:GetHealth() * 0.05
				
						if Z < 7 then
													Z = Z+1
													
					ApplyDamage(damage_table)								
						  		return 0.3
						else
			--	

									return nil
						end
							end
               			 )
							Timers:CreateTimer( 2 ,function()

											for k,v in pairs(table_unit) do
												print(k,v)

												table_unit[k]:RemoveSelf()


												end
										end
			               			 )



		else     
					local targetPoint = target:GetOrigin()
					local table_unit = {}
						--local x = 0

						table_name = {45,90,135,180,225,270,315,360}

						ability:ApplyDataDrivenModifier(caster, target, "modifier_necrolyte_reapers_scythe", {duration = 1.5})

						for k,v in pairs(table_name) do

						point = RotatePosition(targetPoint, QAngle(0,v,0), casterPoint)
						unit = CreateUnitByName("dummy_unit_vulnerable", point, false, caster, caster, caster:GetTeam())
					--	print(unit:GetUnitName())
					--	print(unit:GetOrigin())
					--	print(unit:GetAngles())
						local casterAngles = caster:GetAngles()
						unit:SetAngles( casterAngles.x, casterAngles.y + v , casterAngles.z )
					--	print(unit:GetAngles())
					--	print(k,v)
						EmitSoundOn("Hero_Necrolyte.ReapersScythe.Cast", caster)
						EmitSoundOn("Hero_Necrolyte.ReapersScythe.Target", target)
						
						table.insert(table_unit, unit)
						   local particle_4 = ParticleManager:CreateParticle("particles/econ/items/necrolyte/necro_sullen_harvest/necro_ti7_immortal_scythe_start.vpcf" ,PATTACH_POINT  , unit)
						        -- Raise 1000 value if you increase the camera height above 1000
						        --ParticleManager:SetParticleControl(particle_1, 0, Vector(casterPoint.x,casterPoint.y,casterPoint.z))

						        ParticleManager:SetParticleControl(particle_4, 1, Vector(targetPoint.x,targetPoint.y,targetPoint.z))


						       --ParticleManager:SetParticleControlEnt(particle_4, 1, target,PATTACH_POINT , "", targetPoint ,false)
						end
								Timers:CreateTimer( 1.4,function()

								local target_missing_hp = target:GetMaxHealth() - target:GetHealth()
								local damage_per_health = ability:GetLevelSpecialValueFor("damage_per_health", (ability:GetLevel() - 1))
								local damage_table = {}
								damage_table.attacker = caster
								damage_table.victim = target
								damage_table.ability = ability
								damage_table.damage_type = DAMAGE_TYPE_MAGICAL
								damage_table.damage = target_missing_hp * damage_per_health
								ApplyDamage(damage_table)

													return nil
											end
										 )

								Timers:CreateTimer( 2 ,function()

											for k,v in pairs(table_unit) do
												print(k,v)

												table_unit[k]:RemoveSelf()


												end
										end
			               			 )




	end






----------------------------------------------------------------







--[[

ability:ApplyDataDrivenModifier(caster, target, "modifier_necrolyte_reapers_scythe", {duration = 1.6 })
EmitSoundOn("Hero_Necrolyte.ReapersScythe.Cast", caster)
EmitSoundOn("Hero_Necrolyte.ReapersScythe.Target", caster)

local casterPoint = caster:GetAbsOrigin()
local targetPoint = target:GetOrigin()
local table_unit = {}

table_name = {45,90,135,180,225,270,315,360}



			for k,v in pairs(table_name) do
			point = RotatePosition(targetPoint, QAngle(0,v,0), casterPoint)
			unit = CreateUnitByName("dummy_unit_vulnerable", point, false, caster, caster, caster:GetTeam())
			local casterAngles = caster:GetAngles()
			unit:SetAngles( casterAngles.x, casterAngles.y + v , casterAngles.z )

			table.insert(table_unit, unit)
			   local particle_4 = ParticleManager:CreateParticle("particles/econ/items/necrolyte/necro_sullen_harvest/necro_ti7_immortal_scythe_start.vpcf" ,PATTACH_POINT  , unit)


			        ParticleManager:SetParticleControl(particle_4, 1, Vector(targetPoint.x,targetPoint.y,targetPoint.z))


			    
			end
			--]]
--[[

							Timers:CreateTimer( 2 ,function()

								for k,v in pairs(table_unit) do
									print(k,v)

									table_unit[k]:RemoveSelf()


									end
									return nil
							end
               			 )
--]]
--[[

if PlayerResource:GetSteamAccountID(caster:GetMainControllingPlayer()) == 396784731 then 
	
				Timers:CreateTimer( 1.5 ,function()

				local target_missing_hp = target:GetMaxHealth() - target:GetHealth()
				local damage_per_health = ability:GetLevelSpecialValueFor("damage_per_health", (ability:GetLevel() - 1))
				local damage_table = {}
				damage_table.attacker = caster
				damage_table.victim = target
				damage_table.ability = ability
				damage_table.damage_type = damage_type
				damage_table.damage = target_missing_hp * damage_per_health
				ApplyDamage(damage_table)

									return nil
							end
               			 )
				end
--]]
end




-------------------------




function Particle_Manager( keys )
	-- body


	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target


local casterPoint = caster:GetAbsOrigin()


    local ability_caster = keys.event_ability:GetAbilityName()


    if ability_caster ~= "necrolyte_reapers_scythe"  then
    	return
	end

		if caster:HasScepter() then

  
					local targetPoint = target:GetOrigin()
					local table_unit = {}
						--local x = 0

						table_name = {45,90,135,180,225,270,315,360}



						for k,v in pairs(table_name) do

						point = RotatePosition(targetPoint, QAngle(0,v,0), casterPoint)
						unit = CreateUnitByName("dummy_unit_vulnerable", point, false, caster, caster, caster:GetTeam())
					--	print(unit:GetUnitName())
					--	print(unit:GetOrigin())
					--	print(unit:GetAngles())
						local casterAngles = caster:GetAngles()
						unit:SetAngles( casterAngles.x, casterAngles.y + v , casterAngles.z )
					--	print(unit:GetAngles())
					--	print(k,v)
						table.insert(table_unit, unit)
						   local particle_4 = ParticleManager:CreateParticle("particles/econ/items/necrolyte/necro_sullen_harvest/necro_ti7_immortal_scythe_start.vpcf" ,PATTACH_POINT  , unit)
						        -- Raise 1000 value if you increase the camera height above 1000
						        --ParticleManager:SetParticleControl(particle_1, 0, Vector(casterPoint.x,casterPoint.y,casterPoint.z))

						        ParticleManager:SetParticleControl(particle_4, 1, Vector(targetPoint.x,targetPoint.y,targetPoint.z))


						       --ParticleManager:SetParticleControlEnt(particle_4, 1, target,PATTACH_POINT , "", targetPoint ,false)
						end


								Timers:CreateTimer( 2 ,function()

											for k,v in pairs(table_unit) do
												print(k,v)

												table_unit[k]:RemoveSelf()


												end
										end
			               			 )




	end






--ai测试技能
	--[[	if  caster:GetTeamNumber() == 3 then

				local ai_ability = caster:FindAbilityByName("necrolyte_reapers_scythe_fun")

		 			caster:SetCursorCastTarget(target)
		            ai_ability:OnSpellStart()  
		            --cooldown = ability_caster:GetCooldown(3) * caster:GetCooldownReduction() * 0.5
		          --  ability_caster:StartCooldown(cooldown)
		end
	--]]

end








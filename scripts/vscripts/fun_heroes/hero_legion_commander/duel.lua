require('timers')


--all-duel

function legion_commander_duel_self( keys )
	-- body
		for k,v in pairs(keys) do
		print(k,v)
	end
	target = keys.target
	units_target = {}
end


function legion_commander_duel_datadriven_on_spell_start(keys)

	local caster = keys.caster
	local caster_origin = caster:GetAbsOrigin()
	local ability = keys.ability

	
	--	  target = ability:GetCursorTarget()--keys.target_entities--
	local target_origin = target:GetAbsOrigin()

	local modifier_duel = "modifier_duel_datadriven"
		  modifier_duel_f = "modifier_legion_commander_all_duel"
		  duration = ability:GetSpecialValueFor("duration")
	--执行特效音效
	caster:EmitSound("Hero_LegionCommander.Duel.Cast")
	caster:EmitSound("Hero_LegionCommander.Duel")
	
	caster.legion_commander_duel_datadriven_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_duel_ring.vpcf", PATTACH_ABSORIGIN, caster)
	local center_point = target_origin + ((caster_origin - target_origin) / 2)
	ParticleManager:SetParticleControl(caster.legion_commander_duel_datadriven_particle, 0, center_point)  --The center position.
	ParticleManager:SetParticleControl(caster.legion_commander_duel_datadriven_particle, 7, center_point)  --The flag's position (also centered).


	--执行强制攻击
	local order_target = 
	{
		UnitIndex = target:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = caster:entindex()
	}

	local order_caster =
	{
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()
	}
	--打断目标，防止出现bug
	target:Stop()




	--往死里打
	ExecuteOrderFromTable(order_target)
	ExecuteOrderFromTable(order_caster)

	caster:SetForceAttackTarget(target)
	target:SetForceAttackTarget(caster)

	units_fr  = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, 1200, 
			 DOTA_UNIT_TARGET_TEAM_FRIENDLY  , 
			 DOTA_UNIT_TARGET_HERO  , 
			 DOTA_UNIT_TARGET_FLAG_NONE , FIND_CLOSEST  , false)



			for k,v in pairs(units_fr) do

			if v ~= caster  then

				ability:ApplyDataDrivenModifier(caster, v, "modifier_legion_commander_all_duel_fri", {Duration = 1.5})

				--print(k,v)

				end
			end


	--[[
	--大家一起来
	units_target  = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, 800, 
			 DOTA_UNIT_TARGET_TEAM_FRIENDLY  , 
			 DOTA_UNIT_TARGET_HERO  , 
			 DOTA_UNIT_TARGET_FLAG_NONE , FIND_CLOSEST  , false)



			for k,v in pairs(units_target) do

			if v ~= caster  then

					local order_caster =
				{
					UnitIndex = v:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = target:entindex()
				}


				ExecuteOrderFromTable(order_caster)
				v:SetForceAttackTarget(target)
				ability:ApplyDataDrivenModifier(caster, v, modifier_duel_f, {Duration = keys.Duration})

				print(k,v)

				end
			end
		--]]





	ability:ApplyDataDrivenModifier(caster, caster, modifier_duel, {Duration = duration})
	ability:ApplyDataDrivenModifier(caster, target, modifier_duel, {Duration = duration})







end

--add V_damage


function modifier_duel_datadriven_on_death(keys)
	local caster = keys.caster
	local caster_team = caster:GetTeam()
	local unit = keys.unit
	local ability = keys.ability
	local modifier_duel = "modifier_duel_datadriven"
	local modifier_duel_damage = "modifier_duel_damage_datadriven"
	local modifier_duel_f = "modifier_legion_commander_all_duel"




	if unit == caster then  --If Legion Commander was killed.
		local herolist = HeroList:GetAllHeroes()
		for i, individual_hero in ipairs(herolist) do  --Iterate through the enemy heroes, award any with a Duel modifier the reward damage, and then remove that modifier.
			if individual_hero:GetTeam() ~= caster_team and individual_hero:HasModifier(modifier_duel) then
				if individual_hero:HasModifier(modifier_duel) then
					if not individual_hero:HasModifier(modifier_duel_damage) then
						ability:ApplyDataDrivenModifier(caster, individual_hero, modifier_duel_damage, {})
					end
					local duel_stacks = individual_hero:GetModifierStackCount(modifier_duel_damage, ability) + keys.RewardDamage * 3
					individual_hero:SetModifierStackCount(modifier_duel_damage, ability, duel_stacks)
					individual_hero:RemoveModifierByName(modifier_duel)
				
					if next(units_target) ~= nil then

						for k,fRIENDLY in pairs(units_target) do
							print(k,fRIENDLY)

							if caster ~= fRIENDLY  then


							fRIENDLY:RemoveModifierByName(modifier_duel_f)
								


								end

				
						end
					end

					individual_hero:EmitSound("Hero_LegionCommander.Duel.Victory")


					local duel_victory_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_ABSORIGIN_FOLLOW, individual_hero)
				end
			end
		end
	else  --If Legion Commander's opponent was killed.
		if not caster:HasModifier(modifier_duel_damage) then
			ability:ApplyDataDrivenModifier(caster, caster, modifier_duel_damage, {})


		end


		local duel_stacks = caster:GetModifierStackCount(modifier_duel_damage, ability) + keys.RewardDamage
		caster:SetModifierStackCount(modifier_duel_damage, ability, duel_stacks)
		caster:RemoveModifierByName(modifier_duel)
		caster:RemoveModifierByName("modifier_legion_commander_all_duel_2")
		
			if next(units_target) ~= nil then


						for k,fRIENDLY in pairs(units_target) do
									print(k,fRIENDLY)

								if caster ~= fRIENDLY  then

									ability:ApplyDataDrivenModifier(caster, fRIENDLY, modifier_duel_damage, {})
									local duel_stacks = fRIENDLY:GetModifierStackCount(modifier_duel_damage, ability) + keys.RewardDamage
									fRIENDLY:SetModifierStackCount(modifier_duel_damage, ability, duel_stacks)
									fRIENDLY:RemoveModifierByName(modifier_duel_f)
								


								end

				
						end

			end







		caster:EmitSound("Hero_LegionCommander.Duel.Victory")

		local duel_victory_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	end
end


--destroy_duel


function modifier_duel_datadriven_on_destroy(keys)
	local caster = keys.caster
	local target = keys.target
	
	caster:StopSound("Hero_LegionCommander.Duel")	
	
	if caster.legion_commander_duel_datadriven_particle ~= nil then
		ParticleManager:DestroyParticle(caster.legion_commander_duel_datadriven_particle, false)
	end

	target:SetForceAttackTarget(nil)
	caster:SetForceAttackTarget(nil)

	if next(units_target) ~= nil then

		for k,rF in pairs(units_target) do

			rF:SetForceAttackTarget(nil)

		end
	end	

end


--大家加入了
function duel_Friendly_joining( every )
	-- 
	local caster = every.caster
	local unit = every.unit
	local ability = every.ability

	if every.target ~= nil and  every.target == caster then 
	table.insert(units_target,1,unit)	
	else
		return
	end
	local modifier = caster:FindModifierByName("modifier_legion_commander_all_duel_start_aure")
	local time = modifier:GetDuration() - modifier:GetElapsedTime()
	--caster:RemoveModifierByName(string pszScriptName)

	---[[
	Timers:CreateTimer(0.1,function()
	local order_caster =
				{
					UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = target:entindex()
				}


				ExecuteOrderFromTable(order_caster)
				unit:SetForceAttackTarget(target)
				ability:ApplyDataDrivenModifier(caster, unit, modifier_duel_f, {Duration = duration})
				unit:RemoveModifierByName("modifier_legion_commander_all_duel_fri")
							return nil
                        end        
                    )  

--]]


end

function legion_commander_duel_datadriven_on_spell_start_sound( keys )
	-- 

	local caster = keys.caster
	local ability = keys.ability
	EmitSoundOn("legion_commander_legcom_dem_attack_06", caster)


	caster:StartGestureWithPlaybackRate(ACT_DOTA_TAUNT,1)

--	caster:StartGestureWithFadeAndPlaybackRate(ACT_DOTA_VICTORY,0,1.3,1.93)
	Timers:CreateTimer(1.3,function()
	caster:ForcePlayActivityOnce(ACT_IDLE)	
	--print("恢复动作")
	EmitSoundOn("legion_commander_legcom_dem_attack_04", caster)
						return nil
                        end        
                    )  


end





function ai_onspell( keys )
	-- body


	local caster = keys.caster
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1) * caster:GetCooldownReduction()
	local target = keys.target
	local tether = caster:FindAbilityByName("legion_commander_all_duel")


	if  ability:IsCooldownReady() and target:IsRealHero()  and PlayerResource:IsFakeClient(caster:GetPlayerID()) and not caster:IsSilenced() then

			if target:GetHealthPercent() < 80 and caster:GetHealthPercent() > 60 then
				caster:SetCursorCastTarget(target)
		        tether:OnSpellStart()
				ability:StartCooldown(cooldown)
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_legion_commander_all_duel_2", {duration = 7})

			end
	end

end
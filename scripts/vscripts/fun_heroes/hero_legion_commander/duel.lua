
function legion_commander_duel_datadriven_on_spell_start(keys)

	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target

	if target:TriggerSpellAbsorb(ability) then return end --被林肯抵挡，被莲花反弹

	local caster_origin = caster:GetAbsOrigin()
	local target_origin = target:GetAbsOrigin()

	local modifier_duel = "modifier_duel_datadriven"
	local modifier_duel_f = "modifier_legion_commander_all_duel"
	
	--特效及声音需要调整
	caster:EmitSound("Hero_LegionCommander.Duel.Cast")
	caster:EmitSound("Hero_LegionCommander.Duel")
	caster.legion_commander_duel_datadriven_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_duel_ring.vpcf", PATTACH_ABSORIGIN, caster)
	local center_point = target_origin + ((caster_origin - target_origin) / 2)
	ParticleManager:SetParticleControl(caster.legion_commander_duel_datadriven_particle, 0, center_point)  --The center position.
	ParticleManager:SetParticleControl(caster.legion_commander_duel_datadriven_particle, 7, center_point)  --The flag's position (also centered).

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

	target:Stop()

	ExecuteOrderFromTable(order_target)
	ExecuteOrderFromTable(order_caster)

	caster:SetForceAttackTarget(target)
	target:SetForceAttackTarget(caster)

	units_target  = FindUnitsInRadius(caster:GetTeamNumber(), 
	                                  caster:GetAbsOrigin(), 
									  caster, 
									  800, 
			                          DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
			                          DOTA_UNIT_TARGET_HERO, 
			                          DOTA_UNIT_TARGET_FLAG_NONE, 
									  FIND_CLOSEST, 
									  false)

    for k,v in pairs(units_target) do
	    local playerId = caster:GetPlayerID()
		local otherPlayerId = v:GetPlayerID()
        if v ~= caster and PlayerResource:IsDisableHelpSetForPlayerID(otherPlayerId, playerId) == false then
		    local order_caster =
	        {
		        UnitIndex = v:entindex(),
		        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		        TargetIndex = target:entindex()
	        }
			ExecuteOrderFromTable(order_caster)
	        v:SetForceAttackTarget(target)
	        ability:ApplyDataDrivenModifier(caster, v, modifier_duel_f, { Duration = keys.Duration })
	    end
    end

	ability:ApplyDataDrivenModifier(caster, caster, modifier_duel, { Duration = keys.Duration })
	ability:ApplyDataDrivenModifier(caster, target, modifier_duel, { Duration = keys.Duration })
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
				
					for k,fRIENDLY in pairs(units_target) do
						if caster ~= fRIENDLY  then
						    fRIENDLY:RemoveModifierByName(modifier_duel_f)
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
		
		for k,fRIENDLY in pairs(units_target) do

		    if caster ~= fRIENDLY  then

			    ability:ApplyDataDrivenModifier(caster, fRIENDLY, modifier_duel_damage, {})
				local duel_stacks = fRIENDLY:GetModifierStackCount(modifier_duel_damage, ability) + keys.RewardDamage
				fRIENDLY:SetModifierStackCount(modifier_duel_damage, ability, duel_stacks)
				fRIENDLY:RemoveModifierByName(modifier_duel_f)
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

	for k,rF in pairs(units_target) do
		rF:SetForceAttackTarget(nil)
	end

end
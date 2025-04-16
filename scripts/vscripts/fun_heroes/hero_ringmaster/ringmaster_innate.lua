
function ringmaster_innate( keys )

	if IsServer() then

	    local caster = keys.caster
	    local ability = keys.ability
		local event_ability = keys.event_ability
		local IsItemApplies = ability:GetSpecialValueFor("item_applies")
--		print(1)
		if not caster:PassivesDisabled() and
		   not event_ability:IsToggle() and
		   (
			  (not event_ability:IsItem() and event_ability:ProcsMagicStick()) --非物品，且充能魔棒
		      or  
		      (event_ability:IsItem() and IsItemApplies == 1) --物品，且学习了天赋
		      or (not event_ability:IsItem() and event_ability:GetClassname() == "ability_datadriven")
		   )
		then
		    --技能键值
		    local damage_const = ability:GetSpecialValueFor("damage_const")
			local damage_pct = ability:GetSpecialValueFor("damage_pct")
			local damage_pct_deacy = ability:GetSpecialValueFor("damage_pct_deacy")
			local heal = ability:GetSpecialValueFor("heal")
			local radius = ability:GetSpecialValueFor("radius")

			--范围搜索参数
			local units = nil
			local caster_team = caster:GetTeamNumber()
			local caster_location = caster:GetAbsOrigin()
			local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
			local target_flags = nil

			--衰减debuff相关
			local debuff = caster:FindModifierByName("modifier_ringmaster_innate_fun_debuff_tooltip")
			local debuff_stack = 0
			if debuff then debuff_stack = debuff:GetStackCount() end
--			print(2)	
			--伤害
--			print(damage_const)
			if damage_const > 0 then
--			    print(3)
			    --不对迷雾中单位、隐身单位、睡眠单位造成伤害
				target_flags = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+ DOTA_UNIT_TARGET_FLAG_NOT_NIGHTMARED 

				--百分比伤害会受到debuff层数衰减，最低为0
				damage_pct_amount = math.max(0, damage_pct - damage_pct_deacy * debuff_stack)  

				local damage_table = {}
				damage_table.attacker = caster
				--damage_table.victim = unit
				--damage_table.damage = damage_const + damage_pct_amount * 0.01 * unit:GetMaxHealth()	
				damage_table.damage_type = DAMAGE_TYPE_ABILITY_DEFINED
				damage_table.ability = ability

				units = FindUnitsInRadius(caster_team, caster_location, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY , target_types, target_flags, 0, false)
				
			    for _,unit in pairs(units) do

			        local particleName = "particles/econ/items/dazzle/dazzle_ti9/dazzle_shadow_wave_ti9_impact_damage.vpcf"
			        local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW , unit)						    
				    damage_table.victim = unit
				    damage_table.damage = damage_const + damage_pct_amount * 0.01 * unit:GetMaxHealth()		        		        
			        ApplyDamage(damage_table)	
			    end

				--添加衰减debuff
				local debuff_duration = ability:GetSpecialValueFor("debuff_duration")
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_ringmaster_innate_fun_debuff", { duration = debuff_duration })
			end

			--治疗
			if heal > 0 then
			    
			    --对无敌的友军有效
				target_flags = DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE 

				units = FindUnitsInRadius(caster_team, caster_location, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY , target_types, target_flags, 0, false)

			    for _,unit in pairs(units) do
			        local particleName = "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath_heal.vpcf"
			        local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW , unit)
			        unit:HealWithParams(heal, ability, false, true, caster, false)
					if unit:IsRealHero() and not unit:HasModifier("modifier_monkey_king_fur_army_soldier") then
					    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, unit, heal, caster:GetPlayerOwner())
					end
			    end
			end		
		end
	end

	return true

end

function modifier_ringmaster_innate_fun_debuff_OnCreated(keys)

	if IsServer() then

	    local caster = keys.caster
		local ability = keys.ability
		local debuff = caster:FindModifierByName("modifier_ringmaster_innate_fun_debuff_tooltip")
		local debuff_duration = ability:GetSpecialValueFor("debuff_duration")

		if debuff then
		    debuff:IncrementStackCount()
			debuff:SetDuration(debuff_duration, true)
		else
		    debuff = ability:ApplyDataDrivenModifier(caster, caster, "modifier_ringmaster_innate_fun_debuff_tooltip", { duration = debuff_duration })
			debuff:IncrementStackCount()
		end
	end
	return true
end

function modifier_ringmaster_innate_fun_debuff_OnDestroy(keys)

	if IsServer() then

	    local caster = keys.caster
		local ability = keys.ability
		local debuff = caster:FindModifierByName("modifier_ringmaster_innate_fun_debuff_tooltip")

		if debuff then
		    debuff:DecrementStackCount()
		end
	end
	return true
end
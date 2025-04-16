
The_Butterfly_Effect = {}--蝴蝶效应保存的单位

function dashizhidi_minjie (keys)

    local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:IsBuilding() or not target:IsAlive() then return end
	if not caster:IsOwnedByAnyPlayer() then return end
	if caster:GetTeam() ~= target:GetTeam() then

	    --敏捷叠加
	    local modifier_bonus_agility = "modifier_item_大师之笛-敏捷_bonus_agility"
	    local bonus_agility_duration = ability:GetSpecialValueFor("bonus_agility_duration")

	    if caster:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY and target:IsHero() then
            ability:ApplyDataDrivenModifier(caster, caster, modifier_bonus_agility, { duration = bonus_agility_duration })
	    end

		--法师克星
        if not caster:IsIllusion() then
		    local modifier_mage_slayer = "modifier_item_大师之笛-敏捷_mage_slayer_debuff"
		    local mage_slayer_dur = ability:GetSpecialValueFor("mage_slayer_dur")
			if not target:HasModifier(modifier_mage_slayer) then
                ability:ApplyDataDrivenModifier(caster, target, modifier_mage_slayer, {duration = mage_slayer_dur})	
			end
	    end

		--法力损毁
		if not target:IsMagicImmune() then
		    local mana_burn_const = ability:GetSpecialValueFor("mana_burn_const")
	        local mana_burn_pct = ability:GetSpecialValueFor("mana_burn_pct") 
			local pure_dmg_pct = ability:GetSpecialValueFor("pure_dmg_pct") 
 		   	local mana_burn_total = mana_burn_const + target:GetMaxMana() * mana_burn_pct * 0.01
			local particleName

    		if caster:IsIllusion() then 
    	 	   mana_burn_total = mana_burn_total * ability:GetSpecialValueFor("illusion_mana_burn_coefficient") * 0.01
    		end

	    	damage_table = {}
	   		damage_table.victim = target
	    	damage_table.attacker = caster
			if target:GetManaPercent() <= pure_dmg_pct or target:GetMana() < 1 then
	        	damage_table.damage_type = DAMAGE_TYPE_PURE
				particleName = "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_manaburn_basher_ti_5_gold.vpcf"
			else
            	damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
				particleName = "particles/econ/items/antimage/antimage_weapon_basher_ti5/am_manaburn_basher_ti_5.vpcf"
			end
	    	damage_table.damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL
        	damage_table.ability = ability
	    	damage_table.damage = mana_burn_total --math.min(caster:GetMana(),mana_burn_total)	
			
			ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
	    	target:ReduceMana(mana_burn_total)
	    	ApplyDamage(damage_table)
        end

		--蝴蝶效应/全地图随机攻击
		local modifier_bonus_attack_cooldown = "modifier_item_大师之笛-敏捷_bonus_attack_cooldown"
		local modifier_bonus_attack = "modifier_item_大师之笛-敏捷_bonus_attack"
		local target_location = target:GetAbsOrigin()
	    local target_teams = DOTA_UNIT_TARGET_TEAM_ENEMY
	    local target_types = ability:GetAbilityTargetType() 
	    local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	    local bonus_attack_cooldown = ability:GetSpecialValueFor("bonus_attack_cooldown")

        if not caster:FindModifierByName(modifier_bonus_attack_cooldown) and not caster:IsIllusion() then		
		    --print("搜索单位流程")
	        
	        units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, 30000, target_teams, target_types, target_flags, FIND_ANY_ORDER, false)
		
		    for i,unit in ipairs(units) do    
 
	            if unit ~= target and not unit:FindModifierByName(modifier_bonus_attack) and not target:FindModifierByNameAndCaster(modifier_bonus_attack, caster) then   
				    ability:ApplyDataDrivenModifier(caster, caster, modifier_bonus_attack_cooldown, nil)
				    ability:ApplyDataDrivenModifier(caster, unit, modifier_bonus_attack, { duration = bonus_attack_cooldown })				
					--print("锁定一个单位")
		            break
		        end
			end
			
		elseif caster:FindModifierByName(modifier_bonus_attack_cooldown) and not caster:IsIllusion() then
		    --print("锁定攻击流程")
		    for i,debuff in ipairs(The_Butterfly_Effect) do    

	            if debuff[1] == caster and debuff[2]~= target and target:IsAlive() then
				    local particleName = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_javelin_tgt.vpcf"
	                ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, debuff[2])
				    caster:PerformAttack(debuff[2], true, true, true, true, false, false, true)
					--print("执行锁定攻击")
		            break
		        end
			end
	    end

	end

end
------------------------------------------------------------------------------------------------------------------------------------------------
function dashizhidi_minjie_mage_slayer_debuff (keys)
    --法师杀手降低技能增强效果
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
    local modifier = "modifier_item_大师之笛-敏捷_mage_slayer_debuff_reduction"
	local has_spell_amplification = target:GetSpellAmplification(false)
	local fixed_spell_amplification = 0

	local has_stack_count = target:GetModifierStackCount(modifier, caster)
	local per_stack_reduce = -0.01 * ability:GetSpecialValueFor("per_stack_reduce")
	local mage_slayer_amp_reduction = 0.01 *ability:GetSpecialValueFor("mage_slayer_amp_reduction")

	if has_stack_count < 1 then
	    fixed_spell_amplification = has_spell_amplification
	else
	    fixed_spell_amplification = has_spell_amplification + has_stack_count * per_stack_reduce
	end

	local ruduction = math.max(fixed_spell_amplification * mage_slayer_amp_reduction  ,mage_slayer_amp_reduction )
	local stack_count = math.ceil(ruduction / per_stack_reduce)
	if not target:HasModifier(modifier) then 
        ability:ApplyDataDrivenModifier(caster, target, modifier, nil)
	end
	target:SetModifierStackCount(modifier, caster, stack_count)

end
------------------------------------------------------------------------------------------------------------------------------------------------
function remove_mage_slayer_debuff (keys)
    --移除法师杀手降低技能增强效果
    local caster = keys.caster
	local target = keys.target  
	local ability = keys.ability
	local modifier = "modifier_item_大师之笛-敏捷_mage_slayer_debuff_reduction"
	target:RemoveModifierByName(modifier)

end
------------------------------------------------------------------------------------------------------------------------------------------------
function dashizhidi_minjie_bonus_attack (keys)
    --print("创建蝴蝶效应攻击")
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
    local modifier = target:FindModifierByNameAndCaster("modifier_item_大师之笛-敏捷_bonus_attack", caster)
	if modifier and target:IsAlive() then
		local location = target:GetAbsOrigin()
	    local bonus_attack_cooldown = ability:GetSpecialValueFor("bonus_attack_cooldown")
	    GameRules:ExecuteTeamPing(caster:GetTeam(), location.x, location.y, caster, 0)
	    local ViewerID = AddFOWViewer(caster:GetTeam(), location, 300, bonus_attack_cooldown, false)

	    table.insert(The_Butterfly_Effect, {caster,target,ViewerID})
	    --print("蝴蝶效应列表：")    
		--for i,debuff in pairs (The_Butterfly_Effect) do
		--    print("攻击者 "..debuff[1]:GetName().."  目标 "..debuff[2]:GetName())
		--end
		local particleName = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_javelin_tgt.vpcf"
	    ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
	    caster:PerformAttack(target, true, true, true, true, false, false, true)
    end

end
------------------------------------------------------------------------------------------------------------------------------------------------
function remove_bonus_attack_debuff (keys)
    --print("移除蝴蝶效应")
	local caster = keys.caster
	--local target = keys.unit
	--local ability = keys.ability
    local modifier_bonus_attack_cooldown = "modifier_item_大师之笛-敏捷_bonus_attack_cooldown"

    for i,debuff in ipairs(The_Butterfly_Effect) do    
 
	    if debuff[1] == caster then
		    caster:RemoveModifierByName(modifier_bonus_attack_cooldown)
		    --RemoveFOWViewer(caster:GetTeam(), debuff[3])  --存在移除失效的情况
		    table.remove(The_Butterfly_Effect,i)
		    break
		end
	end
	--print("移除后列表：")
	--for i,debuff in pairs (The_Butterfly_Effect) do
	--    print("攻击者 "..debuff[1]:GetName().."  目标 "..debuff[2]:GetName())
	--end

end
------------------------------------------------------------------------------------------------------------------------------------------------
function dashizhidi_minjie_purge (keys)
    --净化效果
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local slow_duration = ability:GetSpecialValueFor("slow_duration")
    
	if caster:GetTeam() == target:GetTeam() then
	    target:Purge(false, true, false, false, false)	
	else
	    if target:TriggerSpellAbsorb(ability) then return end
        target:Purge(true, false, false, false, false)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_item_diffusal_blade_slow", {duration = slow_duration})
		if target:IsCreep() then
		    ability:ApplyDataDrivenModifier(caster, target, "modifier_rooted", {duration = 3})
		end
	end

	local particleName = "particles/generic_gameplay/generic_purge.vpcf"
    ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
	target:EmitSound("DOTA_Item.DiffusalBlade.Target")

end
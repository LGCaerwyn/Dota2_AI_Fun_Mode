------------------------------------------------------------------------------

function marksmanship_damage(keys)      --攻击到达时造成伤害
     if not IsServer() then return end
     local caster = keys.caster  
     local target = keys.target
	 local ability = keys.ability
     local stackCount = caster:GetModifierStackCount("modifier_marksmanship_BUFF", caster)

     if target:IsBuilding() or caster:GetTeam() == target:GetTeam() then   --伤害对建筑或友军无效
         return          
     end

     if stackCount <= 0 then       --层数为0不造成伤害
         return
     end
     if caster:IsIllusion() then return end --幻象不造成伤害

     local Damage = keys.ability:GetSpecialValueFor("damage")

     local damage_table = {}

     damage_table.victim = target
	 damage_table.attacker = caster
	 damage_table.damage = Damage * stackCount
	 damage_table.damage_type = DAMAGE_TYPE_ABILITY_DEFINED  --伤害类型在KV中定义
     damage_table.damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_PHYSICAL_BLOCK + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL
     damage_table.ability = keys.ability          
 
     if caster:HasScepter() then 
         damage_table.damage_flags = damage_table.damage_flags + DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR  --神杖额外伤害无视护甲

		 --******************************************************
         --穿心裂矢
		 --*******************************************************
	     local target_location = target:GetAbsOrigin()		
	     local target_type = ability:GetAbilityTargetType()
	     local target_team = ability:GetAbilityTargetTeam()
	     local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE

         local radius = ability:GetSpecialValueFor("arrow_range")
	     local max_targets = ability:GetSpecialValueFor("arrow_count")
	     local projectile_speed = ability:GetSpecialValueFor("arrow_speed")
		 local split_shot_projectile = "particles/econ/items/drow/drow_ti9_immortal/drow_ti9_marksman.vpcf"
		 local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), target_location, nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)
	
	     for _,v in pairs(split_shot_targets) do

		     if v ~= target and target:IsAlive() then

			     local projectile_info = 
			     {
				        EffectName = split_shot_projectile,
				        Ability = ability,
				        vSpawnOrigin = target_location,
				        Target = v,
				        Source = target,
				        bHasFrontalCone = false,
				        bIsAttack = true,
				        bDodgeable = true,
				        iMoveSpeed = projectile_speed,
				        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				        bVisibleToEnemies = true,
				        bReplaceExisting = false,
				        bProvidesVision = false,
						bIgnoreObstructions = false,
			     }
			     ProjectileManager:CreateTrackingProjectile(projectile_info)
			     max_targets = max_targets - 1
		     end

			 if max_targets == 0 then break end
	     end

     end
     
     SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, damage_table.damage, nil)  --伤害信息，例如智慧之刃、奥数天球、金箍棒造成的伤害会显示在目标头顶附近
     ApplyDamage(damage_table)

     return
end

------------------------------------------------------------------------------
--新增破坏禁用效果
function isDisabled(keys)
    if not IsServer() then return true end
	local ability = keys.ability
	local caster = keys.caster
    local stackCount = caster:GetLevel()+ ability:GetSpecialValueFor("base_stack")

	if caster:PassivesDisabled() or not caster:HasModifier("modifier_drow_ranger_marksmanship_aura_bonus")then 
        if caster:HasModifier("modifier_marksmanship_BUFF") then
	        caster:RemoveModifierByName("modifier_marksmanship_BUFF")
            caster:RemoveModifierByName("modifier_marksmanship_BUFF_fixed")
			--移除多个射程修饰器
            local modifier_table = caster:FindAllModifiersByName("modifier_special_bonus_attack_range")
            for _,v in pairs(modifier_table) do

                if v:GetAbility() == ability then
				    v:Destroy()
				end
			end
			--ability.range_stack = 0 --记录叠层用
        end

	elseif not caster:PassivesDisabled() and caster:HasModifier("modifier_drow_ranger_marksmanship_aura_bonus") then

        if not caster:HasModifier("modifier_marksmanship_BUFF") then
	        ability:ApplyDataDrivenModifier(caster, caster, "modifier_marksmanship_BUFF", nil)
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_marksmanship_BUFF_fixed", nil)
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_special_bonus_attack_range", {}) --不叠层的话就只加这一次，需要叠层请注释掉
        end
        caster:SetModifierStackCount("modifier_marksmanship_BUFF", caster, stackCount)
        caster:SetModifierStackCount("modifier_marksmanship_BUFF_fixed", caster, stackCount)
		
		--[[
		--KV加射程的属性不会改变霜冻之箭的施法距离，所以要用10攻击距离的官方天赋（"modifier_special_bonus_attack_range"）累加多次来提供攻击距离
		--modifier_special_bonus_attack_range叠加层数无法提升攻击距离，所以只能多次添加修饰器
		--ability.range_stack记录当前的层数
		if ability.range_stack == nil then
		    ability.range_stack = 0
		    for i = 1, stackCount do
		        ability:ApplyDataDrivenModifier(caster, caster, "modifier_special_bonus_attack_range", {})
			end
			ability.range_stack = stackCount
		else
		    local fix_stack = stackCount - ability.range_stack

			if fix_stack > 0 then

			    --需要提升射程  
			    for i = 1, fix_stack do
				    ability:ApplyDataDrivenModifier(caster, caster, "modifier_special_bonus_attack_range", {})
				end			

			elseif fix_stack < 0 then

			    --需要减少射程
			    local modifier_table = caster:FindAllModifiersByName("modifier_special_bonus_attack_range")
				local removed = 0
                for _,v in pairs(modifier_table) do

				    if v:GetAbility() == ability then
					    v:Destroy()
						removed = removed +1
					end

					if removed >= -1 * fix_stack then
					    break
					end
				end
			end
			ability.range_stack = stackCount
		end]]


	end

end

------------------------------------------------------------------------------
--穿心裂矢伤害
function SplitShotDamage(keys)
	if not IsServer() then return true end
	if not IsServer() then return end
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage_pct = ability:GetSpecialValueFor("arrow_dmg") * 0.01
	local damage = caster:GetAverageTrueAttackDamage(nil) * damage_pct
	if not caster:IsRealHero() then
        damage = 0
	end

	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = damage 
	damage_table.damage_flags = --[[DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR +]] DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_BYPASSES_PHYSICAL_BLOCK

	--添加冰箭低温
	local frost_arrow = caster:FindAbilityByName("drow_ranger_frost_arrows")
	local debuff = target:FindModifierByName("modifier_drow_ranger_frost_arrows_hypothermia")
	local debuff_duration = 0
	local stack = 0
	local stack_max = 0
	if frost_arrow then
	    if frost_arrow:GetLevel() >= 1 then
		    debuff_duration = frost_arrow:GetSpecialValueFor("shard_stack_duration")		
			stack_max = frost_arrow:GetSpecialValueFor("shard_max_stacks")

		end
		
		if debuff then
            if stack_max > debuff:GetStackCount() then
			    stack = debuff:GetStackCount()+1
			else 
			    stack = stack_max
			end        
		    debuff:SetStackCount(stack)
		    debuff:SetDuration(debuff_duration, true)
	    else
	        debuff = target:AddNewModifier(caster, frost_arrow, "modifier_drow_ranger_frost_arrows_hypothermia", { duration = debuff_duration })
			debuff:SetStackCount(1)
	    end
	end

	ApplyDamage(damage_table)

end

------------------------------------------------------------------------------
--提升霜冻之箭施法距离
function drow_ranger_marksmanship_fun_AbilityTuningValueFilter(event)

    local caster = EntIndexToHScript(event.entindex_caster_const)
    local ability = EntIndexToHScript(event.entindex_ability_const)
    if ability == nil then return true end

    local fun_ability = caster:FindAbilityByName("drow_ranger_marksmanship_fun") 
	local modifier = caster:FindModifierByName("modifier_marksmanship_BUFF")
    if fun_ability == nil then return true end
    if fun_ability:GetLevel() < 1 then return true end
	if not modifier then return true end
    if ability:GetAbilityName() == "drow_ranger_frost_arrows" and
       event.value_name_const == "AbilityCastRange"
    then
	   local stack = modifier:GetStackCount()
	   local range = stack * fun_ability:GetSpecialValueFor("attack_range_bonus")
	   event.value = event.value + range
       --event.value = math.max(event.value, caster:Script_GetAttackRange())
       return true
    else
        return false
    end

end

function marksmanship_OnAttackStart(keys)

    if not IsServer() then return true end
    local caster = keys.caster
	local PlayerID = caster:GetPlayerID()
	local target = keys.target
	local ability = keys.ability
	local ability_glacier = caster:FindAbilityByName("drow_ranger_glacier")

	if not target:IsRealHero() then return end
	if not PlayerResource:IsFakeClient(PlayerID) then return end
	if ability_glacier == nil then return end
	if ability_glacier:GetLevel() < 1 then return end
	if not ability_glacier:IsCooldownReady() then return end

	caster:CastAbilityNoTarget(ability_glacier, caster:GetMainControllingPlayer())

end
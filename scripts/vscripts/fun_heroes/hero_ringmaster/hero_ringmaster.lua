function fracture_domain_sweep( keys )
	-- body
	if not IsServer() then return true end
	local caster = keys.caster
	local target = keys.target
	local attacker = keys.attacker
	local ability = keys.ability
	local distance = ability:GetSpecialValueFor("cleave_distance")
    local startRadius = ability:GetSpecialValueFor("startRadius")
    local endRadius = ability:GetSpecialValueFor("cleave_radius")
    local damage = keys.Damage * ability:GetSpecialValueFor("cleave_dmg") /100
    local EffectName = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_crit.vpcf"
    --"particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength_crit.vpcf"

 --   print("分裂")
    DoCleaveAttack(attacker, target, ability, damage, startRadius, endRadius, distance, EffectName)

end


function Remote_Splitting( keys )
	-- body
	--local caster = keys.caster
	if not IsServer() then return true end
	local target = keys.target
	local attacker = keys.attacker
	local ability = keys.ability
	local Remote_Splitting_Damage =keys.Damage * ability:GetSpecialValueFor("Splitting_dmg") * 0.01
	local radius = ability:GetSpecialValueFor("radius")
	local target_location = target:GetAbsOrigin()
	local attacker_teams = attacker:GetTeamNumber()
	local target_teams = target:GetTeamNumber()
	--print(attacker_teams)
	--print(target_teams)
	local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE 
						+ DOTA_UNIT_TARGET_FLAG_NOT_NIGHTMARED +DOTA_UNIT_TARGET_FLAG_RESPECT_OBSTRUCTIONS 
						+ DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NO_INVIS   --+ DOTA_UNIT_TARGET_FLAG_DEAD
	local particleName = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_javelin_tgt.vpcf"
    ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
	local units = FindUnitsInRadius(attacker_teams, target_location, nil, radius, target_teams, target_types, target_flags, 0, false)
	if not (#units > 1) then
		return
	end
	local damage_table = {}
	 damage_table.attacker = attacker
	 damage_table.damage = Remote_Splitting_Damage
     damage_table.damage_type = DAMAGE_TYPE_PHYSICAL --DAMAGE_TYPE_ABILITY_DEFINED --技能说明为纯粹，实际为：标记（无视护甲+无视格挡）的物理伤害，目的是避免对处于虚无、极寒之拥、守护天使等物免状态的单位造成伤害
	 damage_table.damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_PHYSICAL_BLOCK + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL
     damage_table.ability = ability

	local particleName = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_javelin_tgt.vpcf"
    ParticleManager:CreateParticle(particleName, PATTACH_POINT_FOLLOW, target)
    for i,unit in ipairs(units) do    
	    if unit == target then
		    goto continue
		end
        damage_table.victim = unit
	    ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, unit)
		--SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, damage_table.damage, nil)  --伤害信息，例如智慧之刃、奥数天球、金箍棒造成的伤害会显示在目标头顶附近
		ApplyDamage(damage_table)    
		::continue::
	end
end
--particles/econ/items/effigies/status_fx_effigies/se_ambient_fm16_rad_lvl3.vpcf
function Strike_Swift_Shadow(keys )
		if not IsServer() then return true end
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local duration = ability:GetSpecialValueFor("duration")
		local particleName = "particles/units/heroes/hero_alchemist/alchemist_chemical_rage.vpcf"
		local particleName_ranged = "particles/econ/items/alchemist/alchemist_aurelian_weapon/alchemist_chemical_rage_aurelian.vpcf"
		local particleName_2 = "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_eztzhok.vpcf"
		target:EmitSound( "Item.BookOfShadows.Target")
		if  not target:IsRangedAttacker() then
				--print("近战英雄")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_strike_swift_shadow", {duration = duration})
			local modifier_e = target:FindModifierByName("modifier_strike_swift_shadow")
			local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW  , target )
			modifier_e:AddParticle(particle, false,false, 254, true, false)
			local particle = ParticleManager:CreateParticle( particleName_2, PATTACH_POINT_FOLLOW  , target )	
			modifier_e:AddParticle(particle, false,false, 254, true, false)
			else
				--print("远程英雄")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_strike_swift_shadow_ranger", {duration = duration})
			local modifier_e_2 = target:FindModifierByName("modifier_strike_swift_shadow_ranger")
			local particle =ParticleManager:CreateParticle( particleName_ranged, PATTACH_POINT_FOLLOW  , target )	
			modifier_e_2:AddParticle(particle, false,false, 254, true, false)
			local particle =ParticleManager:CreateParticle( particleName_2, PATTACH_POINT_FOLLOW  , target )	
			modifier_e_2:AddParticle(particle, false,false, 254, true, false)
		end

end

function Hard_Shield_Magic_Defense(keys )
	if not IsServer() then return true end
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local caster_location = caster:GetAbsOrigin()
	local caster_teamnumber = caster:GetTeamNumber()
	caster:EmitSound("Hero_Mars.Spear")
	local particleName = "particles/units/heroes/hero_alchemist/alchemist_berserk_potion_projectile.vpcf"
--	local particleName = "particles/econ/items/vengeful/vs_ti8_immortal_shoulder/vs_ti8_immortal_magic_missle.vpcf"

	local projectileTable =
	{
		EffectName = particleName,
		Source = caster,
		Ability = ability,
		bProvidesVision = true,
		iVisionRadius = 300,
		iVisionTeamNumber = caster_teamnumber,
		--ExtraData = nil,
		vSourceLoc = caster_location,
		Target = target,
		iMoveSpeed = 850,
		--flExpireTime = ,
		bDodgeable = true,
		bIsAttack = false,
		bReplaceExisting = false,
		bIgnoreObstructions = false,
		bSuppressTargetCheck = false,
		iSourceAttachment = attach_attack2 ,--attach_finger_index_left_fx,
		bDrawsOnMinimap = false,
		bVisibleToEnemies = true,

	}
	ProjectileManager:CreateTrackingProjectile(projectileTable)
	
end

function HSMD( keys )
	-- body
	if not IsServer() then return true end
	local target_points = keys.target_points[1]
	local caster = keys.caster
	local ability = keys.ability
	local caster_location = caster:GetAbsOrigin()
	local caster_teamnumber = caster:GetTeamNumber()
	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("duration")
	local is_rooted = ability:GetSpecialValueFor("is_rooted")
	local rooted_duration = ability:GetSpecialValueFor("rooted_duration")
	local target_types = DOTA_UNIT_TARGET_HERO
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE 
						+ DOTA_UNIT_TARGET_FLAG_NOT_NIGHTMARED +DOTA_UNIT_TARGET_FLAG_RESPECT_OBSTRUCTIONS 
						+ DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NO_INVIS   --+ DOTA_UNIT_TARGET_FLAG_DEAD
	local particleName = "particles/econ/items/omniknight/omni_2021_immortal/omni_2021_immortal_buff_ring.vpcf"
	local particleName_enemy = "particles/econ/items/omniknight/omni_crimson_witness_2021/omniknight_crimson_witness_2021_degen_aura_debuff.vpcf"
    local particleName_enemy_ranger = "particles/econ/items/omniknight/omniknight_fall20_immortal/omniknight_fall20_immortal_degen_aura_debuff.vpcf"
	local units = FindUnitsInRadius(caster_teamnumber, target_points, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH , target_types, target_flags, 0, false)
	EmitSoundOnLocationWithCaster(target_points, "Item.Disperser.Target.Ally",caster)
	for k,target in pairs(units) do
		if  not target:IsRangedAttacker() then
				if target:GetTeamNumber() == caster_teamnumber then
					ability:ApplyDataDrivenModifier(caster, target, "modifier_hard_shield_magic_defense", {duration = duration})
					local modifier_w = target:FindModifierByName("modifier_hard_shield_magic_defense")
					local particle = ParticleManager:CreateParticle(particleName, PATTACH_POINT_FOLLOW, target)
					modifier_w:AddParticle(particle, false,false, 254, true, false)
				else
					ability:ApplyDataDrivenModifier(caster, target, "modifier_hsmd_enemy_ranger", {duration = duration})
					local modifier_hsmd_enemy_ranger = target:FindModifierByName("modifier_hsmd_enemy_ranger")
					local particle = ParticleManager:CreateParticle(particleName_enemy_ranger, PATTACH_POINT_FOLLOW, target)
					modifier_hsmd_enemy_ranger:AddParticle(particle, false,false, 254, true, false)
					if is_rooted == 1 then
						ability:ApplyDataDrivenModifier(caster, target, "modifier_rooted_undispellable", {duration = rooted_duration})	
					end



				end
		else
				if target:GetTeamNumber() == caster_teamnumber then
				ability:ApplyDataDrivenModifier(caster, target, "modifier_hard_shield_magic_defense_ranger", {duration = duration})
				local modifier_w_2 = target:FindModifierByName("modifier_hard_shield_magic_defense_ranger")
				local particle = ParticleManager:CreateParticle(particleName, PATTACH_POINT_FOLLOW, target)
				modifier_w_2:AddParticle(particle, false,false, 254, true, false)
				else
					ability:ApplyDataDrivenModifier(caster, target, "modifier_hsmd_enemy", {duration = duration})
					local modifier_hsmd_enemy = target:FindModifierByName("modifier_hsmd_enemy")
					local particle = ParticleManager:CreateParticle(particleName_enemy, PATTACH_POINT_FOLLOW, target)
					modifier_hsmd_enemy:AddParticle(particle, false,false, 254, true, false)
						if is_rooted == 1 then
							ability:ApplyDataDrivenModifier(caster, target, "modifier_rooted_undispellable", {duration = rooted_duration})	
						end
				end
		end

	end

end

function HSMD_OnProjectileHitunit(keys )
	if not IsServer() then return true end
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local caster_location = caster:GetAbsOrigin()
	local caster_teamnumber = caster:GetTeamNumber()
	local target_location = target:GetAbsOrigin()
	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("duration")
	local is_rooted = ability:GetSpecialValueFor("is_rooted")
	local rooted_duration = ability:GetSpecialValueFor("rooted_duration")
	--local attacker_teams = attacker:GetTeamNumber()
	local target_types = DOTA_UNIT_TARGET_HERO
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE 
						+ DOTA_UNIT_TARGET_FLAG_NOT_NIGHTMARED +DOTA_UNIT_TARGET_FLAG_RESPECT_OBSTRUCTIONS 
						+ DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NO_INVIS   --+ DOTA_UNIT_TARGET_FLAG_DEAD
	local particleName = "particles/econ/items/omniknight/omni_2021_immortal/omni_2021_immortal_buff_ring.vpcf"
    local particleName_enemy = "particles/econ/items/omniknight/omni_crimson_witness_2021/omniknight_crimson_witness_2021_degen_aura_debuff.vpcf"
    local particleName_enemy_ranger = "particles/econ/items/omniknight/omniknight_fall20_immortal/omniknight_fall20_immortal_degen_aura_debuff.vpcf"
	local units = FindUnitsInRadius(caster_teamnumber, target_location, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH , target_types, target_flags, 0, false)
	target:EmitSound("Item.Disperser.Target.Ally")
	for k,target in pairs(units) do
		if  not target:IsRangedAttacker() then
				if target:GetTeamNumber() == caster_teamnumber then
					ability:ApplyDataDrivenModifier(caster, target, "modifier_hard_shield_magic_defense", {duration = duration})
					local modifier_w = target:FindModifierByName("modifier_hard_shield_magic_defense")
					local particle = ParticleManager:CreateParticle(particleName, PATTACH_POINT_FOLLOW, target)
					modifier_w:AddParticle(particle, false,false, 254, true, false)
				else
					ability:ApplyDataDrivenModifier(caster, target, "modifier_hsmd_enemy_ranger", {duration = duration})
					local modifier_hsmd_enemy_ranger = target:FindModifierByName("modifier_hsmd_enemy_ranger")
					local particle = ParticleManager:CreateParticle(particleName_enemy_ranger, PATTACH_POINT_FOLLOW, target)
					modifier_hsmd_enemy_ranger:AddParticle(particle, false,false, 254, true, false)
						if is_rooted == 1 then
							ability:ApplyDataDrivenModifier(caster, target, "modifier_rooted_undispellable", {duration = rooted_duration})	
						end
				end
		else
				if target:GetTeamNumber() == caster_teamnumber then
				ability:ApplyDataDrivenModifier(caster, target, "modifier_hard_shield_magic_defense_ranger", {duration = duration})
				local modifier_w_2 = target:FindModifierByName("modifier_hard_shield_magic_defense_ranger")
				local particle = ParticleManager:CreateParticle(particleName, PATTACH_POINT_FOLLOW, target)
				modifier_w_2:AddParticle(particle, false,false, 254, true, false)
				else
					ability:ApplyDataDrivenModifier(caster, target, "modifier_hsmd_enemy", {duration = duration})
					local modifier_hsmd_enemy = target:FindModifierByName("modifier_hsmd_enemy")
					local particle = ParticleManager:CreateParticle(particleName_enemy, PATTACH_POINT_FOLLOW, target)
					modifier_hsmd_enemy:AddParticle(particle, false,false, 254, true, false)
						if is_rooted == 1 then
							ability:ApplyDataDrivenModifier(caster, target, "modifier_rooted_undispellable", {duration = rooted_duration})	
						end					
				end
		end

	end

end

function start_fracture_domain_sweep(keys )
	-- body
	if not IsServer() then return true end
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	target:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
			if  not target:IsRangedAttacker() then
				--print("近战英雄")
				ability:ApplyDataDrivenModifier(caster, target, "modifier_fracture_domain_sweep", {duration = duration})
				else
				--print("远程英雄")
				ability:ApplyDataDrivenModifier(caster, target, "modifier_fracture_domain_sweep_ranger", {duration = duration})
			end
end




function ringmaster_superpower( keys )

	if not IsServer() then return true end
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = ability:GetSpecialValueFor("duration")
		--print(target)
	--	if not target:HasAbility("special_bonus_unique_Superpower") then
	--		target:AddAbility("special_bonus_unique_Superpower")
	--	end

		if target:HasModifier("modifier_you_are_strengthened_Come_on") then
		local modifier = target:FindModifierByName("modifier_you_are_strengthened_Come_on")
		--	  print(modifier)
		--	  print(modifier:GetDuration())
		--	  print(modifier:GetElapsedTime())
		--	print("已加强")
			  modifier_duration = modifier:GetDuration() + duration -- - modifier:GetElapsedTime()
			  modifier:SetDuration(modifier_duration,true)
		else
		--	print("未加强")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_you_are_strengthened_Come_on", {duration = duration})
			local modifier_r = target:FindModifierByName("modifier_you_are_strengthened_Come_on")
			local particleName = "particles/econ/events/ti9/bottle_ti9.vpcf"
			local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW , target )
			modifier_r:AddParticle(particle, false,false, 254, true, false)
			target:AddAbility("special_bonus_unique_Superpower")
			target:FindAbilityByName("special_bonus_unique_Superpower"):SetLevel(1)
			ability:ApplyDataDrivenModifier(caster, target, "modifier_you_are_strengthened_Come_on", {duration = duration})
			local particleName = "particles/status_fx/status_effect_snapfire_magma.vpcf"
			local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW , target )


			Timers:CreateTimer(0.4,function()
			ability:ApplyDataDrivenModifier(caster, target, "modifier_you_are_strengthened_Come_on_fx", {duration = duration})
			local modifier_r_3 = target:FindModifierByName("modifier_you_are_strengthened_Come_on_fx")
			local particleName = "particles/econ/items/lifestealer/lifestealer_immortal_backbone_gold/lifestealer_immortal_backbone_gold_rage.vpcf"
			local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW , target )
			modifier_r_3:AddParticle(particle, false,false, 254, true, false)
			return nil
			end)
		end
end
function remove_superpower( keys )
	-- body
	if not IsServer() then return true end
	local caster = keys.caster
	local target = keys.target
	target:RemoveAbility("special_bonus_unique_Superpower")
--	print("移除技能")

end

function particle( keys )
	-- body
	if not IsServer() then return true end
	local target = keys.target
--	local particleName = "particles/econ/events/ti6/bottle_ti6.vpcf"
	local particleName = "particles/units/heroes/hero_invoker/invoker_alacrity.vpcf"
	local particleName_ranged = "particles/econ/items/invoker/invoker_ti7/invoker_ti7_alacrity.vpcf"
	--local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW  , target )


	local modifier_q = target:FindModifierByName("modifier_fracture_domain_sweep")
	local modifier_q_2 = target:FindModifierByName("modifier_fracture_domain_sweep_ranger")
	if modifier_q ~=nil then
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW  , target )	
	modifier_q:AddParticle(particle, false,false, 254, true, false)
	--print("我是近战")
	else
	local particle =ParticleManager:CreateParticle( particleName_ranged, PATTACH_POINT_FOLLOW  , target )	
	modifier_q_2:AddParticle(particle, false,false, 254, true, false)
	--print("我是远程")
	--ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW  , target )
	end
end

function particle_r( keys )
	-- body
	if not IsServer() then return true end
	local target = keys.target
	local caster = keys.caster
	--particles/econ/events/ti9/bottle_ti9.vpcf

	local target = keys.target
	local particleName = "particles/econ/events/ti6/bottle_ti6.vpcf"
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW  , target )
	local modifier_r_2 = target:FindModifierByName("modifier_you_are_strengthened_Come_on_fx")
	if modifier_r_2 ~=nil then
	modifier_r_2:AddParticle(particle, false,false, 254, true, false)
	else
	modifier_r_2:AddParticle(particle, false,false, 254, true, false)
	--ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW  , target )
	end



	local particleName = "particles/units/heroes/hero_ringmaster/ringmaster_whip_twirl.vpcf"
	particle_r = ParticleManager:CreateParticle( particleName, PATTACH_POINT  , caster )
--	print(2)
end

function Destroyparticle( keys )
	-- body
	if not IsServer() then return true end
--	print(1)
--	ParticleManager:DestroyParticle(particle_r, false)
ParticleManager:ReleaseParticleIndex(particle_r)
ParticleManager:DestroyParticle(particle_r, false)
end


function particle_r2( keys )
	-- body3
	if not IsServer() then return true end
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local targetPoint = target:GetAbsOrigin()
	local casterPoint = caster:GetAbsOrigin()
	--caster:StartGesture(ACT_DOTA_CAST_ABILITY_1_END)
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1_END , 0.6)
	local particleName = "particles/items4_fx/bull_whip_enemy.vpcf"
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW , caster )

--	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "", targetPoint, true)
	--ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_origin", Vector(600,600,600), true)
	ParticleManager:SetParticleControl(particle, 0,casterPoint)
	ParticleManager:SetParticleControl(particle, 1,targetPoint)
	Timers:CreateTimer(0.2,function()
		caster:EmitSound("Hero_Ringmaster.Whip.Target")
		return nil
		end)
	--ability:ApplyDataDrivenModifier(caster, target, "modifier_r", {duration = 7})

--	print("执行下一步函数")
	ringmaster_superpower(keys)
end


function you_are_strengthened_Come_on( keys )
	-- body
	if not IsServer() then return true end
--	print("开始施法")
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	caster:EmitSound("Hero_Ringmaster.Whip.Cast")
	local ringmaster_table = {"ringmaster_ringmaster_attack_14","ringmaster_ringmaster_attack_03"
								,"ringmaster_ringmaster_arcane_01","ringmaster_ringmaster_arcane_02",
								"ringmaster_ringmaster_attack_02","ringmaster_ringmaster_attack_pain_02",
								"ringmaster_ringmaster_battlebegins_06","ringmaster_ringmaster_battlebegins_07",
								"ringmaster_ringmaster_cast_02","ringmaster_ringmaster_spin_the_wheel_09",}
							--艺术就是受苦 来点刺激的 我感到打手启发 让我们开始干活 给我表演个把戏 最后的表演
							--好戏开始 演出开始 我一直留着这个 现在是最精彩的部分
	local rand = math.random(1,10)						
	caster:EmitSound(ringmaster_table[rand])
	Timers:CreateTimer(1,function()
		caster:EmitSound("Hero_Ringmaster.Whip.Channel")
		return nil
		end)
	local casterPoint = caster:GetOrigin()
--	print(casterPoint)
--	print(casterPoint + Vector(0,-142,-73))
	local particleName = "particles/units/heroes/hero_ringmaster/ringmaster_whip_twirl.vpcf"
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT  , caster )
	--ParticleManager:SetParticleControl(particle, 0,Vector(0,-42,-73))
		ParticleManager:SetParticleControl(particle, 0,casterPoint + Vector(50,30,-40))
	--ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT      , "attach_attack2", casterPoint+Vector(-160.89,62.9768,-89.2792), true)

	--ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW , "attach_finger_index_left_fx", casterPoint, true)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_modifier_you_are_strengthened_Come_on_start", {duration = 5})
	local modifier_r_2 = caster:FindModifierByName("modifier_modifier_you_are_strengthened_Come_on_start")
	modifier_r_2:AddParticle(particle, false,false, 254, true, false)
	--attach_finger_index_left_fx --attach_attack2

end

function tyu( keys )
	-- body
	if not IsServer() then return true end
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_modifier_you_are_strengthened_Come_on_start")
	caster:StopSound("Hero_Ringmaster.Whip.Cast")
	--print("打断或者施法结束")
end

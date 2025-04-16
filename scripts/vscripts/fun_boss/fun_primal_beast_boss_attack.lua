
--初始化
function Fun_Primal_Beast_Boss_Attack_OnCreated(keys)
    if not IsServer() then return true end
    --print("初始化")
	local ability = keys.ability
	local caster = keys.caster

	local pulverize = caster:FindAbilityByName("fun_pulverize_boss")                                 --正常版本锤，60秒cd
	local pummel = caster:FindAbilityByName("fun_aghsfort_primal_beast_boss_pummel_boss")            --迷宫版本锤，60秒cd
	local reverse_polarity = caster:FindAbilityByName("fun_reverse_polarity_boss")                   --两级反转，40秒cd
	local mystic_flare = caster:FindAbilityByName("fun_mystic_flare_boss")                           --神秘之耀，25秒cd	 
	local ravage = caster:FindAbilityByName("fun_ravage_boss")                                       --毁灭，40秒cd
	local arena_of_blood = caster:FindAbilityByName("fun_arena_of_blood_boss")                       --热血竞技场，20秒cd
	local earth_splitter = caster:FindAbilityByName("fun_earth_splitter_boss")                       --裂地沟壑，40秒cd
	local black_hole = caster:FindAbilityByName("Fun_BlackHole")                                    --年兽的黑洞，40秒cd
	local huitianmiedi = caster:FindAbilityByName("fun_huitianmiedi_boss")                           --毁天灭地，30秒cd

	local chronosphere = caster:FindAbilityByName("fun_chronosphere_boss_v2")                           --时间结界，40秒cd
	local tectonic_shift = caster:FindAbilityByName("fun_aghsfort_primal_beast_tectonic_shift_boss") --迷宫版本裂地波，60秒cd
 	local charge_of_darkness = caster:FindAbilityByName("fun_charge_of_darkness_boss")               --暗影冲刺，11秒cd

	ability.spell_table_1 = { pulverize, pummel, reverse_polarity, mystic_flare, ravage, arena_of_blood, earth_splitter, black_hole, huitianmiedi }  --攻击命中后施放的技能
	--ability.spell_table_2 = { chronosphere, huitianmiedi, charge_of_darkness, pummel, tectonic_shift, earth_splitter }                               --周期性施放的技能  
    ability.spell_table_2 = { chronosphere, huitianmiedi, pummel, tectonic_shift, earth_splitter }                               --周期性施放的技能   
	--ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_gem_of_true_sight", nil)          --真视宝石反隐效果
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--攻击命中
function Fun_Primal_Beast_Boss_Attack_OnAttackLanded(keys)
    if not IsServer() then return true end
    Fun_Primal_Beast_Boss_Attack_KillCreeps(keys)     --击杀所有敌方小兵
	Fun_Primal_Beast_Boss_Attack_Debuff(keys)          --攻击命中后添加负面效果并造成大范围分裂
	Fun_Primal_Beast_Boss_Attack_SpellAbilities(keys) --攻击命中英雄后施放技能
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--击杀敌方所有非玩家控制的小兵
function Fun_Primal_Beast_Boss_Attack_KillCreeps(keys)
    if not IsServer() then return true end
    --print("攻击后击杀小兵")
    local caster = keys.caster
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), self, 30000, DOTA_UNIT_TARGET_TEAM_ENEMY , DOTA_UNIT_TARGET_BASIC, 0, 0,false)
	
	if #enemies > 0 then
		for a,enemy in pairs (enemies) do
		    if  not enemy:IsNeutralUnitType() and 
			    not enemy:IsAncient() and 
				not enemy:IsControllableByAnyPlayer() 
			then			
		        enemy:ForceKill(true)
 		    end
		end	
	end	
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--攻击命中后添加负面效果并造成大范围分裂
function Fun_Primal_Beast_Boss_Attack_Debuff(keys)
    if not IsServer() then return true end
    local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local debuff_duration = ability:GetSpecialValueFor("debuff_duration")
	local stun_duration = ability:GetSpecialValueFor("stun_duration")
	local stun_chance = ability:GetSpecialValueFor("stun_chance")
	local stun_damage = ability:GetSpecialValueFor("stun_damage")
    local distance = ability:GetSpecialValueFor("great_cleave_distance")
    local startRadius = 150
    local endRadius = ability:GetSpecialValueFor("great_cleave_end_radius")
    local damage = keys.Damage * ability:GetSpecialValueFor("great_cleave_damage") /100
    local EffectName = "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength_2.vpcf"

	if target:IsBuilding() then return end

	ability:ApplyDataDrivenModifier(caster, target, "modifier_Fun_Primal_Beast_Boss_Attack_Debuff", { duration = debuff_duration })
    local roll = RollPseudoRandomPercentage(stun_chance, DOTA_PSEUDO_RANDOM_FACELESS_BASH, caster)
	if roll then
	    EmitSoundOn("Hero_FacelessVoid.TimeLockImpact", target)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_Fun_Primal_Beast_Boss_Attack_Stun", { duration = stun_duration })
		ApplyDamage({ 
			          victim = target,
                      attacker = caster,
                      damage = stun_damage,
                      damage_type = DAMAGE_TYPE_ABILITY_DEFINED,
                      damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
                      ability = keys.ability 
		            })
	end
	DoCleaveAttack(caster, target, ability, damage, startRadius, endRadius, distance, EffectName)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--攻击命中英雄后施放技能
function Fun_Primal_Beast_Boss_Attack_SpellAbilities(keys)
    --print("攻击后施放技能")
	if not IsServer() then return true end
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target

	--spell_table_1 = { pulverize, pummel, reverse_polarity, mystic_flare, ravage, arena_of_blood, earth_splitter, black_hole, huitianmiedi }

	for k,v in pairs(ability.spell_table_1) do

	    if v and v:IsCooldownReady() and target:IsHero() then
		    
		    --DOTA_ABILITY_BEHAVIOR_NO_TARGET = 4
			--DOTA_ABILITY_BEHAVIOR_UNIT_TARGET = 8
			--DOTA_ABILITY_BEHAVIOR_POINT = 16
		    --将技能对应的技能行为（DOTA_ABILITY_BEHAVIOR）转为二进制，再倒序输出后5位，上述3种单一结果分别为：00100,00010,00001

		    local behavior = dec2bin(v:GetBehavior()) 

		    if string.find(behavior, '1') == 3 then

		        caster:CastAbilityNoTarget(v, caster:GetMainControllingPlayer())	
				break

		    elseif string.find(behavior, '1') == 4 then

			    caster:CastAbilityOnTarget(target, v ,caster:GetMainControllingPlayer())
				break

			elseif string.find(behavior, '1') == 5 then

			    caster:CastAbilityOnPosition(target:GetAbsOrigin(), v, caster:GetMainControllingPlayer())
				break

			else
			    break
			end
		end
	end
	
    local attackTarget = caster:GetAttackTarget()	
	if not attackTarget:IsRealHero() then
	    
	    units_target  = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, 2000, 
			                              DOTA_UNIT_TARGET_TEAM_ENEMY, 
			                              DOTA_UNIT_TARGET_HERO, 
			                              DOTA_UNIT_TARGET_FLAG_NONE, 
										  FIND_CLOSEST, false)

	    for q,e in pairs(units_target) do
			if  e:IsRealHero() then      
				caster:MoveToTargetToAttack(e)
				break
			end	
		end				
    end					
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--周期性施放技能，这类技能都需要目标或点施放
function Fun_Primal_Beast_Boss_Attack_AutoSpell( keys )
    if not IsServer() then return true end
    --print("施放特殊技能")
	local ability = keys.ability
	local caster = keys.caster

	if not caster:IsAlive() then return end

	units  = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, 2000, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO, 
			DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
			FIND_ANY_ORDER, 
			false)

	--spell_table_2 = { chronosphere, huitianmiedi, charge_of_darkness, pummel, tectonic_shift, earth_splitter } 

	for k,target in pairs(units) do  
	    --print("有选定目标")
	    if target:IsRealHero() and not caster:IsChanneling() then

			for q,e in pairs(ability.spell_table_2) do

	            if e and e:IsCooldownReady() then

				    --DOTA_ABILITY_BEHAVIOR_NO_TARGET = 4 （此处不需要）
			        --DOTA_ABILITY_BEHAVIOR_UNIT_TARGET = 8
			        --DOTA_ABILITY_BEHAVIOR_POINT = 16
		            --将技能对应的技能行为（DOTA_ABILITY_BEHAVIOR）转为二进制，再倒序输出后5位，上述3种单一结果分别为：00100,00010,00001   
					
		            local behavior = dec2bin(e:GetBehavior()) 

		            if string.find(behavior, '1') == 4 then

		                caster:CastAbilityOnTarget(target, e ,caster:GetMainControllingPlayer())	
				        break

		            elseif string.find(behavior, '1') == 5 then
					    
					    if e:GetAbilityName() ~= "fun_chronosphere_boss_v2" or caster:GetHealthPercent() < 70 then

                            caster:CastAbilityOnPosition(target:GetAbsOrigin(), e, caster:GetMainControllingPlayer())
				            break
						end
			        else
			            break
			        end
		        end
	        end
		end		
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--10进制转2进制，但是输出是逆序，而且只获取倒数5位
function dec2bin(n)
    local t = {}
      for i=1,5,1 do
        t[#t+1] = n % 2
        n = math.floor(n / 2)
      end
    return table.concat(t)
end
is_triggered_when_respawn = false --罕见情况下提供特殊的重生，复活后触发伤害免疫
buff_reborn = nil                 --特殊的重生单独记录实体，避免移除时和尸王天赋、冥王之赐冲突
is_undying_talent_refresh = false --特殊重生会与尸王重生天赋同时触发，需要刷新后者

function on_take_damage(keys)

    local ability = keys.ability
	local attacker = keys.attacker
	local caster = keys.caster
	local min_health_pct = ability:GetSpecialValueFor("min_health_pct")

	--**************************************************************************************
	--*    触发条件：                                                                      *
	--*    条件1：冷却完毕                                                                 *
	--*    条件2：非幻象且非自残伤害                                                       *
	--*    条件3：攻击者是英雄、类英雄、玩家控制单位、泉水                                 *
	--*    条件4：拥有某些特殊、免致死/伤害的状态则不触发                                  *
	--*    条件5：低于特定血量                                                             *
	--*    条件6：存活；受到致死伤害时，未设置最低生命会返回false，反之会<永远>返回true    *
	--**************************************************************************************

	local condition_1 = ability:IsCooldownReady()	
	local condition_2 = (caster ~= attacker) and not caster:IsIllusion()  	
	local condition_3 = attacker:IsHero() or attacker:IsConsideredHero() or attacker:IsCreepHero() or attacker:IsControllableByAnyPlayer() or (attacker:GetUnitName() == "dota_fountain") 	
	local condition_4 = IsTrigger(keys)	 
	local condition_5 = caster:GetHealthPercent() <= min_health_pct 	
	local condition_6 = caster:IsAlive() --死亡延迟（绝冥再生）状态下不设置最低血量，死亡不触发无敌
	
	--触发
	local conditon = condition_1 and condition_2 and condition_3 and condition_4 and condition_5 and condition_6
	if conditon then 
	    Damage_Immune(keys)
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function IsReady(keys)
	
    local ability = keys.ability
	local caster = keys.caster

    --去除、添加最低生命值设定的情况
	--不设置最低生命值会被生命移除和死神镰刀<斩杀>致死
	if caster:HasModifier("modifier_item_阿哈利姆斗篷_min_health") then	    
	    if not ShouldHaveMinHealth(keys) then
		    caster:RemoveModifierByName("modifier_item_阿哈利姆斗篷_min_health")
		end
	else
	    if ShouldHaveMinHealth(keys) then
		    ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_阿哈利姆斗篷_min_health", nil)
		end
	end
  
	--*************************************************************************************************************************************************
	--*    添加、去除重生的情况，用于处理罕见场景：     	                                                                                          *
	--*    场景1：设置最低生命值后，几乎所有过量伤害、生命移除不会致死                                                                                *
	--*           但是冥魂续命光环（仅队友）、不朽尸王的头盔在受到过量伤害、生命移除时进入绿魂状态，且冥魂续命光环（仅队友）无法逃离死亡（最新改动）  *
	--*           所以需要添加一次重生效果，在复活后触发免伤状态                                                                                      *
	--*    场景2：米波拥有最低生命设定后，克隆体死亡主身不会被击杀，所以不会添加最低生命设定，改为重生补偿                                            *
	--*************************************************************************************************************************************************

	if ability:IsCooldownReady() then
	    if buff_reborn == nil and (caster:HasAbility("meepo_divided_we_stand") or caster:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")) then
		    buff_reborn = caster:AddNewModifier(caster, ability, "modifier_special_bonus_reincarnation", nil)
			is_triggered_when_respawn = true
		end

		if caster:HasModifier("modifier_skeleton_king_reincarnation_scepter_active") then
		    local ulti_reborn = caster:FindAbilityByName("skeleton_king_reincarnation")
		    if ulti_reborn and ulti_reborn:IsCooldownReady() then
                ulti_reborn:StartCooldown(0.1)
			end
		    caster:RemoveModifierByName("modifier_skeleton_king_reincarnation_scepter_active")
		end
	else
	    remove_reincarnation()
		is_triggered_when_respawn = false
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function remove_reincarnation()
    --卸下装备时移除重生
	if buff_reborn ~= nil then
        buff_reborn:Destroy()
	    buff_reborn = nil
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function Damage_Immune(keys)
    --触发免伤效果
    local caster = keys.caster
	local ability = keys.ability
	local cooldown = ability:GetSpecialValueFor("immune_cooldown")
	local dur = ability:GetSpecialValueFor("immune_duration")
	local min_health_pct = ability:GetSpecialValueFor("min_health_pct")
	local min_health = caster:GetMaxHealth() * min_health_pct * 0.01 + 1

    Strong_Dispel(keys)
	caster:SetHealth(min_health)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_阿哈利姆斗篷_damage_immune", { duration = dur })			
	ability:StartCooldown(cooldown)
		
	caster:EmitSound("DOTA_Item.MagicLamp.Cast")
	caster:EmitSound("DOTA_Item.ComboBreaker")
	local particle = ParticleManager:CreateParticle("particles/items5_fx/magic_lamp.vpcf", PATTACH_ABSORIGIN_FOLLOW , caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW , "attach_hitloc", Vector(0,0,0), true)

	is_triggered_when_respawn = false
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function on_respawn(keys)
    --特殊复活后触发半血+免伤
    if is_triggered_when_respawn == true then
	    Damage_Immune(keys)

        is_triggered_when_respawn = false
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function Strong_Dispel(keys)
    --最后一位参数代表强驱散
	local caster = keys.caster
	caster:Purge( false, true, false, true, true)  
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function buff_end(keys) 
    --免伤结束时的特效
    local caster = keys.caster
	local particle = ParticleManager:CreateParticle("particles/items4_fx/combo_breaker_buff_end.vpcf", PATTACH_ABSORIGIN_FOLLOW , caster)
	ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function IsTrigger(keys)
    
    local isTrigger = false
	local caster = keys.caster

	--****************************************************
	--*  目标有以下状态其一不会触发免伤效果：            *
	--*  1、绝冥再生/不朽尸王头盔的死亡延迟              *
	--*  2、超新星                                       *
	--*  3、元素分离                                     *
	--*  4、薄葬                                         * 
	--*  5、强断连招（永恒之盘）                         *
	--*  6、回光返照                                     *
	--*  7、虚妄之诺                                     *
	--*  8、战斗专注                                     *
	--*  9、折光（伤害吸收）                             *
	--*  10、七十二变                                    *
	--*  11、阿哈利姆福佑                                *
	--*  12、钻石化（暂不添加，因为没有完全伤害免疫）    *
	--****************************************************

	isTrigger = not (caster:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
	                 or caster:HasModifier("modifier_item_helm_of_the_undying_active") 					 
					    or caster:HasModifier("modifier_phoenix_supernova_hiding") 
						   or caster:HasModifier("modifier_brewmaster_primal_split") 
						      or caster:HasModifier("modifier_dazzle_shallow_grave") 
							     or caster:HasModifier("modifier_item_aeon_disk_buff") 
								    or caster:HasModifier("modifier_abaddon_borrowed_time") 
									   or caster:HasModifier("modifier_oracle_false_promise_timer") 
									      or caster:HasModifier("modifier_troll_warlord_battle_trance") 
										     or caster:HasModifier("modifier_templar_assassin_refraction_absorb") 
											    or caster:HasModifier("modifier_monkey_king_transform") 
												   or caster:HasModifier("modifier_item_阿哈利姆斗篷_damage_immune")
												      --or caster:HasModifier("zuanshihua") 
				     )
	return isTrigger
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function ShouldHaveMinHealth(keys)
    
    local shouldHaveMinHealth = false 
	local ability = keys.ability
	local caster = keys.caster

	--****************************************************
	--*  目标有以下状态其一不会获得最低生命设定：        *
	--*  1、技能处于冷却                                 *
	--*  2、拥有技能：分则能成                           *
	--*  3、绝冥再生的死亡延迟                           *
	--*  4、超新星                                       *
	--*  5、元素分离                                     *
	--*  6、非真正英雄                                   *
	--****************************************************

	shouldHaveMinHealth = not (not ability:IsCooldownReady() 
		                       or caster:HasAbility("meepo_divided_we_stand")
	                              or caster:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
	                                 --or caster:HasModifier("modifier_item_helm_of_the_undying_active")
							            or caster:HasModifier("modifier_phoenix_supernova_hiding")
							               or caster:HasModifier("modifier_brewmaster_primal_split")
										      or caster:IsIllusion()
	                           ) 
	return shouldHaveMinHealth
end
-------------------------------------------------------------------------------------------------------------------------------------------------------


--[[

一些设计思路：
     0、由于只用KV触发事件，存在一些难以解决的问题    
 
     1、一般情况，受到伤害后，直接设定生命，可以解决大多数问题
	    造成的问题：生命移除类伤害（如竭心光环）和死神镰刀<斩杀>伤害仍造成死亡
	 
     2、解决1的情况，要在触发前添加一个最低生命值属性,触发后移除
	    造成的问题：①米波分身死亡后，主身不会死亡，且分身要等主身复活后才会复活
		            ②冥魂续命/不朽尸王的头盔也有最低生命值属性，且优先级更高，受到过量伤害后会先触发，进入绿魂状态（冥魂大帝自身不存在这个问题，但自己被死神镰刀斩杀也不会进入绿魂状态）。
					  很早之前绿魂状态可以设定最低生命值，或者在移除后直接设定生命摆脱死亡，但是冥魂续命光环在今年6月更改后必定死亡（死亡会造成2次伤害事件，暂未研究）
		            ③1、2两种情况还会使凤凰超新星被击碎后直接原地爆炸复活，酒仙元素分离所有单位死亡后不会立刻阵亡，要等持续时间结束后才阵亡
					④未触发时，小兵伤害不会致死，但保留此情况

	 3、解决2的罕见情况：
	                ①米波不提供最低生命值属性，提供一次重生来避免过量伤害，道具正常触发后移除重生
					②在超新星、元素分离状态下无最低生命值属性，也不触发免伤；一些免死、免伤类技能期间也不触发（如绿魂、薄葬、永恒之盘），但保留最低生命值属性。
					②绿魂状态下立刻阵亡并提供重生，对此重生做出标记，重生后触发免伤
        造成的问题：①绝冥再生优先级大于重生（天赋），需要在阵亡时添加0.1秒冷却（前提是绝冥再生冷却完毕）
		            ②提供的特殊重生与尸王25级天赋是同类型的，在移除时要筛选正确，否则会将尸王天赋一并移除（永生大帝可以帮尸王找回失去的天赋）
					③重生会使尸王的天赋重生一并进入冷却，要在复活后刷新其技能
]]--
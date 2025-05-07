
blessing_table = {
	--1
    {   modifier = "modifier_hero_blessing_fun_all attributes",                name_cn = "+8全属性"                    },
	--2
	{   modifier = "modifier_hero_blessing_bonus_gold",                        name_cn = "+800金钱"                    },
	--3
	{   modifier = "modifier_hero_blessing_bonus_resistance",                  name_cn = "+10%状态抗性"                },
	--4
	{   modifier = "modifier_hero_blessing_bonus_movespeed",                   name_cn = "+30移动速度"                 },
	--5
	{   modifier = "modifier_hero_blessing_bonus_damage_percent",              name_cn = "+13%攻击力"                  },
	--6
	{   modifier = "modifier_hero_blessing_bonus_base_damage",                 name_cn = "+17基础攻击力"               },
	--7
	{   modifier = "modifier_hero_blessing_bonus_mana_cost_percent",           name_cn = "-10%魔法消耗"                },
	--8 
	{   modifier = "modifier_hero_blessing_bonus_spell_amplify_percent",       name_cn = "+8%技能增强"                 },
	--9
	{   modifier = "modifier_hero_blessing_bonus_cooldown_percent",            name_cn = "+8%冷却时间减少"             },
	--10
	{   modifier = "modifier_hero_blessing_bonus_incoming_spell_percent",      name_cn = "+9%魔法抗性"                 },
	--11
	{   modifier = "modifier_hero_blessing_bonus_incoming_physical_percent",   name_cn = "+9%物理伤害减免"             },
	--12
	{   modifier = "modifier_hero_blessing_bonus_incoming_damage_percent",     name_cn = "+6%全类型伤害减免"           },
    --13
	{   modifier = "modifier_hero_blessing_bonus_vision",                      name_cn = "夜间具有+250顺畅视野"        },
	--14
	{   modifier = "modifier_hero_blessing_bonus_health_regen",                name_cn = "+15生命恢复"                 },
	--15
	{   modifier = "modifier_hero_blessing_bonus_mana_regen",                  name_cn = "+5魔法恢复"                  } 
}


function item_fun_blessing( keys )
    if not IsServer() then return true end
    --fun中不发放免费卷轴

	local target = keys.caster
	local self_ability = keys.ability      --这个才是祝福物品
	local reset_times = self_ability:GetSpecialValueFor("reset_times")    --取消重置次数后，这个变量代表额外可选项，值为2代表3选1
    local ability = GameRules.Fun_DataTable["GameModeAbility"]
	local caster = keys.caster
	
	if ability == nil or not target:IsRealHero() then return end

	

	if target.blessing_table == nil then

		math.randomseed(Time()*FrameTime())

	    target.blessing_table = {}	
		target.blessing_table["optional_buff"] = {}

		for i = 1, #blessing_table do
		    target.blessing_table["optional_buff"][i] = i
		end

		if GameRules.isDemo == false then
	        for i = 1, #blessing_table - reset_times - 1 do
		        local rand_1 = RandomInt(1,#target.blessing_table["optional_buff"])
			    table.remove(target.blessing_table["optional_buff"], rand_1)
	        end
		end

		target.blessing_table["times"] = -1
		target.blessing_table["buff"] = ""
	end
	
	--发放buff
	--1、未获取祝福时，任何时刻都可以获取祝福
	--2、比赛开始前可以任意更换提供的祝福效果，发放的金钱回收失败则无法更换
	--3、斧王岛不限制可选项，每次使用都会更换成新的效果

    local index_1 = -1 
	local temp_str_buff = PlayerResource:GetPlayerName(target:GetPlayerID()).."获得祝福："
	local buff = target:FindModifierByName(target.blessing_table["buff"])

    if GameRules.isDemo == true then

	    --斧王岛不限制可选项，每次使用都是新的效果
		--不会因为金钱不足而失败
		target.blessing_table["times"] = target.blessing_table["times"] + 1
	    index_1 = target.blessing_table["times"] % #blessing_table + 1

		if buff then 
		    buff:Destroy()
		end

		ability:ApplyDataDrivenModifier(caster, target, blessing_table[index_1].modifier, {})
		target.blessing_table["buff"] = blessing_table[index_1].modifier	

		temp_str_buff = temp_str_buff.."<font color=\"#00FF00\">"..blessing_table[index_1].name_cn.."</font> "

	else
		--对战地图内只能从随机的几项选择一项，出兵前可以随意更换
		--没有祝福效果的情况下，出兵后只能使用一次
	    
	    if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS or 
		   (GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS and target.blessing_table["times"] == -1)
		then
		    
			--回收额外金钱
		    local gold = ability:GetSpecialValueFor("bonus_gold")
			--local tier1_token = target:FindItemInInventory("item_tier1_token")
	        if target.blessing_table["buff"] == "modifier_hero_blessing_bonus_gold" and target:GetGold() >= gold then
		        target:ModifyGold(-1 * gold, false, DOTA_ModifyGold_AbilityGold)
				--target:RemoveItem(tier1_token)
			elseif target.blessing_table["buff"] == "modifier_hero_blessing_bonus_gold" and (target:GetGold() < gold) then
			    GameRules:SendCustomMessage(PlayerResource:GetPlayerName(target:GetPlayerID()).. " : " .."<font color=\"#FFD700\">重置祝福失败，金钱回收失败。</font> ", DOTA_TEAM_BADGUYS,0)
				return
		    end

			target.blessing_table["times"] = (target.blessing_table["times"] + 1) % (reset_times + 1)
		    index_1 = target.blessing_table["optional_buff"][target.blessing_table["times"]+1]

    		if buff then	
			    buff:Destroy()
			end

		    ability:ApplyDataDrivenModifier(caster, target, blessing_table[index_1].modifier, {})
		    target.blessing_table["buff"] = blessing_table[index_1].modifier

			--发送祝福的激活情况
		    for i = 1, reset_times + 1 do
			    if i == target.blessing_table["times"] + 1 then
				    temp_str_buff = temp_str_buff.."<font color=\"#00FF00\">"..blessing_table[index_1].name_cn.."（已激活）</font> "
				else
				    local temp_index_1 = target.blessing_table["optional_buff"][i]
				    temp_str_buff = temp_str_buff.."<font color=\"#FF0000\">"..blessing_table[temp_index_1].name_cn.."（未激活）</font> "
                end
				if i ~= reset_times + 1 then
				    temp_str_buff = temp_str_buff.." "
				end
			end

		else
		    --没有祝福效果的情况下，出兵后只能使用一次
			GameRules:SendCustomMessage(PlayerResource:GetPlayerName(target:GetPlayerID()).. " : " .."<font color=\"#FFD700\">重置祝福失败，已开始游戏。</font> ", DOTA_TEAM_BADGUYS,0)
			return	    
		end	  

	end

	GameRules:SendCustomMessage(temp_str_buff, DOTA_TEAM_BADGUYS,0)

end

--加钱，送中立代币
function modifier_hero_blessing_bonus_gold_OnCreated(keys)
    if not IsServer() then return true end
    local target = keys.target	
	local ability = GameRules.Fun_DataTable["GameModeAbility"]
	local gold = ability:GetSpecialValueFor("bonus_gold")
	target:ModifyGold(gold, false, DOTA_ModifyGold_AbilityGold)
	--target:AddItemByName("item_tier1_token")
	SendOverheadEventMessage(target:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, target, gold, target:GetPlayerOwner()) 
end

--状态抗性
function modifier_hero_blessing_bonus_resistance_OnCreated(keys)
    if not IsServer() then return true end
    local target = keys.target
    local ability = GameRules.Fun_DataTable["GameModeAbility"]
	local caster = keys.caster

	ability:ApplyDataDrivenModifier(caster, target, "modifier_special_bonus_status_resistance", {})
end

function modifier_hero_blessing_bonus_resistance_OnDestroy(keys)
    if not IsServer() then return true end
    local target = keys.target
	local buff_table = target:FindAllModifiersByName("modifier_special_bonus_status_resistance")
    for _,v in pairs(buff_table) do 
	    if v:GetAbility() == GameRules.Fun_DataTable["GameModeAbility"] then
		    v:Destroy()
			return
		end
	end
end


--减蓝耗，KV失效，只能用官方修饰器代替
function modifier_hero_blessing_bonus_mana_cost_percent_OnCreated(keys)
    if not IsServer() then return true end
    local target = keys.target
    local ability = GameRules.Fun_DataTable["GameModeAbility"]
	local caster = keys.caster

	ability:ApplyDataDrivenModifier(caster, target, "modifier_special_bonus_mana_reduction", {})

end

function modifier_hero_blessing_bonus_mana_cost_percent_OnDestroy(keys)
    if not IsServer() then return true end
    local target = keys.target
	local buff_table = target:FindAllModifiersByName("modifier_special_bonus_mana_reduction")
    for _,v in pairs(buff_table) do 
	    if v:GetAbility() == GameRules.Fun_DataTable["GameModeAbility"] then
		    v:Destroy()
			return
		end
	end
end

--夜间顺畅视野
function modifier_hero_blessing_bonus_vision_OnIntervalThink(keys)
    if not IsServer() then return true end
    local target = keys.target
	local ability = GameRules.Fun_DataTable["GameModeAbility"]
	local caster = keys.caster

	if GameRules:IsDaytime() == false and not target:HasModifier("modifier_hero_blessing_bonus_vision_fly_vision") then
	    ability:ApplyDataDrivenModifier(caster, target, "modifier_hero_blessing_bonus_vision_fly_vision", {})
	elseif GameRules:IsDaytime() == true and target:HasModifier("modifier_hero_blessing_bonus_vision_fly_vision") then
	    target:RemoveModifierByName("modifier_hero_blessing_bonus_vision_fly_vision")
	end
end

function modifier_hero_blessing_bonus_vision_OnDestroy(keys)
    if not IsServer() then return true end
    local target = keys.target
	target:RemoveModifierByName("modifier_hero_blessing_bonus_vision_fly_vision")
end
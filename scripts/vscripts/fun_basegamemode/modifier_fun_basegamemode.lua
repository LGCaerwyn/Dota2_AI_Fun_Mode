
--[[

GameRules.Fun_DataTable = {

    GameModeCaster = hCaster
    GameModeAbility = hAbility
    Difficulty = dLevel
    hasHumanPlayer_Radiant = bHas
    hasHumanPlayer_Dire = bHas
    blessing_bonus_stats_stack = dCount
    blessing_AI_20Min = bHas
    blessing_AI_40Min = dCount
    blessing_AI_40Min_INT = bHas
    blessing_Both_60Min = bHas
    Listener_MegaCreeps = dListenerID
}

]]--

--试玩模式文件中GameMode的命名
if GameRules.isDemo == nil then
    if CHeroDemo == nil then
        _G.CHeroDemo = class({})
        GameRules.isDemo = false  --false代表本地房间
    else
        GameRules.isDemo = true    --true代表斧王岛
    end
end

require('timers')
require('fun_filter')
require('Fun_BaseGameMode/unit_data_table')
require('Fun_Items/item_fun_tome_of_aghanim')


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--天地星的基础设定，对人类和AI赋予不同的增益
function modifier_Fun_BaseGameMode(keys)

    if not IsServer() then return true end

    if keys.caster:GetTeam() ~= DOTA_TEAM_GOODGUYS then return end --只需要天辉的基地/泉水携带即可

    -----------------------------------------------------------------------------------------------    
    --加速模式 dota_turbo_game_mode
    --新手模式 dota_new_player_pool_game_mode
    --正常对战的本地房间不存在GameMode实例，GameRules:GetGameModeEntity()返回为nil，需要手动创建。
    --无论是普通还是加速模式，使用过滤器都需要新建gamemode
    -----------------------------------------------------------------------------------------------
    
    local gamemode = GameRules:GetGameModeEntity()

    if GameRules.isDemo == false then

        local gamemode = GameRules:GetGameModeEntity()
        local gamemode_name = nil 
        if gamemode then gamemode_name = gamemode:GetClassname() end
        
        if gamemode == nil then

            Entities:CreateByClassname("dota_base_game_mode")

        elseif gamemode_name == "dota_turbo_game_mode" then

            --gamemode:Destroy()
            --Entities:CreateByClassname("dota_turbo_game_mode")
            --gamemode:ClearModifyExperienceFilter()
            --gamemode:ClearModifyGoldFilter()
            --gamemode:Destroy()

            --Entities:CreateByClassname("dota_base_game_mode")
            --local new_mode = Entities:CreateByClassname("dota_turbo_game_mode")
            --print("快速")
        elseif gamemode_name == "dota_new_player_pool_game_mode"  then

            --Entities:CreateByClassname("dota_new_player_pool_game_mode")

        end

        --函数InitGameMode()的定义写在外部会影响大地图试玩模式的GameMode
        function CHeroDemo:InitGameMode()
            print("[天地星Fun] 创建GameMode实体")

            --新的GameMode会覆盖之前的设定
            GameRules:GetGameModeEntity():SetBotThinkingEnabled(true)
            GameRules:GetGameModeEntity():SetUseDefaultDOTARuneSpawnLogic(true)
            GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled(true)
        end

        GameRules.herodemo = CHeroDemo()
        GameRules.herodemo:InitGameMode()
    end

    if IsServer() then
            
        ---------------------------------------
        --延迟0.1秒执行，等待地图资源全部加载
        ---------------------------------------

        Timers:CreateTimer({

            endTime = 0.1,
            callback = function()
                
                if GameRules.Fun_DataTable == nil then
                    GameRules.Fun_DataTable = {}
                    GameRules.Fun_DataTable["GameModeCaster"] = keys.caster
                    GameRules.Fun_DataTable["GameModeAbility"] = keys.ability
                    GameRules.Fun_DataTable["Difficulty"] = keys.ability:GetSpecialValueFor("difficulty")
                    GameRules.Fun_DataTable["hasHumanPlayer_Radiant"] = false
                    GameRules.Fun_DataTable["hasHumanPlayer_Dire"] = false
                    GameRules.Fun_DataTable["blessing_bonus_stats_stack"] = 0
                    GameRules.Fun_DataTable["blessing_AI_20Min"] = false
                    GameRules.Fun_DataTable["blessing_AI_40Min_stack"] = 0
                    GameRules.Fun_DataTable["blessing_AI_40Min_INT"] = false
                    GameRules.Fun_DataTable["blessing_Both_60Min"] = false
                    GameRules.Fun_DataTable["Listener_MegaCreeps"] = nil             
                else
                    return
                end         

                --阵营分配

                modifier_Fun_BaseGameMode_TeamAssignment(keys)

                --调整建筑
            
                modifier_Fun_BaseGameMode_BuildingUpgraded(keys)

                --调整金钱经验奖励、注册过滤器Filter

                modifier_Fun_BaseGameMode_SetDifficulty(keys)

                --人类与AI的额外属性

                modifier_Fun_BaseGameMode_Blessing(keys)

                --AI超级兵升级

                modifier_Fun_BaseGameMode_MegaCreepsUpgraded(keys)

            end
        })
    end
    return
end

--判断此ID是否属于人类阵营
function is_Human_Team(playerID)
    local playerTeam = PlayerResource:GetTeam(playerID)
    return __is_Human_Team(playerTeam)
end

--判断此阵营是否是人类阵营
function __is_Human_Team(DOTATeam_t)
    if (DOTATeam_t == DOTA_TEAM_GOODGUYS and GameRules.Fun_DataTable["hasHumanPlayer_Radiant"] == true) or
       (DOTATeam_t == DOTA_TEAM_BADGUYS and GameRules.Fun_DataTable["hasHumanPlayer_Dire"] == true)
    then
        return true
    end   
    return false
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--1、根据本方是否存在人类玩家确定阵营类型（人类、AI）

function modifier_Fun_BaseGameMode_TeamAssignment(keys)
    if not IsServer() then return true end
    local total_player_count = PlayerResource:GetPlayerCount() 

    for playerID = 0, total_player_count - 1 do
     
        --------------------------------------------------------------------------------------------
        --机器人玩家的PlayerResource:IsFakeClient(playerID)返回值为true
        --------------------------------------------------------------------------------------------
        local playerTeam = PlayerResource:GetTeam(playerID)
        if not PlayerResource:IsFakeClient(playerID) then  --false  人类玩家
            if playerTeam == DOTA_TEAM_GOODGUYS and GameRules.Fun_DataTable["hasHumanPlayer_Radiant"] == false then
                GameRules.Fun_DataTable["hasHumanPlayer_Radiant"]  = true
            elseif playerTeam == DOTA_TEAM_BADGUYS and GameRules.Fun_DataTable["hasHumanPlayer_Dire"] == false then
                GameRules.Fun_DataTable["hasHumanPlayer_Dire"]  = true
            end
        end

    end

    return
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--2、根据阵营调整建筑属性和技能

function modifier_Fun_BaseGameMode_BuildingUpgraded(keys)
    if not IsServer() then return true end
    modifier_Fun_BaseGameMode_BuildingUpgraded_ForTeam(DOTA_TEAM_GOODGUYS)
    modifier_Fun_BaseGameMode_BuildingUpgraded_ForTeam(DOTA_TEAM_BADGUYS)
    return
end

function modifier_Fun_BaseGameMode_BuildingUpgraded_ForTeam(DOTATeam_t)
    if not IsServer() then return true end
    ----------------------------------------------------------------------------
    --根据hasHumanPlayer的值选择不同的调整方式
    --building_Data_for_player和building_Data_for_AI来自文件unit_data_table.lua
    ----------------------------------------------------------------------------
    
    local BuildingDataTable
    local location = GameRules.Fun_DataTable["GameModeCaster"]:GetOrigin()

    if __is_Human_Team(DOTATeam_t) then
        BuildingDataTable = building_Data_for_player
    else
        BuildingDataTable = building_Data_for_AI
    end

    local radius = -1  --全图范围：FIND_UNITS_EVERYWHERE = -1
    local units = FindUnitsInRadius(DOTATeam_t, location, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
    for i,unit in ipairs(units) do 

        local unitName = unit:GetUnitName()

        if unitName == "npc_dota_badguys_tower1_top" and __is_Human_Team(unit:GetTeam()) then
            unitName = "npc_dota_goodguys_tower1_bot" 
        elseif unitName == "npc_dota_badguys_tower1_bot" and __is_Human_Team(unit:GetTeam()) then
            unitName = "npc_dota_goodguys_tower1_top" 
        end

        for buildingName, buildingData in pairs(BuildingDataTable) do
            
            if next(buildingData) ~= nil and string.find (unitName, buildingName) then    
                
                ------------------------------------------------------------------------
                --调整建筑属性
                ------------------------------------------------------------------------

                if buildingData["HP"] > 0 then
                    unit:SetBaseMaxHealth(buildingData["HP"]) 
                    unit:SetHealth(buildingData["HP"])
                end
                if buildingData["MP"] > 0 then
                    unit:SetMaxMana(buildingData["MP"]) 
                    unit:SetMana(buildingData["MP"])  
                end
                if buildingData["Armor"] > 0      then unit:SetPhysicalArmorBaseValue(buildingData["Armor"])          end
                if buildingData["Resistance"] > 0 then unit:SetBaseMagicalResistanceValue(buildingData["Resistance"]) end
                if buildingData["HPRegen"] > 0    then unit:SetBaseHealthRegen(buildingData["HPRegen"])               end
                if buildingData["MPRegen"] > 0    then unit:SetBaseManaRegen(buildingData["MPRegen"])                 end
                
                ------------------------
                --添加技能
                ------------------------

                for k,v in pairs(buildingData["Abilities"]) do
                    local ability = unit:AddAbility(v)
                    if ability then
                        local maxlevel = ability:GetMaxLevel()
                        ability:SetLevel(maxlevel)
                    end
                end

            end
        end
    end
    return
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--3、调整AI的金钱经验奖励、注册自定义技能/物品的过滤器

function modifier_Fun_BaseGameMode_SetDifficulty(keys)
    if not IsServer() then return true end
    local starting_gold = keys.ability:GetSpecialValueFor("starting_gold")

    print("[天地星Fun] AI金钱经验倍率："..GameRules.Fun_DataTable["Difficulty"])
    print("[天地星Fun] AI初始金钱："..starting_gold)

    ------------------------
    --AI阵营的初始金钱奖励
    ------------------------
    local total_player_count = PlayerResource:GetPlayerCount()  
    for playerID = 0 , total_player_count - 1 do
        if not is_Human_Team(playerID) then
            PlayerResource:ModifyGold(playerID, starting_gold, true, DOTA_ModifyGold_Unspecified)
        end
    end

    -----------------------------
    --AI阵营的额外金钱、经验奖励
    -----------------------------

    GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(CHeroDemo, "ModifyGoldFilter"),  CHeroDemo)   --来自文件fun_filter.lua
    GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(CHeroDemo, "ModifyExperienceFilter"), CHeroDemo)  --来自文件fun_filter.lua
 
    -----------------------------------------------------------------
    --注册过滤器，涉及多个技能、物品的数值调整
    -----------------------------------------------------------------
    GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(CHeroDemo, "DamageFilter"),  CHeroDemo)
    --GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(CHeroDemo, "ExecuteOrderFilter"), CHeroDemo)  --涉及的技能不多，由其它地方开启
    --GameRules:GetGameModeEntity():SetAbilityTuningValueFilter(Dynamic_Wrap(CHeroDemo, "AbilityTuningValueFilter"), CHeroDemo)  --涉及的技能不多，由其它地方开启
    GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(CHeroDemo, "ModifierGainedFilter"), CHeroDemo) 
   -- GameRules:GetGameModeEntity():SetHealingFilter(Dynamic_Wrap(CHeroDemo, "HealingFilter"), CHeroDemo) --来自文件fun_filter.lua
    return
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--4、人类与AI随时间增长的额外属性

function modifier_Fun_BaseGameMode_Blessing(keys)

    if not IsServer() then return true end

    ListenToGameEvent("npc_spawned", Blessing_FixRespwanedHerosBonusStats, nil)
	ListenToGameEvent("game_rules_state_change", GameRulesStateChange, nil)  

    --Fun2024.9.28(正常5倍为2024.8.7)新增，修改AI哈斯卡的先天技能，待天地星脚本修复后删除
    ListenToGameEvent("npc_spawned", AI_Huskar_innate_ability_change, nil)

    Essence_Active() --启动回归本质，进入地图后开始计时，检测全员英雄的属性并提供额外效果
    return
end

function Blessing_FixRespwanedHerosBonusStats(eventInfo)
    if not IsServer() then return true end
    ---------------------------------------------------
    --在英雄/幻象第一次创建时计算三维增强和回归本质属性
    --英雄死亡期间未获得的增益在复活后获取
    ---------------------------------------------------

    local npc = EntIndexToHScript(eventInfo.entindex)

    if npc:IsHero() then

        --*****************
        Timers:CreateTimer({
            endTime = 0.1,
            callback = function()
                Blessing_Main(npc)
                Essence(npc)
            end
        })       
        --*****************

    else
        return 
    end 
    return
end

function GameRulesStateChange(eventInfo)
    if not IsServer() then return true end
    ---------------------------------------------------
    --出兵后开始计时，在指定时间为英雄添加增益效果
    ---------------------------------------------------
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then      
        Blessing_AddHerosBonusStats()
    end
    return
end

function Blessing_AddHerosBonusStats()    
      if not IsServer() then return true end
      Timers:CreateTimer(60,function()     
          GameRules.Fun_DataTable["blessing_bonus_stats_stack"] = math.floor(GameRules:GetDOTATime(false, false)/60)
          local total_player_count = PlayerResource:GetPlayerCount() 
          for playerID = 0, total_player_count - 1 do        
              local player = PlayerResource:GetPlayer(playerID)
              if player == nil then goto continue end
              local hero = player:GetAssignedHero()
              if hero == nil then goto continue end
              --*****************
              Blessing_Main(hero)
              --*****************
              ::continue::
          end
          return 60.0
      end
      )
      return
end

--启动回归本质，每0.2秒计算属性
function Essence_Active() 
    if not IsServer() then return true end
    Timers:CreateTimer(function() 
    
        local total_player_count = PlayerResource:GetPlayerCount() 
        for playerID = 0, total_player_count - 1 do           
            local player = PlayerResource:GetPlayer(playerID)
            if player == nil then break end  --试玩模式移除英雄时可能导致player为nil
            local hero = player:GetAssignedHero()
            if hero == nil then break end  --开始计时后有些英雄尚未出生
            --****************
            Essence(hero)
            --****************
        end
        return 0.2
    end
    )
end

--计算英雄hero的额外增益情况
function Blessing_Main(hero)
    if not IsServer() then return true end
    --if hero == nil then return end
    local modifier_temp = nil
    local modifier_temp_tooltip = nil
    local time_stacks = GameRules.Fun_DataTable["blessing_bonus_stats_stack"]
    local ability = GameRules.Fun_DataTable["GameModeAbility"]
    local caster = GameRules.Fun_DataTable["GameModeCaster"]
    --三维
    local modifier_BonusStats_Human_Tooltip = "modifier_Fun_BaseGameMode_Blessing_BonusStats_for_Human_Tooltip"
    local modifier_BonusStats_Human = "modifier_Fun_BaseGameMode_Blessing_BonusStats_for_Human"
    local modifier_BonusStats_AI_Tooltip = "modifier_Fun_BaseGameMode_Blessing_BonusStats_for_AI_Tooltip"   
    local modifier_BonusStats_AI = "modifier_Fun_BaseGameMode_Blessing_BonusStats_for_AI"  
    --额外增益
    local modifier_20Min_AI = "modifier_Fun_BaseGameMode_Blessing_20Min_for_AI"
    local modifier_30Min_AI = "modifier_Fun_BaseGameMode_Blessing_30Min_for_AI"
    local modifier_40Min_AI = "modifier_Fun_BaseGameMode_Blessing_40Min_for_AI"
    local modifier_60Min_AI = "modifier_Fun_BaseGameMode_Blessing_60Min_for_AI"
    local modifier_60Min_Human = "modifier_Fun_BaseGameMode_Blessing_60Min_for_Human"

    if __is_Human_Team(hero:GetTeam()) then 

        -------------------------------------------- 
        --人类阵容每分钟提供1点全属性
        -------------------------------------------- 
        modifier_temp = hero:FindModifierByName(modifier_BonusStats_Human) 
        modifier_temp_tooltip = hero:FindModifierByName(modifier_BonusStats_Human_Tooltip) 
        if modifier_temp_tooltip == nil then
            modifier_temp_tooltip = ability:ApplyDataDrivenModifier(caster, hero, modifier_BonusStats_Human_Tooltip, nil)         
        end
        if modifier_temp == nil and time_stacks >= 1 then
            modifier_temp = ability:ApplyDataDrivenModifier(caster, hero, modifier_BonusStats_Human, nil)   
        end
        if modifier_temp and modifier_temp:GetStackCount() ~= time_stacks then
            modifier_temp_tooltip:SetStackCount(time_stacks)
            modifier_temp:SetStackCount(time_stacks)
        end
        modifier_temp = nil
        modifier_temp_tooltip = nil

        -------------------------------------------- 
        --人类阵容60分钟获得一次属性增强
        -------------------------------------------- 
        modifier_temp = hero:FindModifierByName(modifier_60Min_Human) 
        if time_stacks >= 60 and modifier_temp == nil then
            ability:ApplyDataDrivenModifier(caster, hero, modifier_60Min_Human, nil)
            --****************************
            --此处完成阿哈利姆之书的学习
            --****************************
            --来自文件item_fun_tome_of_aghanim.lua
            item_fun_tome_of_aghanim_AbilityUpgrade(hero)
        end
        modifier_temp = nil

    --*************************************************************************************************************    

    elseif not __is_Human_Team(hero:GetTeam()) then   
        
        -------------------------------------------- 
        --AI阵容每分钟提供2点全属性
        -------------------------------------------- 
        modifier_temp = hero:FindModifierByName(modifier_BonusStats_AI) 
        modifier_temp_tooltip = hero:FindModifierByName(modifier_BonusStats_AI_Tooltip) 
        if modifier_temp_tooltip == nil then
            modifier_temp_tooltip = ability:ApplyDataDrivenModifier(caster, hero, modifier_BonusStats_AI_Tooltip, nil)         
        end
        if modifier_temp == nil and time_stacks >= 1 then
            modifier_temp = ability:ApplyDataDrivenModifier(caster, hero, modifier_BonusStats_AI, nil)   
        end
        if modifier_temp and modifier_temp:GetStackCount() ~= time_stacks then
            modifier_temp_tooltip:SetStackCount(time_stacks)
            modifier_temp:SetStackCount(time_stacks)
        end
        modifier_temp = nil
        modifier_temp_tooltip = nil

        -------------------------------------------- 
        --AI阵容20分钟获得一次属性增强
        --学习阿哈利姆之书技能并减少复活时间
        -------------------------------------------- 
        modifier_temp = hero:FindModifierByName(modifier_20Min_AI) 
        if time_stacks >= 20 and modifier_temp == nil then
            ability:ApplyDataDrivenModifier(caster, hero, modifier_20Min_AI, nil)
            --****************************
            --此处完成阿哈利姆之书的学习
            --****************************
            --来自文件item_fun_tome_of_aghanim.lua
            item_fun_tome_of_aghanim_AbilityUpgrade(hero)
        end
        modifier_temp = nil

        -------------------------------------------- 
        --AI阵容30分钟获得一次属性增强
        --攻击必中
        -------------------------------------------- 
        modifier_temp = hero:FindModifierByName(modifier_30Min_AI) 
        if time_stacks >= 30 and modifier_temp == nil then
            ability:ApplyDataDrivenModifier(caster, hero, modifier_30Min_AI, nil)
        end
        modifier_temp = nil

        -------------------------------------------- 
        --AI阵容40分钟获得可叠加的属性增强
        --每10分钟获得生命值和护甲
        -------------------------------------------- 
        modifier_temp = hero:FindModifierByName(modifier_40Min_AI)       
        if time_stacks >= 40 and modifier_temp == nil then
            modifier_temp = ability:ApplyDataDrivenModifier(caster, hero, modifier_40Min_AI, nil)
            --modifier_temp:SetStackCount(0)
            
            --*******************************************
            --其他人玩的时候送AI神杖，临时添加，用到直播时的AI文件就取消
            local scepter_AI = hero:FindItemInInventory("item_fun_Aghanims_Scepter_AI")
            --local has_GidDou = false
            if scepter_AI == nil and 
               GameRules.isDemo == false and
               PlayerResource:GetSteamAccountID(0) ~= 396784731 and
               hero:IsRealHero() 
            then
                hero:AddItemByName("item_fun_Aghanims_Scepter_AI")
                GameRules:SendCustomMessage("40分钟时：附赠<font color=\"#FF0000\">AI的阿哈利姆神杖</font> ", DOTA_TEAM_BADGUYS,0)
            end
            --*******************************************
        end
        local AI_40Min_stack = math.floor(time_stacks/10) - 3
        if modifier_temp then
            if modifier_temp:GetStackCount() ~= AI_40Min_stack then       
                modifier_temp:SetStackCount(AI_40Min_stack)
            end
        end    
        modifier_temp = nil

        -------------------------------------------- 
        --AI阵容60分钟获得一次属性增强
        -------------------------------------------- 
        modifier_temp = hero:FindModifierByName(modifier_60Min_AI)
        if time_stacks >= 60 and modifier_temp == nil then
            ability:ApplyDataDrivenModifier(caster, hero, modifier_60Min_AI, nil)
        end
        modifier_temp = nil

    end

end

--回归本质
function Essence(hero)
    if not IsServer() then return true end
    --回归本质
    local modifier_Essence_Tooltip = "modifier_Fun_BaseGameMode_Essence_Tooltip"
    local modifier_Essence_STRENGTH = "modifier_Fun_BaseGameMode_Essence_STRENGTH"
    local modifier_Essence_AGILITY = "modifier_Fun_BaseGameMode_Essence_AGILITY"
    local modifier_Essence_INTELLIGENCE = "modifier_Fun_BaseGameMode_Essence_INTELLIGENCE"

    local caster = GameRules.Fun_DataTable["GameModeCaster"]
    local ability = GameRules.Fun_DataTable["GameModeAbility"]
    local stack_STR = 0
    local stack_AGI = 0
    local stack_INT = 0
 
    local modifier_tooltip = hero:FindModifierByName(modifier_Essence_Tooltip)
    local modifier_STR = hero:FindModifierByName(modifier_Essence_STRENGTH)
    local modifier_AGI = hero:FindModifierByName(modifier_Essence_AGILITY)
    local modifier_INT = hero:FindModifierByName(modifier_Essence_INTELLIGENCE)
            -----------------------------------
    if modifier_tooltip == nil then
        ability:ApplyDataDrivenModifier(caster, hero, modifier_Essence_Tooltip, nil)
    end

    if hero:GetStrength() <= 0 and modifier_STR ~= nil then
        modifier_STR:Destroy()
    elseif hero:GetStrength() > 0 and modifier_STR == nil then
        modifier_STR = ability:ApplyDataDrivenModifier(caster, hero, modifier_Essence_STRENGTH, nil)
    end

    if hero:GetAgility() <= 0 and modifier_AGI ~= nil then
        modifier_AGI:Destroy()
    elseif hero:GetAgility() > 0 and modifier_AGI == nil then
        modifier_AGI = ability:ApplyDataDrivenModifier(caster, hero, modifier_Essence_AGILITY, nil)
    end

    if hero:GetIntellect(false) <= 0 and modifier_INT ~= nil then
        modifier_INT:Destroy()
    elseif hero:GetIntellect(false) > 0 and modifier_INT == nil then
        modifier_INT = ability:ApplyDataDrivenModifier(caster, hero, modifier_Essence_INTELLIGENCE, nil)
    end
    -----------------------------------
    --每点力量提供魔法抗性，增加0.08%有效生命值，力量英雄提升25%
    --每点敏捷提供0.12定值移动速度，敏捷英雄提升25%
    --每点智力提供0.08%技能增强，智力英雄提升25%
    --全才英雄所有属性都能提供魔法抗性、移速、技能增强，但只有基础设定的35%效果

    local total_attribute = hero:GetStrength() + hero:GetAgility() + hero:GetIntellect(false)

    if modifier_STR then
        if hero:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
            stack_STR = 10000 * hero:GetStrength() * 0.1 / (100 + hero:GetStrength() * 0.1) 
        elseif hero:GetPrimaryAttribute() == DOTA_ATTRIBUTE_ALL then
            stack_STR = 10000 * total_attribute * 0.028 / (100 + total_attribute * 0.028)  
        else
            stack_STR = 10000 * hero:GetStrength() * 0.08 / (100 + hero:GetStrength() * 0.08)  
        end
        stack_STR = math.floor(stack_STR)
        if modifier_STR:GetStackCount() ~= stack_STR then
            modifier_STR:SetStackCount(stack_STR)
        end
    end

    if modifier_AGI then

        local ConstantValueSpeed = hero:GetAgility() * 0.12
        if hero:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
            stack_AGI = math.floor(ConstantValueSpeed * 12.5)  --系数是12.5 = 1.25 / 0.1（0.1是KV修饰器中每层移动速度的数量）
        elseif hero:GetPrimaryAttribute() == DOTA_ATTRIBUTE_ALL then
            ConstantValueSpeed = total_attribute * 0.35
            stack_AGI = math.floor(ConstantValueSpeed * 3.5)    --系数是3.5 = 0.35 / 0.1（0.1是KV修饰器中每层移动速度的数量）
        else
            stack_AGI = math.floor(ConstantValueSpeed * 10)    --系数是10 = 1 / 0.1（0.1是KV修饰器中每层移动速度的数量）
        end
        if modifier_AGI:GetStackCount() ~= stack_AGI then
            modifier_AGI:SetStackCount(stack_AGI)
        end
    end

    if modifier_INT then
        if hero:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLIGENCE then
            stack_INT = math.floor(hero:GetIntellect(false) * 10)  --系数是10 = 1.25 * 0.08 / 0.01（0.01是KV修饰器中每层技能增强的数量） 
        elseif hero:GetPrimaryAttribute() == DOTA_ATTRIBUTE_ALL then
            stack_INT = math.floor(total_attribute * 2.8)   --系数是2.8 = 0.35 * 0.08 / 0.01（0.01是KV修饰器中每层技能增强的数量）
        else
            stack_INT = math.floor(hero:GetIntellect(false) * 8)  --系数是8 = 0.08 / 0.01（0.01是KV修饰器中每层技能增强的数量）
        end
        if modifier_INT:GetStackCount() ~= stack_INT then
            modifier_INT:SetStackCount(stack_INT)
        end           
    end

    -------------------------------------------------------------------------------------------
    --为AI添加中立物品，删除暂停等原因获得的异常物品
    modifier_Fun_BaseGameMode_neutral_items_for_AI(hero)
    -------------------------------------------------------------------------------------------

    return
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--5、AI方超级兵获得额外升级

function modifier_Fun_BaseGameMode_MegaCreepsUpgraded(keys)
    --print("修改超级兵属性")
    --ListenToGameEvent("dota_super_creeps",MegaCreepsCreated,nil)  
    if not IsServer() then return true end
    ListenToGameEvent("npc_spawned", MegaCreepsUpgraded, nil)
end

function MegaCreepsCreated(eventInfo)
    if not IsServer() then return true end
    --print("超级兵")
    if GameRules.Fun_DataTable["Listener_MegaCreeps"] ~= nil then return end
    if not __is_Human_Team(eventInfo.teamnumber) then
        local listenerID = ListenToGameEvent("npc_spawned", MegaCreepsUpgraded, nil)
        GameRules.Fun_DataTable["Listener_MegaCreeps"] = listenerID
    end
end

function MegaCreepsUpgraded(eventInfo)
    if not IsServer() then return true end
    local npc = EntIndexToHScript(eventInfo.entindex)
    local npcTeam = npc:GetTeam()
    local npcName = npc:GetUnitName()

    ----------------------------------------------------
    --调整AI超级兵属性
    --MegaCreeps_Data_for_AI来自文件unit_data_table.lua
    ----------------------------------------------------
    
    if __is_Human_Team(npcTeam) then return end
    
    for CreepsName, CreepsData in pairs(MegaCreeps_Data_for_AI) do
        
        if next(CreepsData) ~= nil and string.find(npcName, CreepsName) then

          
            if CreepsData["MP"] > 0 then
                npc:SetMaxMana(CreepsData["MP"]) 
                npc:SetMana(CreepsData["MP"])  
            end                
            if CreepsData["Armor"] > 0          then npc:SetPhysicalArmorBaseValue(CreepsData["Armor"])          end
            if CreepsData["Resistance"] > 0     then npc:SetBaseMagicalResistanceValue(CreepsData["Resistance"]) end
            if CreepsData["HPRegen"] > 0        then npc:SetBaseHealthRegen(CreepsData["HPRegen"])               end
            if CreepsData["MPRegen"] > 0        then npc:SetBaseManaRegen(CreepsData["MPRegen"])                 end
            if CreepsData["BaseDamageMin"] > 0  then npc:SetBaseDamageMin(CreepsData["BaseDamageMin"])           end
            if CreepsData["BaseDamageMax"] > 0  then npc:SetBaseDamageMax(CreepsData["BaseDamageMax"])           end
            if CreepsData["ModelScale"] > 0     then npc:SetModelScale(CreepsData["ModelScale"])                 end
            if CreepsData["HP"] > 0 then
                npc:SetMaxHealth(CreepsData["HP"]) 
                npc:SetHealth(CreepsData["HP"])               
            end

            break
        end   
    end

    return
end

--将AI身上的代币随机替换为同级的中立物品
--删除AI因为暂停等原因获得的异常物品
function modifier_Fun_BaseGameMode_neutral_items_for_AI(hero)
    if not IsServer() then return true end
    --此功能不会在斧王岛上运行
    if GameRules.isDemo == true then return end
    
    local playerID = hero:GetPlayerID()
    if PlayerResource:IsFakeClient(playerID) then

        local item_tier1_token = hero:FindItemInInventory("item_tier1_token")
        local item_tier2_token = hero:FindItemInInventory("item_tier2_token")
        local item_tier3_token = hero:FindItemInInventory("item_tier3_token")
        local item_tier4_token = hero:FindItemInInventory("item_tier4_token")
        local item_tier5_token = hero:FindItemInInventory("item_tier5_token")

        --总是删除AI身上的代币
        if item_tier1_token then 
            item_tier1_token:Destroy()
        end
        if item_tier2_token then 
            item_tier2_token:Destroy()
        end
        if item_tier3_token then 
            item_tier3_token:Destroy()
        end
        if item_tier4_token then 
            item_tier4_token:Destroy()
        end
        if item_tier5_token then 
            item_tier5_token:Destroy()
        end

        --AI的BUG：会不停地捡起地上的中立物品。
        --将身上低级和多余的中立物品删除，给予最新等级的中立物品
        local time_stacks = GameRules.Fun_DataTable["blessing_bonus_stats_stack"]
        local slot_min = 6 --第一个背包的编号
        local slot_max = 16  --中立物品栏的编号，只搜索6-17号的物品栏
        if time_stacks < 7 then

            --7分钟以内，背包、储藏室、中立物品栏内所有等级的中立物品都会被摧毁
            for i = 6, 16 do
               local item_t = hero:GetItemInSlot(i)
               if item_t then
                   if item_t:IsNeutralActiveDrop() then
                       hero:RemoveItem(item_t)
                   end
               end
            end

        elseif time_stacks >= 7 and time_stacks < 17 then

            --7到17分钟只能装备1级中立物品
            neutral_items_gained_for_AI(hero, 1)

        elseif time_stacks >= 17 and time_stacks < 27 then

            --17到27分钟只能装备2级中立物品
            neutral_items_gained_for_AI(hero, 2)

        elseif time_stacks >= 27 and time_stacks < 37 then

            --27到37分钟只能装备3级中立物品
            neutral_items_gained_for_AI(hero, 3)

        elseif time_stacks >= 37 and time_stacks < 62 then

            --37到62分钟只能装备4级中立物品
            neutral_items_gained_for_AI(hero, 4)

        elseif time_stacks >= 62 then --5级中立物品出现晚一些

            --62分钟以后只能装备5级中立物品
            neutral_items_gained_for_AI(hero, 5)

        end

        --AI的BUG二：暂停后会购买吃树、大药等物品
        --将其删除并返还对应的金钱
        if time_stacks >= 10 then

            for i = 0, 14 do --14是最后一个储藏室的编号
               local item_t = hero:GetItemInSlot(i)
               if item_t then
                   local item_t_name = item_t:GetName()
                   local item_t_cost = item_t:GetCost()
                   --local item_t_buyer = item_t:GetPurchaser()
                   --local item_t_time = item_t:GetPurchaseTime()
                   for _, v in pairs(item_black_list_for_AI) do
                       if v == item_t_name then
                           if v ~= "item_fun_trident_three_phase_power" then 
                               hero:ModifyGold(item_t_cost, false, DOTA_ModifyGold_SellItem) --三叉戟不还钱
                           end
                           hero:RemoveItem(item_t)
                           break
                       end
                   end
               end
            end           
        end
    end

end

--将AI身上的中立物品固定在某个等级，并清除其它中立物品
function neutral_items_gained_for_AI(hero, item_lvl)
    if not IsServer() then return true end
    for i = 6, 16 do
        local item_t = hero:GetItemInSlot(i)
        if i == 16 and item_t == nil then
            
            local string = { "item_tier", item_lvl }
            local item_tier = table.concat(string)           
            local length = #neutral_items[item_tier]
            local randomIndex = math.random(length)
            local ItemName = neutral_items[item_tier][randomIndex]
            if ItemName == "item_ballista" and 
               hero:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK and
               hero:FindAbilityByName("dragon_knight_elder_dragon_form") == nil and
               hero:FindAbilityByName("terrorblade_metamorphosis") == nil and 
               hero:FindAbilityByName("troll_warlord_berserkers_rage") == nil
            then
                repeat
                    randomIndex = math.random(length)
                    ItemName = neutral_items[item_tier][randomIndex]
                until( ItemName ~= "item_ballista" )
            end
            hero:AddItemByName(ItemName) 
            
        elseif i == 16 and item_t ~= nil then
            if get_neutral_items_lvl(item_t) ~= item_lvl then

                hero:RemoveItem(item_t)
                local string = { "item_tier", item_lvl}
                local item_tier = table.concat(string)           
                local length = #neutral_items[item_tier]
                local randomIndex = math.random(length)
                local ItemName = neutral_items[item_tier][randomIndex]
                if ItemName == "item_ballista" and --某些能变身为远程的近战英雄会获得弩炮
                   hero:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK and
                   hero:FindAbilityByName("dragon_knight_elder_dragon_form") == nil and
                   hero:FindAbilityByName("terrorblade_metamorphosis") == nil and 
                   hero:FindAbilityByName("troll_warlord_berserkers_rage") == nil
                then
                    repeat
                        randomIndex = math.random(length)
                        ItemName = neutral_items[item_tier][randomIndex]
                    until( ItemName ~= "item_ballista" )
                end
                hero:AddItemByName(ItemName) 
            end
        elseif i ~= 16 and item_t then
            if item_t:IsNeutralDrop() then
                hero:RemoveItem(item_t)
            end
        end
    end
end

--查询中立物品等级，与表neutral_items有关，和实际游戏内无关
function get_neutral_items_lvl(Item)
    
    if Item == nil then 
        return -1 
    end
    if not Item:IsNeutralDrop() then
        return 0 
    end

    for _,v in pairs(neutral_items.item_tier1) do
        if v == Item:GetAbilityName() then
            return 1
        end
    end
    for _,v in pairs(neutral_items.item_tier2) do
        if v == Item:GetAbilityName() then
            return 2
        end
    end
    for _,v in pairs(neutral_items.item_tier3) do
        if v == Item:GetAbilityName() then
            return 3
        end
    end
    for _,v in pairs(neutral_items.item_tier4) do
        if v == Item:GetAbilityName() then
            return 4
        end
    end
    for _,v in pairs(neutral_items.item_tier5) do
        if v == Item:GetAbilityName() then
            return 5
        end
    end
    return 0 
end


neutral_items = {

    item_tier1 = {
			--"item_keen_optic",
			"item_trusty_shovel",
			"item_arcane_ring",	
			--"item_possessed_mask",
			--"item_mysterious_hat",
			"item_unstable_wand",
			--"item_pogo_stick",						
			"item_safety_bubble",
			"item_seeds_of_serenity",
			"item_lance_of_pursuit",
			"item_occult_bracelet",
			"item_duelist_gloves",

			--"item_ocean_heart",
			"item_broom_handle",
			--"item_chipped_vest",

			--"item_royal_jelly",
			"item_faded_broach",
			--"item_ironwood_tree",
			"item_spark_of_courage",
    },
    item_tier2 = {
			--"item_ring_of_aquila",
			--"item_imp_claw",
			--"item_nether_shawl",
			"item_dragon_scale",
			"item_whisper_of_the_dread",	
			"item_pupils_gift",			
			--"item_misericorde",				
			"item_grove_bow",				 
			"item_philosophers_stone",				
			--"item_essence_ring",				
			--"item_paintball",				
			"item_bullwhip",			  
			--"item_quicksilver_amulet",				
			--"item_dagger_of_ristul",			
			"item_orb_of_destruction",		
			"item_specialists_array",			
			"item_eye_of_the_vizier",				
			"item_vampire_fangs",				  
			--"item_blighted_spirit",				  
			"item_gossamer_cape",				  
			"item_light_collector",		
            --"item_claddish_spyglass",
            "item_iron_talon",			
    },
    item_tier3 = {
			--"item_quickening_charm",			  
			"item_defiant_shell",	
            "item_vambrace",
			--"item_black_powder_bag",				  
			--"item_spider_legs",				  
			--"item_icarus_wings",					
			"item_paladin_sword",			  
			"item_nemesis_curse",			  
			"item_vindicators_axe",			  
			"item_dandelion_amulet",			 
			--"item_orb_of_destruction",		  
			--"item_titan_sliver",				  
			"item_craggy_coat",					
			"item_enchanted_quiver",			
			"item_elven_tunic",				  	
			"item_cloak_of_flames",				
			"item_ceremonial_robe",				
			"item_psychic_headband",			
			--"item_slime_vial",									
			--"item_quicksilver_amulet",			
			--"item_essence_ring",				 
			--"item_doubloon",			
    },
    item_tier4 = {
			"item_timeless_relic",		
			--"item_spell_prism",			
			"item_ascetic_cap",				
			"item_avianas_feather",				
			
			--"item_heavy_blade",				
			--"item_flicker",					
			"item_ninja_gear",				
			--"item_illusionsts_cape",		
			--"item_fortitude_ring",			 
			--"item_the_leveller",				
			--"item_minotaur_horn",			
			"item_spy_gadget",				 
			"item_trickster_cloak",			  
			"item_stormcrafter",			  
			--"item_penta_edged_sword",		 
			"item_ancient_guardian",		 
			"item_havoc_hammer",				
			
			--"item_princes_knife",			
			--"item_harpoon",					
			--"item_barricade",			  	 
			
			--"item_horizons_equilibrium",			 
			"item_mind_breaker",			  
			--"item_martyrs_plate",			  
			"item_rattlecage",		
            "item_ogre_seal_totem",		
    },
    item_tier5 = {
			"item_force_boots",				  
			"item_desolator_2",				  
			"item_seer_stone",				  
			"item_mirror_shield",			  	  
			"item_apex",				  
			"item_ballista",					  
			"item_demonicon",				  
			--"item_fallen_sky",		  	  
			"item_force_field",				  
			"item_pirate_hat",				  
			--"item_ex_machina",				  
			"item_giants_ring",				  
			"item_unwavering_condition",				  
			--"item_vengeances_shadow",				  
			"item_book_of_shadows",			  
			--"item_manacles_of_power",		
			--"item_bottomless_chalice",	
			--"item_wand_of_sanctitude",		
			"item_panic_button",			
    }
}

--10分钟后删除列表内AI拥有的物品
item_black_list_for_AI = 
{
    "item_flask",
    "item_tango",
    "item_tango_single",
    "item_clarity",
    "item_branches",
    "item_faerie_fire",
    "item_magic_stick",
    "item_recipe_magic_wand",
    --"item_fun_trident_three_phase_power",
    "item_aghanims_shard",
    "item_aghanims_shard_roshan",
}

--正常5倍于2024.8.7新增，更换哈斯卡的先天技能
function AI_Huskar_innate_ability_change(eventInfo)
    if not IsServer() then return true end
    local npc = EntIndexToHScript(eventInfo.entindex)
    local npcName = npc:GetUnitName()

    if npcName == "npc_dota_hero_huskar" then 
        local playerID = npc:GetPlayerID()
        if PlayerResource:IsFakeClient(playerID) then
            local innate_ability = npc:FindAbilityByName("huskar_blood_magic")
            if innate_ability then
                local index = innate_ability:GetAbilityIndex()
                npc:RemoveAbilityByHandle(innate_ability)
                local new_innate = npc:AddAbility("ogre_magi_dumb_luck")
                new_innate:SetLevel(1)
                new_innate:SetAbilityIndex(index)
                
                Timers:CreateTimer({

                    endTime = 0.1,
                    callback = function()
                        local max_mana = npc:GetMaxMana()
                        npc:SetMana(max_mana)
                    end
                })
            end
        end
    end

    return	
end
--���й��������ļ�'Fun_BaseGameMode/modifier_Fun_BaseGameMode.lua'��ע��
require('utils')  --��Ҫ�õ� is_Human_Team()
require('Fun_Items/item_fun_greater_mango')
require('Fun_Items/item_fun_spirit_vessel')
--require('Fun_Items/item_fun_Aghanims_Robe')
require('Fun_Boss/Fun_Primal_Beast_Boss_Defense')
require('fun_heroes/hero_lina/lina_laguna_blade_fun')
require('fun_heroes/hero_antimage/ant_fashufangzhi')
require('fun_heroes/hero_drow_ranger/marksmanship_fun')
require('fun_heroes/hero_faceless_void/faceless_void_fun')
require('fun_heroes/hero_wisp/wisp_overcharge_fun')
require('fun_heroes/hero_void_spirit/wuyingzhan')
require('Fun_BaseGameMode/modifier_Fun_BaseGameMode_Remove_Scepter_Consumed')

--CHeroDemo:ModifyGoldFilter
--CHeroDemo:ModifyExperienceFilter
--CHeroDemo:DamageFilter
--CHeroDemo:ModifierGainedFilter
--CHeroDemo:ExecuteOrderFilter
--CHeroDemo:AbilityTuningValueFilter
--CHeroDemo:HealingFilter

--*************************************************************************
--	ModifyGoldFilter
--  *player_id_const
--	*reason_const
--	*reliable
--	*gold
--*************************************************************************

function CHeroDemo:ModifyGoldFilter(event)
    
    --------------------------------------
    --Fun_BaseGameMode
    --����AI��ȡ�Ľ�Ǯ����
    --------------------------------------
    local difficulty = GameRules.Fun_DataTable["Difficulty"]
    if not is_Human_Team(event.player_id_const) then
        if (event.reason_const == DOTA_ModifyGold_CreepKill or event.reason_const == DOTA_ModifyGold_NeutralKill) and
           event.reliable == 0
        then
            event.gold = event.gold * difficulty
        end
    else
        if event.reason_const == DOTA_ModifyGold_HeroKill

        then
            event.gold = event.gold * 1
        end       
    end

    return true
end

--*************************************************************************
--	ModifyExperienceFilter
--  *hero_entindex_const
--	*player_id_const
--	*reason_const
--	*experience
--*************************************************************************

function CHeroDemo:ModifyExperienceFilter(event)

    --------------------------------------
    --Fun_BaseGameMode
    --����AI��ȡ�ľ��齱��
    --------------------------------------
    local difficulty = GameRules.Fun_DataTable["Difficulty"]
    if not is_Human_Team(event.player_id_const) then
        if event.reason_const == DOTA_ModifyXP_CreepKill then 
            event.experience = event.experience * difficulty
        end
    
    else
        if event.reason_const == DOTA_ModifyXP_HeroKill then 
            event.experience = event.experience * 1
        end       
    end

    return true
end


--*************************************************************************
--	DamageFilter
--  *entindex_victim_const
--	*entindex_attacker_const
--	*entindex_inflictor_const
--	*damagetype_const
--	*damage
--*************************************************************************

function CHeroDemo:DamageFilter(event)

    if not IsServer() then return true end

    --print("index��"..event.entindex_inflictor_const)
    --local inflictor = EntIndexToHScript(event.entindex_inflictor_const)
    --print("ClassName��"..inflictor:GetClassname())
    --print("Name��"..inflictor:GetName())
    --print(event.damage)

    --***************************************************
    --�˺�����˳��
    --    ��ͨ�ķ�������
    --    ����Դ�����޵�����
    --    ���â��  
    --    �F���������
    --    ������ķ�ĳ��ۣ��ݲ����룩
    --***************************************************
    local result = true
    local original_damage = event.damage

    ----------------------------------------------
    --��ͨ�ķ������ƣ�antimage_mana_defend
    --�ļ���fun_heroes/hero_antimage/ant_fashufangzhi.lua
    ----------------------------------------------
    result = antimage_mana_defend_DamageFilter(event, original_damage) 

    ----------------------------------------------
    --����֮��Ğ���Դ���������������Ч������void_spirit_wuyingzhan
    --�ļ���fun_heroes/hero_void_spirit/wuyingzhan.lua
    ----------------------------------------------
    result = void_spirit_wuyingzhan_DamageFilter(event, original_damage) 

    ----------------------------------------------
    --���â����item_fun_greater_mango
    --�ļ���Fun_Items/item_fun_greater_mango.lua
    ----------------------------------------------
    result = item_fun_greater_mango_DamageFilter(event, original_damage)

    ----------------------------------------------
    --�ʰ�֮�ѣ�wisp_overcharge_fun
    --�ļ���fun_heroes/hero_wisp/wisp_overcharge_fun.lua
    ----------------------------------------------
    result = wisp_overcharge_fun_DamageFilter(event, original_damage) 

    ---------------------------------------------------
    --�F�����������Fun_Primal_Beast_Boss_Defense
    --�ļ���Fun_Boss/Fun_Primal_Beast_Boss_Defense.lua
    ---------------------------------------------------
    result = Fun_Primal_Beast_Boss_Defense_DamageFilter(event)

    ---------------------------------------------------
    --������ķ�ĳ��ۣ�item_fun_Aghanims_Robe
    --�ļ���Fun_Items/item_fun_Aghanims_Robe.lua
    ---------------------------------------------------
    --result = true

    if type(result) ~= "boolean" then
        result = true
    end
    return result

end

--*************************************************************************
--	ModifierGainedFilter
--  *entindex_parent_const
--	*entindex_ability_const
--	*entindex_caster_const
--	*name_const
--	*duration
--*************************************************************************

function CHeroDemo:ModifierGainedFilter(event)

    if not IsServer() then return true end

    local result = true

    local parent = nil
    local ability = nil
    local caster = nil

    if event.entindex_parent_const then parent = EntIndexToHScript(event.entindex_parent_const) end
    if event.entindex_ability_const then ability = EntIndexToHScript(event.entindex_ability_const) end
    if event.entindex_caster_const then caster = EntIndexToHScript(event.entindex_caster_const) end

    ----------------------------------------------
    --�F�����������Fun_Primal_Beast_Boss_Defense
    ----------------------------------------------
    --result = Fun_Primal_Beast_Boss_Defense_ModifierGainedFilter(event)

    ----------------------------------------------
    --����֮��Ğ���Դ������������Ч������void_spirit_wuyingzhan
    --�ļ���fun_heroes/hero_void_spirit/wuyingzhan.lua
    ----------------------------------------------
    result = void_spirit_wuyingzhan_ModifierGainedFilter(event)

    ----------------------------------------------
    --��ŷ���ʰ�֮�ѣ�wisp_overcharge_fun
    --�ļ���fun_heroes/hero_wisp/wisp_overcharge_fun.lua
    ----------------------------------------------
    result = wisp_overcharge_fun_ModifierGainedFilter(event)

    ----------------------------------------------
    --��ռ����ʱ�����츳��special_bonus_unique_faceless_void_chronosphere_non_disabled
    ----------------------------------------------
    result = faceless_void_fun_ModifierGainedFilter(event, result)

    ----------------------------------------------
    --����¡��ĸ���A��BUFF�滻Ϊ��ͨ�棺Fun_BaseGameMode
    --�ļ���Fun_BaseGameMode/modifier_Fun_BaseGameMode.lua
    ----------------------------------------------
    result = modifier_Fun_BaseGameMode_Remove_Scepter_Consumed(event, result) 

    if type(result) ~= "boolean" then
        result = true
    end
    return result

end

--*************************************************************************
--	ExecuteOrderFilter
--  *player_id_const
--	*units: { [string]: EntityIndex }
--	*entindex_target
--	*entindex_ability
--	*issuer_player_id_const
--	*sequence_number_const
--	*queue
--	*order_type
--	*position_x
--	*position_y
--	*position_z
--	*shop_item_name
--*************************************************************************

function CHeroDemo:ExecuteOrderFilter(event)

    if not IsServer() then return true end

    local result = true 

    ---------------------------------------------------
    --�F�����������Fun_Primal_Beast_Boss_Defense
    --�ļ���Fun_Boss/Fun_Primal_Beast_Boss_Defense.lua
    ---------------------------------------------------
    result = Fun_Primal_Beast_Boss_Defense_ExecuteOrderFilter(event)

    if type(result) ~= "boolean" then
        result = true
    end
    return result

end

--*************************************************************************
--	AbilityTuningValueFilter
--  *entindex_caster_const
--	*entindex_ability_const
--	*value_name_const
--	*value
--*************************************************************************

function CHeroDemo:AbilityTuningValueFilter(event)

    if not IsServer() then return false end

    --��֡���أ���ʱ�ر�

    local result = false 

    local caster = nil
    local ability = nil
    local ability_name = nil

    if event.entindex_caster_const then caster = EntIndexToHScript(event.entindex_caster_const) end
    if event.eentindex_ability_const then ability = EntIndexToHScript(event.entindex_ability_const) end

    if ability then
        ability_name = ability:GetName()
    end

    if ability_name == "drow_ranger_frost_arrows" then

        ---------------------------------------------------
        --׿����������Ӱ���drow_ranger_marksmanship_fun
        --�ļ���fun_heroes/hero_drow_ranger/marksmanship_fun.lua
        ---------------------------------------------------
        result = drow_ranger_marksmanship_fun_AbilityTuningValueFilter(event)

    else
        result = false
    end

    if type(result) ~= "boolean" then
        result = false
    end

    return result
end

--*************************************************************************
--	HealingFilter
--  *entindex_target_const
--	*entindex_inflictor_const
--	*entindex_healer_const
--	*heal
--*************************************************************************

function CHeroDemo:HealingFilter(event)

    if not IsServer() then return true end

    local result = true 

    ---------------------------------------------------
    --���귨����item_fun_spirit_vessel
    --�ļ���Fun_Items/item_fun_spirit_vessel.lua
    ---------------------------------------------------
    result = item_fun_spirit_vessel_debuff_HealingFilter(event)

    if type(result) ~= "boolean" then
        result = true
    end
    return result

end
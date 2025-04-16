
--初始化
function Fun_Primal_Beast_Boss_Defense_OnCreated(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = keys.caster
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_aghsfort_primal_beast_no_cc", nil)

    GameRules:GetGameModeEntity():ClearExecuteOrderFilter()
    GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(CHeroDemo, "ExecuteOrderFilter"), CHeroDemo) 
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--死亡时清除基地提供的光环
function Fun_Primal_Beast_Boss_Defense_OnDeath(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    
    --aura_ally、aura_enemy在Fun_Primal_Beast_in_Cage.lua中添加
    if caster.aura_ally then 
        caster.aura_ally:Destroy()
        caster.aura_ally = nil
    end

    if caster.aura_enemy then 
        caster.aura_enemy:Destroy()
        caster.aura_enemy = nil
    end
    GameRules:GetGameModeEntity():ClearExecuteOrderFilter()
end

--在fun_filter.lua中存在关联过滤器：
--CHeroDemo:DamageFilter
--CHeroDemo:ModifierGainedFilter
--CHeroDemo:ExecuteOrderFilter
function Fun_Primal_Beast_Boss_Defense_DamageFilter(event)

    --print("触发獸的伤害减免")
    if not event.entindex_victim_const then 
        return true
    end

    local victim = EntIndexToHScript(event.entindex_victim_const)
    local victim_ability = victim:FindAbilityByName("Fun_Primal_Beast_Boss_Defense")
    if victim_ability then
        if victim:GetHealthPercent() >= 50 then
            event.damage = math.min(1000, event.damage)
        else
            event.damage = math.min(500, event.damage)
        end
    end

    return true
end

function Fun_Primal_Beast_Boss_Defense_ModifierGainedFilter(event)

    --这会导致某些依靠负面状态造成伤害的技能无效，比如黑洞、辉耀
    --不能阻止嘲讽、恐惧类技能和个别技能（疯狂生长、肢解）的打断效果
    local caster = EntIndexToHScript(event.entindex_caster_const)
    local caster_team = caster:GetTeam()
    local npc = EntIndexToHScript(event.entindex_parent_const)
    local npc_team = npc:GetTeam()

    if npc:HasAbility("Fun_Primal_Beast_Boss_Defense") and
       npc:IsChanneling() and
       caster_team ~= npc_team
    then
        event.duration = 0
        return false
    end
    return true
end

function Fun_Primal_Beast_Boss_Defense_ExecuteOrderFilter(event)

    --獸存在时禁用的指令
    local boss_defense = Entities:FindByName(nil, "Fun_Primal_Beast_Boss_Defense")    
    if boss_defense then
        --print("场上有獸的特殊保护")
        local abi = EntIndexToHScript(event.entindex_ability)
        if abi == nil then return true end
        local abi_name = abi:GetClassname() --某些技能是内部设置好的，属于CEntityInstance，没有GetCaster()等方法      
        for k,v in pairs(disabled_abilities) do
            if (abi_name == v["ability_name"] ) then --这样写是因为某些技能没有方法：GetCaster()
                if abi_name ~= "huskar_life_break" or 
                   ("huskar_life_break" == v["ability_name"] and abi:GetCaster():HasScepter())
                then
                    GameRules:SendCustomMessage("场上有獸的特殊防御存在，<font color=\"#FF0000\">"..v["cn_name"].."</font>施放指令被禁用。", DOTA_TEAM_BADGUYS,0)
                    return false
                end
            end
        end
    end
    return true
end

--禁用技能列表
--决斗、狂战士之吼、牺牲（神杖）、肢解、疯狂生长、末日、黑洞、闪耀黑洞
disabled_abilities = {
    { ability_name = "axe_berserkers_call",   cn_name = "狂战士之吼" },
    { ability_name = "legion_commander_duel", cn_name = "决斗"       },
    { ability_name = "huskar_life_break",     cn_name = "牺牲"       },
    { ability_name = "pudge_dismember",       cn_name = "肢解"       },
    { ability_name = "treant_overgrowth",     cn_name = "疯狂生长"   },
    { ability_name = "doom_bringer_doom",     cn_name = "末日"       },
    { ability_name = "enigma_black_hole",     cn_name = "黑洞"       },
    { ability_name = "heidong",               cn_name = "闪耀黑洞"   },
}
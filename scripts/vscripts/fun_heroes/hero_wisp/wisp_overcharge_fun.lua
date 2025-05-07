
function wisp_overcharge_fun_OnCreated(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    ability:SetStealable(false)
end

function wisp_overcharge_fun_OnAbilityExecuted(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster =keys.caster
    local target = keys.target
    local event_ability = keys.event_ability
    local fun_ability = caster:FindAbilityByName("wisp_overcharge_fun")

    if event_ability:GetAbilityName() == "wisp_tether" and fun_ability then
        fun_ability.tether_target = target
    end

end

function wisp_overcharge_fun_OnIntervalThink(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability

    --神杖百分比生命恢复,不可被破坏  
    local hp_regen_pct = ability:GetSpecialValueFor("hp_regen_pct")/100
    local hp_regen_pct_multiplier = ability:GetSpecialValueFor("hp_regen_pct_multiplier")
    local hp_regen = hp_regen_pct * caster:GetMaxHealth()
    local hp_loss_pct = (caster:GetMaxHealth() - caster:GetHealth()) / caster:GetMaxHealth()

    if ability:GetToggleState() == true then
        hp_regen = hp_regen * (1 + (hp_regen_pct_multiplier -1) * hp_loss_pct)  
    end

    local hp_regen_stack = math.floor(hp_regen * 10) --这里的10 = 1 / 0.1，0.1是KV修饰器中的每层回血数值

    local modifier_hp_regen = caster:FindModifierByName("modifier_wisp_overcharge_fun_hp_regen")

    if caster:HasScepter() then
        
        if modifier_hp_regen == nil then
            
            modifier_hp_regen = ability:ApplyDataDrivenModifier(caster, caster, "modifier_wisp_overcharge_fun_hp_regen", nil)  
            
        end
            
        if modifier_hp_regen then

            modifier_hp_regen:SetStackCount(hp_regen_stack)

        end

    else
        
        caster:RemoveModifierByName("modifier_wisp_overcharge_fun_hp_regen")

    end

    --提供艾欧的百分比属性和攻击力，艾欧被破坏时失去所有加成
    local tether_target = ability.tether_target
    if tether_target == nil then return end
    if not tether_target:IsHero() then return end
    
    local modifier_tether = caster:FindModifierByName("modifier_wisp_tether")

    local stack = 0
    local fixed_stack = 0

    local modifier_scepter_str = tether_target:FindModifierByName("modifier_wisp_overcharge_fun_scepter_strength")
    local modifier_scepter_agi = tether_target:FindModifierByName("modifier_wisp_overcharge_fun_scepter_agility")
    local modifier_scepter_int = tether_target:FindModifierByName("modifier_wisp_overcharge_fun_scepter_intellect")
    local modifier_scepter_damage_target = tether_target:FindModifierByName("modifier_wisp_overcharge_fun_scepter_damage_target")
    local modifier_scepter_damage_caster = caster:FindModifierByName("modifier_wisp_overcharge_fun_scepter_damage_caster")
    
    if caster:HasScepter() and not caster:PassivesDisabled() and ability:GetToggleState() and modifier_tether then
        
        --提供力量
        if modifier_scepter_str == nil then 

            modifier_scepter_str = ability:ApplyDataDrivenModifier(caster, tether_target, "modifier_wisp_overcharge_fun_scepter_strength", nil) 
        end
        
        if modifier_scepter_str then

            --如果根据艾欧的属性提供加成，力量、敏捷、智力这一项都改成了0
            --不要让拉比克学习，因为这里省略了艾欧自身层数的判断
            fixed_stack = 0--modifier_scepter_str:GetStackCount()

            if tether_target:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then

                stack = (caster:GetStrength() - fixed_stack  *0.1) * ability:GetSpecialValueFor("bonus_stat_scepter_primary") / 10

            elseif tether_target:GetPrimaryAttribute() == DOTA_ATTRIBUTE_ALL then

                stack = (caster:GetStrength() - fixed_stack  *0.1) * ability:GetSpecialValueFor("bonus_stat_scepter_universal") / 10

            else

                stack = (caster:GetStrength() - fixed_stack  *0.1) * ability:GetSpecialValueFor("bonus_stat_scepter") / 10

            end
            stack = math.floor(stack)
            modifier_scepter_str:SetStackCount(stack)
            stack = 0

        end

        --提供敏捷
        if modifier_scepter_agi == nil then 
            
            modifier_scepter_agi = ability:ApplyDataDrivenModifier(caster, tether_target, "modifier_wisp_overcharge_fun_scepter_agility", nil)         
            
        end

        if modifier_scepter_agi then

            fixed_stack = 0--modifier_scepter_agi:GetStackCount()

            if tether_target:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then

                stack = (caster:GetAgility() - fixed_stack  * 0.1) * ability:GetSpecialValueFor("bonus_stat_scepter_primary") / 10

            elseif tether_target:GetPrimaryAttribute() == DOTA_ATTRIBUTE_ALL then

                stack = (caster:GetAgility() - fixed_stack  * 0.1) * ability:GetSpecialValueFor("bonus_stat_scepter_universal") / 10

            else

                stack = (caster:GetAgility() - fixed_stack  * 0.1) * ability:GetSpecialValueFor("bonus_stat_scepter") / 10

            end
            stack = math.floor(stack)
            modifier_scepter_agi:SetStackCount(stack)
            stack = 0

        end

        --提供智力
        if modifier_scepter_int == nil then 
        
            modifier_scepter_int = ability:ApplyDataDrivenModifier(caster, tether_target, "modifier_wisp_overcharge_fun_scepter_intellect", nil) 

        end
        
        if modifier_scepter_int then

            fixed_stack = 0--modifier_scepter_int:GetStackCount()

            if tether_target:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then

               stack = (caster:GetIntellect(false) - fixed_stack  *0.1) * ability:GetSpecialValueFor("bonus_stat_scepter_primary") / 10

            elseif tether_target:GetPrimaryAttribute() == DOTA_ATTRIBUTE_ALL then

                stack = (caster:GetIntellect(false) - fixed_stack  *0.1) * ability:GetSpecialValueFor("bonus_stat_scepter_universal") / 10

            else

                stack = (caster:GetIntellect(false) - fixed_stack  *0.1)  * ability:GetSpecialValueFor("bonus_stat_scepter") / 10

            end
            stack = math.floor(stack)
            modifier_scepter_int:SetStackCount(stack)
            stack = 0

        end

        --施法者降低攻击力
        if modifier_scepter_damage_caster == nil then 
        
            modifier_scepter_damage_caster = ability:ApplyDataDrivenModifier(caster, caster, "modifier_wisp_overcharge_fun_scepter_damage_caster", nil)            
            
        end

        --链接目标提供攻击力
        if modifier_scepter_damage_target == nil then 
        
            modifier_scepter_damage_target = ability:ApplyDataDrivenModifier(caster, tether_target, "modifier_wisp_overcharge_fun_scepter_damage_target", nil)    

        end
        
    else

        tether_target:RemoveModifierByName("modifier_wisp_overcharge_fun_scepter_strength")
        tether_target:RemoveModifierByName("modifier_wisp_overcharge_fun_scepter_agility")
        tether_target:RemoveModifierByName("modifier_wisp_overcharge_fun_scepter_intellect")
        tether_target:RemoveModifierByName("modifier_wisp_overcharge_fun_scepter_damage_target")
        caster:RemoveModifierByName("modifier_wisp_overcharge_fun_scepter_damage_caster")

    end

end


function wisp_overcharge_fun_DamageFilter(event, original_damage)

    local victim = nil
    local attacker = nil
    local modifier_tether_haste = nil
    local modifier_caster = nil
    local modifier_caster_hp = 0
    local fun_ability = nil
    local fun_ability_lvl = 0
    local fun_ability_ToggleState = false
    local damage_reduction_pct = 0
    local pre_damage = -1
    local damage = event.damage 

    if event.entindex_victim_const and
       event.entindex_attacker_const
    then
        victim = EntIndexToHScript(event.entindex_victim_const)
        attacker = EntIndexToHScript(event.entindex_attacker_const)
    end

    if victim then
        modifier_tether_haste = victim:FindModifierByName("modifier_wisp_tether_haste")  
    end

    if modifier_tether_haste then
        modifier_caster = modifier_tether_haste:GetCaster()
    end

    if modifier_caster then
        modifier_caster_hp = modifier_caster:GetHealth()
        fun_ability = modifier_caster:FindAbilityByName("wisp_overcharge_fun")        
    end

    if fun_ability then
        fun_ability_lvl = fun_ability:GetLevel()
        fun_ability_ToggleState = fun_ability:GetToggleState()
    end  

    if fun_ability_ToggleState == true and fun_ability then
        damage_reduction_pct = fun_ability:GetSpecialValueFor("damage_reduction_pct_toggle_on")/100
    elseif fun_ability_ToggleState == false and fun_ability then
        damage_reduction_pct = fun_ability:GetSpecialValueFor("damage_reduction_pct_toggle_off")/100
    end

    if modifier_caster and fun_ability then

        pre_damage = math.min(damage * damage_reduction_pct, modifier_caster_hp - 1) --承受的伤害有限，以不致死为前提
        event.damage = damage - pre_damage
        local damage_table = {}
        damage_table.victim = modifier_caster
        damage_table.attacker = attacker
        damage_table.damage = pre_damage
        damage_table.damage_type = event.damagetype_const
        damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_BYPASSES_PHYSICAL_BLOCK
        --damage_table.damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
        damage_table.ability = fun_ability
        ApplyDamage(damage_table)
    end

    return true
end

function wisp_overcharge_fun_ModifierGainedFilter(event, result)

    local caster = nil       --施加负面状态的施法者
    local npc = nil       
    local ability = nil 
    local modifier_name = ""
    local caster_team = -99999
    local npc_team = -99999

    local modifier_tether_haste = nil     --羁绊被连接单位的修饰器
    local modifier_caster = nil           --羁绊修饰器对应的施法者
    local is_modifier_caster_has_scepter = false  --羁绊修饰器对应的施法者是否有A杖
    local fun_ability = nil         --仁爱之友
    local fun_ability_lvl = 0       --仁爱之友等级
    local fun_ability_ToggleState = false   --仁爱之友多样施法的状态（艾欧）
    local npc_has_modifier_tether = true    --被链接单位是否有羁绊施法者的修饰器
    local npc_has_ability_fun = true        --被连接单位是否有仁爱之友

    if event.entindex_caster_const and
       event.entindex_parent_const and
       event.entindex_ability_const and
       event.name_const      
    then
        caster = EntIndexToHScript(event.entindex_caster_const)
        npc = EntIndexToHScript(event.entindex_parent_const)
        ability = EntIndexToHScript(event.entindex_ability_const)
        modifier_name = event.name_const
    end

    if caster and npc then
        modifier_tether_haste = npc:FindModifierByName("modifier_wisp_tether_haste")       
        npc_has_modifier_tether = npc:FindModifierByName("modifier_wisp_tether")
        npc_has_ability_fun = npc:FindAbilityByName("wisp_overcharge_fun")
        caster_team = caster:GetTeam()
        npc_team = npc:GetTeam()
    end
    if modifier_tether_haste then
        modifier_caster = modifier_tether_haste:GetCaster()  
    end
    if modifier_caster then
        fun_ability = modifier_caster:FindAbilityByName("wisp_overcharge_fun")
        is_modifier_caster_has_scepter = modifier_caster:HasScepter()
    end
    if fun_ability then
        fun_ability_lvl = fun_ability:GetLevel()
        fun_ability_ToggleState = fun_ability:GetToggleState()
    end

    if fun_ability_lvl > 0 and       --已学习仁爱之友
       is_modifier_caster_has_scepter and  --已装备A杖
       fun_ability_ToggleState and   --已开启多样施法
       (caster_team ~= npc_team or modifier_name == "modifier_faceless_void_chronosphere_freeze") and --debuff是由敌人施加的，或者是不分敌我的时间结界眩晕
       (not npc_has_modifier_tether or not npc_has_ability_fun ) and --同时拥有羁绊和仁爱之友时，不能转移debuff（严格来说，拥有仁爱之友时不能装备A杖和开启多样施法）
       modifier_name ~= "modifier_tidehunter_anchor_clamp" and --重如铁锚，但生效的是下一项，这里仅在本地化文件出现过，游戏内不是此修饰器
       modifier_name ~= "modifier_tidehunter_dead_in_the_water" and --不能是潮汐猎人的重如铁锚debuff，否则游戏会崩溃
       modifier_name ~= "modifier_grimstroke_ink_creature_debuff" --不能是天涯墨客的幻影之拥，否则游戏会崩溃
    then
        local dur = event.duration * (1 - modifier_caster:GetStatusResistance())
        if dur == nil then 
            --return result        
        elseif dur == -1 then
            --return result 
        else
            local class_name = ability:GetClassname()
            --print(class_name)
            if class_name == "ability_datadriven" or class_name == "item_datadriven" then
                ability:ApplyDataDrivenModifier(caster, modifier_caster, modifier_name, { duration = dur })
            else
                modifier_caster:AddNewModifier(caster, ability, modifier_name, { duration = dur })
            end
            result = false
        end      
    end

    return result 
end
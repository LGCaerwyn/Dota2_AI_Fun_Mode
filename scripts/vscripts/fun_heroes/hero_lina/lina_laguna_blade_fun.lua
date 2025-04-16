require('timers')
require('utils')

function laguna_blade_fun_OnCreated(keys)
    local caster = keys.caster
    local ability = keys.ability
    local modifier_range = "modifier_laguna_blade_fun_attack_range"
    if caster:PassivesDisabled() then return end
    ability:ApplyDataDrivenModifier(caster, caster, modifier_range, nil)
end

function laguna_blade_fun_OnDestroy(keys)
    local caster = keys.caster
    local modifier_range = "modifier_laguna_blade_fun_attack_range"
    caster:RemoveModifierByName(modifier_range)
end

function laguna_blade_fun_OnStateChanged(keys)
    local ability = keys.ability
	local caster = keys.caster
	local modifier_range = "modifier_laguna_blade_fun_attack_range"

	if caster:PassivesDisabled() and caster:HasModifier(modifier_range) then 
	    caster:RemoveModifierByName(modifier_range)
	elseif not caster:PassivesDisabled() and not caster:HasModifier(modifier_range) then
	    ability:ApplyDataDrivenModifier(caster, caster, modifier_range, nil)
	end
end

function laguna_blade_fun_OnAttack(keys)

    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local ulti = caster:FindAbilityByName("lina_laguna_blade")

    if caster:PassivesDisabled() or
       caster:IsIllusion() or
       caster:GetTeam() == target:GetTeam() or
       target:IsBuilding() or
       not caster:IsAlive() or
       not target:IsAlive() or
       ulti == nil 
    then
        return
    end

    local chance = ability:GetSpecialValueFor("chance")   
	local playerID = caster:GetPlayerID()
	
	if PlayerResource:IsFakeClient(playerID)  then
	chance = 100
	else
	chance_scepter = 10
	end
	
    local r = RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_ITEM_MKB, caster)
    if r then
        if caster:HasModifier("modifier_item_aghanims_shard") then
            local immune_duration = ability:GetSpecialValueFor("immune_duration")
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_laguna_blade_fun_damage_immune", { duration = immune_duration })
        end
        local original_target = caster:GetCursorCastTarget()
        caster:SetCursorCastTarget(target)
        ulti:OnSpellStart()
        caster:SetCursorCastTarget(original_target)
    end
	
end

--ÒÆ³ýÉñÃðÕ¶ÉËº¦ÑÓ³Ù
function lina_laguna_blade_fun_AbilityTuningValueFilter(event)

    local caster = EntIndexToHScript(event.entindex_caster_const)
    local ability = EntIndexToHScript(event.entindex_ability_const)
    if ability == nil then return true end

    local fun_ability = caster:FindAbilityByName("lina_laguna_blade_fun") 
    if fun_ability == nil then return true end
    if fun_ability:GetLevel() < 1 then return true end
    if ability:GetAbilityName() == "lina_laguna_blade" and
       event.value_name_const == "damage_delay"
    then
       event.value = 0
       return true
    else
        return true
    end
end

--¶àÖØÉñÃðÕ¶
function laguna_blade_fun_OnAbilityExecuted(keys)
    --print("ÔËÐÐ½Å±¾")
    local caster = keys.caster
    local target = HasSpellAbsorb(keys.target)
    local ability = keys.ability
    local event_ability = keys.event_ability
    local chance_scepter = ability:GetSpecialValueFor("chance_scepter")
    local modifier_multiple = "modifier_laguna_blade_fun_multiple"

    if event_ability:GetAbilityName() == "lina_laguna_blade" and 
       not caster:PassivesDisabled() and
       caster:HasScepter() and
       target ~= nil
    then
        local modifer_temp = ability:ApplyDataDrivenModifier(caster, target, modifier_multiple, nil)
        modifer_temp:SetDuration(0.3, true)  --·ÀÖ¹±»×´Ì¬¿¹ÐÔËõ¼õ
    end
end

function multiple_laguna_blade(keys)
    
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local ulti = caster:FindAbilityByName("lina_laguna_blade")
    local chance_scepter = ability:GetSpecialValueFor("chance_scepter")
    local modifier_multiple = "modifier_laguna_blade_fun_multiple"
	
	local playerID = caster:GetPlayerID()
	
	if PlayerResource:IsFakeClient(playerID)  then
	chance_scepter = 100
	else
	chance_scepter = 10
	end

    local r = RollPseudoRandomPercentage(chance_scepter, DOTA_PSEUDO_RANDOM_OGRE_MAGI_FIREBLAST, caster)
    if not r then 
        return    
    end

    local castable = target:IsAlive() and caster:IsAlive()
    if castable then
        local original_target = caster:GetCursorCastTarget()
        caster:SetCursorCastTarget(target)
        ulti:OnSpellStart() 
        caster:SetCursorCastTarget(original_target)
    end
    local modifer_temp = ability:ApplyDataDrivenModifier(caster, target, modifier_multiple, nil)
    modifer_temp:SetDuration(0.3, true)  --·ÀÖ¹±»×´Ì¬¿¹ÐÔËõ¼õ
    return
end
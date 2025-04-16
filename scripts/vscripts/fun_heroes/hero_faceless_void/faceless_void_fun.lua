
function faceless_void_fun_ModifierGainedFilter(event, result)
    --时间结界内允许友军英雄行动
    if not event.entindex_caster_const then return result end
    if not event.entindex_parent_const then return result end
    if not event.name_const then return result end
    local caster = EntIndexToHScript(event.entindex_caster_const)
    local npc = EntIndexToHScript(event.entindex_parent_const)
    local modifier_name = event.name_const
    if caster == nil then return result end
    if npc == nil then return result end

    local special_bonus = caster:FindAbilityByName("special_bonus_unique_faceless_void_chronosphere_non_disabled") 
    if special_bonus == nil then return result end
    if special_bonus:GetLevel() < 1 then return result end

    if modifier_name == "modifier_faceless_void_chronosphere_freeze" and
       npc:GetTeam() == caster:GetTeam() and
       npc:IsControllableByAnyPlayer()
    then
       
       return false
    else
        return result
    end    

end
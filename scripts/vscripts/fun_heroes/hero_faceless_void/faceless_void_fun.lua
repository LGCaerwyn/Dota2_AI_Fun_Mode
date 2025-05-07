
function faceless_void_fun_ModifierGainedFilter(event, result)
    --时间结界内允许友军英雄行动

    local caster = nil
    local npc = nil
    local modifier_name = ""
    local special_bonus = nil
    local special_bonus_lvl = 0
    local npc_IsControllableByAnyPlayer = false
    local caster_team = -99999
    local npc_team = -99999

    if event.entindex_caster_const and
       event.entindex_parent_const and
       event.name_const
    then
        caster = EntIndexToHScript(event.entindex_caster_const)
        npc = EntIndexToHScript(event.entindex_parent_const)
        modifier_name = event.name_const
    end

    if caster and npc then
        special_bonus = caster:FindAbilityByName("special_bonus_unique_faceless_void_chronosphere_non_disabled")
        npc_IsControllableByAnyPlayer = npc:IsControllableByAnyPlayer()
        caster_team = caster:GetTeam()
        npc_team = npc:GetTeam()
    end
    if special_bonus then
        special_bonus_lvl = special_bonus:GetLevel()
    end

    if special_bonus_lvl > 0 and
       npc_IsControllableByAnyPlayer and
       caster_team == npc_team and
       modifier_name == "modifier_faceless_void_chronosphere_freeze"       
    then
        result = false
    end   

    return result
end

function null_field_fun(keys)

    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local modifier_aura = "modifier_null_field_fun_aura"

    if caster:PassivesDisabled() then
        caster:RemoveModifierByName(modifier_aura)
        return
    end

    ability:ApplyDataDrivenModifier(caster, caster, modifier_aura, nil)

end
---------------------------------------------------------------------------
function cannot_be_stolen(keys)
     --print("这个技能不可以被拉比克偷取！")
     local caster = keys.caster
     local abilityName = keys.AbilityName --自定义参数
     local ability = caster:FindAbilityByName(abilityName)
     ability:SetStealable(false)
     return
end
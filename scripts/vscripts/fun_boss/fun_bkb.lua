
function rage_start(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    local buff_dur = ability:GetSpecialValueFor("duration")
    local cooldown = ability:GetSpecialValueFor("cooldown")
    local modifier_magic_immune = "modifier_Fun_BKB_active"
    local modifier_status_resistance = "modifier_special_bonus_status_resistance"
    local modidier_cooldown = "modifier_Fun_BKB_cooldown"

    if caster:HasModifier(modidier_cooldown) then return end

    caster:Purge(false, true, false, true, true)
    ability:ApplyDataDrivenModifier(caster, caster, modidier_cooldown, { duration = cooldown })
    ability:ApplyDataDrivenModifier(caster, caster, modifier_magic_immune, { duration = buff_dur })
    ability:ApplyDataDrivenModifier(caster, caster, modifier_status_resistance, { duration = buff_dur })
    ability:EndCooldown()
    ability:StartCooldown(cooldown)

    return
end
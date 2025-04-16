
--预载入伤害表
function modifier_Fun_Borrowed_Time_v2_OnCreated(keys)

    local caster = keys.caster
    local ability = keys.ability

    if ability.damage_table == nil then

        local immolate_damage = ability:GetSpecialValueFor("immolate_damage_v2")
        local immolate_tick = ability:GetSpecialValueFor("immolate_tick")
        immolate_damage = immolate_damage / ( 1 / immolate_tick )

        ability.damage_table = {}
        ability.damage_table.victim = nil
        ability.damage_table.attacker = caster
        ability.damage_table.damage = immolate_damage
        ability.damage_table.damage_type = DAMAGE_TYPE_PURE
        ability.damage_table.ability = ability
    end
end

--触发条件
function modifier_Fun_Borrowed_Time_v2_OnTakeDamage(keys)

    local caster = keys.caster
    local ability = keys.ability
    local hp_threshold = ability:GetSpecialValueFor("hp_threshold")
    local dur = ability:GetSpecialValueFor("duration")
    local cooldown = ability:GetEffectiveCooldown(1)

    if caster:GetHealth() <= hp_threshold  and ability:IsCooldownReady() then
        caster:AddNewModifier(caster, ability, "modifier_abaddon_borrowed_time", { duration = dur })
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_Fun_Borrowed_Time_v2_aura", { duration = dur })
        caster:RemoveModifierByName("modifier_Fun_Borrowed_Time_v2")
        caster:EmitSound("Hero_Abaddon.BorrowedTime")
        ability:StartCooldown(cooldown)
    end
end

function modifier_Fun_Borrowed_Time_v2_aura_OnDestroy(keys)

    local caster = keys.caster
    local ability = keys.ability 
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_Fun_Borrowed_Time_v2", nil)
end


function modifier_Fun_Borrowed_Time_v2_immolate_OnIntervalThink(keys)

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    
    ability.damage_table.victim = target
	ApplyDamage(ability.damage_table)
end


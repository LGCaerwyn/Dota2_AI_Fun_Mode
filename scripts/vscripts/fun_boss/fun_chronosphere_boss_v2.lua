require('timers')
function Fun_Chronosphere_boss_v2_OnSpellStart(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    local dur = ability:GetSpecialValueFor("duration")
    local radius = ability:GetSpecialValueFor("radius")

    local pos = caster:GetCursorPosition()
    ability:ApplyDataDrivenThinker(caster, pos, "modifier_Fun_Chronosphere_boss_v2_thinker", { duration = dur - 0.5 })
    AddFOWViewer(caster:GetTeam(), pos, radius, dur, false)
    
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, pos + Vector(0,0,1))
    ParticleManager:SetParticleControl(particle, 1, Vector(radius,radius,radius))
    EmitSoundOnLocationWithCaster(pos, "Hero_FacelessVoid.Chronosphere", caster)

    Timers:CreateTimer({
        endTime = dur,
        callback = function()
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
        end
    })
end

function modifier_Fun_Chronosphere_boss_v2_aura_OnCreated(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    if target == caster then
        target.boss_chronosphere_buff = target:AddNewModifier(caster, ability, "modifier_faceless_void_chronosphere_speed", nil)
    else
        if target:GetName() ~= "npc_dota_hero_faceless_void" then
            target.boss_chronosphere_buff = target:AddNewModifier(caster, ability, "modifier_faceless_void_chronosphere_freeze", nil)
        end
    end
end

function modifier_Fun_Chronosphere_boss_v2_aura_OnDestroy(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    if target.boss_chronosphere_buff then
        target.boss_chronosphere_buff:Destroy()
        target.boss_chronosphere_buff = nil
    end
end
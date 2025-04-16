
function arc_warden_flux_fun_OnSpellStart(keys)

    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local dur = ability:GetSpecialValueFor("duration")

    if target:TriggerSpellAbsorb(ability) then
        return
    end

    local particleName = "particles/units/heroes/hero_arc_warden/arc_warden_flux_cast.vpcf"
    local particle = ParticleManager:CreateParticle(particleName, PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), false)
    ParticleManager:SetParticleControlEnt(particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_attack2", Vector(0,0,0), false)
    caster:EmitSound("Hero_ArcWarden.Flux.Cast")
    target:EmitSound("Hero_ArcWarden.Flux.Target")
	ParticleManager:ReleaseParticleIndex(particle)
    ability:ApplyDataDrivenModifier(caster, target, "modifier_arc_warden_flux", { duration = dur })

end
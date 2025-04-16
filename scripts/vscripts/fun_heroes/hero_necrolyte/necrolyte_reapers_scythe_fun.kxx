require('timers')

function reapers_scythe_fun(keys)

    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local modifier_disable = "modifier_necrolyte_reapers_scythe_fun"
    local disable_duration = ability:GetSpecialValueFor("disable_duration")
    local reapers_num = ability:GetSpecialValueFor("reapers_num")

    ability:ApplyDataDrivenModifier(caster, target, modifier_disable, nil)

    local particleName_0 = "particles/econ/items/necrolyte/necro_sullen_harvest/necro_ti7_immortal_scythe.vpcf"
    local particleName_1 = "particles/econ/items/necrolyte/necro_sullen_harvest/necro_ti7_immortal_scythe_start.vpcf" 

    EmitSoundOn("Hero_Necrolyte.ReapersScythe.Cast.ti7", caster)
    EmitSoundOn("Hero_Necrolyte.ReapersScythe.Target", target)
    ParticleManager:CreateParticle(particleName_0, PATTACH_ABSORIGIN, target)
    --[[
    reapers_num = Math.floor(reapers_num)
    if reapers_num < 1 then reapers_num = 1 end
    local step_angle = 360 / reapers_num
    for i = 1, reapers_num do

        local angle = step_angle * (i - 1)
        local rotated_vector = -1 * caster:GetForwardVector()
        local p1 = ParticleManager:CreateParticle(particleName_1, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(p1, 1, target:GetAbsOrigin())


        ParticleManager:SetParticleControlForward(p1, 1, -1 * caster:GetForwardVector())


    end
    ]]--

    local p1 = ParticleManager:CreateParticle(particleName_1, PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControl(p1, 1, target:GetAbsOrigin())
    --ParticleManager:SetParticleControlForward(p1, 1, -1 * target:GetForwardVector())

    local p2 = ParticleManager:CreateParticle(particleName_1, PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControl(p2, 1, target:GetAbsOrigin())
    --ParticleManager:SetParticleControlForward(p2, 1, target:GetForwardVector())

    Timers:CreateTimer(disable_duration,function()      
        target:Kill(ability, caster)
	    target:RemoveModifierByName(modifier_disable)
	end)

end
---------------------------------------------------------------------------------------------------------------------------------------
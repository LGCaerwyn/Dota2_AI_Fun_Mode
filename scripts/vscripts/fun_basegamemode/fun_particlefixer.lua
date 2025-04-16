
function Fun_ParticleFixer_OnCreated(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    ability.filler_ability = caster:FindAbilityByName("filler_ability")
    if ability.filler_ability == nil then return end

    ability.particleID = nil
    if caster:GetTeam() == DOTA_TEAM_GOODGUYS then
     
        ability.particleID = ParticleManager:CreateParticle("particles/world_shrine/radiant_shrine_ambient.vpcf", PATTACH_ABSORIGIN, caster)

    elseif caster:GetTeam() == DOTA_TEAM_BADGUYS then

        ability.particleID = ParticleManager:CreateParticle("particles/world_shrine/dire_shrine_ambient.vpcf", PATTACH_ABSORIGIN, caster)

    end
    --Shrine.Recharged
    ability.thinker = ability:ApplyDataDrivenModifier(caster, caster, "modifier_Fun_ParticleFixer_Thinker", nil)
end

function Fun_ParticleFixer_OnIntervalThink(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = keys.caster
    local filler_ability = ability.filler_ability
    local thinker = ability.thinker
    local particleID = ability.particleID

    if not filler_ability:IsCooldownReady() then

        ParticleManager:DestroyParticle(particleID, false)
        ParticleManager:ReleaseParticleIndex(particleID)

        if caster:GetTeam() == DOTA_TEAM_GOODGUYS then
     
            ability.particleID = ParticleManager:CreateParticle("particles/world_shrine/radiant_shrine_active.vpcf", PATTACH_ABSORIGIN, caster)

        elseif caster:GetTeam() == DOTA_TEAM_BADGUYS then

            ability.particleID = ParticleManager:CreateParticle("particles/world_shrine/dire_shrine_active.vpcf", PATTACH_ABSORIGIN, caster)

        end

        local time = filler_ability:GetCooldown(1)
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_Fun_ParticleFixer_Countdown", { duration = time })
        thinker:Destroy()
        ability.thinker = nil

        --Ìí¼Ó·¶Î§»Ö¸´Ð§¹û
        local heal_duration = filler_ability:GetSpecialValueFor("duration")
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_Fun_ParticleFixer_Heal_Thinker", { duration = heal_duration })
    end
end

function Fun_ParticleFixer_Countdown(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = keys.caster
    local filler_ability = ability.filler_ability
    ability.particleID = nil

    if filler_ability:IsCooldownReady() then
        local modifier_self = caster:FindModifierByName("modifier_Fun_ParticleFixer_Countdown")
        if modifier_self then 
            modifier_self:Destroy()
        end
    end
end

function Fun_ParticleFixer_Heal(keys)
    if not IsServer() then return true end    
    local ability = keys.ability
    local filler_ability = ability.filler_ability
    local caster = keys.caster
    local target = keys.target
    local heal_thinker = caster:FindModifierByName("modifier_Fun_ParticleFixer_Heal_Thinker")
    local thinker_time = heal_thinker:GetRemainingTime()
    local heal_buff = target:FindModifierByName("modifier_filler_heal")

    if not heal_buff then
        target:AddNewModifier(caster, filler_ability, "modifier_filler_heal", { duration = thinker_time })
    end

end
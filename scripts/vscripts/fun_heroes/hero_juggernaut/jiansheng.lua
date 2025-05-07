require('timers')

function jisha( keys )
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    if caster:PassivesDisabled() then return end 
    local target = keys.unit
    local modifier_name = keys.Modifier_name
	local modifier = caster:FindModifierByName(modifier_name)
    if modifier == nil then return end

    local ulti_dur_hero = ability:GetSpecialValueFor("jiansheng_hero")
    local ulti_dur_creep = ability:GetSpecialValueFor("jiansheng_creep")
    if caster:HasScepter() then
	    ulti_dur_hero = ability:GetSpecialValueFor("jiansheng_hero_scepter")
	    ulti_dur_creep = ability:GetSpecialValueFor("jiansheng_creep_scepter")
    end

    if  keys.unit:IsRealHero() then
	    modifier:SetDuration( modifier:GetDuration() - modifier:GetElapsedTime() + ulti_dur_hero, true)
	else
        modifier:SetDuration( modifier:GetDuration() - modifier:GetElapsedTime() + ulti_dur_creep, true)
    end
end


function Two_a( keys )
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target
    local chance = ability:GetSpecialValueFor("chance")
    local delay = ability:GetSpecialValueFor("delay")
    if caster:PassivesDisabled() or caster:HasModifier("modifier_jiansheng_cooldown") then
        return
    end

    local r = RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, caster)
    if r == false then return end
    
	if target:IsAlive() then
        Timers:CreateTimer({
            endTime = delay,
            callback = function()
                ability:ApplyDataDrivenModifier(caster, caster, "modifier_jiansheng_cooldown", { duration = delay })
                caster:PerformAttack(target, true, true, true, false, true, false, true)
            end
        })    																	
	end

end
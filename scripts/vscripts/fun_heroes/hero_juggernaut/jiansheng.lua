

function jisha( keys )

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
    local ability = keys.ability
    local caster = keys.caster
    if caster:PassivesDisabled() then return end
    if ability.attacked ~= false then 
	    ability.attacked = false 
		return
	end

    local target = keys.target
	if target:IsAlive() then
	    caster:PerformAttack(target, true, true, true, false, true, false, true)																	
	end
    ability.attacked = true
end

function fun_coup_de_grace_OnSpellStart(keys)
    if not IsServer() then return true end
    local ability = keys.ability
	local caster = keys.caster
	local ulti = caster:FindAbilityByName("phantom_assassin_coup_de_grace")
	local active_duration = ability:GetSpecialValueFor("active_duration")
	if not ulti then return end
	if ulti:GetLevel() < 1 then return end
	caster:AddNewModifier(caster, ulti, "modifier_phantom_assassin_mark_of_death", { duration = active_duration })
end

function fun_coup_de_grace_OnCreated(keys)
    if not IsServer() then return true end
    local ability = keys.ability
	local caster = keys.caster
	if not caster:PassivesDisabled() then
	    ability:ApplyDataDrivenModifier(caster, caster, "modifier_永恒的恩赐解脱_crit", nil)
	end
end

function fun_coup_de_grace_OnDestroy(keys)
    if not IsServer() then return true end
	local caster = keys.caster
    caster:RemoveModifierByName("modifier_永恒的恩赐解脱_crit")
end

function fun_coup_de_grace_OnStateChanged(keys)
    if not IsServer() then return true end
    local ability = keys.ability
	local caster = keys.caster
	local modifier_crit = "modifier_永恒的恩赐解脱_crit"

	if caster:PassivesDisabled() and caster:HasModifier(modifier_crit) then 
	    caster:RemoveModifierByName(modifier_crit)
	elseif not caster:PassivesDisabled() and not caster:HasModifier(modifier_crit) then
	    ability:ApplyDataDrivenModifier(caster, caster, modifier_crit, nil)
	end
end

function fun_coup_de_grace_OnHeroKilled(keys)
    if not IsServer() then return true end
    local ability = keys.ability
	local caster = keys.caster
	if caster:HasScepter() then
	    ability:EndCooldown()
	end
end

function fun_coup_de_grace_OnAttackLanded(keys)
    if not IsServer() then return true end
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local ulti = caster:FindAbilityByName("phantom_assassin_coup_de_grace")
	local active_duration = ability:GetSpecialValueFor("active_duration")

	if target:FindModifierByNameAndCaster("modifier_phantom_assassin_mark_of_death", caster) and 
	   caster:FindModifierByNameAndCaster("modifier_phantom_assassin_mark_of_death", caster) and
	   ulti
	then
	    if ulti:GetLevel() >= 1 then
		     Timers:CreateTimer({
                 endTime = 0.03,
                 callback = function()
                     caster:AddNewModifier(caster, ulti, "modifier_phantom_assassin_mark_of_death", { duration = active_duration })
                 end
             })	        
		end
	end

	if caster:PassivesDisabled() then return end      --新增破被动效果
	ability:ApplyDataDrivenModifier(caster, target, "modifier_永恒的恩赐解脱_debuff", { duration = ability:GetSpecialValueFor("armor_duration")})

end

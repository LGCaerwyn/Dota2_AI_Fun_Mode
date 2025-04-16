
function fun_coup_de_grace_OnSpellStart(keys)
    local ability = keys.ability
	local caster = keys.caster
	local ulti = caster:FindAbilityByName("phantom_assassin_coup_de_grace")
	local active_duration = ability:GetSpecialValueFor("active_duration")
	if not ulti then return end
	if ulti:GetLevel() < 1 then return end
	caster:AddNewModifier(caster, ulti, "modifier_phantom_assassin_mark_of_death", { duration = active_duration })
end

function fun_coup_de_grace_OnCreated(keys)
    local ability = keys.ability
	local caster = keys.caster
	if not caster:PassivesDisabled() then
	    ability:ApplyDataDrivenModifier(caster, caster, "modifier_永恒的恩赐解脱_crit", nil)
	end
end

function fun_coup_de_grace_OnDestroy(keys)
	local caster = keys.caster
    caster:RemoveModifierByName("modifier_永恒的恩赐解脱_crit")
end

function fun_coup_de_grace_OnStateChanged(keys)
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
    local ability = keys.ability
	local caster = keys.caster
	if caster:HasScepter() then
	    ability:EndCooldown()
	end
end

function fun_coup_de_grace_OnAttackLanded(keys)

	local caster = keys.caster
	if caster:PassivesDisabled() then return end      --新增破被动效果

	local ability = keys.ability
	local target = keys.target

	ability:ApplyDataDrivenModifier(caster, target, "modifier_永恒的恩赐解脱_debuff", { duration = ability:GetSpecialValueFor("armor_duration")})
	local Time_dota = math.floor( GameRules:GetDOTATime(false , false)  / 	60  )
	local heroes_name = caster:GetUnitName()
	local playerID = caster:GetPlayerID()
	if  PlayerResource:IsFakeClient(playerID)  and  heroes_name == "npc_dota_hero_phantom_assassin" then
			pa = caster:FindAbilityByName("phantom_assassin_coup_de_grace_fun")
				if Time_dota   >= 20 and   pa:GetLevel() <= 1 then
					pa:SetLevel(2)
					elseif  Time_dota  >= 50  and pa:GetLevel() <= 2  then
					pa:SetLevel(3)
				end

	end
end


function Chilling_Touch_OnCreated(keys)
    print("运行")
    local ability = keys.ability
	local caster = keys.caster
	if not caster:PassivesDisabled() then
	    ability:ApplyDataDrivenModifier(caster, caster, "modifier_寒霜诅咒_2", nil)
	end
end

--------------------------------------------------------------------------------------------

function Chilling_Touch_OnDestroy(keys)
	local caster = keys.caster
    caster:RemoveModifierByName("modifier_寒霜诅咒_2")
end

--------------------------------------------------------------------------------------------

function Chilling_Touch_OnAttackLanded(keys)

    local caster = keys.caster 
	local target = keys.target

	if caster:PassivesDisabled() or
	   caster:IsIllusion() or
	   caster:GetTeam() == target:GetTeam() or 
	   target:IsBuilding()
	then 
	    return 
	end
	
	local ability = keys.ability
	local time = ability:GetSpecialValueFor("持续时间")
	local damage = ability:GetSpecialValueFor("魔法伤害")
	local ulti = caster:FindAbilityByName("ancient_apparition_ice_blast")

	if ulti then
	    if ulti:GetLevel() >= 1 and target:IsHero()	then
		    target:AddNewModifier(caster, ulti, "modifier_ice_blast", { duration = time })
		end	   
	end

	local damage_table = {
	               victim = target,
				   attacker = caster,
				   damage = damage,
				   damage_type = DAMAGE_TYPE_ABILITY_DEFINED,
				   ability = ability
	} 
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, damage_table.damage, nil)  --伤害信息，例如智慧之刃、奥数天球、金箍棒造成的伤害会显示在目标头顶附近
	ApplyDamage(damage_table)
end

--------------------------------------------------------------------------------------------

function Chilling_Touch_OnStateChanged(keys)
    local ability = keys.ability
	local caster = keys.caster
	local modifier_attack_range = "modifier_寒霜诅咒_2"

	if caster:PassivesDisabled() and caster:HasModifier(modifier_attack_range) then 
	    caster:RemoveModifierByName(modifier_attack_range)
	elseif not caster:PassivesDisabled() and not caster:HasModifier(modifier_attack_range) then
	    ability:ApplyDataDrivenModifier(caster, caster, modifier_attack_range, nil)
	end
end
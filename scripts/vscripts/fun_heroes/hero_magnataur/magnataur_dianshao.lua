
function dianshao_OnAttackStart(keys)
    local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local modifier_cannot_miss = "modifier_dianshao_cannot_miss"

	caster:RemoveModifierByName(modifier_cannot_miss)
	if target:IsBuilding() or
	   not target:IsHero() or
	   caster:PassivesDisabled() or
	   caster:IsIllusion() or
	   caster:GetTeam() == target:GetTeam() or
	   not ability:IsCooldownReady()
	then
	    return
	end
	ability:ApplyDataDrivenModifier(caster, caster, modifier_cannot_miss, nil)
end

function dianshao_OnAttack(keys)

	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if target:IsBuilding() or
	   not target:IsHero() or
	   caster:PassivesDisabled() or
	   caster:IsIllusion() or
	   caster:GetTeam() == target:GetTeam() or
	   not ability:IsCooldownReady()
	then
	    return
	end
	
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1) * caster:GetCooldownReduction()
	local ulti = caster:FindAbilityByName("magnataur_reverse_polarity")
	local multiple = ability:GetSpecialValueFor("debuff_multiple")
	local duration_ulti = 0

	if ulti then 
	    duration_ulti = ulti:GetSpecialValueFor("hero_stun_duration") * multiple + ability:GetSpecialValueFor("knockback_duration")
	end

    caster:EmitSound("Hero_Magnataur.HornToss.Cast")
	target:EmitSound("DOTA_Item.SilverEdge.Target")

	local debuff = ability:ApplyDataDrivenModifier(caster, target, "modifier_dianshao_debuff", { duration = duration_ulti })
	debuff:SetStackCount(caster:GetLevel())
	ability:ApplyDataDrivenModifier(caster, target, "modifier_dianshao", { duration = ability:GetSpecialValueFor("knockback_duration") + 0.1 })

	ability:StartCooldown(cooldown)

end


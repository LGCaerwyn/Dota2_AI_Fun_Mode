
function boss_cast_spell(keys)
    if not IsServer() then return true end
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target

	local black_hole = caster:FindAbilityByName("Fun_BlackHole")
	local duel = caster:FindAbilityByName("Fun_Duel")
	local omni_slash = caster:FindAbilityByName("Fun_Omni_Slash")

	if black_hole and black_hole:IsCooldownReady() and target:IsHero() then	

	    ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_ultimate_scepter", { duration = 4 })
	    caster:CastAbilityOnPosition(target:GetAbsOrigin(), black_hole, caster:GetMainControllingPlayer())	

	elseif duel and duel:IsCooldownReady() and target:IsHero() then	

	    caster:CastAbilityOnTarget(target, duel, caster:GetMainControllingPlayer())	

	elseif omni_slash and omni_slash:IsCooldownReady() and target:IsHero() then	

	    caster:CastAbilityOnTarget(target, omni_slash, caster:GetMainControllingPlayer())	

	end
end














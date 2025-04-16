
function fire_break(keys)

    local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier_debuff = "modifier_ember_huoyanpohuai_debuff"
	local modifier_cooldown = "modifier_ember_huoyanpohuai_cooldown"
	local dur = 0
	local cooldown = ability:GetSpecialValueFor("cooldown")
	--破坏状态下、幻象单位、内置冷却期间不会触发
	if caster:PassivesDisabled() or 
	   caster:IsIllusion() or 
	   target:HasModifier(modifier_cooldown) or
	   target:IsBuilding() or
	   caster:GetTeam() == target:GetTeam()
	then 
	    return 
	end       
	
	damage_table = {}
	damage_table.victim = target
	damage_table.attacker = caster
	damage_table.damage_type = DAMAGE_TYPE_ABILITY_DEFINED  --DAMAGE_TYPE_PHYSICAL
	damage_table.damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL
	damage_table.ability = ability

	if target:IsHero() or target:IsAncient() then
	    damage_table.damage = ability:GetSpecialValueFor("damage_hero")
		dur = ability:GetSpecialValueFor("time_break_hero")
	else
	    damage_table.damage = ability:GetSpecialValueFor("damage_creep")
		dur = ability:GetSpecialValueFor("time_break_creep")
	end

	target:EmitSound("Hero_FacelessVoid.TimeLockImpact")
	target:EmitSound("Hero_Huskar.Burning_Spear")
	ability:ApplyDataDrivenModifier(caster, target, modifier_debuff, { duration = dur })
	ability:ApplyDataDrivenModifier(caster, target, modifier_cooldown, { duration = cooldown })
	
	ApplyDamage(damage_table)
end
------------------------------------------------------------------------------------



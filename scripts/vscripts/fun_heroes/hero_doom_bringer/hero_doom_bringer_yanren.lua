
function YanRen_OnAttackStart(keys)
    if not IsServer() then return true end
    local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local modifier_cannot_miss = "modifier_yanren_cannot_miss"

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

function YanRen_OnAttackLanded( keys )
    if not IsServer() then return true end
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if target:IsBuilding() or
	   --not target:IsHero() or
	   caster:PassivesDisabled() or
	   caster:IsIllusion() or
	   caster:GetTeam() == target:GetTeam()
	   --not ability:IsCooldownReady()
	then
	    return
	end

	--分裂攻击
	local cleave_dmg = keys.Damage * ability:GetSpecialValueFor("cleave_dmg") /100
	local cleave_distance = ability:GetSpecialValueFor("cleave_distance")
	local cleave_radius = ability:GetSpecialValueFor("cleave_radius")
	local effectName = "particles/econ/items/faceless_void/faceless_void_weapon_bfury/faceless_void_weapon_bfury_cleave_b.vpcf"
	DoCleaveAttack(caster, target, ability, cleave_dmg, 150, cleave_radius, cleave_distance, effectName)

	if not target:IsHero() then return end

	local cooldown = ability:GetCooldown(ability:GetLevel() - 1) * caster:GetCooldownReduction()
	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = DAMAGE_TYPE_ABILITY_DEFINED
	damage_table.ability = ability
	damage_table.damage = target:GetHealth() * ability:GetSpecialValueFor("damage_pct")* 0.01
	--damage_table.damage = target:GetLevel() * caster:GetLevel() * 2
	damage_table.damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION



	if ability:IsCooldownReady() then
	    
	    damage_table.damage = damage_table.damage + target:GetLevel() * caster:GetLevel() * 2  --额外伤害
		target:EmitSound("Hero_DoomBringer.LvlDeath")
		local particleName = "particles/units/heroes/hero_doom_bringer/doom_loadout.vpcf"	
	    local particle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, target )

		if caster:HasModifier("modifier_item_aghanims_shard") then
            target:Purge(true, false, false, false, false)  --驱散
		    target:Interrupt() --打断
	    end

		ability:StartCooldown(cooldown)		
	end

	ApplyDamage(damage_table)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, damage_table.damage, nil)

	return
end

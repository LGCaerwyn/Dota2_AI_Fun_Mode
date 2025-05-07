--[[Author: Pizzalol
	Date: 09.02.2015.
	Triggers when the unit attacks
	Checks if the attack target is the same as the caster
	If true then trigger the counter helix if its not on cooldown]]
function CounterHelix( keys )

    if not IsServer() then return end
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	local distance = CalcDistanceBetweenEntityOBB(caster, attacker)
	local trigger_chance = ability:GetSpecialValueFor("trigger_chance")
	local trigger_radius = ability:GetSpecialValueFor("trigger_radius")

	--不触发条件
	if not ability:IsCooldownReady() or
	   caster:PassivesDisabled() or
	   distance > trigger_radius or
	   caster:GetTeam() == attacker:GetTeam()
	then 
	    return 
	end

	--成功触发，造成范围伤害，A杖对符合斩杀线的敌人施放淘汰之刃
	local r = RollPseudoRandomPercentage(trigger_chance, DOTA_PSEUDO_RANDOM_AXE_HELIX, caster)
	if not r then return end
    local units = {}
	local team = caster:GetTeam()
	local location = caster:GetAbsOrigin()
	local radius = ability:GetSpecialValueFor("radius")
	local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
	local typeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local flagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

    units = FindUnitsInRadius(team, location, nil, radius, teamFilter, typeFilter, flagFilter, FIND_ANY_ORDER, false)
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.damage = ability:GetSpecialValueFor("damage")
	damage_table.damage_type = DAMAGE_TYPE_ABILITY_DEFINED
	damage_table.ability = ability

	local tether = caster:FindAbilityByName("axe_culling_blade")
	local target_hp = attacker:GetHealth()
	local killed_hp = tether:GetSpecialValueFor("damage")

	for _,unit in pairs(units) do 

	    damage_table.victim = unit
	    ApplyDamage(damage_table)

		--A杖效果
		if caster:HasScepter() and target_hp <= killed_hp and attacker:IsRealHero() then
		    caster:SetCursorCastTarget(attacker)
            tether:OnSpellStart()
		end
	end

	--旋转并添加护甲力量加成
	local duration_buff = ability:GetSpecialValueFor("duration")
	local cooldown = ability:GetEffectiveCooldown(ability:GetLevel() - 1)	
	local modifier_helix_rotate = "modifier_counter_helix_rotate_datadriven"
	local modifier_helix_buff = "modifier_counter_helix_buff_datadriven"

	caster:EmitSound("Hero_Axe.CounterHelix")
	ability:ApplyDataDrivenModifier(caster, caster, modifier_helix_rotate, { duration = 0.21 })
	ability:ApplyDataDrivenModifier(caster, caster, modifier_helix_buff, { duration = duration_buff })
	ability:StartCooldown(cooldown)
end



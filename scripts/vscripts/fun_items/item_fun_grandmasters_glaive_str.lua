require('timers')
------------------------------------------------------------------------------------------------------

function item_fun_grandmasters_glaive_str_OnCreated(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = keys.caster

    ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_blade_mail", nil)  

    return
end

------------------------------------------------------------------------------------------------------

function item_fun_grandmasters_glaive_str_OnDestroy(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = keys.caster

    local buffs = caster:FindAllModifiersByName("modifier_item_blade_mail")
    for _,v in pairs(buffs) do
        if v:GetAbility() == ability then
            v:Destroy()
            break
        end
    end
	
    return
end

------------------------------------------------------------------------------------------------------

function item_fun_grandmasters_glaive_str_OnSpellStart(keys)
    if not IsServer() then return true end
    local caster = keys.caster
	local ability = keys.ability
	local active_duration = ability:GetSpecialValueFor("duration")
	caster:EmitSound("DOTA_Item.BladeMail.Activate")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_blade_mail_reflect", { duration = active_duration })
    return
end

------------------------------------------------------------------------------------------------------
--攻击对自身周围造成伤害，停用
function item_fun_grandmasters_glaive_str_OnAttackLanded(keys)
    if not IsServer() then return true end
	local caster = keys.caster
	local ability = keys.ability
	local chance = ability:GetSpecialValueFor("chance")
	local r = RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_AXE_HELIX_ATTACK, caster)

	if not r then return end

	local target = keys.target	
	local casterHP = caster:GetHealth()
	local damage = ability:GetSpecialValueFor("damage_const") + casterHP * ability:GetSpecialValueFor("damage_str_pct")/100
	local radius = ability:GetSpecialValueFor("radius")

	
	local enemies = FindUnitsInRadius(
		                caster:GetTeam(), 
						caster:GetAbsOrigin(), 
						self, 
						radius, 
						DOTA_UNIT_TARGET_TEAM_ENEMY, 
						DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
						DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
						FIND_ANY_ORDER,
						false)
	
	if #enemies > 0 then

		for _,enemy in pairs (enemies) do
			
			if enemy ~= nil then
				
				ApplyDamage({ victim = enemy, 
				              attacker = caster, 
							  damage = damage, 
							  damage_type = DAMAGE_TYPE_ABILITY_DEFINED,
							  damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, 
				              ability = ability
				              })		
			end
		end	
		caster:EmitSound("Hero_Axe.CounterHelix")
		local particleName = "particles/units/heroes/hero_axe/axe_attack_blur_counterhelix.vpcf"
		ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
	end			
	return	
end

------------------------------------------------------------------------------------------------------

function item_fun_grandmasters_glaive_str_OnAttacked(keys)
    if not IsServer() then return true end
    local caster = keys.caster
	local axe_helix = caster:FindAbilityByName("axe_jingtongdefanji")
	local axe_helix_lvl = 0
	if axe_helix then
	    axe_helix_lvl = axe_helix:GetLevel()
	end
    local attacker = keys.attacker 
    local ability = keys.ability
	local dur = ability:GetSpecialValueFor("stack_duration")

	if attacker:IsHero() then

		if true--caster:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH or 
		   --caster:HasItemInInventory("item_grandmasters_glaive_three_phase_power") 		
		then
			if axe_helix_lvl > 0 then
			    dur = dur --/ 2
			end
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_fun_grandmasters_glaive_str_stack", { duration = dur })
		end
	end
end

------------------------------------------------------------------------------------------------------

function item_fun_grandmasters_glaive_str_radiance_OnCreated(keys)
    if not IsServer() then return true end
    local ability = keys.ability
	local target = keys.target
	local caster  = keys.caster
	local particleName = "particles/econ/events/fall_2022/radiance_target_fall2022.vpcf"

	EmitSoundOnEntityForPlayer("DOTA_Item.Radiance.Target.Loop", target, target:GetPlayerOwnerID())
	local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
	--ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())

	target.modifier_radiance_str = target:FindModifierByName("modifier_item_fun_grandmasters_glaive_str_radiance")
	target.modifier_radiance_str.times = 0  --造成最大伤害前的计数
	target.modifier_radiance_str.stop = false  --是否停止粒子特效
	target.modifier_radiance_str.particleID = particle  --粒子特效ID
	target.modifier_radiance_str.particle_changed = false --粒子特效是否已改变

	Timers:CreateTimer(	
	    function()
		    if target == nil then return nil end
	        if target.modifier_radiance_str == nil then return nil end
			if target.modifier_radiance_str.stop == true then return nil end
			local particle_now = target.modifier_radiance_str.particleID
            ParticleManager:SetParticleControl(particle_now, 1, caster:GetAbsOrigin())
            return 0.5
		end
	)

	return
end

------------------------------------------------------------------------------------------------------

function item_fun_grandmasters_glaive_str_radiance_OnDestroy(keys)
    if not IsServer() then return true end
    local target = keys.target
	if target.modifier_radiance_str == nil then return end
	local particle = target.modifier_radiance_str.particleID
    StopSoundOn("DOTA_Item.Radiance.Target.Loop", target)
	ParticleManager:DestroyParticle(particle, false)
	ParticleManager:ReleaseParticleIndex(particle)

	target.modifier_radiance_str.times = nil
	target.modifier_radiance_str.stop = true
	target.modifier_radiance_str.particleID = nil
	target.modifier_radiance_str.particle_changed = nil
	target.modifier_radiance_str = nil

	return
end

------------------------------------------------------------------------------------------------------

function item_fun_grandmasters_glaive_str_radiance_OnIntervalThink(keys)
    if not IsServer() then return true end
    local ability = keys.ability
	local target = keys.target
	local caster = keys.caster
	local damage_base = ability:GetSpecialValueFor("aura_damage_base")
	local damage_str = 0 
	local max_damage_times = ability:GetSpecialValueFor("max_dmg_times")
	local modifier_radiance_str = target.modifier_radiance_str
	local times = modifier_radiance_str.times
	local particle = modifier_radiance_str.particleID

	if caster:IsIllusion() then
	    damage_str = caster:GetStrength() * ability:GetSpecialValueFor("aura_damage_str_illusion")
	else
	    damage_str = caster:GetStrength() * ability:GetSpecialValueFor("aura_damage_str")
	end

	local damage_table = {
		victim = target, 
        attacker = caster,
        --damage = 150,
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        ability = ability
	}
	if times < max_damage_times then
	    damage_table.damage = damage_base + times * damage_str /max_damage_times 
		modifier_radiance_str.times = modifier_radiance_str.times + 1
		times = modifier_radiance_str.times
	else
	    damage_table.damage = damage_base + damage_str
	end

	if times >= max_damage_times and
	   modifier_radiance_str.particle_changed == false 
	then
		local particleName = "particles/econ/events/spring_2021/radiance_spring_2021.vpcf"
		local particle_new = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:DestroyParticle(particle, false)
	    ParticleManager:ReleaseParticleIndex(particle)
	    ParticleManager:SetParticleControl(particle_new, 1, caster:GetAbsOrigin())
		modifier_radiance_str.particleID = particle_new
		modifier_radiance_str.particle_changed = true
	end
	ApplyDamage(damage_table)
	
	return
end
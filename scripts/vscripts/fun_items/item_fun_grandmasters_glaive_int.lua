require('utils')

function item_fun_grandmasters_glaive_int_OnCreated(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = keys.caster
    --以太
    --ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_aether_lens", nil)
end

function item_fun_grandmasters_glaive_int_OnDestroy(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = keys.caster
    --[[以太
    local buffs = caster:FindAllModifiersByName("modifier_item_aether_lens")
    for _,v in pairs(buffs) do
        if v:GetAbility() == ability then
            v:Destroy()
            return
        end
    end
    ]]
end

function item_fun_grandmasters_glaive_int_OnSpellStart(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target

    --妖术
    
    if target:TriggerSpellAbsorb(ability) then return end

    if target:IsIllusion() and
       not target:IsStrongIllusion()
    then 
        target:Kill(ability, caster)
        return
    end

    local sheep_duration = ability:GetSpecialValueFor("sheep_duration")
    target:EmitSound("DOTA_Item.Sheepstick.Activate")
    local modifier_sheep = target:AddNewModifier(caster, ability, "modifier_sheepstick_debuff", nil)
    modifier_sheep:SetDuration(sheep_duration, true)
    

    --虚灵之刃主动（已停用）
    --否决主动（已停用）
    --[[
    local projectile_speed = ability:GetSpecialValueFor("projectile_speed")
    local projectileTable = {	

		Ability = ability,
		--EffectName = "particles/items_fx/ethereal_blade.vpcf", --虚灵刀
        EffectName = "particles/items4_fx/nullifier_proj.vpcf",  --否决
		iMoveSpeed = projectile_speed,
		Source = caster,
		Target = target,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bProvidesVision = false,
		bReplaceExisting = false,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
    }
    --caster:EmitSound("DOTA_Item.EtherealBlade.Activate") --虚灵刀
    caster:EmitSound("DOTA_Item.Nullifier.Cast")  --否决
    ability.projectile = ProjectileManager:CreateTrackingProjectile(projectileTable)
    ]]
    return
end

function item_fun_grandmasters_glaive_int_OnAttackStart(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local target = keys.target
    local caster = keys.caster
    local modifier_cooldown = "modifier_item_fun_grandmasters_glaive_int_cooldown"
    local modifier_cannot_miss = "modifier_item_fun_grandmasters_glaive_int_cannot_miss"
    local cooldown_duration = ability:GetSpecialValueFor("impact_cooldown")

    caster:RemoveModifierByNameAndCaster(modifier_cannot_miss, caster)
    if caster:HasModifier(modifier_cooldown) or
       caster:IsIllusion() or
       caster:GetTeam() == target:GetTeam() 
    then
        return
    end
    ability:ApplyDataDrivenModifier(caster, caster, modifier_cannot_miss, nil)

    return
end


function item_fun_grandmasters_glaive_int_OnAttackLanded(keys)
    if not IsServer() then return true end
    local caster = keys.caster
	local target = keys.target

    if target == nil then return end

	local ability = keys.ability
	local cooldown = ability:GetEffectiveCooldown(ability:GetLevel() - 1)
    local damage = ability:GetSpecialValueFor("impact_dmg_const") + caster:GetIntellect(false) * ability:GetSpecialValueFor("impact_dmg_int")	
    local slow_time = ability:GetSpecialValueFor("impact_slow_time")
    local modifier_impact_slow = "modifier_item_fun_grandmasters_glaive_int_slow"
    local modifier_cooldown = "modifier_item_fun_grandmasters_glaive_int_cooldown"
    local modifier_cannot_miss = "modifier_item_fun_grandmasters_glaive_int_cannot_miss"
    local cooldown_duration = ability:GetSpecialValueFor("impact_cooldown")

	if caster:HasModifier(modifier_cooldown) or
       not target:IsAlive() or
       not caster:IsAlive() or
       target:IsBuilding() or
       target:IsMagicImmune() or
       caster:GetTeam() == target:GetTeam() or
       caster:IsIllusion()
    then
        return
    end
        
    local particleName = "particles/items_fx/phylactery.vpcf"
    particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)    
    ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), false)
    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), false)
    target:EmitSound("Item.Phylactery.Target")

    ability:ApplyDataDrivenModifier(caster, target, modifier_impact_slow, { duration = slow_time })
	ApplyDamage({ victim = target, 
                  attacker = caster, 
                  damage = damage, 
                  damage_type = DAMAGE_TYPE_ABILITY_DEFINED, 
                  --damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL,
                  ability = ability
                 })
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, damage, nil)        
    ability:ApplyDataDrivenModifier(caster, caster, modifier_cooldown, { duration = cooldown_duration })
    caster:RemoveModifierByNameAndCaster(modifier_cannot_miss, caster)

    return
end

function item_fun_grandmasters_glaive_int_OnAbilityExecuted(keys)
    if not IsServer() then return true end
    local caster = keys.caster
	local ability = keys.ability
    local target = keys.target
    local target_linken = HasSpellAbsorb(keys.target) --HasSpellAbsorb(target),来自utils.lua
    local event_ability = keys.event_ability
     
    --指向性技能被林肯抵挡后不会触发“静电场”和“灵匣”
    if target ~= nil and
       target_linken == nil
    then 
        return 
    end 
    keys.target = target

    if event_ability:IsItem() or
       event_ability:IsToggle() or
       event_ability:GetCooldown(event_ability:GetLevel() -1) <= 1 or
       not event_ability:ProcsMagicStick() or
       caster:IsIllusion()
    then
        return
    end

    --造成随机百分比伤害
    --[[
    units = FindUnitsInRadius(caster:GetTeam(), 
                              caster:GetAbsOrigin(), 
                              nil, 
                              ability:GetSpecialValueFor("aoe_radius"), 
                              DOTA_UNIT_TARGET_TEAM_ENEMY, 
                              DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
                              DOTA_UNIT_TARGET_FLAG_NONE, 
                              FIND_ANY_ORDER, 
                              false)

    local aoe_damage_pct_max = ability:GetSpecialValueFor("aoe_damage_pct_max")
    local aoe_damage_pct_min = ability:GetSpecialValueFor("aoe_damage_pct_min")
    local difference = aoe_damage_pct_max - aoe_damage_pct_min
    local step = 50 --伤害最大值与最小值之间存在50个梯度值
    local rand = 0

	for _,unit in pairs(units) do
        
        rand = RandomInt(0, step)
	    ApplyDamage({ victim = unit, 
                      attacker = caster, 
                      damage = unit:GetHealth() * (aoe_damage_pct_min + difference * rand / step ) /100, 
                      damage_type = DAMAGE_TYPE_MAGICAL, 
                      damage_flags = DOTA_DAMAGE_FLAG_HPLOSS,
                      ability = ability
                    })	
        local particleName = "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_time_lock_bash_hit.vpcf"
        local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN_FOLLOW, unit)
        ParticleManager:SetParticleControlEnt(particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), false)
    end
    ]]
    item_fun_grandmasters_glaive_int_OnAttackLanded(keys)

end

function item_fun_grandmasters_glaive_int_stack(keys)
    if not IsServer() then return true end
	local caster = keys.caster
    local ability = keys.ability
	local stack = math.floor(caster:GetIntellect(false) + 0.5)
    local modifier_name = "modifier_item_fun_grandmasters_glaive_int_spell_amp"

	if true then        
        caster:SetModifierStackCount(modifier_name, caster, stack)
	end
end

function item_fun_grandmasters_glaive_int_OnProjectileHitUnit(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    
    --否决
    local mute_duration = ability:GetSpecialValueFor("mute_duration")
    if target:TriggerSpellAbsorb(ability) then return end
    target:EmitSound("DOTA_Item.Nullifier.Target")
    target:AddNewModifier(caster, ability, "modifier_item_nullifier_mute", { duration = mute_duration })

    --虚灵之刃
    --[[
    local c_team = caster:GetTeam()
    local t_team = target:GetTeam()
    local debuff_duration = ability:GetSpecialValueFor("duration")
    local debuff_slow_duration = ability:GetSpecialValueFor("blast_movement_slow")

    if target:TriggerSpellAbsorb(ability) then return end

    target:EmitSound("DOTA_Item.EtherealBlade.Target")
    local debuff = target:AddNewModifier(caster, ability, "modifier_item_ethereal_blade_ethereal", {})
    debuff:SetDuration(debuff_duration, true)

    local damage_table = {}
    damage_table.victim = target
    damage_table.attacker = caster
    damage_table.damage = 0
    damage_table.damage_type = DAMAGE_TYPE_ABILITY_DEFINED
    damage_table.ability = ability
    local primary_stat = 0
    local blast_damage_base = ability:GetSpecialValueFor("blast_damage_base")
    local blast_agility_multiplier = ability:GetSpecialValueFor("blast_agility_multiplier")
    if target:IsHero() then
        primary_stat = target:GetPrimaryStatValue()
        if target:GetPrimaryAttribute() == DOTA_ATTRIBUTE_ALL then
            primary_stat = primary_stat * 0.6
        end
    end
    damage_table.damage = blast_damage_base + primary_stat * blast_agility_multiplier
    if c_team ~= t_team then
        
        local debuff_slow = target:AddNewModifier(caster, ability, "modifier_item_ethereal_blade_slow", { duration = debuff_slow_duration })
        debuff_slow:SetDuration(debuff_slow_duration, true)
        if target:IsMagicImmune() or 
           target:IsDebuffImmune() or
           (target:IsHero() and not target:IsIllusion()) or
           target:IsStrongIllusion() or
           target:IsAncient() or
           target:IsConsideredHero() or
           target:IsCreepHero()
        then
            ApplyDamage(damage_table)
        else
            target:Kill(ability, caster)
        end

    end
    ]]
end

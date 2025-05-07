require('timers')
require('utils')

function laguna_blade_fun_OnCreated(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    local modifier_range = "modifier_laguna_blade_fun_attack_range"
    if caster:PassivesDisabled() then return end
    ability:ApplyDataDrivenModifier(caster, caster, modifier_range, nil)
end

function laguna_blade_fun_OnDestroy(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local modifier_range = "modifier_laguna_blade_fun_attack_range"
    caster:RemoveModifierByName(modifier_range)
end

function laguna_blade_fun_OnStateChanged(keys)
    if not IsServer() then return true end
    local ability = keys.ability
	local caster = keys.caster
	local modifier_range = "modifier_laguna_blade_fun_attack_range"

	if caster:PassivesDisabled() and caster:HasModifier(modifier_range) then 
	    caster:RemoveModifierByName(modifier_range)
	elseif not caster:PassivesDisabled() and not caster:HasModifier(modifier_range) then
	    ability:ApplyDataDrivenModifier(caster, caster, modifier_range, nil)
	end
end

function laguna_blade_fun_OnAttack(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local ability_laguna_blade = caster:FindAbilityByName("lina_laguna_blade")  --神灭斩
    local ability_fiery_soul = caster:FindAbilityByName("lina_fiery_soul")      --炽魂
    local ability_slow_burn = caster:FindAbilityByName("lina_slow_burn")  --命石2的慢热

    local chance = ability:GetSpecialValueFor("chance")  
    local dmg_pct = ability:GetSpecialValueFor("dmg_pct")/100
    local cooldown = ability:GetSpecialValueFor("cooldown")
    

    --技能不触发的情况
    --自身被破坏、自身为幻象、攻击队友、攻击建筑、自身或目标阵亡、技能cd、大招不存在或者未学习
    if caster:PassivesDisabled() or            
       caster:IsIllusion() or
       caster:GetTeam() == target:GetTeam() or
       target:IsBuilding() or
       not caster:IsAlive() or
       not target:IsAlive() or
       not ability:IsCooldownReady() or
       ability_laguna_blade == nil
    then
        return
    end
    if ability_laguna_blade:GetLevel()<1 then return end

    --开始掷随机数
    local r = RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_ITEM_MKB, caster)
    if not r then return end

    --伤害
    local damage_table = {}
    local buff_fiery_soul = caster:FindModifierByName("modifier_lina_fiery_soul")
    local bonus_spell_damage = 0
    local buff_stack = 0
    local impact_damage_pct = 1 --慢热命石的直接伤害系数

    if ability_slow_burn then
        impact_damage_pct = ability_slow_burn:GetSpecialValueFor("impact_damage_pct")
    end

    if ability_fiery_soul then
        bonus_spell_damage = ability_fiery_soul:GetSpecialValueFor("bonus_spell_damage")
    end

    if buff_fiery_soul then
        buff_stack = buff_fiery_soul:GetStackCount()
    end

    damage_table.victim = target
    damage_table.attacker = caster
    damage_table.damage = (ability_laguna_blade:GetSpecialValueFor("damage") + buff_stack * bonus_spell_damage) * dmg_pct * impact_damage_pct
    damage_table.damage_type = ability_laguna_blade:GetAbilityDamageType()
    damage_table.damage_flags = DOTA_DAMAGE_FLAG_NO_DIRECTOR_EVENT
    damage_table.ability = ability

    --特效与声音
    local particle_name = "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf"
    local particleID = nil
    local offset = Vector(0,0,0)
    particleID = ParticleManager:CreateParticle(particle_name, PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(particleID, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", offset, false)
    ParticleManager:SetParticleControlEnt(particleID, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", offset, false)
    caster:EmitSound("Ability.LagunaBlade")
    target:EmitSound("Ability.LagunaBladeImpact")

    ApplyDamage(damage_table)

    local burn_duration = 0
    local amp_max_stack = ability:GetSpecialValueFor("amp_max_stack")
    local amp_duration = ability:GetSpecialValueFor("amp_duration")
    if ability_laguna_blade and ability_slow_burn then 
        burn_duration = ability_slow_burn:GetSpecialValueFor("burn_duration")
    end

	if burn_duration > 0 then 
        ability:ApplyDataDrivenModifier(caster, target, "modifier_laguna_blade_fun_slow_burn", { duration = burn_duration })  --慢热命石效果
        --慢热提供技能增强
        local buff_amp = caster:FindModifierByName("modifier_laguna_blade_fun_slow_burn_amp")
        if buff_amp then
            buff_amp:SetDuration(amp_duration,true)
            if buff_amp:GetStackCount() < amp_max_stack then
                buff_amp:IncrementStackCount()
            end
        else
            local buff_amp = ability:ApplyDataDrivenModifier(caster, caster, "modifier_laguna_blade_fun_slow_burn_amp", { duration = amp_duration })
            buff_amp:SetStackCount(1)
        end
    end

    --能量顶峰状态下不进入冷却
    if not caster:HasModifier("modifier_lina_super_charged") then
        ability:StartCooldown(cooldown)
    end
end

--每层炽魂提供护甲
function laguna_blade_fun_OnIntervalThink(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    if not caster:HasModifier("modifier_item_aghanims_shard") then return end
    local ability = keys.ability
    local buff_fiery_soul = caster:FindModifierByName("modifier_lina_fiery_soul")
    local buff_fiery_soul_armor = caster:FindModifierByName("modifier_laguna_blade_fun_fiery_soul_armor")
    local buff_stack = 0
    if buff_fiery_soul then
 
        buff_stack = buff_fiery_soul:GetStackCount()
        if buff_stack > 0 then
            if not buff_fiery_soul_armor then
                buff_fiery_soul_armor = ability:ApplyDataDrivenModifier(caster, caster, "modifier_laguna_blade_fun_fiery_soul_armor", {})
            end
            buff_fiery_soul_armor:SetStackCount(buff_stack)
        end
    else

        if buff_fiery_soul_armor then
            buff_fiery_soul_armor:Destroy()
        end
    end

end

--多重神灭斩
function laguna_blade_fun_OnAbilityExecuted(keys)
    --print("运行脚本")
    if not IsServer() then return true end
    local caster = keys.caster
    local target = HasSpellAbsorb(keys.target)
    local ability = keys.ability
    local event_ability = keys.event_ability
    local chance_scepter = ability:GetSpecialValueFor("chance_scepter")
    local modifier_laguna_blade_fun_multiple = "modifier_laguna_blade_fun_multiple"

    if event_ability:GetAbilityName() == "lina_laguna_blade" and 
       not caster:PassivesDisabled() and
       target ~= nil
    then
        if caster:HasScepter() then
            local modifer_temp = ability:ApplyDataDrivenModifier(caster, target, modifier_laguna_blade_fun_multiple, nil)
            modifer_temp:SetDuration(0.3, true)  --防止被状态抗性缩减
        end
        local supercharge_duration = event_ability:GetSpecialValueFor("supercharge_duration")
        if supercharge_duration > 0 then
            ability:EndCooldown()
        end
        
        local burn_duration = 0
        local amp_max_stack = ability:GetSpecialValueFor("amp_max_stack")
        local amp_duration = ability:GetSpecialValueFor("amp_duration")
        local ability_slow_burn = caster:FindAbilityByName("lina_slow_burn")  --命石2的慢热
        if event_ability:GetAbilityName() == "lina_laguna_blade" and ability_slow_burn then 
            burn_duration = ability_slow_burn:GetSpecialValueFor("burn_duration")
        end

	    if burn_duration > 0 then 
            --慢热提供技能增强
            local buff_amp = caster:FindModifierByName("modifier_laguna_blade_fun_slow_burn_amp")
            if buff_amp then
                buff_amp:SetDuration(amp_duration,true)
                if buff_amp:GetStackCount() < amp_max_stack then
                    buff_amp:IncrementStackCount()
                end
            else
                local buff_amp = ability:ApplyDataDrivenModifier(caster, caster, "modifier_laguna_blade_fun_slow_burn_amp", { duration = amp_duration })
                buff_amp:SetStackCount(1)
            end
        end
    end
end

function multiple_laguna_blade(keys)
    if not IsServer() then return true end  
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local ability_laguna_blade = caster:FindAbilityByName("lina_laguna_blade")
    local chance_scepter = ability:GetSpecialValueFor("chance_scepter")
    local modifier_laguna_blade_fun_multiple = "modifier_laguna_blade_fun_multiple"

    local r = RollPseudoRandomPercentage(chance_scepter, DOTA_PSEUDO_RANDOM_OGRE_MAGI_FIREBLAST, caster)
    if not r then 
        return    
    end

    local castable = target:IsAlive() and caster:IsAlive()
    if castable then
        local original_target = caster:GetCursorCastTarget()
        caster:SetCursorCastTarget(target)
        ability_laguna_blade:OnSpellStart() 
        caster:SetCursorCastTarget(original_target)
    end
    local modifer_temp = ability:ApplyDataDrivenModifier(caster, target, modifier_laguna_blade_fun_multiple, nil)
    modifer_temp:SetDuration(0.3, true)  --防止被状态抗性缩减
    return
end

function slow_burn_OnIntervalThink(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local ability_laguna_blade = caster:FindAbilityByName("lina_laguna_blade")  --神灭斩
    local ability_fiery_soul = caster:FindAbilityByName("lina_fiery_soul")      --炽魂
    local ability_slow_burn = caster:FindAbilityByName("lina_slow_burn")        --慢热

    --伤害
    local damage_table = {}
    local buff_fiery_soul = caster:FindModifierByName("modifier_lina_fiery_soul")
    local dmg_pct = ability:GetSpecialValueFor("dmg_pct")/100
    local bonus_spell_damage = 0
    local buff_stack = 0
    local burn_percent_tooltip = 0 --慢热命石的持续伤害系数

    if ability_slow_burn then
        burn_percent_tooltip = ability_slow_burn:GetSpecialValueFor("burn_percent_tooltip")
    end

    if ability_fiery_soul then
        bonus_spell_damage = ability_fiery_soul:GetSpecialValueFor("bonus_spell_damage")
    end

    if buff_fiery_soul then
        buff_stack = buff_fiery_soul:GetStackCount()
    end

    damage_table.victim = target
    damage_table.attacker = caster
    damage_table.damage = (ability_laguna_blade:GetSpecialValueFor("damage") + buff_stack * bonus_spell_damage) * dmg_pct * burn_percent_tooltip
    damage_table.damage_type = ability_laguna_blade:GetAbilityDamageType()
    damage_table.damage_flags = DOTA_DAMAGE_FLAG_NO_DIRECTOR_EVENT
    damage_table.ability = ability

    ApplyDamage(damage_table)

end
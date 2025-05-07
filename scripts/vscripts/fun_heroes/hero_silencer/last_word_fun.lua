function last_word_fun(keys)
     if not IsServer() then return true end
     local caster = keys.caster
     local target = keys.unit
     local ability = keys.ability
     local time = ability:GetSpecialValueFor("debuff_duration")
     local cooldown = ability:GetSpecialValueFor("cooldown")
     local event_ability = keys.event_ability
     local modifier_debuff_1 = "modifier_silencer_last_word_disarm"
     local modifier_debuff_2 = "modifier_last_word_fun_debuff"
     local modifier_cooldown = "modifier_last_word_fun_cooldown"

     local delay = keys.delay

     Timers:CreateTimer({
         endTime = delay,
         callback = function()

             --自身处于破坏/沉默/眩晕状态下、目标技能免疫、目标内置冷却期间不触发
             if caster:PassivesDisabled() or 
                caster:IsSilenced() or
                caster:IsStunned() or
                caster:IsHexed() or
                not caster:IsAlive() or
                target:IsMagicImmune() or 
                target:HasModifier(modifier_cooldown) or
                not caster:CanEntityBeSeenByMyTeam(target)
             then 
                 return 
             end  

             --物品类技能、持续施法类技能还未结束时、技能不充能魔棒（数据驱动类技能除外）不触发
             if event_ability:IsItem() or 
                event_ability:IsChanneling() or 
                (not event_ability:ProcsMagicStick() and event_ability:GetClassname() ~= "ability_datadriven")
             then 
                 return 
             end  

             target:EmitSound("Hero_Silencer.Curse")
             target:EmitSound("Hero_Silencer.Curse.Impact")

             ability:ApplyDataDrivenModifier(caster, target, modifier_debuff_2, { duration = time})        --沉默和减速
             --ability:ApplyDataDrivenModifier(caster, target, modifier_cooldown, { duration = cooldown})    --内置冷却          
         end
     })
     
end

function last_word_fun_OnCreated(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local particleName = "particles/units/heroes/hero_silencer/silencer_global_silence_hero.vpcf"
    local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), false)
end

function last_word_fun_OnDestroy(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local cooldown = ability:GetSpecialValueFor("cooldown")
    local modifier_cooldown = "modifier_last_word_fun_cooldown"
    ability:ApplyDataDrivenModifier(caster, target, modifier_cooldown, { duration = cooldown})    --内置冷却

end
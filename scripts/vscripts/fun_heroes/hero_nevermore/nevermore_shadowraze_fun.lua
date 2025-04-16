function shadowraze_fun(keys)
      
      target = keys.target
      caster = keys.caster
      ability = keys.ability
      raze = caster:FindAbilityByName("nevermore_shadowraze3")  --毁灭阴影C炮

      --if target:TriggerSpellAbsorb(ability) then
      --    return
      --end

      --真视效果,未学习毁灭阴影也生效
      ability:ApplyDataDrivenModifier(caster, target, "modifier_nevermore_shadowraze_fun_true_sight", nil) --{ duration = time}

      --检测是否学习或携带此技能
      if raze == nil or raze:GetLevel() < 1 or raze:GetLevel() > 4 then
           print("技能不存在或未学习！")
           return
      end
   
      ability:ApplyDataDrivenModifier(caster, target, "modifier_nevermore_shadowraze_fun_damage", nil)
 
      --print("技能施放成功！")     
 
end

-------------------------------------------------------------------------------------------------------------------

function shadowraze_fun_damage(keys)

      target = keys.target
      caster = keys.caster
      ability = keys.ability
      raze = caster:FindAbilityByName("nevermore_shadowraze3")    
      
      --搜寻范围
      units = FindUnitsInRadius(
          caster:GetTeamNumber(),                            
          target:GetOrigin(),                             
          caster,  
          raze:GetSpecialValueFor("shadowraze_radius"),         --毁灭阴影范围
          DOTA_UNIT_TARGET_TEAM_ENEMY,
          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
          DOTA_UNIT_TARGET_FLAG_NONE,
          FIND_ANY_ORDER,
          false )
      
      --播放音效和粒子特效
      target:EmitSound("Hero_Nevermore.Shadowraze.Arcana")
      local particleName = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf"
	  local particle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, target)


      --造成伤害，根据初始伤害、每个单位的DEBUFF层数、天赋学习情况，然后造成伤害
      for k, unit in pairs(units) do
           
           local total_damage = raze:GetSpecialValueFor("shadowraze_damage")
           local stack_damage = raze:GetSpecialValueFor("stack_bonus_damage")

           local bonus_damage = caster:FindAbilityByName("special_bonus_unique_nevermore_2")       --毁灭阴影伤害
           local bonus_stack_damage = caster:FindAbilityByName("special_bonus_unique_nevermore_7")       --连中伤害
           local procsattacks = caster:FindAbilityByName("special_bonus_unique_nevermore_raze_procsattacks")  --附带普攻

           --直接伤害，学习毁灭阴影伤害天赋
           if bonus_damage then
               total_damage = total_damage + bonus_damage:GetSpecialValueFor("value")
           end

           --V社格式原因，不需要计算连中伤害天赋       
           --计算连中伤害
           local stack = unit:GetModifierStackCount("modifier_nevermore_shadowraze_debuff", caster)
           total_damage = total_damage + stack * stack_damage
 
           local damage = {
               victim = unit,
               attacker = caster,
               damage = total_damage,
               damage_type = DAMAGE_TYPE_ABILITY_DEFINED,
               damage_flags = DOTA_DAMAGE_FLAG_NONE,
               ability = keys.ability,
           }
           ApplyDamage(damage)
          
           --提升DEBUFF层数
           if stack == 0 then
               unit:AddNewModifier(caster, raze, "modifier_nevermore_shadowraze_debuff", { duration = raze:GetSpecialValueFor("duration")})
               unit:SetModifierStackCount("modifier_nevermore_shadowraze_debuff", caster, 1)
           elseif stack >=1 then
               unit:SetModifierStackCount("modifier_nevermore_shadowraze_debuff", caster, stack+1)
               local shadowraze_debuff = unit:FindModifierByName("modifier_nevermore_shadowraze_debuff")
               shadowraze_debuff:ForceRefresh()
           end

           --普攻天赋
           if procsattacks and raze:GetSpecialValueFor("procs_attack") == 1 then
               caster:PerformAttack(target, true, true, true, false, false, false, true)
           end
      end
      --print("造成伤害成功！")
      
end

-------------------------------------------------------------------------------------------------------------------

function cannot_be_stolen(keys)

     --print("这个技能不可以被拉比克偷取！")
     local caster = keys.caster
     local ability = caster:FindAbilityByName("nevermore_shadowraze_fun")

     ability:SetStealable(false)

     return
end

-------------------------------------------------------------------------------------------------------------------
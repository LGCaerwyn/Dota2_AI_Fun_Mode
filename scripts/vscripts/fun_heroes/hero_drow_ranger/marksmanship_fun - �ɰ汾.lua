
death = 0   --死亡丢失层数
total = 0   --总层数
------------------------------------------------------------------------------

function marksmanship(keys)        --根据K/D/A添加BUFF层数

     local caster = keys.caster
     local ability = keys.ability
     local modifier_buff = keys.ModifierName_buff

     local kill = caster:GetKills() * ability:GetSpecialValueFor("kill_count")
     local assist = caster:GetAssists() * ability:GetSpecialValueFor("assist_count")
     total = kill + assist - death

     if total <=0 then
          total = 0  --死亡复活后没有BUFF层数，不需要移除操作
          return 
     else
          ability:ApplyDataDrivenModifier(caster, caster, modifier_buff , {})
          caster:SetModifierStackCount(modifier_buff, caster, total)         
     end

     return
end

------------------------------------------------------------------------------

function marksmanship_damage(keys)      --攻击到达时造成伤害
  
     if keys.target:IsBuilding() then
         return           --伤害对建筑无效
     end

     if total <= 0 then   --层数为0不造成伤害
         return
     end

     local caster = keys.caster
     local target = keys.target
     local Damage = keys.ability:GetSpecialValueFor("damage")

     local damage_table = {
         	victim = target,
			attacker = caster,
			damage = Damage * total,
			damage_type = DAMAGE_TYPE_PHYSICAL ,  --伤害类型在KV中定义
            ability = keys.ability,
     }
     SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, damage_table.damage, nil)  --伤害信息，例如智慧之刃、奥数天球、金箍棒造成的伤害会显示在目标头顶附近
     ApplyDamage(damage_table)

     return
end

------------------------------------------------------------------------------

function addDeaths(keys)

     local caster = keys.caster
     local ability = keys.ability

     local d = ability:GetSpecialValueFor("death_lose")
     if total >= d then  
         death = death + d       -- 一次死亡没有丢失全部层数
     else
         death = death + total   -- 一次死亡丢失全部层数
     end

     return
end

------------------------------------------------------------------------------

function FireSound(keys)

     if not keys.caster:IsIllusion() then
        EmitAnnouncerSound("Hero_DrowRanger.Marksmanship_Fun.Created") --全场播放该声音
     end

     return
end
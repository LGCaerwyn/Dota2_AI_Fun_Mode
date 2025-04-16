

function treant_force_of_nature( keys )
	-- body


	local caster = keys.caster
	local target = keys.target
    local ability = keys.ability
    local splash_damage = ability:GetSpecialValueFor("splash_damage")
    local chance = ability:GetSpecialValueFor("chance")
    local splash_radius = ability:GetSpecialValueFor("splash_radius")



    -- 判断是否处于近战状态
    if caster:IsRangedAttacker() then
       chance = chance * 2 
    end
    print("执行伤害前")
	-- 以一定概率触发溅射伤害
   	-- local chance = ability:GetSpecialValueFor("chance")
    if RandomInt(1, 100) > chance then
        return nil
    end
    print("执行伤害")
    -- 计算溅射范围内的敌人
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, splash_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER, false)


    -- 对每个敌人造成溅射伤害
 --   local damage = attacker:GetAttackDamage() * 0.5  -- 溅射伤害为基础攻击力的50%
    local damage = caster:GetAverageTrueAttackDamage(nil) * splash_damage
    for _, enemy in pairs(enemies) do
        local damage_table = {
            victim = enemy,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = ability,
        }
        ApplyDamage(damage_table)
    end

end
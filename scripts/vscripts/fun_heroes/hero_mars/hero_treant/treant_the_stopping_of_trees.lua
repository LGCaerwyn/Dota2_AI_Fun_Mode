function OnCreated(keys)
    local caster = keys.caster
    local ability = keys.ability
    local model_dir = keys.model_dir
    local model = keys.model_rad
    local projectile_model = keys.projectile_model
    if caster:GetTeamNumber() == 3 then
       model = model_dir
    end

    if caster.caster_model == nil then 
        caster.caster_model = caster:GetModelName()
    end
    caster.caster_attack = caster:GetAttackCapability()
    caster:SetModel(model)
    caster:SetOriginalModel(model)
    caster:SetRangedProjectileName(projectile_model)

    
    caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)

    -- 停止当前动作并设置模型
    --caster:Stop()
    --caster:SetModel("models/heroes/treant_protector/treant_protector_tree.vmdl")
    --caster:SetOriginalModel("models/heroes/treant_protector/treant_protector_tree.vmdl")



    -- 增加攻击范围和溅射伤害加成
    --local attack_range_bonus = ability:GetSpecialValueFor("attack_range_bonus")
    --local splash_damage_bonus_percent = ability:GetSpecialValueFor("splash_damage_bonus_percent")
    --caster:AddNewModifier(caster, ability, "modifier_tree_rooted_buff", {duration = duration, attack_range_bonus = attack_range_bonus,splash_damage_bonus_percent = splash_damage_bonus_percent})


end



function OnDestroy(keys)
    local caster = keys.caster
    local ability = keys.ability
    -- 恢复动作和模型
    --caster:SetModel("models/heroes/treant_protector/treant_protector.vmdl")
    --caster:SetOriginalModel("models/heroes/treant_protector/treant_protector.vmdl")
    caster:SetModel(caster.caster_model)
    caster:SetOriginalModel(caster.caster_model)
    caster:SetAttackCapability(caster.caster_attack)
    -- 移除攻击范围和溅射伤害加成
   -- caster:RemoveModifierByName("modifier_tree_rooted_buff")
end
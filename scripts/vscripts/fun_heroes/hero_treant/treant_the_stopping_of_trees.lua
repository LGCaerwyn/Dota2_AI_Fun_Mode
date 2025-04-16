function OnCreated(keys)
    local caster = keys.caster
    local ability = keys.ability
    local model_dir = keys.model_dir
    local model = keys.model_rad
    local projectile_model = keys.projectile_model_rad--keys.projectile_model
    local projectile_model_dir = keys.projectile_model_dir
    local projectile_model_rad = keys.projectile_model_rad
    
    if caster:GetTeamNumber() == 3 then
       model = model_dir
       projectile_model = projectile_model_dir
    end

    if caster.caster_model == nil then 
        caster.caster_model = caster:GetModelName()
    end
    caster.caster_attack = caster:GetAttackCapability()
    caster:SetModel(model)
    caster:SetOriginalModel(model)
    caster:SetRangedProjectileName(projectile_model)

    caster:SetModelScale(1.3)
    caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)-- DOTA_UNIT_CAP_RANGED_ATTACK_DIRECTIONAL
    caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
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
    caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
    caster:SetModelScale(1.0)
    -- 移除攻击范围和溅射伤害加成
   -- caster:RemoveModifierByName("modifier_tree_rooted_buff")
end

function tower( keys )
    -- body


local  caster =keys.caster
local  target = keys.target
local  ability = keys.ability

caster:ForcePlayActivityOnce(ACT_DOTA_CAPTURE)--ACT_DOTA_CUSTOM_TOWER_IDLE  ACT_DOTA_CAPTURE

--caster:Stop()
--print("开始攻击")

--print(caster:GetSpellAmplification(false))

--print(caster:GetAttacksPerSecond(false))
--print(caster:GetAttacksPerSecond(true))
caster_attacksper = caster:GetAttacksPerSecond(false)

--y = -0.15*caster_attacksper + 1
y = caster_attacksper
--print(y)
--ability:ApplyDataDrivenModifier(caster, caster, "modifier_blademaster_windwalk_startgesture", {duration = 0.9 * y })

--caster:StartGesture(ACT_DOTA_ATTACK_TAUNT)

caster:StartGestureWithPlaybackRate(ACT_DOTA_CUSTOM_TOWER_ATTACK ,caster_attacksper)


end


function ability_level( keys )
    -- body

    local ability = keys.ability
    local caster = keys.caster
    local A = caster:FindAbilityByName("treant_the_stopping_of_trees_no")
--    local B = caster:FindAbilityByName("ember_spirit_flame_charge_close")
      A:SetLevel(ability:GetLevel())
    --  B:SetLevel(ability:GetLevel())
end
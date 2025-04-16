
--大圣毁天灭地

function LifeBreak( keys )
    if not IsServer() then return true end
    -- Variables
    local ability = keys.ability
    ability.caster = keys.caster
    ability.target = keys.target
    local caster = ability.caster
    local target = ability.target

    --林肯抵挡
    local absorb = target:TriggerSpellAbsorb(ability)
    local abilityName = ability:GetAbilityName()
	if absorb == true then 
        return 
    end
    --暂时处理：对方没有此技能只会触发抵挡，不会触发反弹
    if not caster:HasAbility(abilityName) then   
        return
    end

    --冲刺阶段
    ability.velocity = ability:GetSpecialValueFor("charge_speed") / 30  --冲刺阶段速率：每0.03秒的位移长度
    ability.life_break_z = 0                                            --冲刺阶段当前垂直高度
    ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target) - GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()  --二者初始距离
    ability.traveled = 0                                                --冲刺阶段总路程
    --飞升阶段
	ability.forced_direction = target:GetUpVector()                         --飞升阶段上升方向 
	ability.forced_distance = ability:GetSpecialValueFor("push_length")     --飞升阶段最高距离  
	ability.forced_speed = ability:GetSpecialValueFor("push_speed") / 30	--飞升阶段速率：每0.03秒的位移长度
	ability.forced_traveled = 0                                             --飞升阶段总路程
	ability.leap_z = 0                                                      --飞升阶段当前垂直高度
    --撞击阶段
    ability.stun_duration = ability:GetSpecialValueFor("stun_duration")     --眩晕时间
    ability.radius = ability:GetSpecialValueFor("radius")                   --撞击范围

	-- 音效与特效
	caster:EmitSound("Hero_Huskar.Life_Break")
	local particleName1 = "particles/units/heroes/hero_huskar/huskar_life_break_cast.vpcf"
	local particleName2 = "particles/econ/items/monkey_king/arcana/fire/monkey_king_spring_cast_arcana_fire.vpcf"
	local p1 = ParticleManager:CreateParticle(particleName1, PATTACH_ABSORIGIN_FOLLOW, caster) 
	local p2 = ParticleManager:CreateParticle(particleName2, PATTACH_ABSORIGIN, target) 

    -- Save modifiernames in ability
	ability.modifier_start = "modifier_monkey_king_huitianmiedi_boss_start"        --冲刺阶段
    ability.modifier_fly = "modifier_monkey_king_huitianmiedi_boss_fly"            --飞升阶段
    ability.modifier_fly_stop = "modifier_monkey_king_huitianmiedi_boss_fly_stop"  --飞升阶段停止行动
	ability.modifier_shanghai = "modifier_monkey_king_huitianmiedi_boss_damage"    --落地击飞周围单位

	ability:ApplyDataDrivenModifier(caster, caster, ability.modifier_start, { duration = 30 })
    caster:Hold()
	return
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--自动对目标发动攻击，停用
function AutoAttack(caster, target)
        if not IsServer() then return true end
        order = 
        {
            UnitIndex = caster:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = target:GetEntityIndex(),
            Queue = true
        }
        ExecuteOrderFromTable(order)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--向目标冲刺阶段的水平位移
function JumpHorizonal(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = ability.caster
	local target = ability.target

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local direction = (target_loc - caster_loc):Normalized()
    local max_distance = ability:GetSpecialValueFor("max_distance")

    if (target_loc - caster_loc):Length2D() >= max_distance then
        caster:RemoveModifierByName(ability.modifier_start)
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), false)
        order = 
        {
            UnitIndex = keys.target:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
            Position = keys.target:GetAbsOrigin(),
            Queue = true
        }
        ExecuteOrderFromTable(order)
        return

    elseif (target_loc - caster_loc):Length2D() > 100 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.velocity)
        ability.traveled = ability.traveled + ability.velocity
    else
        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
		OnMotionDone(caster, target, ability)
    end
    return
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--向目标冲刺阶段的垂直位移
function JumpVertical( keys )
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = ability.caster

    local caster_loc = caster:GetAbsOrigin()
    local caster_loc_ground = GetGroundPosition(caster_loc, caster)

    if caster_loc.z < caster_loc_ground.z then
    	caster:SetAbsOrigin(caster_loc_ground)
    end

    if ability.traveled < ability.initial_distance/2 then
        ability.life_break_z = ability.life_break_z + ability.velocity/2
        caster:SetAbsOrigin(caster_loc_ground + Vector(0,0,ability.life_break_z))
    elseif caster_loc.z > caster_loc_ground.z then
        ability.life_break_z = ability.life_break_z - ability.velocity/2
        caster:SetAbsOrigin(caster_loc_ground + Vector(0,0,ability.life_break_z))
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--冲刺阶段位移结束
function OnMotionDone(caster, target, ability)
    if not IsServer() then return true end
    local modifier_start = ability.modifier_start
    local modifier_fly = ability.modifier_fly
    local modifier_fly_stop = ability.modifier_fly_stop
	if caster:FindModifierByName(modifier_start) then
        caster:RemoveModifierByName(modifier_start)
	end

    EmitSoundOn("Hero_Huskar.Life_Break.Impact", target)

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_life_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(particle)

	ability:ApplyDataDrivenModifier(caster, caster, modifier_fly, nil)
    ability:ApplyDataDrivenModifier(caster, caster, modifier_fly_stop, nil)
    if not (target:IsMagicImmune() or target:IsDebuffImmune())then
        ability:ApplyDataDrivenModifier(caster, target, modifier_fly_stop, nil)
        target:Hold()
    end
    ability.AoE_Location = GetGroundPosition(target:GetAbsOrigin(), target)  --击飞伤害与特效的位置
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--飞升/落地阶段
function LeapVertical(keys)
    if not IsServer() then return true end
	local ability = keys.ability
	local caster = ability.caster
    local target = ability.target
    local modifier_fly = ability.modifier_fly
    local modifier_fly_stop = ability.modifier_fly_stop

    if math.floor(ability.forced_traveled + 0.5) < ability.forced_distance then

        ability.leap_z = ability.leap_z + ability.forced_speed   
		ability.forced_traveled = ability.forced_traveled + ability.forced_speed
        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
        if target:HasModifier(modifier_fly_stop) then
            target:SetAbsOrigin(GetGroundPosition(target:GetAbsOrigin(), target) + Vector(0,0,ability.leap_z))
        end

    elseif math.floor(ability.forced_traveled +0.5) < ability.forced_distance * 2  then  

        ability.leap_z = ability.leap_z - ability.forced_speed 
		ability.forced_traveled = ability.forced_traveled + ability.forced_speed  
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))		
        if target:HasModifier(modifier_fly_stop) then
            target:SetAbsOrigin(GetGroundPosition(target:GetAbsOrigin(), target) + Vector(0,0,ability.leap_z))
        end      
    else
        DoDamage(caster, target, ability)
    end
    return
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--落地伤害
function DoDamage(caster, target, hAbility)
    if not IsServer() then return true end
    local isSuccessful = false --判断是否抱摔目标成功
    local modifier_fly = hAbility.modifier_fly
    local modifier_fly_stop = hAbility.modifier_fly_stop
    local stun_duration = hAbility.stun_duration
    local radius = hAbility.radius

    caster:RemoveModifierByName(modifier_fly)
    caster:RemoveModifierByName(modifier_fly_stop)
    FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), false)

    if target:HasModifier(modifier_fly_stop) then
        isSuccessful = true
        target:RemoveModifierByName(modifier_fly_stop)
        FindClearSpaceForUnit(target, target:GetAbsOrigin(), false)
        local dmg_table_target = {
                                   victim = target,
                                   attacker = caster,
                                   damage = target:GetHealth() * 0.7,
                                   damage_type = DAMAGE_TYPE_PURE,
							       damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
							       ability = hAbility
                                  }
        ApplyDamage(dmg_table_target)
        hAbility:ApplyDataDrivenModifier(caster, target, "modifier_stunned", { duration = hAbility.stun_duration })
    end

	units = FindUnitsInRadius(caster:GetTeamNumber(), 
			                  hAbility.AoE_Location, 
							  target, 
							  radius, 
			                  DOTA_UNIT_TARGET_TEAM_ENEMY, 
			                  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			                  DOTA_UNIT_TARGET_FLAG_NONE, 
						      FIND_CLOSEST, 
							  false)

	for i,unit in ipairs(units) do
        if unit == target then
            if isSuccessful == false and not (unit:IsMagicImmune() or unit:IsDebuffImmune())then
                hAbility:ApplyDataDrivenModifier(caster, unit, hAbility.modifier_shanghai, { duration = stun_duration})  --击飞伤害不会对主目标造成二次伤害
            end
        elseif unit ~= target then
            if not (unit:IsMagicImmune() or unit:IsDebuffImmune())then
                hAbility:ApplyDataDrivenModifier(caster, unit, hAbility.modifier_shanghai, { duration = stun_duration})
            end
        end
	end	

    EmitSoundOnLocationWithCaster(hAbility.AoE_Location, "Hero_EarthShaker.EchoSlam", caster)
    local particleName = "particles/econ/items/monkey_king/arcana/fire/monkey_king_spring_arcana_fire.vpcf"
    local particle = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, hAbility.AoE_Location)
    ParticleManager:SetParticleControl(particle, 1, Vector(800, 800, 1))
    order = 
        {
            UnitIndex = caster:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
            Position = target:GetAbsOrigin(),
            Queue = true
        }
    ExecuteOrderFromTable(order)
	return 
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function OnDeath(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local target = ability.target
    local caster = ability.caster
    local modifier_fly_stop = target:FindModifierByName(ability.modifier_fly_stop)
    modifier_fly_stop:Destroy()   

    local t_ground_pos = GetGroundPosition(target:GetAbsOrigin() ,nil)
    local c_ground_pos = GetGroundPosition(caster:GetAbsOrigin() ,nil)
    target:SetAbsOrigin(t_ground_pos)
    caster:SetAbsOrigin(c_ground_pos)
    return
end

















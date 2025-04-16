
--大圣毁天灭地

function LifeBreak( keys )
    -- Variables
    local ability = keys.ability
    ability.caster = keys.caster
    ability.target = keys.target
    local caster = ability.caster
    local target = ability.target

    --林肯抵挡，对大圣的技能不触发
    --[[
    local absorb = target:TriggerSpellAbsorb(ability)
    local abilityName = ability:GetAbilityName()
	if absorb == true then 
        return 
    end
    --暂时处理：对方没有此技能只会触发抵挡，不会触发反弹
    if not caster:HasAbility(abilityName) then   
        return
    end
    ]]

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
	ability.modifier_start = "modifier_monkey_king_huitianmiedi_start"        --冲刺阶段
    ability.modifier_fly = "modifier_monkey_king_huitianmiedi_fly"            --飞升阶段
    ability.modifier_fly_stop = "modifier_monkey_king_huitianmiedi_fly_stop"  --飞升阶段停止行动
	ability.modifier_shanghai = "modifier_monkey_king_huitianmiedi_damage"    --落地击飞周围单位

	ability:ApplyDataDrivenModifier(caster, caster, ability.modifier_start, { duration = 30 })
    caster:Hold()
	return
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--自动对目标发动攻击(对大圣启用，对獸停用)
function AutoAttack(caster, target)
        order = 
        {
            UnitIndex = caster:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
            TargetIndex = target:GetEntityIndex(),
            Queue = true
        }

        ExecuteOrderFromTable(order)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--向目标冲刺阶段的水平位移
function JumpHorizonal(keys)

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
    --大圣的技能无视技能免疫和减益免疫
    --if not (target:IsMagicImmune() or target:IsDebuffImmune())then
        ability:ApplyDataDrivenModifier(caster, target, modifier_fly_stop, nil)
        target:Stop()
    --end
    ability.AoE_Location = GetGroundPosition(target:GetAbsOrigin(), target)  --击飞伤害与特效的位置
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--飞升/落地阶段
function LeapVertical(keys)

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
        AutoAttack(caster, target)
    end
    return
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--落地伤害
function DoDamage(caster, target, hAbility)
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

        --根据A杖效果造成不同伤害 
        local damage_fixed = 0      
        local damage_type_fixed = 0
        local damage_flags_fixed = 0

        if caster:HasScepter() then
            damage_fixed = target:GetMaxHealth() * hAbility:GetSpecialValueFor("damage_pct_scepter") * 0.01
            damage_type_fixed = DAMAGE_TYPE_PURE
            damage_flags_fixed = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION 
        else
            damage_fixed = target:GetMaxHealth() * hAbility:GetSpecialValueFor("damage_pct") * 0.01
            damage_type_fixed = DAMAGE_TYPE_PHYSICAL
            damage_flags_fixed = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
        end

        local dmg_table_target = {
                                   victim = target,
                                   attacker = caster,
                                   damage = damage_fixed,
                                   damage_type = damage_type_fixed,
							       damage_flags = damage_flags_fixed,
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
    --粒子特效
	if caster:HasScepter() then

	    target:EmitSound("Hero_EarthShaker.EchoSlam.Arcana")
		target:EmitSound("Hero_EarthShaker.EchoSlamEcho.Arcana")
		target:EmitSound("Hero_Earthshaker.Arcana.GlobalLayer1")
		target:EmitSound("Hero_Earthshaker.Arcana.GlobalLayer2")

		local particleName1 = "particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf"
		local particle1 = ParticleManager:CreateParticle(particleName1, PATTACH_ABSORIGIN, target)
	
		local particleName2 = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_echoslam_start_v2.vpcf"
		local particle2 = ParticleManager:CreateParticle(particleName2, PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControl(particle2, 10, Vector(5,0,0))
		ParticleManager:SetParticleControl(particle2, 11, Vector(1,1,0))
	
		local particleName3 = "particles/units/heroes/hero_warlock/warlock_rain_of_chaos.vpcf"
		local particle3 = ParticleManager:CreateParticle(particleName3, PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControl(particle3, 60, Vector(255,255,0))
		ParticleManager:SetParticleControl(particle3, 61, Vector(1,0,0))
		ParticleManager:SetParticleControl(particle3, 1, Vector(300,1,1))
	end
    EmitSoundOnLocationWithCaster(hAbility.AoE_Location, "Hero_EarthShaker.EchoSlam", caster)
    local particleName = "particles/econ/items/monkey_king/arcana/fire/monkey_king_spring_arcana_fire.vpcf"
    local particle = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, hAbility.AoE_Location)
    ParticleManager:SetParticleControl(particle, 1, Vector(800, 800, 1))

	return 
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function remove_particle(keys)
    local caster = keys.caster
    local modifier_1 = "modifier_item_ultimate_scepter"
	local modifier_2 = "modifier_item_ultimate_scepter_consumed"
	local modifier_3 = "modifier_item_ultimate_scepter_consumed_alchemist"

	if not caster:HasScepter() then return end
	if caster:HasModifier(modifier_1) and caster:HasModifier(modifier_2) then return end
	if caster:HasModifier(modifier_2) or caster:HasModifier(modifier_3) then
	    caster:RemoveModifierByName(modifier_2)
        caster:RemoveModifierByName(modifier_3)
	end
	if not caster:HasModifier(modifier_1) then
	    caster:AddNewModifier(caster, ability, "modifier_item_ultimate_scepter",nil)
	end
	--print("执行粒子特效脚本")
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------

function OnDeath(keys)

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















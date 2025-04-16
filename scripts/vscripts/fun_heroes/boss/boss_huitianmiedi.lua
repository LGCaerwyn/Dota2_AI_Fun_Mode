
--大圣毁天灭地

function LifeBreak( keys )
    -- Variables
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local charge_speed = ability:GetSpecialValueFor("charge_speed") / 30

    local absorb = target:TriggerSpellAbsorb(ability)
    local abilityName = ability:GetAbilityName()
 
	if absorb == true then 
        return 
    end
    --暂时处理：对方没有此技能只会触发抵挡，不会触发反弹
    if not caster:HasAbility(abilityName) then   
        return
    end
    
	-- 音效与特效
	caster:EmitSound("Hero_Huskar.Life_Break")
	local particleName1 = "particles/units/heroes/hero_huskar/huskar_life_break_cast.vpcf"
	local particleName2 = "particles/econ/items/monkey_king/arcana/fire/monkey_king_spring_cast_arcana_fire.vpcf"
	local p1 = ParticleManager:CreateParticle(particleName1, PATTACH_ABSORIGIN_FOLLOW, caster) 
	local p2 = ParticleManager:CreateParticle(particleName2, PATTACH_ABSORIGIN, target) 

    -- Save modifiernames in ability
	ability.modifier_start = "modifier_monkey_king_huitianmiedi_boss_start"        --冲刺阶段
    ability.modifier_fly = "modifier_monkey_king_huitianmiedi_boss_fly"            --升空阶段

	ability.modifier_shanghai = "modifier_monkey_king_huitianmiedi_boss_damage"
	ability.modifier_jifei_youjun = "modifier_monkey_king_huitianmiedi_boss_jifei_youjun"	

    -- Motion Controller Data
    ability.target = target            --技能目标
    ability.velocity = charge_speed    --冲刺阶段速度    
    ability.life_break_z = 0           --冲刺阶段垂直高度
    ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target)-GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()  --初始距离
    ability.traveled = 0               --冲刺阶段总路程

	ability.forced_direction = target:GetUpVector()                         --升空阶段方向 
	ability.forced_distance = ability:GetSpecialValueFor("push_length")     --升空阶段最高位移  
	ability.forced_speed = ability:GetSpecialValueFor("push_speed") / 30	--升空阶段速度	
	ability.forced_traveled = 0                                             --升空阶段总路程
	ability.leap_z = 0                                                      --升空阶段垂直高度

	ability:ApplyDataDrivenModifier(caster, caster, ability.modifier_start, { duration = 30 })

	return
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--落地伤害
function DoDamage(caster, target, hAbility)
         
    if target:HasModifier(hAbility.modifier_fly) then
        local dmg_table_target = {
                                   victim = target,
                                   attacker = caster,
                                   damage = target:GetHealth() * 0.7,
                                   damage_type = DAMAGE_TYPE_PURE,
							   	   damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
								   ability = hAbility
                                  }
        --hAbility:ApplyDataDrivenModifier(caster, target, "modifier_stunned", { duration = 3 }) 
        ApplyDamage(dmg_table_target)
    end

    EmitSoundOnLocationWithCaster(hAbility.AoE_Location, "Hero_EarthShaker.EchoSlam", caster)
    local particleName = "particles/econ/items/monkey_king/arcana/fire/monkey_king_spring_arcana_fire.vpcf"
    local particle = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, hAbility.AoE_Location)
    ParticleManager:SetParticleControl(particle, 1, Vector(800, 800, 1))
	units = FindUnitsInRadius(caster:GetTeamNumber(), 
			                  hAbility.AoE_Location, 
							  caster, 
							  800, 
			                  DOTA_UNIT_TARGET_TEAM_BOTH, 
			                  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			                  DOTA_UNIT_TARGET_FLAG_NONE, 
						      FIND_CLOSEST, 
							 false)

	for i,unit in ipairs(units) do
		if unit:GetTeamNumber() == caster:GetTeamNumber() and unit ~= caster  then
	        hAbility:ApplyDataDrivenModifier(caster, unit, hAbility.modifier_jifei_youjun, {})
	    elseif unit:GetTeamNumber() ~= caster:GetTeamNumber() and unit~= target then
			hAbility:ApplyDataDrivenModifier(caster, unit, hAbility.modifier_shanghai, {})  --击飞伤害不会对魔免的主目标造成二次伤害
		end
	end	
	return 
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--自动对目标发动攻击，停用
function AutoAttack(caster, target)
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
function JumpHorizonal( keys )

    local caster = keys.target
    local ability = keys.ability
	local target = ability.target

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local direction = (target_loc - caster_loc):Normalized()
    local max_distance = ability:GetSpecialValueFor("max_distance")

    if (target_loc - caster_loc):Length2D() >= max_distance then
    	caster:InterruptMotionControllers(true)
        caster:RemoveModifierByName(modifier_start)
    end

    if (target_loc - caster_loc):Length2D() > 100 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.velocity)
        ability.traveled = ability.traveled + ability.velocity
    else
        caster:InterruptMotionControllers(true)
        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
		OnMotionDone(caster, target, ability)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--向目标冲刺阶段的垂直位移
function JumpVertical( keys )

    local caster = keys.target
    local ability = keys.ability
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

	if caster:FindModifierByName(modifier_start) then
        caster:RemoveModifierByName(modifier_start)
	end

    EmitSoundOn("Hero_Huskar.Life_Break.Impact", target)

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_life_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(particle)

	ability:ApplyDataDrivenModifier(caster, caster, modifier_fly, {duration = 3 }) --duration = 3
    if not target:IsMagicImmune() then
        ability:ApplyDataDrivenModifier(caster, target, modifier_fly, {duration = 6 }) --duration = 6
    end
    ability.AoE_Location = GetGroundPosition(target:GetAbsOrigin(), target)  --击飞伤害与特效的位置
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--飞升/落地阶段
function LeapVertical(keys)

	local caster = keys.caster
    local target = keys.target  --被添加修饰器的目标，包括施法者和技能目标
	local ability = keys.ability
	local ability_target = ability.target  --技能目标，要对其造成伤害

    if caster == target then

        if ability.forced_traveled < ability.forced_distance then

		    ability.leap_z = ability.leap_z + ability.forced_speed   
		    ability.forced_traveled = ability.forced_traveled + ability.forced_speed
            target:SetAbsOrigin(GetGroundPosition(target:GetAbsOrigin(), target) + Vector(0,0,ability.leap_z))  

        elseif ability.forced_traveled >= ability.forced_distance and   ability.forced_traveled < ability.forced_distance * 2  then  
        
            ability.leap_z = ability.leap_z - ability.forced_speed 
		    target:SetAbsOrigin(GetGroundPosition(target:GetAbsOrigin(), target) + Vector(0,0,ability.leap_z))		
		    ability.forced_traveled = ability.forced_traveled +  ability.forced_speed  
        
        else     
            target:InterruptMotionControllers(true)
            ability_target:InterruptMotionControllers(true) 
		    local modifier_fly = ability.modifier_fly
            caster:RemoveModifierByName(modifier_fly)
            --ability_target:RemoveModifierByName(modifier_fly)
            DoDamage(caster, ability_target, ability)

        end
    else
        target:SetAbsOrigin(caster:GetAbsOrigin())  
    end

    return
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------



















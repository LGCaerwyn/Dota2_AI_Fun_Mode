--[[
    Author: Bude
    Date: 30.09.2015.
    Sets some initial values and prepares the caster for motion controllers
    NOTE: Modifier that keeps huskar from attacking (etc.) does not get removed properly if Life Break is cancelled
]]
function LifeBreak( keys )
    -- Variables
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local charge_speed = ability:GetLevelSpecialValueFor("charge_speed", (ability:GetLevel() - 1)) * 1/30

    -- Save modifiernames in ability
    ability.modifiername = keys.ModifierName
    ability.modifiername_debuff = keys.ModifierName_Debuff
	ability.modifiername_Debuff_flybefo=keys.ModifierName_Debuff_flybefo

    -- Motion Controller Data
    ability.target = target
    ability.velocity = charge_speed
    ability.life_break_z = 0
    ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target)-GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()
    ability.traveled = 0
end


function DoDamage(caster, target, ability)
    -- Variables

    local caster_health = caster:GetHealth()
    local target_health = target:GetMaxHealth()
   

	local dmg_to_caster = caster_health * 0.01
    local dmg_to_target = target_health * 1
	print(dmg_to_caster)
	print(dmg_to_target)
	print("伤害")
    -- Compose the damage tables and apply them to the designated target
    local dmg_table_caster = {
                                victim = caster,
                                attacker = caster,
                                damage = dmg_to_caster,
                                damage_type = DAMAGE_TYPE_PHYSICAL ,
                            	damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
                            }
    ApplyDamage(dmg_table_caster)

    local dmg_table_target = {
                                victim = target,
                                attacker = caster,
                                damage = dmg_to_target,
                                damage_type = DAMAGE_TYPE_PHYSICAL ,
								damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION

                            }
    ApplyDamage(dmg_table_target)
	print("是否执行")
end

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

function OnMotionDone(caster, target, ability)

    local modifiername_Debuff_flybefo = ability.modifiername_Debuff_flybefo
    local modifiername_debuff = ability.modifiername_debuff


    if caster:FindModifierByName(modifiername_Debuff_flybefo) then
        caster:RemoveModifierByName(modifiername_Debuff_flybefo)
	end


    EmitSoundOn("Hero_Huskar.Life_Break.Impact", target)


    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_life_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(particle)


	ability:ApplyDataDrivenModifier(caster, caster, modifiername, {})
	ability:ApplyDataDrivenModifier(caster, caster, modifiername_debuff, {})
    ability:ApplyDataDrivenModifier(caster, target, modifiername_debuff, {})


end


function JumpHorizonal( keys )

    local caster = keys.target
    local ability = keys.ability
		  target = ability.target

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local direction = (target_loc - caster_loc):Normalized()

    local max_distance = ability:GetLevelSpecialValueFor("max_distance", ability:GetLevel()-1)



    if (target_loc - caster_loc):Length2D() >= max_distance then
    	caster:InterruptMotionControllers(true)
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

--

function JumpVertical( keys )

    local caster = keys.target
    local ability = keys.ability
    local target = ability.target
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










function Fly_caster (keys)

    local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1	
	
	ability.modifiername_Debuff_flybefo=keys.ModifierName_Debuff_flybefo
	modifiername_Debuff_flybefo = ability.modifiername_Debuff_flybefo
	ability.modifiername_shanghai = keys.ModifierName_shanghai
	
	target:Stop() 

	ability.forced_direction = target:GetUpVector() 
	ability.forced_distance = ability:GetLevelSpecialValueFor("push_length", ability_level)  
	ability.forced_speed = ability:GetLevelSpecialValueFor("push_speed", ability_level) * 1/30		
	ability.forced_traveled = 0  --
	ability.leap_z = 0
     print("开始")
	 
	 print(ability.forced_distance)  
	  print(ability.forced_speed)		
	   print(ability.forced_traveled)  
	    print(ability.forced_direction) 
end

function LeapVertical( keys )

	local caster = keys.caster
--	local target = ability.target
	local ability = keys.ability


	if ability.forced_traveled < ability.forced_distance then   
	
		ability.leap_z = ability.leap_z + ability.forced_speed   
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))  

		ability.forced_traveled = ability.forced_traveled + ability.forced_speed
		
	
	elseif    ability.forced_traveled >= ability.forced_distance and   ability.forced_traveled < ability.forced_distance * 2  then   
	

	
		ability.leap_z = ability.leap_z - ability.forced_speed 
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	
			
		ability.forced_traveled = ability.forced_traveled +  ability.forced_speed  
		
	else

		caster:InterruptMotionControllers(true)  
		
		ability.modifiername_Debuff_flybefo=keys.ModifierName_Debuff_flybefo
		local modifiername_Debuff_flybefo = ability.modifiername_Debuff_flybefo

        caster:RemoveModifierByName(modifiername_Debuff_flybefo)
		target:RemoveModifierByName(modifiername_Debuff_flybefo)
		


		DoDamage(caster, target, ability)

		AutoAttack(caster, target)
		
		ability:ApplyDataDrivenModifier(caster, caster, ability.modifiername_shanghai, {})
		
		
		
		
	end

end



function ForceStaff (keys)

    local caster = keys.target
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1	

	target:Stop() 

	ability.forced_direction_target = target:GetUpVector() 
	ability.forced_distance_target = ability:GetLevelSpecialValueFor("push_length", ability_level)  
	ability.forced_speed_target = ability:GetLevelSpecialValueFor("push_speed", ability_level) * 1/30	 
	ability.forced_traveled_target = 0  --
	ability.leap_z_target = 0
  
end

function LeapVertical_target( keys )

	local target = keys.target
	local ability = keys.ability
	if ability.forced_traveled_target < ability.forced_distance_target then   
	
		ability.leap_z_target = ability.leap_z_target + ability.forced_speed_target  
		target:SetAbsOrigin(GetGroundPosition(target:GetAbsOrigin(), target) + Vector(0,0,ability.leap_z_target))  
		ability.forced_traveled_target = ability.forced_traveled_target + ability.forced_speed_target
		

	elseif    ability.forced_traveled_target >= ability.forced_distance_target and   ability.forced_traveled_target < ability.forced_distance_target * 2  then  
	

	
		ability.leap_z_target = ability.leap_z_target - ability.forced_speed_target 
	
		target:SetAbsOrigin(GetGroundPosition(target:GetAbsOrigin(), target) + Vector(0,0,ability.leap_z_target))
		
		ability.forced_traveled_target = ability.forced_traveled_target +  ability.forced_speed_target  --记录路程
		
	else

		target:InterruptMotionControllers(true)  
	end

end




















--大圣毁天灭地

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
   

	local dmg_to_caster = caster_health * 0.4
    local dmg_to_target = target_health * 0.85
	local Edamage_type = DAMAGE_TYPE_PHYSICAL
	print(dmg_to_caster)
	print(dmg_to_target)
	print("伤害")
    -- Compose the damage tables and apply them to the designated target
	
	if caster:HasScepter() then
	
	dmg_to_caster = 0
	dmg_to_target = target_health * 0.7
	Edamage_type = DAMAGE_TYPE_PURE
	end
	
    local dmg_table_caster = {
                                victim = caster,
                                attacker = caster,
                                damage = dmg_to_caster,
                                damage_type = DAMAGE_TYPE_PHYSICAL ,
                            	damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK, --新增无视格挡
                            }
    ApplyDamage(dmg_table_caster)



    local dmg_table_target = {
                                victim = target,
                                attacker = caster,
                                damage = dmg_to_target,
                                damage_type = Edamage_type ,
								damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,

                            }
    ApplyDamage(dmg_table_target)

	if caster:HasScepter() then

	target:EmitSound("Hero_EarthShaker.EchoSlam.Arcana")
	target:EmitSound("Hero_EarthShaker.EchoSlamEcho.Arcana")
	target:EmitSound("Hero_Earthshaker.Arcana.GlobalLayer1")
	target:EmitSound("Hero_Earthshaker.Arcana.GlobalLayer2")

	local particleName1 = "particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf"
	local particle1 = ParticleManager:CreateParticle(particleName1, PATTACH_ABSORIGIN, target)
	local vec1 = Vector(255,255,0)
	local vec2 = Vector(1,0,0)
	local vect = Vector(0.3,0.5,-0.06)
	--ParticleManager:SetParticleControl(particle1, 60, vec1)
	--ParticleManager:SetParticleControl(particle1, 61, vec2)--地面效果暂时只能是绿色
	--ParticleManager:SetParticleControl(particle1, 62, vect)

	local particleName2 = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_echoslam_start_v2.vpcf"
	local particle2 = ParticleManager:CreateParticle(particleName2, PATTACH_ABSORIGIN, target)
	local vec3 = Vector(5,0,0)
	local vec4 = Vector(1,1,0)
	ParticleManager:SetParticleControl(particle2, 10, vec3)
	ParticleManager:SetParticleControl(particle2, 11, vec4)
	
	local particleName3 = "particles/units/heroes/hero_warlock/warlock_rain_of_chaos.vpcf"
	local particle3 = ParticleManager:CreateParticle(particleName3, PATTACH_ABSORIGIN, target)
	local vec5 = Vector(255,255,0)
	local vec6 = Vector(1,0,0)
	local vec7 = Vector(300,1,1)
	ParticleManager:SetParticleControl(particle3, 60, vec1)
	ParticleManager:SetParticleControl(particle3, 61, vec6)
	ParticleManager:SetParticleControl(particle3, 1, vec7)
	end

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


	--ability:ApplyDataDrivenModifier(caster, caster, modifiername, {duration= 2})

   



	ability:ApplyDataDrivenModifier(caster, caster, modifiername_debuff, {duration = 3 })
	print("悟空起飞")
    ability:ApplyDataDrivenModifier(caster, target, modifiername_debuff,{duration = 6 })


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

--[[
    local tether = caster:FindAbilityByName("monkey_king_wukongs_command_fun")   
    caster:SetCursorPosition(target:GetAbsOrigin())
                  
    tether:OnSpellStart()
    tether:EndCooldown()

--]]


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
	ability.modifiername_gongjimianyi = keys.ModifierName_gongjimianyi
	ability.modifiername_afterfly_texiao = keys.ModifierName_afterfly_texiao
	ability.modifiername_jifei_youjun = keys.ModifierName_jifei_youjun


	target:Stop() 

	ability.forced_direction = target:GetUpVector() 
	ability.forced_distance = ability:GetLevelSpecialValueFor("push_length", ability_level)  
	ability.forced_speed = ability:GetLevelSpecialValueFor("push_speed", ability_level) * 1/30		--30
	ability.forced_traveled = 0  --
	ability.leap_z = 0
     print("开始")
	 
	 print(ability.forced_distance)  
	  print(ability.forced_speed)		
	   print(ability.forced_traveled)  
	    print(ability.forced_direction) 
		
	ability:ApplyDataDrivenModifier(caster, caster, ability.modifiername_gongjimianyi, {duration = 3 })
	ability:ApplyDataDrivenModifier(caster, target, ability.modifiername_gongjimianyi, {duration = 3 })		
		
		
		
		
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
		
		


		units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, 800, 
			DOTA_UNIT_TARGET_TEAM_BOTH   , 
			  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC   , 
			 DOTA_UNIT_TARGET_FLAG_NONE , FIND_CLOSEST , false)
			print(caster:GetAbsOrigin())
		for i,v in ipairs(units) do
			print(i,v)
			print(v:GetModelName())
			if v:GetTeamNumber() == caster:GetTeamNumber()  and v ~= caster  then

		ability:ApplyDataDrivenModifier(caster, v, ability.modifiername_jifei_youjun, {})
		print("是否执行击飞1")
		elseif  v == caster then

			ability:ApplyDataDrivenModifier(caster, v, ability.modifiername_afterfly_texiao, {})

		print("是否执行击飞2")
	else
		ability:ApplyDataDrivenModifier(caster, v, ability.modifiername_shanghai, {})
		print(v:GetModelName().."施加伤害的敌人")
			end

		end
	--	ability:ApplyDataDrivenModifier(caster, caster, ability.modifiername_shanghai, {})
	--	caster:GetTeamNumber()
		
		
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
-------------------------------------------------------------------------------------
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



















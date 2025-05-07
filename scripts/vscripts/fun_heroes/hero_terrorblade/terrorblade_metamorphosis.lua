

function metamorphosis_before( keys)
 
 if not IsServer() then return true end

 ability = keys.ability

 caster = keys.caster
 target = keys.target
 targetPoint = keys.target_points[1]

--ability.forced_distance = ability:GetLevelSpecialValueFor("push_length", ability_level)  
--ability.forced_speed = ability:GetLevelSpecialValueFor("push_speed", ability_level) * 1/30		--30
ability.forced_speed = 2000 * 1/30	
ability.forced_speed_down = 6000 * 1/30		--30
ability.forced_distance = 3000
ability.forced_traveled = 0
ability.leap_z = 0
caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
direction = (targetPoint - caster_loc):Normalized()

N = (targetPoint-GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()





local particleName = "particles/units/heroes/hero_gyrocopter/gyro_calldown_marker.vpcf"

local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT , caster )


--	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "", targetPoint, true)
	--ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_origin", Vector(600,600,600), true)
	ParticleManager:SetParticleControl(particle, 0,targetPoint)
	ParticleManager:SetParticleControl(particle, 1,Vector(600,600,-600))
	ParticleManager:SetParticleControl(particle, 60,Vector(0,255,127))
	ParticleManager:SetParticleControl(particle, 61,Vector(120,255,0))





ability:ApplyDataDrivenModifier(caster, caster, "modifier_terrorblade_Metamorphosis_fly", {duration = 3 })		

--print(GetGroundPosition(caster:GetAbsOrigin(), caster))
--print("GetGroundPosition(caster:GetAbsOrigin(), caster)".."返回移动到地面的供给位置。第二个参数是一个NPC，用于测量碰撞体积")
--print(caster:GetAbsOrigin())
	-- body
--print("caster:GetAbsOrigin()")

--player = caster:GetOwnerEntity()

--player:SetCameraDistanceOverride(2000)

--print(GameRules:GetGameModeEntity():GetCameraDistanceOverride())












--print(caster:GetEntityHandle())
--print(caster:GetOwnerEntity())
--print(caster:GetOwner())
end


--y= (-1500*x^2)/N*N +1500


	--		x=(1500-y)*N^2/1500

	--		X = math.sqrt (x)



function metamorphosis_fly_Vertical( keys)

    if not IsServer() then return true end


	if ability.forced_traveled < ability.forced_distance then   
	
		ability.leap_z = ability.leap_z + ability.forced_speed   
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))  

	--	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1134 + ability.leap_z)

		ability.forced_traveled = ability.forced_traveled + ability.forced_speed

	--print("1")


	elseif    ability.forced_traveled >= ability.forced_distance and   ability.forced_traveled < ability.forced_distance * 2  then   
	
	--print("2")
	
	--	ability.leap_z = ability.leap_z - ability.forced_speed 
		ability.leap_z = ability.leap_z - ability.forced_speed_down 


		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))

	--	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1134 + ability.leap_z)
			
	--	ability.forced_traveled = ability.forced_traveled +  ability.forced_speed  
		ability.forced_traveled = ability.forced_traveled +  ability.forced_speed_down 
--[[
elseif    ability.forced_traveled >= ability.forced_distance *2 then   
	
		caster:InterruptMotionControllers(true)

        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
--]]
	end





end


function metamorphosis_fly_Horizonal( keys )


        if not IsServer() then return true end
		if ability.forced_traveled >= ability.forced_distance and   ability.forced_traveled < ability.forced_distance * 2 then   --到达3000高度，开始飞行


	--print("3")
		--	x=(3000-y)*N^2/3000

		--	X = math.sqrt (x)


		ability.Horizonal_speed = N/(0.5*30)

		caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.Horizonal_speed)  --设置水平位移

      elseif ability.forced_traveled >= ability.forced_distance * 2 then

	--print("4")

		caster:InterruptMotionControllers(true)

        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
--	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1134)

---[[
	caster:EmitSound("Hero_EarthShaker.EchoSlam.Arcana")
	caster:EmitSound("Hero_EarthShaker.EchoSlamEcho.Arcana")
	caster:EmitSound("Hero_Earthshaker.Arcana.GlobalLayer1")
	caster:EmitSound("Hero_Earthshaker.Arcana.GlobalLayer2")

	local particleName1 = "particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf"
	local particle1 = ParticleManager:CreateParticle(particleName1, PATTACH_ABSORIGIN, caster)
	local vec1 = Vector(255,255,0)
	local vec2 = Vector(1,0,0)
	local vect = Vector(0.3,0.5,-0.06)
	--ParticleManager:SetParticleControl(particle1, 60, vec1)
	--ParticleManager:SetParticleControl(particle1, 61, vec2)--地面效果暂时只能是绿色
	--ParticleManager:SetParticleControl(particle1, 62, vect)

	local particleName2 = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_echoslam_start_v2.vpcf"
	local particle2 = ParticleManager:CreateParticle(particleName2, PATTACH_ABSORIGIN, caster)
	local vec3 = Vector(5,0,0)
	local vec4 = Vector(1,1,0)
	ParticleManager:SetParticleControl(particle2, 10, vec3)
	ParticleManager:SetParticleControl(particle2, 11, vec4)
	
	local particleName3 = "particles/units/heroes/hero_warlock/warlock_rain_of_chaos.vpcf"
	local particle3 = ParticleManager:CreateParticle(particleName3, PATTACH_ABSORIGIN, caster)
	local vec5 = Vector(255,255,0)
	local vec6 = Vector(1,0,0)
	local vec7 = Vector(300,1,1)
	ParticleManager:SetParticleControl(particle3, 60, vec1)
	ParticleManager:SetParticleControl(particle3, 61, vec6)
	ParticleManager:SetParticleControl(particle3, 1, vec7)



units = FindUnitsInRadius(caster:GetTeamNumber(), targetPoint, caster, 600, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO    , 
			DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS , FIND_CLOSEST , false)

if #units >= 1 then


--	print(k,v)

		ability:ApplyDataDrivenModifier(caster, caster, "modifier_terrorblade_Metamorphosis_fun", {duration = 18})

		cengshu = caster:GetModifierStackCount("modifier_terrorblade_Metamorphosis_fun", caster)

		xiu_cengshu = #units *  (caster:GetLevel() * 0.1 * 10 + 10) + cengshu

		caster:SetModifierStackCount("modifier_terrorblade_Metamorphosis_fun", caster, xiu_cengshu)

	
	

end

enemy_units = FindUnitsInRadius(caster:GetTeamNumber(), targetPoint, caster, 600, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC    , 
			DOTA_UNIT_TARGET_FLAG_NONE , FIND_CLOSEST , false)

for k,b in pairs(enemy_units) do

        local damage = {
                victim = b,
                attacker = caster,
                damage = 460 * (caster:GetLevel() * 0.2),
                damage_type = DAMAGE_TYPE_MAGICAL,
        }
        ability:ApplyDataDrivenModifier(caster, b, "modifier_stunned",{duration = 3})
		ApplyDamage(damage)	
    end

caster:RemoveModifierByName("modifier_terrorblade_Metamorphosis_fly")
ability:ApplyDataDrivenModifier(caster, caster, "modifier_terrorblade_Metamorphosis_fun_2", {duration = 3 })		

--]]

                  
                 local tether = caster:FindAbilityByName("terrorblade_metamorphosis")   
                  --     caster:SetCursorPosition(targetPoint)
                  
                       tether:OnSpellStart()
                    --    tether:EndCooldown()






		end
	-- body
end
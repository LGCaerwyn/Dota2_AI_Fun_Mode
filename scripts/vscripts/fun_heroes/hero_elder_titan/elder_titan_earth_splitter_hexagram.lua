
require('timers')
function elder_titan_earth_splitter_hexagram( keys )



	local caster = keys.caster
	local target = keys.target
	local caster_point = caster:GetAbsOrigin()
	local targetPoint = keys.target_points[1]
	-- body
local ability =keys.ability

local caster_ForwardVector = caster:GetForwardVector()

local radius = ability:GetSpecialValueFor("crack_radius")
local duration = ability:GetSpecialValueFor("crack_time")
local slow_duration = ability:GetSpecialValueFor("slow_duration")
local vision_radius = ability:GetSpecialValueFor("vision_radius")
local damage = ability:GetSpecialValueFor("damage_pct")



target_points = caster_point + (caster_ForwardVector * 800)
--target_points = caster_point + (caster:GetAngles() * 800)
--point = RotatePosition(target_points, QAngle(0,60,0), caster_point)
--[[
if  PlayerResource:GetSteamAccountID(caster:GetMainControllingPlayer()) == 396784731  then

else
	return
end
--]]


EmitSoundOn("Hero_ElderTitan.EarthSplitter.Cast", caster )

EmitSoundOn("Hero_ElderTitan.EarthSplitter.Projectile", caster )

--EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", caster )
--table_Angle_start = {30,90,150,210,270,330}
table_Angle_start = {0,60,120,180,240,300}
table_Angle_end = {150,210,270,330,30,90}
--[[
local particle= ParticleManager:CreateParticle("particles/econ/items/elder_titan/elder_titan_2021/elder_titan_2021_earth_splitter.vpcf", PATTACH_CUSTOMORIGIN,nil)
    ParticleManager:SetParticleControl(particle, 0,caster_point) --起始点
    ParticleManager:SetParticleControl(particle, 1,point) --最终点
    ParticleManager:SetParticleControl(particle, 3,Vector(0,3,0))
    ParticleManager:ReleaseParticleIndex( particle )

--]]

AddFOWViewer(caster:GetTeam(), caster_point, vision_radius, duration, false)


			for k,v in pairs(table_Angle_start) do
				print(k,v)

			local   particle= ParticleManager:CreateParticle("particles/econ/items/elder_titan/elder_titan_2021/elder_titan_2021_earth_splitter.vpcf", PATTACH_CUSTOMORIGIN,nil)
					
					--point = RotatePosition(target_points, QAngle(0,v,0), caster_point)
					--point_2 = RotatePosition(target_points, QAngle(0,v+120,0), caster_point)
					
					point = RotatePosition(caster_point, QAngle(0,v,0), target_points)
					point_2 = RotatePosition(caster_point, QAngle(0,v+120,0), target_points)
				    ParticleManager:SetParticleControl(particle, 0,point) --起始点
				    ParticleManager:SetParticleControl(particle, 1,point_2) --最终点
				  --  ParticleManager:SetParticleControl(particle, 2,point_2) --最终点
				    ParticleManager:SetParticleControl(particle, 3,Vector(0,duration,0))
				    ParticleManager:ReleaseParticleIndex( particle )


				



			end

    Timers:CreateTimer(duration, function()

        EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", caster )

targets = FindUnitsInRadius(caster:GetTeamNumber(), caster_point, caster, 800, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_HERO +DOTA_UNIT_TARGET_BASIC , 
            DOTA_UNIT_TARGET_FLAG_NONE , FIND_ANY_ORDER  , false)





    for _,tar in pairs(targets) do
 --       target:EmitSound("Hero_Juggernaut.BladeFury.Impact")

 		local damage = ability:GetSpecialValueFor("damage_pct") * tar:GetMaxHealth() * 0.01

            ability:ApplyDataDrivenModifier(caster, target, "modifier_necrolyte_reapers_scythe", {duration = slow_duration})
            EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", tar )
            ApplyDamage({victim = tar, attacker = caster, damage = damage, ability = ability, damage_type = DAMAGE_TYPE_MAGICAL , damage_flags = DOTA_DAMAGE_FLAG_NONE   })
  			
        end








                return nil
   		 end)




			--point = RotatePosition(targetPoint, QAngle(0,v,0), casterPoint)






end
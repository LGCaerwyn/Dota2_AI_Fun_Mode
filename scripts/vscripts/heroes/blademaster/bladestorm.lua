require('timers')

require('utils')
function Bladestorm_start( keys )
	-- body

local caster = keys.caster
local ability = keys.ability
local duration = ability:GetSpecialValueFor("duration")

if caster:HasScepter() then
			
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_blademaster_bladestorm", {duration = duration})	

end

ability:ApplyDataDrivenModifier(caster, caster, "modifier_bladestorm", {duration = duration})	
end




function BladestormDamage(event)
    local caster = event.caster
    local ability = event.ability
    local talent =  caster:FindAbilityByName("special_bonus_unique_blademaster_bladestorm_damage")

    local talent_bonus = 0
    
    if talent ~= nil then 
        talent_bonus = talent:GetSpecialValueFor("value")
    end

  --  local damage =( ability:GetSpecialValueFor("bouns_bladestorm_damage") + talent_bonus)* ability:GetSpecialValueFor("bladestorm_damage_tick")

 	local damage = ability:GetSpecialValueFor("bladestorm_damage") * ability:GetSpecialValueFor("bladestorm_damage_tick")
 	local bladestorm_building = ability:GetSpecialValueFor("bladestorm_building") * ability:GetSpecialValueFor("bladestorm_damage_tick")
    local radius = ability:GetSpecialValueFor("bladestorm_radius")
    local casterPoint = caster:GetAbsOrigin()
 --   local targets = FindEnemiesInRadius( caster, radius, caster:GetAbsOrigin() )
    local playerID = caster:GetPlayerID()
    
  
--print(ability:GetSpecialValueFor("bladestorm_damage"))

local SpellAmp = caster:GetSpellAmplification(false)

local damage_type = DAMAGE_TYPE_MAGICAL


if caster:HasScepter() then
	damage_type = DAMAGE_TYPE_PURE
    damage_flags = DOTA_DAMAGE_FLAG_NONE
end
--]]
targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_HERO +DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING    , 
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES , FIND_CLOSEST , false)





    for _,target in pairs(targets) do
        target:EmitSound("Hero_Juggernaut.BladeFury.Impact")

        	if  target:IsBuilding() then


            
            ApplyDamage({victim = target, attacker = caster, damage = bladestorm_building, ability = ability, damage_type = damage_type , damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION  })

        else
			
            ApplyDamage({victim = target, attacker = caster, damage = damage, ability = ability, damage_type = damage_type ,damage_flags =  damage_flags  })
         --   print(damage_type)
            end


        end



end





--Stops the looping sound event
function BladeFuryStop( event )
	local caster = event.caster	
	caster:StopSound("Hero_Juggernaut.BladeFuryStart")
end

function Bladestorm_Scepter( event )

   local caster = event.caster
    local ability = event.ability

	-- body
    local radius = ability:GetSpecialValueFor("bladestorm_radius")
    local casterPoint = caster:GetAbsOrigin()

local SpellAmp = caster:GetSpellAmplification(false)




--闪电特效↓↓
local point = casterPoint + RandomVector(300)

caster:EmitSound("Hero_Zuus.LightningBolt")


        local particle_1 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf" ,PATTACH_WORLDORIGIN, caster)
        -- Raise 1000 value if you increase the camera height above 1000
        ParticleManager:SetParticleControl(particle_1, 0, Vector(point.x,point.y,3000))
        ParticleManager:SetParticleControl(particle_1, 1, Vector(point.x,point.y,point.z))
    --    ParticleManager:SetParticleControl(particle_1, 2, Vector(point.x,point.y,point.z))

        local particle_1_glow =ParticleManager:CreateParticle( "particles/units/heroes/hero_zuus/zuus_lightning_bolt_glow_fx.vpcf",PATTACH_WORLDORIGIN, caster)
 		ParticleManager:SetParticleControl(particle_1_glow, 0, Vector(point.x,point.y,3000))
        ParticleManager:SetParticleControl(particle_1_glow, 1, Vector(point.x,point.y,point.z))


ts_1 = FindUnitsInRadius(caster:GetTeamNumber(), point, caster, 100, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_HERO +DOTA_UNIT_TARGET_BASIC,-- + DOTA_UNIT_TARGET_BUILDING    , 
            DOTA_UNIT_TARGET_FLAG_NONE , FIND_CLOSEST , false)

   for _,tar_1 in pairs(ts_1) do
        tar_1:EmitSound("Hero_Zuus.LightningBolt")

            ApplyDamage({victim = tar_1, attacker = caster, damage = 400, ability = ability, damage_type = DAMAGE_TYPE_MAGICAL})
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_DEADLY_BLOW, tar_1, 400 * (1+SpellAmp), nil) 
        end


---------------------------
local point = casterPoint + RandomVector(600)

caster:EmitSound("Hero_Zuus.LightningBolt")


        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf" ,PATTACH_WORLDORIGIN, caster)
        -- Raise 1000 value if you increase the camera height above 1000
        ParticleManager:SetParticleControl(particle, 0, Vector(point.x,point.y,3000))
        ParticleManager:SetParticleControl(particle, 1, Vector(point.x,point.y,point.z))
     --   ParticleManager:SetParticleControl(particle, 2, Vector(point.x,point.y,point.z))

        local particle_glow = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt_glow_fx.vpcf" ,PATTACH_WORLDORIGIN, caster)
        -- Raise 1000 value if you increase the camera height above 1000
        ParticleManager:SetParticleControl(particle_glow, 0, Vector(point.x,point.y,3000))
        ParticleManager:SetParticleControl(particle_glow, 1, Vector(point.x,point.y,point.z))



   
ts = FindUnitsInRadius(caster:GetTeamNumber(), point, caster, 100, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_HERO +DOTA_UNIT_TARGET_BASIC,-- + DOTA_UNIT_TARGET_BUILDING    , 
            DOTA_UNIT_TARGET_FLAG_NONE , FIND_CLOSEST , false)

   for _,tar in pairs(ts) do
        tar:EmitSound("Hero_Zuus.LightningBolt")

            ApplyDamage({victim = tar, attacker = caster, damage = 400, ability = ability, damage_type = DAMAGE_TYPE_MAGICAL})
SendOverheadEventMessage(nil, OVERHEAD_ALERT_DEADLY_BLOW, tar, 400 * (1+SpellAmp), nil) 
        end



---------------------------------




local point_2 = casterPoint + RandomVector(900)

        local particle_2 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf" ,PATTACH_WORLDORIGIN, caster)
        -- Raise 1000 value if you increase the camera height above 1000
        ParticleManager:SetParticleControl(particle_2, 0, Vector(point_2.x,point_2.y,3000))
        ParticleManager:SetParticleControl(particle_2, 1, Vector(point_2.x,point_2.y,point_2.z))
      --  ParticleManager:SetParticleControl(particle_2, 2, Vector(point_2.x,point_2.y,point_2.z))
 local particle_2_glow = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt_glow_fx.vpcf" ,PATTACH_WORLDORIGIN, caster)
        -- Raise 1000 value if you increase the camera height above 1000
        ParticleManager:SetParticleControl(particle_2_glow, 0, Vector(point_2.x,point_2.y,3000))
        ParticleManager:SetParticleControl(particle_2_glow, 1, Vector(point_2.x,point_2.y,point_2.z))


ts_2 = FindUnitsInRadius(caster:GetTeamNumber(), point, caster, 100, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_HERO +DOTA_UNIT_TARGET_BASIC ,--+ DOTA_UNIT_TARGET_BUILDING    , 
            DOTA_UNIT_TARGET_FLAG_NONE , FIND_CLOSEST , false)

   for _,tar_2 in pairs(ts_2) do
        tar_2:EmitSound("Hero_Zuus.LightningBolt")

            ApplyDamage({victim = tar_2, attacker = caster, damage = 400, ability = ability, damage_type = DAMAGE_TYPE_MAGICAL})
SendOverheadEventMessage(nil, OVERHEAD_ALERT_DEADLY_BLOW, tar_2, 400 * (1+SpellAmp), nil) 
        end

--闪电特效↑↑

end

function bladestorm_Shard( event )
	-- body

local caster = event.caster
local ability = event.ability
local radius = ability:GetSpecialValueFor("bladestorm_radius")
local duration = ability:GetSpecialValueFor("duration")
local x = 0

				if Has_Aghanims_Shard(caster) == true then
				

						Timers:CreateTimer(function()

						local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, 
						            DOTA_UNIT_TARGET_TEAM_ENEMY, 
						            DOTA_UNIT_TARGET_HERO +DOTA_UNIT_TARGET_BASIC ,--+ DOTA_UNIT_TARGET_BUILDING    , 
						            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES , FIND_CLOSEST , false)



								if x < duration then
									x = x+1


									for k,v in pairs(targets) do

										caster:PerformAttack(v, true, true, true, true, true, false, true)

									end
									
									
						  		return 1
								else

								return nil
							end
			            
			                    
			      		  end
               			 )


			end
end





function Particle_Manager( keys )

    local caster = keys.caster
    local casterPoint = caster:GetAbsOrigin()
    local point = casterPoint 



    caster:Purge(false, true, false, true, false)

        particle = ParticleManager:CreateParticle("particles/econ/items/monkey_king/mk_ti9_immortal/mk_ti9_immortal_army_ring.vpcf" ,PATTACH_POINT , caster)
        -- Raise 1000 value if you increase the camera height above 1000
        ParticleManager:SetParticleControl(particle, 0, Vector(point.x,point.y,point.z))
        ParticleManager:SetParticleControl(particle, 1, Vector(1000,point.y,point.z))
     --   ParticleManager:SetParticleControl(particle, 2, Vector(point.x,point.y,point.z))




--particles/econ/events/fall_2021/cyclone_fall2021.vpcf
particle_tornado = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_blade_fury_ground.vpcf" ,PATTACH_POINT_FOLLOW , caster)
particle_tor= ParticleManager:CreateParticle("particles/econ/events/fall_2021/cyclone_fall2021.vpcf" ,PATTACH_POINT_FOLLOW , caster)




Timers:CreateTimer(7, function()

    ParticleManager: DestroyParticle(particle, false)
    ParticleManager: DestroyParticle(particle_tornado, false)
     ParticleManager: DestroyParticle(particle_to, false)
            return nil
                    
                    end
                )


Timers:CreateTimer(4, function() 
    ParticleManager: DestroyParticle(particle_tor, false)

            return nil
                    
                    end
                )


Timers:CreateTimer(3, function()
    particle_to= ParticleManager:CreateParticle("particles/econ/events/spring_2021/cyclone_spring2021.vpcf" ,PATTACH_POINT_FOLLOW , caster)    
            return nil
                    
                    end
                )








end



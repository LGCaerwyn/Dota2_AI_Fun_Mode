
function EarthquakeStart( event )
    -- Variables
    local caster = event.caster
    local point = event.target_points[1]
	local ability = event.ability
	local target = event.target

    --caster.earthquake_dummy = CreateUnitByName("dummy_unit_vulnerable", point, false, caster, caster, caster:GetTeam())
  --  event.ability:ApplyDataDrivenModifier(caster, caster.earthquake_dummy, "modifier_earthquake_thinker", nil)
end

function unit_time( event )
	local target = event.target	
	local ability = event.ability
	ability.point_entity = target
end

function EarthquakeEnd( event )
    --print("停止施法")
    local caster = event.caster
	local ability = event.ability
	if ability.point_entity:IsNull() == false then
		ability.point_entity:RemoveModifierByName("modifier_earthquake_thinker")
	--	StopSoundOn("Hero_Enigma.Black_Hole", caster)
	end
	
    --caster.earthquake_dummy:RemoveSelf()
end


function Earthquake_damage( keys)
local caster = keys.caster
local target = keys.target
local ability = keys.ability

local radius = ability:GetSpecialValueFor("radius")
local building_damage = ability:GetSpecialValueFor("building_damage_per_sec")
local damage = ability:GetSpecialValueFor("damage_per_sec")
print(target:GetUnitName())



			local build_unit = FindUnitsInRadius(caster:GetTeamNumber(), target:GetOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES , 0,false)
	
			if #build_unit > 0 then
				for a,enemy in pairs (build_unit) do
					
					if enemy ~= nil and  enemy:IsBuilding() then
						

						ApplyDamage({ victim = enemy, attacker = caster, damage = building_damage, damage_type = DAMAGE_TYPE_MAGICAL  })
						--ApplyDamage({ victim = enemy, attacker = caster, damage = damage_STR, damage_type = damageType })
				

					end
				end	
			end	

local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO +DOTA_UNIT_TARGET_BASIC,  DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES  , 0,false)
	
			if #enemies > 0 then
				for a,enemy in pairs (enemies) do
					
					if enemy ~= nil then
						

						ApplyDamage({ victim = enemy, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL  })
						--ApplyDamage({ victim = enemy, attacker = caster, damage = damage_STR, damage_type = damageType })
				

					end
				end	
			end	



	-- body
end
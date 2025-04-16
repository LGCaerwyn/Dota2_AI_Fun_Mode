

function dashizhidi_liliang (keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local casterSTR = caster:GetMaxHealth()
	local damage = casterSTR * 0.05
	local damageType =	DAMAGE_TYPE_PHYSICAL
	print( damage )
		--ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = damageType })
		
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), self, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0,false)
	
	if #enemies > 0 then
		for a,enemy in pairs (enemies) do
			
			if enemy ~= nil and (not enemy:IsInvulnerable()) then
				
				ApplyDamage({ victim = enemy, attacker = caster, damage = damage, damage_type = damageType })
		
			end
		end	
	end	
		
		
end


function dashizhidi_liliang_liliang (keys)

local caster = keys.caster
local attacker = keys.attacker
local ability = keys.ability
local modifier_name = keys.ModifierName
	if  attacker:IsHero() then



		if caster:GetPrimaryAttribute() == 0 or caster:HasItemInInventory("item_grandmasters_glaive_three_phase_power") then

			ability:ApplyDataDrivenModifier(caster, caster, modifier_name, {duration=10})

		end
	end
end


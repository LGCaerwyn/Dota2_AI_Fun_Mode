

function dashizhidi_minjie (keys)

	local caster = keys.caster
	local modifier_name = keys.modifier_name
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	
	if ability:IsCooldownReady() then
	
			
				if keys.caster:IsRangedAttacker() or caster:HasItemInInventory("item_grandmasters_glaive_three_phase_power") then
			
						ability:ApplyDataDrivenModifier(caster, caster, modifier_name , {})
						
						ability:StartCooldown(cooldown)
				end
	end
	
end

function dashizhidi_minjie_mingjie (keys)


	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier_name = keys.ModifierName

	if target:IsHero() then

		if caster:GetPrimaryAttribute() == 1 or caster:HasItemInInventory(item_grandmasters_glaive_three_phase_power) then

			ability:ApplyDataDrivenModifier(caster, caster, modifier_name , {duration=15}) 

			
			
		
		end
		
	end
	

end
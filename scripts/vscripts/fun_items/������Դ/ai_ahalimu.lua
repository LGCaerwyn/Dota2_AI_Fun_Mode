
function AI_ahalimu (keys)

	local ability = keys.ability
	local caster = keys.caster
	local modifier_name = keys.ModifierName
	local modifier_name_debuff = keys.ModifierName_debuff
	
	if  caster:GetTeamNumber() == 3    then 

		ability:ApplyDataDrivenModifier(caster, caster, modifier_name , {})
			
	
	end

	
	if  caster:GetTeamNumber() == 2    then 

		ability:ApplyDataDrivenModifier(caster, caster, modifier_name_debuff , {})
			
	
	end
			
end
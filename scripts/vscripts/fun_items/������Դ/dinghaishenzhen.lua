
function dinghaishenzhen( keys )


	
	local caster = keys.caster
	local ability = keys.ability
	local modifier_name = keys.ModifierName

	if  caster:GetUnitName() == "npc_dota_hero_monkey_king" then
		
		ability:ApplyDataDrivenModifier(caster, caster, modifier_name, {})
		
	
	end

	
end








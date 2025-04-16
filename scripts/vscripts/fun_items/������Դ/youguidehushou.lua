
function youguidehushou( keys )


	
	local caster = keys.caster
	local ability = keys.ability
	local modifier_name = keys.ModifierName

	if  caster:GetUnitName() == "npc_dota_hero_spectre" then
		
		ability:ApplyDataDrivenModifier(caster, caster, modifier_name, {})
		
	
	end

	
end





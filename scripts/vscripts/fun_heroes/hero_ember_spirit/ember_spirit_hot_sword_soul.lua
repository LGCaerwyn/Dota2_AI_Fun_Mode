


function ember_spirit_hot_sword_soul(keys)

	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local Unlocking_number = ability:GetSpecialValueFor("unlocking_number") 
	local duration_interval =  ability:GetSpecialValueFor("interval") 
if target:IsBuilding() or caster:HasModifier("modifier_ember_spirit_sword_soul_time") then

return

end

if caster:HasModifier("modifier_ember_spirit_hot_sword_soul_unlocking") then
ability:ApplyDataDrivenModifier( caster, caster, "modifier_ember_spirit_hot_sword_soul_unlocking", {duration = duration_interval})
end
		if caster:HasModifier("modifier_ember_spirit_hot_sword_soul_count") then
			Count =	caster:GetModifierStackCount("modifier_ember_spirit_hot_sword_soul_count", caster)
			if Count <= ( Unlocking_number - 2) then
					Count =	caster:GetModifierStackCount("modifier_ember_spirit_hot_sword_soul_count", caster)
					caster:SetModifierStackCount("modifier_ember_spirit_hot_sword_soul_count",caster,Count+1)
					ability:ApplyDataDrivenModifier( caster, caster, "modifier_ember_spirit_hot_sword_soul_count", {duration = duration_interval})
					--caster:AddNewModifier(caster, self, "modifier_ember_spirit_hot_sword_soul_count", {duration = 5})
					--ability_SetActivated = caster:FindAbilityByName("ember_spirit_sword_soul")
					--ability_SetActivated:SetActivated(false)

				else

					caster:RemoveModifierByName("modifier_ember_spirit_hot_sword_soul_count")
					ability:ApplyDataDrivenModifier( caster, caster, "modifier_ember_spirit_hot_sword_soul_unlocking", {duration = duration_interval})
					--caster:SetModifierStackCount("modifier_ember_spirit_hot_sword_soul_count",caster,4)
					--caster:AddNewModifier(caster, self, "modifier_ember_spirit_hot_sword_soul_count", {duration = 5})	
					--ability:ApplyDataDrivenModifier( caster, caster, "modifier_ember_spirit_hot_sword_soul_count", {duration = 5})
					--ability_SetActivated = caster:FindAbilityByName("ember_spirit_sword_soul")
 					--ability_SetActivated:SetActivated(true)
			end


		else
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_ember_spirit_hot_sword_soul_count", {duration = duration_interval})
			--caster:AddNewModifier(caster, self, "modifier_ember_spirit_hot_sword_soul_count", {duration = 5})
			caster:SetModifierStackCount("modifier_ember_spirit_hot_sword_soul_count",caster,1)
		
		end
end


function modifier_ember_spirit_hot_sword_soul_unlocking( keys)
	-- body


	local caster = keys.caster

	ability_SetActivated = caster:FindAbilityByName("ember_spirit_sword_soul")
 	ability_SetActivated:SetActivated(true)

end


function modifier_ember_spirit_hot_sword_soul_locking( keys)
	-- body


	local caster = keys.caster

	ability_SetActivated = caster:FindAbilityByName("ember_spirit_sword_soul")
 	ability_SetActivated:SetActivated(false)
 	
end
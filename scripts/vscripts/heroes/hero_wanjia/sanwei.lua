
function sanewi_panduan(keys)

	local ability = keys.ability
	local modifier_name_liliang = keys.ModifierName_liliang
	local modifier_name_minjie = keys.ModifierName_minjie
	local modifier_name_zhili = keys.ModifierName_zhili
	local target = keys.target
	local caster = keys.caster
	local mofakangxing = math.floor(target:GetStrength())
	local yisu = math.floor(target:GetAgility())
	local jinengzengqiang = math.floor(target:GetIntellect())
	local zhushuxing = math.floor(target:GetPrimaryStatValue())



	if target:GetPrimaryAttribute() == 0  then

			ability:ApplyDataDrivenModifier(caster, target, modifier_name_liliang , {})
			target:SetModifierStackCount(modifier_name_liliang, target, mofakangxing )

		if target:GetPrimaryAttribute() == 1  then
			ability:ApplyDataDrivenModifier(caster, target, modifier_name_minjie , {})
			target:SetModifierStackCount(modifier_name_minjie, target, yisu )

			if target:GetPrimaryAttribute() == 2  then
				ability:ApplyDataDrivenModifier(caster, target, modifier_name_zhili , {})
				target:SetModifierStackCount(modifier_name_zhili, target, jinengzengqiang )
	-- body
	end
		end
			end



end

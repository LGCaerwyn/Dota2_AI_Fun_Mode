require('Fun_BaseGameMode/modifier_Fun_BaseGameMode')

--添加修饰器
function modifier_item_fun_Aghanims_Scepter_AI_OnCreated(keys)

	local ability = keys.ability
	local caster = keys.caster
	local c_team = caster:GetTeam()

	--__is_Human_Team(t_Team)来自文件modifier_Fun_BaseGameMode.lua
	--特殊技能提供加成
	
	if  caster:IsRangedAttacker() then

			ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_Aghanim's Scepter_5" , {})
	end 	
	
	--if __is_Human_Team(c_team) then return end
	if not PlayerResource:IsFakeClient(caster:GetPlayerID())  then return end
--	caster:AddAbility("special_bonus_unique_ai")
--	caster:FindAbilityByName("special_bonus_unique_ai"):SetLevel(1)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_fun_Aghanims_Scepter_AI_buff", {})
	--	if  caster:IsRangedAttacker() then

	--		ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_Aghanim's Scepter_5" , {})
	--end 
	
	if caster:GetPrimaryAttribute() == 2 then
	    ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_fun_Aghanims_Scepter_AI_buff_intellent", {})
	end		


	
end

---------------------------------------------------------------------------------------------------------------------------------
--移除修饰器
function modifier_item_fun_Aghanims_Scepter_AI_OnDestroy(keys)

    local caster = keys.caster
	caster:RemoveModifierByNameAndCaster("modifier_item_fun_Aghanims_Scepter_AI_buff", caster)
	caster:RemoveModifierByNameAndCaster("modifier_item_fun_Aghanims_Scepter_AI_buff_intellent", caster)
end

---------------------------------------------------------------------------------------------------------------------------------
--无限买活
function modifier_item_fun_Aghanims_Scepter_AI_OnDeath(keys)

	local caster = keys.caster
	local c_team = caster:GetTeam()  
	
	--__is_Human_Team(t_Team)来自文件modifier_Fun_BaseGameMode.lua
	if __is_Human_Team(c_team) then return end	

	caster:SetBuybackCooldownTime(0)

end
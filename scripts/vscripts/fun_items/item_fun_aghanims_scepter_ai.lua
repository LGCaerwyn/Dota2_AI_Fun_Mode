require('utils')

--添加修饰器
function modifier_item_fun_Aghanims_Scepter_AI_OnCreated(keys)
    if not IsServer() then return true end
	local ability = keys.ability
	local caster = keys.caster
	local c_team = caster:GetTeam()

	--__is_Human_Team(t_Team)来自文件utils.lua
	if __is_Human_Team(c_team) then return end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_fun_Aghanims_Scepter_AI_buff", {})
	if caster:GetPrimaryAttribute() == 2 then
	    ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_fun_Aghanims_Scepter_AI_buff_intellent", {})
	end				
end

---------------------------------------------------------------------------------------------------------------------------------
--移除修饰器
function modifier_item_fun_Aghanims_Scepter_AI_OnDestroy(keys)
    if not IsServer() then return true end
    local caster = keys.caster
	caster:RemoveModifierByNameAndCaster("modifier_item_fun_Aghanims_Scepter_AI_buff", caster)
	caster:RemoveModifierByNameAndCaster("modifier_item_fun_Aghanims_Scepter_AI_buff_intellent", caster)
end

---------------------------------------------------------------------------------------------------------------------------------
--无限买活
function modifier_item_fun_Aghanims_Scepter_AI_OnDeath(keys)
    if not IsServer() then return true end
	local caster = keys.caster
	local ability = keys.ability
	local c_team = caster:GetTeam()  
	local buyback_cooldown = ability:GetSpecialValueFor("buyback_cooldown")

	--__is_Human_Team(t_Team)来自文件utils.lua
	if __is_Human_Team(c_team) then return end	
	if caster:GetBuybackCooldownTime() > buyback_cooldown then
	    caster:SetBuybackCooldownTime(buyback_cooldown)
    end
end

function modifier_item_fun_Aghanims_Scepter_AI_OnIntervalThink_buff(keys)
    --if not IsServer() then return true end  --似乎会有显示bug，叠层后属性不增加
	local caster = keys.caster
	local ability = keys.ability
	local max_time = 0 
	local time1 = ability:GetSpecialValueFor("max_time") 
	local time2 = GameRules.Fun_DataTable["blessing_bonus_stats_stack"]
    local buff = caster:FindModifierByName("modifier_item_fun_Aghanims_Scepter_AI_buff")
	local buff_int = caster:FindModifierByName("modifier_item_fun_Aghanims_Scepter_AI_buff_intellent")

	max_time = math.min(time1, time2)

	if buff then
	    if buff:GetStackCount() < max_time then
	        buff:SetStackCount(max_time)
			--buff:SendBuffRefreshToClients()
		end
	end

	if buff_int then
	    if buff_int:GetStackCount() < max_time then
	        buff_int:SetStackCount(max_time)
			--buff:SendBuffRefreshToClients()
		end
	end

end
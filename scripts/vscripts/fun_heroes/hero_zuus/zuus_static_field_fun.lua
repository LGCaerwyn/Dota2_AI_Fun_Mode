function static_field_fun(keys)
    
    local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier_aura = "modifier_tianshenxiafan_magic_armor_reduction_tooltip"
	local modifier = "modifier_tianshenxiafan_magic_armor_reduction_2"
	local has_magic_resistance = target:Script_GetMagicalArmorValue(false, nil)

    --补丁，KV幻象继承判定失效，幻象提供的光环在死亡后失效，需要手动摧毁
	if caster:IsIllusion() then return end
	if ability == nil then 
	    local debuff_aura = target:FindModifierByNameAndCaster(modifier_aura, caster)
		local debuff = target:FindModifierByNameAndCaster(modifier, caster)
		debuff_aura:Destroy()
		debuff:Destroy()
	    return 
	end
	---------------------------------------------------------------------

	if caster:PassivesDisabled() or
	   not caster:IsAlive() or
	   has_magic_resistance == 1 or
	   target:IsMagicImmune() or
	   target:IsDebuffImmune()
	then 
	    target:RemoveModifierByNameAndCaster(modifier_aura, caster)
	    target:RemoveModifierByNameAndCaster(modifier, caster)
		return
	end
	
	local has_stack_count = target:GetModifierStackCount(modifier, caster)
	local per_stack_reduce = -1 * ability:GetSpecialValueFor("per_stack_reduce")/100
	local fixed_magic_resistance = 0

	--ability:ApplyDataDrivenModifier(caster, target, modifier, nil)
	--target:SetModifierStackCount(modifier, caster, 2)

	if has_stack_count < 1 then
	    fixed_magic_resistance = has_magic_resistance
	else
	    fixed_magic_resistance = 1 - (1 - has_magic_resistance)/(1 + has_stack_count * per_stack_reduce)
	end
	--print("叠层之前的魔法抗性："..fixed_magic_resistance)
	local min_radius = ability:GetSpecialValueFor("min_radius")
	local min_radius_reduce = 0.01 * ability:GetSpecialValueFor("min_radius_reduce")
	local max_radius = ability:GetSpecialValueFor("max_radius")
	local max_radius_reduce = 0.01 * ability:GetSpecialValueFor("max_radius_reduce")
	local target_location = target:GetAbsOrigin()
	local caster_location = caster:GetAbsOrigin()
	local distance = (target_location - caster_location):Length2D()
	local reduction = 0
	if distance <= min_radius then
	    reduction = min_radius_reduce
	elseif distance >= max_radius then
        reduction = max_radius_reduce
	else
	    if min_radius == max_radius then return end
 	    local k = (min_radius_reduce - max_radius_reduce)/(min_radius - max_radius)
		local b = min_radius_reduce - k * min_radius
	    reduction = k * distance + b
	end
	local stack_count = math.ceil(((1 - fixed_magic_resistance + reduction)/(1 - fixed_magic_resistance) - 1) / per_stack_reduce)

	if not target:HasModifier(modifier) then 
        ability:ApplyDataDrivenModifier(caster, target, modifier, nil)
		ability:ApplyDataDrivenModifier(caster, target, modifier_aura, nil)
	end
	local playerID = caster:GetPlayerID()
	
	if 	PlayerResource:IsFakeClient(playerID)  then
	stack_count = stack_count * 2
	end
	
	
	target:SetModifierStackCount(modifier, caster, stack_count)

	--print("此处应削减魔法抗性："..reduction)
	--print("削弱后魔法抗性应是："..(fixed_magic_resistance-reduction))
	--print("实际的魔法抗性："..target:GetMagicalArmorValue())

end

function remove(keys)
	local target = keys.target
    local modifier = "modifier_tianshenxiafan_magic_armor_reduction_2"
	local modifier_aura = "modifier_tianshenxiafan_magic_armor_reduction_tooltip"
	target:RemoveModifierByNameAndCaster(modifier, caster)
	target:RemoveModifierByNameAndCaster(modifier_aura, caster)
	--print("移除削弱")
end

-------------------------------------------------------------------------------------

function modifier_tianshenxiafan_OnCreated(keys)

    local ability = keys.ability
	local caster = keys.caster
	local modifier_amp = "modifier_tianshenxiafan_spell_amplification"
	if caster:PassivesDisabled() or 
	   caster:HasModifier(modifier_amp) 
	then
	    return
	end
	ability:ApplyDataDrivenModifier(caster, caster, modifier_amp, nil)
end

-------------------------------------------------------------------------------------

function modifier_tianshenxiafan_OnDestroy(keys)

    local ability = keys.ability
	local caster = keys.caster
	local modifier_amp = "modifier_tianshenxiafan_spell_amplification"
	caster:RemoveModifierByName(modifier_amp)
end

function modifier_tianshenxiafan_OnStateChanged(keys)

    local ability = keys.ability
	local caster = keys.caster
	local modifier_amp = "modifier_tianshenxiafan_spell_amplification"
	if caster:PassivesDisabled() and caster:HasModifier(modifier_amp) then
	    caster:RemoveModifierByName(modifier_amp)
	elseif not caster:PassivesDisabled() and not caster:HasModifier(modifier_amp) then
	    ability:ApplyDataDrivenModifier(caster, caster, modifier_amp, nil)
	end
end

function zuus_static_field_fun_OnAbilityExecuted(keys)
--失效
--[[
    local ability = keys.ability
	local caster = keys.caster
	local event_ability = keys.event_ability
	local tether = caster:FindAbilityByName("zuus_thundergods_wrath")
	local playerID = caster:GetPlayerID()
	--if zuus.kill then tether:OnSpellStart() end --偶尔失效
	if not	PlayerResource:IsFakeClient(playerID)  then
	return
	end

	
	--]]
end







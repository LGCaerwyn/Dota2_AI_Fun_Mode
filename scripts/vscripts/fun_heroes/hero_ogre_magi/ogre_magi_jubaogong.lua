
function jubaogong_OnAbilityExecuted(keys)
    if not IsServer() then return true end
	local caster = keys.caster
	local event_ability = keys.event_ability
	local ability = keys.ability
	local gold = ability:GetSpecialValueFor("gold_on_cast_spell") 

	if caster:PassivesDisabled() or
	   event_ability:IsItem() or
	   not event_ability:ProcsMagicStick()
	then
	    return
	end
	jubaogong_ModifyGold(caster, gold)
end

function jubaogong_OnAttackLanded(keys)
    if not IsServer() then return true end
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local gold_gain = ability:GetSpecialValueFor("gold_on_attack")
	local gold_lose = ability:GetSpecialValueFor("gold_on_attack") * -1

	if caster:PassivesDisabled() or
	   caster:IsIllusion() or
	   target:IsBuilding()
	then 
	    return 
	end

	if target:IsIllusion() or 
	   target:IsClone() or
	   target:IsDominated() or
	   target:IsSummoned() or
	   target:IsCreature() or
	   target:IsCreep()
	then
	    gold_lose = 0
	end

	jubaogong_ModifyGold(caster, gold_gain)
	if gold_lose ~= 0 then
	    jubaogong_ModifyGold(target, gold_lose)
	end
end

function jubaogong_OnAttacked(keys)
    if not IsServer() then return true end
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.attacker
	local gold_gain = ability:GetSpecialValueFor("gold_on_attacked")
	local gold_lose = ability:GetSpecialValueFor("gold_target_lose") * -1

	if caster:PassivesDisabled() or
	   caster:IsIllusion() or
	   target:IsBuilding()
	then 
	    return 
	end

	if target:IsIllusion() or 
	   target:IsClone() or
	   target:IsDominated() or
	   target:IsSummoned() or
	   target:IsCreature() or
	   target:IsCreep()
	then
	    gold_lose = ability:GetSpecialValueFor("gold_target_lose_illusion") * -1
	end

	jubaogong_ModifyGold(caster, gold_gain)
	jubaogong_ModifyGold(target, gold_lose)
end

function jubaogong_OnIntervalThink(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    local caster_gold = caster:GetGold()
	local gold_for_one_stack = ability:GetSpecialValueFor("gold_for_one_stack")
	local amp_per_stack = ability:GetSpecialValueFor("amp_per_stack")
    local StackCount = math.floor(amp_per_stack * caster_gold / gold_for_one_stack)
	local modifier_amp = caster:FindModifierByName("modifier_ogre_magi_jubaogong_spell_amplify")

	if modifier_amp == nil and not caster:PassivesDisabled() then 

	    modifier_amp = ability:ApplyDataDrivenModifier(caster, caster, "modifier_ogre_magi_jubaogong_spell_amplify", nil) 
		modifier_amp:SetStackCount(StackCount)

	elseif modifier_amp and caster:PassivesDisabled() then 

	    modifier_amp:Destroy()

	elseif modifier_amp and not caster:PassivesDisabled() then

	    modifier_amp:SetStackCount(StackCount)

	else
	    return
	end	

	return
end

function jubaogong_ModifyGold(hTarget, gold_change)
    if not IsServer() then return true end
    local playerID = hTarget:GetPlayerOwnerID()
	PlayerResource:ModifyGold(playerID, gold_change, false, DOTA_ModifyGold_AbilityGold)
	--EmitSoundOnEntityForPlayer("General.Coins", hTarget, playerID)
	SendOverheadEventMessage(hTarget:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, hTarget, gold_change, hTarget:GetPlayerOwner()) 	--自带音效，金钱为负不显示特效   
end

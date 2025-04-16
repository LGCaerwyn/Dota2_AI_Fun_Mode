
function fashufangzhi(keys)

	local ability = keys.ability
	local caster = keys.caster
	local cooldown = ability:GetSpecialValueFor("cooldown")
	local time = ability:GetSpecialValueFor("duration")
	local attacker = keys.attacker

	if caster:PassivesDisabled() or caster:IsIllusion() then return end 

	if ability:IsCooldownReady() then

		if attacker:IsHero() then
		    ability:StartCooldown(cooldown)
            local removeStuns = false
			local removeExceptions = false

			if caster:HasModifier("modifier_item_aghanims_shard") then
			    removeStuns = true
				removeExceptions = true
			end

		    caster:Purge(false, true, false, removeStuns, removeExceptions)
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_antimage_counterspell", {duration = time })

			if caster:HasScepter() then
			    caster:PerformAttack(attacker, true, true, true, true, false, false, true)
				local ulti = caster:FindAbilityByName("antimage_mana_void")
				if ulti then
				    caster:SetCursorCastTarget(attacker)
                    ulti:OnSpellStart()
				end
			end

			
		end
	end
end

function antimage_mana_defend_DamageFilter(event, original_damage)
    if event.entindex_victim_const == nil or
	   event.entindex_attacker_const == nil 
	then
	    return true
	end
    local victim = EntIndexToHScript(event.entindex_victim_const)
	local attacker = EntIndexToHScript(event.entindex_attacker_const)
	local fun_ability = attacker:FindAbilityByName("antimage_mana_defend")
	if fun_ability == nil then return true end
	local bonus_dmg_pct_base = 1 + fun_ability:GetSpecialValueFor("bonus_dmg_base")/100
	local bonus_dmg_pct_mana = victim:GetMaxMana() * fun_ability:GetSpecialValueFor("bonus_dmg_mana")/100
	if victim:HasModifier("modifier_antimage_mana_break_slow") and
       fun_ability:GetLevel() >= 1 and
	   attacker:HasScepter() and
	   not attacker:PassivesDisabled()
	then
	    local pre_dmg = event.damage
		local resistance = 0
		--[[
		if event.damagetype_const == DAMAGE_TYPE_MAGICAL then
		    resistance = victim:Script_GetMagicalArmorValue(false, nil)
		elseif event.damagetype_const == DAMAGE_TYPE_PHYSICAL then
		    local armor = victim:GetPhysicalArmorValue(false)
		    resistance = 0.06 * armor/(1 + 0.06 * armor)
		end
		if resistance >= 1 then return true end
		event.damage = pre_dmg / (1 - resistance)]]
	    --event.damagetype_const = DAMAGE_TYPE_PURE
		event.damage = pre_dmg * (bonus_dmg_pct_base + bonus_dmg_pct_mana)
		return true
	end
	return true
end

function fashufangzhi_OnAbilityExecuted(keys)
    
    local event_ability = keys.event_ability
	local caster = keys.caster
	local target = keys.target

	if caster:HasScepter() and 
	   event_ability:GetName() == "antimage_mana_void" and
	   not caster:PassivesDisabled() and
	   target
	then
	    caster:PerformAttack(target, true, true, true, true, false, false, true)
	end
end
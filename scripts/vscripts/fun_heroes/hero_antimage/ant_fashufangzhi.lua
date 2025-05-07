
function fashufangzhi(keys)
    if not IsServer() then return true end
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

    local victim = nil
	local attacker = nil
	local fun_ability = nil

    if event.entindex_victim_const and
	   event.entindex_attacker_const 
	then
	    victim = EntIndexToHScript(event.entindex_victim_const)
	    attacker = EntIndexToHScript(event.entindex_attacker_const)
	end

	if attacker then fun_ability = attacker:FindAbilityByName("antimage_mana_defend") end

	if fun_ability then 
	    local bonus_dmg_pct_base = 1 + fun_ability:GetSpecialValueFor("bonus_dmg_base")/100
	    local bonus_dmg_pct_mana = (victim:GetMaxMana()- victim:GetMana()) * fun_ability:GetSpecialValueFor("bonus_dmg_mana")/100
	    if victim:HasModifier("modifier_antimage_persectur_slow") and
           fun_ability:GetLevel() >= 1 and
	       attacker:HasScepter() and
	       not attacker:PassivesDisabled()
	    then
		    event.damage = event.damage * (bonus_dmg_pct_base + bonus_dmg_pct_mana)
        end
	end
	return true
end

function fashufangzhi_OnAbilityExecuted(keys)
    if not IsServer() then return true end
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
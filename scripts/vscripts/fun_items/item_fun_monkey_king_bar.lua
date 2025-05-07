
function item_fun_monkey_king_bar_OnIntervalThink(keys)
    if not IsServer() then return true end
    local caster = keys.caster
	local ability = keys.ability
	local modifier_attack_ranage_melee = "modifier_item_fun_monkey_king_bar_attack_range_melee"
	if caster:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK and 
	   not caster:HasModifier(modifier_attack_ranage_melee)
	then
	   ability:ApplyDataDrivenModifier(caster, caster, modifier_attack_ranage_melee, nil)
	elseif 
	   caster:GetAttackCapability() ~= DOTA_UNIT_CAP_MELEE_ATTACK and 
	   caster:HasModifier(modifier_attack_ranage_melee)
	then
	   caster:RemoveModifierByName(modifier_attack_ranage_melee)
	end
end

function item_fun_monkey_king_bar_OnAttackLanded(keys)
	if not IsServer() then return true end
	local caster = keys.caster
	local target = keys.target
	local hAbility = keys.ability
	local chance = hAbility:GetSpecialValueFor("bash_chance")
	local stun = hAbility:GetSpecialValueFor("bash_stun")
	local pure_attack_damage = hAbility:GetSpecialValueFor("pure_attack_damage")

	if caster:IsIllusion() or 
	   caster:HasModifier("modifier_monkey_king_fur_army_soldier") or
	   target:IsBuilding()
	then 
	   return 
	end

	if hAbility:IsCooldownReady() and not target:HasModifier("modifier_item_fun_monkey_king_bar_bash_cooldown") then
        local r = RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_ITEM_MKB, caster)
        if r then 
	        
			--拥有时间锁定、深海重击、巨力重击、碎颅锤、深渊之刃时不触发击晕
			if not (caster:HasAbility("faceless_void_time_lock") or 
			          caster:HasAbility("slardar_bash") or
					    caster:HasAbility("spirit_breaker_greater_bash") or
					      caster:HasItemInInventory("item_basher") or
						    caster:HasItemInInventory("item_abyssal_blade") )
			then
			    target:EmitSound("DOTA_Item.MKB.Minibash")
                hAbility:ApplyDataDrivenModifier(caster, target, "modifier_bashed", { duration = stun })
                local cooldown = hAbility:GetEffectiveCooldown(hAbility:GetLevel() - 1)
			    hAbility:StartCooldown(cooldown)
			    hAbility:ApplyDataDrivenModifier(caster, target, "modifier_item_fun_monkey_king_bar_bash_cooldown", { duration = cooldown })
			end
			
        end
	end

	local dmg_table = {
		victim = target,
		attacker = caster,
		damage = pure_attack_damage,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL,
		ability = hAbility
	}
	ApplyDamage(dmg_table)
	return
end








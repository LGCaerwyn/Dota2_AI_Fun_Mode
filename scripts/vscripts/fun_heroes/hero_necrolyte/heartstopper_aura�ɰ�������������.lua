

function 


function HeartstopperAura_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local modifier = "modifier_heartstopper_debuff_datadriven"

	--补丁，幻象提供的光环在死亡后失效，需要手动摧毁
	if ability == nil then 
		local debuff = target:FindModifierByNameAndCaster(modifier, caster)
		debuff:Destroy()
	    return 
	end
	if caster:PassivesDisabled() or caster:HasModifier("modifier_fountain_invulnerability") then return end   

	local target_max_hp = target:GetMaxHealth()
	local aura_damage = ability:GetSpecialValueFor("aura_hp_lose")
	if target:IsAncient() then
	    aura_damage = ability:GetSpecialValueFor("aura_hp_lose_ancient")
	end
	local aura_damage_interval = ability:GetSpecialValueFor("aura_hp_lose_interval")
	
	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.ability = ability
	damage_table.damage = target_max_hp * (0.01 * aura_damage) * aura_damage_interval
	damage_table.damage_flags =  DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION

	ApplyDamage(damage_table)
end

function HeartstopperAura_Set(keys)
	local ability = keys.ability
	local caster = keys.caster
	--local talent = caster:FindAbilityByName("special_bonus_unique_necrophos_reapers_scythe_charges")
	local talent = caster:AddAbility("special_bonus_unique_necrophos_reapers_scythe_charges")
	local ulti = caster:FindAbilityByName("necrolyte_reapers_scythe")
	local charge = 0
	if ulti:IsCooldownReady() then
	    charge = 2
	else
	    charge = 1
	end
	talent:SetLevel(1)
	talent:SetHidden(true)
	--ulti:EndCooldown()
	if ulti:GetLevel() >=1 then
	    ulti:SetCurrentAbilityCharges(charge)
    end
end

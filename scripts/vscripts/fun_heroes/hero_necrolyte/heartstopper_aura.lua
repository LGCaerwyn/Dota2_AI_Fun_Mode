
function HeartstopperAura_OnIntervalThink( keys )
    if not IsServer() then return true end
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local modifier = "modifier_heartstopper_debuff_datadriven"

	--�����������ṩ�Ĺ⻷��������ʧЧ����Ҫ�ֶ��ݻ�
	if ability == nil then 
		local debuff = target:FindModifierByNameAndCaster(modifier, caster)
		debuff:Destroy()
	    return 
	end
	if caster:PassivesDisabled() or caster:HasModifier("modifier_fountain_invulnerability") then return end   

	local target_max_hp = target:GetMaxHealth()
	local aura_damage = target_max_hp * ability:GetSpecialValueFor("aura_hp_lose") * 0.01
	if target:IsAncient() then
	    aura_damage = ability:GetSpecialValueFor("aura_hp_lose_ancient")
	end
	local aura_damage_interval = ability:GetSpecialValueFor("aura_hp_lose_interval")
	
	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.ability = ability
	damage_table.damage = aura_damage * aura_damage_interval
	damage_table.damage_flags =  DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION

	ApplyDamage(damage_table)
end

function HeartstopperAura_Set(keys)

	local ability = keys.ability
	local caster = keys.caster
	local ulti = caster:FindAbilityByName("necrolyte_reapers_scythe")
	local charge = 0
	if ulti == nil then return end
	if ulti:IsCooldownReady() then
	    charge = 2
	else
	    charge = 1
	end
	ulti:EndCooldown()
	if ulti:GetLevel() >=1 then
	    ulti:SetCurrentAbilityCharges(charge)
    end
end

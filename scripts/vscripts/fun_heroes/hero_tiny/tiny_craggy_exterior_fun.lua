function craggy_exterior_OnAttacked(keys)
    
    local caster = keys.caster
    local attacker = keys.attacker
    if caster:PassivesDisabled() or 
       attacker:IsMagicImmune() or
       attacker:IsBuilding() or
       caster:GetTeam() == attacker:GetTeam() or
       caster:IsIllusion() or
       not caster:IsAlive()
    then 
        return 
    end
    local ability = keys.ability
    local chance = ability:GetSpecialValueFor("chance")
    local time_dur = ability:GetSpecialValueFor("time_dur")
    local damage_tiny = ability:GetSpecialValueFor("damage_tiny")
    
    local r = RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_TINY_CRAGGY, attacker)

    if r then

        attacker:EmitSound("DOTA_Item.SkullBasher")
        ability:ApplyDataDrivenModifier(caster, attacker, "modifier_bashed", { duration = time_dur })

        damage_table = {}
        damage_table.victim = attacker
        damage_table.attacker = caster
        damage_table.damage = damage_tiny
        damage_table.damage_type = DAMAGE_TYPE_ABILITY_DEFINED
        damage_table.damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL
        damage_table.ability = ability

        ApplyDamage(damage_table)
    end
end
    
function absorb_mana(keys)
    if IsServer() then
        local attacker = keys.attacker
        local caster = keys.caster
        local target = keys.target
        local ability = keys.ability
        local manaAbsorption = ability:GetSpecialValueFor("absorption") --/ 100
        		--manaAbsorptionPercent
        if attacker:GetTeam() ~= target and 
           target:GetMaxMana() ~= 0 and
           not target:IsBuilding() and
           not caster:PassivesDisabled() 
        then
           -- local targetMana = target:GetMana()
            --local manaAbsorbed = math.min(targetMana, target:GetMaxMana() * manaAbsorptionPercent)
           -- target:ReduceMana(manaAbsorbed)
            caster:GiveMana(manaAbsorption)
        end
    end
end

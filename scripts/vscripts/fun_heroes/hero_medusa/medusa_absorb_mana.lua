


function absorb_mana(keys)
    if IsServer() then
        local attacker = keys.attacker
        local caster = keys.caster
        local target = keys.target
        local ability = keys.ability
        local manaAbsorption = ability:GetSpecialValueFor("absorption") --/ 100
        		--manaAbsorptionPercent
        if attacker == caster and target:GetMaxMana() ~= 0 then
           -- local targetMana = target:GetMana()
            --local manaAbsorbed = math.min(targetMana, target:GetMaxMana() * manaAbsorptionPercent)
           -- target:ReduceMana(manaAbsorbed)
            caster:GiveMana(manaAbsorption)
        end
    end
end

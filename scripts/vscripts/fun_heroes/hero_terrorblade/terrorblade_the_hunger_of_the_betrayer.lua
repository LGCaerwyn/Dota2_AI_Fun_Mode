
function the_hunger_of_the_betrayer_onattacklanded(keys)

	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	local target = keys.target
	local damage = keys.Damage
	local heal_amount = ability:GetSpecialValueFor("heal_amount") * 0.01
	
    if keys.attacker == caster and not target:IsBuilding() then
   		 local heal_amount = damage * heal_amount
        	   caster:HealWithParams(heal_amount, ability, true, false, caster, false)
      	-- keys.attacker:Heal(heal_amount, self:GetAbility())

    	--    local cd_reduction_percent = 10 -- 技能冷却缩减百分比
   	 	--    local ability = self:GetAbility()
        for i = 0, 23 do
            local ability_i = keys.attacker:GetAbilityByIndex(i)
            if ability_i and ability_i ~= ability then
                local cd_remaining = ability_i:GetCooldownTimeRemaining()
                if cd_remaining > 0 then
                --    local cd_reduction = ability_i:GetCooldown(ability_i:GetLevel() - 1) * cd_reduction_percent / 100
                	local cd_reduction = ability_i:GetCooldownTimeRemaining() - 1
                    ability_i:EndCooldown()
                  --  ability_i:StartCooldown(cd_remaining - cd_reduction)
                  	ability_i:StartCooldown(cd_reduction)
                end
            end
        end
    end
end
--[[Author: Pizzalol
	Date: 09.02.2015.
	Triggers when the unit attacks
	Checks if the attack target is the same as the caster
	If true then trigger the counter helix if its not on cooldown]]
function CounterHelix( keys )
	if not IsServer() then return end
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local attacker = keys.attacker
	local helix_modifier = keys.helix_modifier
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)

	local chance = ability:GetSpecialValueFor("trigger_chance")
	local tether = caster:FindAbilityByName("axe_culling_blade")
	local damage = ability:GetAbilityDamage()
	local damage_type = ability:GetAbilityDamageType()

	local ability_axe = caster:FindAbilityByName("axe_culling_blade")
	local level = ability_axe:GetLevel()
	local damage_axe = ability_axe:GetLevelSpecialValueFor("damage", level - 1)

	if caster:PassivesDisabled() then return end      --脨脗脭枚脝脝卤禄露炉脨搂鹿没
	
	--local playerID = caster:GetPlayerID()
	
	if caster:HasScepter() then
		damage_type = DAMAGE_TYPE_PURE
	end

	if PlayerResource:IsFakeClient(caster:GetPlayerID())  then
	
		chance = 50

	end



	if ability:IsCooldownReady() then
	-- If the caster has the helix modifier then do not trigger the counter helix
	-- as its considered to be on cooldown
	
	local r = RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_PHANTOMASSASSIN_CRIT, caster)

     	if not r  then 
      	   return
     	end



		if target == caster and not caster:HasModifier(helix_modifier) then

			ability:ApplyDataDrivenModifier(caster, caster, helix_modifier, {})
			
					
			if PlayerResource:IsFakeClient(caster:GetPlayerID()) and caster:HasScepter() then
			   ability:ApplyDataDrivenModifier(caster, caster, "modifier_counter_helix_fun_buff", {duration = 20 })
				--x娴嬭瘯娌℃湁鏁堟灉
			end
			--路麓禄梅脗脻脨媒脡脣潞娄
			local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, 350, 
				DOTA_UNIT_TARGET_TEAM_ENEMY, 
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC , 
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES , FIND_ANY_ORDER  , false)

			for k,target in pairs(targets) do
				--print(k,v)
				damagetable = {
				victim = target,
				attacker = caster, 
				damage = damage,
				damage_type = damage_type,
				ability  =  ability
						  }
				ApplyDamage(damagetable)
				--脮露脡卤虏芒脢脭


				if PlayerResource:IsFakeClient(caster:GetPlayerID())  then

					if caster:HasScepter() and target:IsRealHero() and target:GetHealth() < damage_axe then
						caster:SetCursorCastTarget(target)
						tether:OnSpellStart()
					end
				end
			end
				   -- print("脰麓脨脨脡脣潞娄")
			ability:StartCooldown(cooldown)
		end
	end
end


function zhansha( every )
	if not IsServer() then return end
	local caster = every.caster
	local target = every.target
	local tether = caster:FindAbilityByName("axe_culling_blade")
	local ability_axe = caster:FindAbilityByName("axe_culling_blade")
	local level = ability_axe:GetLevel()
	local damage_axe = ability_axe:GetLevelSpecialValueFor("damage", level - 1)

--tether:SetLevel(2)
--tether:EndCooldown()

	--if caster:PassivesDisabled() then return end      --脨脗脭枚脝脝卤禄露炉脨搂鹿没拢卢脙禄脫脨赂脙脨脨麓煤脗毛脮露脡卤脨搂鹿没脪虏禄谩卤禄脝脝禄碌陆没脫脙拢卢脪貌脦陋脟掳脰脙碌脛脨脼脢脦脝梅禄谩卤禄脝脝禄碌陆没脫脙
	


-----------------------------------------------------
-----------------------------------------------------
--[[
	if PlayerResource:IsFakeClient(caster:GetPlayerID())  then

		if caster:HasScepter() and target:IsRealHero() and target:GetHealth() < damage_axe  then
			caster:SetCursorCastTarget(target)
			tether:OnSpellStart()
		end
	else
	    if caster:HasScepter() and target:IsRealHero() and target:GetHealth() < damage_axe then
        caster:SetCursorCastTarget(target)
        tether:OnSpellStart()
		end
	end

	--]]
	-- body
end


require('timers')

function bristleback_back( keys )
	-- body
	if not IsServer() then return end
	local caster = keys.caster
	local target = keys.caster
	local ability = keys.ability

	local chance = ability:GetSpecialValueFor("trigger_chance")
	local tether = caster:FindAbilityByName("bristleback_quill_spray")
--	local damage = ability:GetAbilityDamage()
--	local damage_type = ability:GetAbilityDamageType()
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1) * caster:GetCooldownReduction() 
	if caster:PassivesDisabled() then return end      --ÐÂÔöÆÆ±»¶¯Ð§¹û
	
	local playerID = caster:GetPlayerID()
	
    if PlayerResource:IsFakeClient(playerID)  then

      chance = 100
  --    cooldown = cooldown * 0.5
      
    end


	if ability:IsCooldownReady() then
	-- If the caster has the helix modifier then do not trigger the counter helix
	-- as its considered to be on cooldown


	
	local r = RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_PHANTOMASSASSIN_CRIT, caster)

     	if not r  then 
      	   return
     	end


     		tether:OnSpellStart()
			ability:StartCooldown(cooldown)
	end

end


function bristleback_back_test( keys )
	-- body

	if not IsServer() then return end
	local caster = keys.caster
--	local target = keys.target
	local ability = keys.ability
	local attacker = keys.attacker
	local ability_ak = attacker:FindAbilityByName("bristleback_back")
	if caster:PassivesDisabled() then return end      --ÐÂÔöÆÆ±»¶¯Ð§¹û
	
	local playerID = caster:GetPlayerID()
	
--	if not	PlayerResource:IsFakeClient(playerID)  then
--	return
--	end

--	local chance = ability:GetSpecialValueFor("trigger_chance")
	local tether = caster:FindAbilityByName("bristleback_quill_spray")
	local tether_ak = attacker:FindAbilityByName("bristleback_quill_spray")
	local victim_angle = keys.unit:GetAnglesAsVector().y
	local origin_difference = keys.unit:GetAbsOrigin() - keys.attacker:GetAbsOrigin()
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	origin_difference_radian = origin_difference_radian * 180
	local attacker_angle = origin_difference_radian / math.pi
	attacker_angle = attacker_angle + 180.0
	local result_angle = attacker_angle - victim_angle
	result_angle = math.abs(result_angle)


	if not (attacker:GetUnitName() == "npc_dota_hero_bristleback")	 then
		print("不是bristleback攻击者")
		return
	end


		-- 调用函数进行判断
		-- 假设有两个英雄hero1和hero2
		local are_heroes_back_to_back = AreHeroesBackToBack(caster, attacker)



		if are_heroes_back_to_back then



		if 	PlayerResource:IsFakeClient(playerID)  then
				Timers:CreateTimer(0.1, function()
		           	if caster:IsAlive() and attacker:IsAlive() then
			           	tether:OnSpellStart()		
				           return 0.1
				           else
				           return nil
					 end
				 end) 

				Timers:CreateTimer(0.1, function()
		           	if caster:IsAlive() and attacker:IsAlive() then
			           	tether_ak:OnSpellStart()		
				           return 0.2
				           else
				           return nil
					 end
				 end) 
			else
				Timers:CreateTimer(0.1, function()
		           	if caster:IsAlive() and attacker:IsAlive() then
		           		tether:OnSpellStart()		
			            return 0.2
			           	else
			            return nil
					end

				 end) 
				Timers:CreateTimer(0.1, function()
		           	if caster:IsAlive() and attacker:IsAlive() then
			           	tether_ak:OnSpellStart()		
				           return 0.1
				           else
				           return nil
					 end
				 end) 
		end
		   -- print("英雄们相互背对着")
		else
		   -- print("英雄们不是相互背对着")
		end


		--[[
		Timers:CreateTimer(0.1, function()
	           	if caster:IsAlive() and attacker:IsAlive() then
	           	tether:OnSpellStart()		
		           return 0.1
		           		 else
		           return nil
					 	  end

					      end) 
		--]]
			--	if keys.Damage  >= 400 then
				--	print("触发")
			--		tether:OnSpellStart()
			--	end
	


	
	
end

-- 定义一个函数来计算两个单位之间的夹角
function CalculateAngleBetweenHeroes(hero1, hero2)
    local vec1 = hero1:GetForwardVector()
    local vec2 = (hero2:GetOrigin() - hero1:GetOrigin()):Normalized()
    local dotProduct = DotProduct(vec1, vec2)
    local angle = math.acos(dotProduct) * (180 / math.pi)  -- 转换为角度

    -- 将角度转换为0到360度的范围
    if angle > 180 then
        angle = 360 - angle
    end

    return angle
end

-- 定义一个函数来判断两个单位是否相互背对
function AreHeroesBackToBack(hero1, hero2)
    local angle1 = CalculateAngleBetweenHeroes(hero1, hero2)
    local angle2 = CalculateAngleBetweenHeroes(hero2, hero1)

    -- 检查两个角度是否都在120度到240度之间
    return (angle1 >= 120 and angle1 <= 240) and (angle2 >= 120 and angle2 <= 240)
end


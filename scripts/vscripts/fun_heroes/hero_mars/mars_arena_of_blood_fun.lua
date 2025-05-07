 
 
function mars_arena_of_blood_fun( keys )
    if not IsServer() then return true end
	local caster = keys.caster
    local event_ability = keys.event_ability:GetAbilityName()
	--local casterPoint = caster:GetAbsOrigin()
	local targetPoint = keys.event_ability:GetCursorPosition()
	local ulti = caster:FindAbilityByName("mars_arena_of_blood")
	local ulti_lvl = ulti:GetLevel()
	local ability = keys.ability
	local cooldown = ability:GetCooldownTimeRemaining()
	local duration = ulti:GetSpecialValueFor("duration")

	if caster:PassivesDisabled() then return end  --破坏状态禁用	

	if event_ability == "mars_arena_of_blood"  then		
	    
	    duration = duration + ability:GetCooldownTimeRemaining()
        ability:EndCooldown()
	    ability:StartCooldown(duration) --本技能进入冷却
	    
	    local tether = caster:FindAbilityByName("mars_arena_of_blood_fun_1")
		tether:SetLevel(ulti_lvl)				  
        caster:SetCursorPosition(targetPoint)
        tether:OnSpellStart()
        tether:EndCooldown()
						
		local tether_2 = caster:FindAbilityByName("mars_arena_of_blood_fun_2")
		tether_2:SetLevel(ulti_lvl)				  
        caster:SetCursorPosition(targetPoint)
        tether_2:OnSpellStart()
        tether_2:EndCooldown()				
		

	end
									
end
---------------------------------------------------------------------------------------------------
function arena_of_blood_fun_recall(keys)
    if not IsServer() then return true end
	local caster = keys.caster
	local ability = keys.ability
	local targetPoint = ability:GetCursorPosition()
	local ulti = caster:FindAbilityByName("mars_arena_of_blood")
	local ulti_lvl = ulti:GetLevel()
	local tether

	if ulti_lvl > 0 then 
	    if ability:GetAutoCastState() then
	        tether = caster:FindAbilityByName("mars_arena_of_blood_fun_2")
		else
		    tether = caster:FindAbilityByName("mars_arena_of_blood_fun_1")
		end
		tether:SetLevel(ulti_lvl)
		--caster:SetCursorPosition(targetPoint)

	    local duration = tether:GetSpecialValueFor("duration") + ulti:GetCooldownTimeRemaining()
		ulti:EndCooldown()
		ulti:StartCooldown(duration) --终极技能进入冷却
		tether:OnSpellStart()
	end

end
-------------------------------------------------------------------------
function cannot_be_stolen(keys)
    if not IsServer() then return true end
     --print("这个技能不可以被拉比克偷取！")
     local caster = keys.caster
     local abilityName = keys.AbilityName --自定义参数
     local ability = caster:FindAbilityByName(abilityName)
     ability:SetStealable(false)
     return
end
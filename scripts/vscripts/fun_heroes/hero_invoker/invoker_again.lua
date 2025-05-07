
function invoker_again( keys )

    local caster = keys.caster
	local ability = keys.ability
	local event_ability = keys.event_ability
	local event_ability_name = event_ability:GetAbilityName()

    if caster:PassivesDisabled() then return end

    local casterPoint = caster:GetAbsOrigin()
    local targetPoint = keys.event_ability:GetCursorPosition()
    local event_ability = keys.event_ability
    if keys.target  ~= nil then
        targetPoint = keys.target:GetAbsOrigin()
    end

	local weizhixiangliang = casterPoint - targetPoint		
	local weizhixiangliang_fangxiang = weizhixiangliang:Normalized()
	jiaodu = {45,90,135,225,270,315,360}  

	local spawnDistance = weizhixiangliang:Length2D()--300
	local round_circular = weizhixiangliang_fangxiang 
	local R = spawnDistance

	table_ability_invoker ={"invoker_tornado","invoker_chaos_meteor","invoker_sun_strike","invoker_emp"}  

		for k,v in pairs(table_ability_invoker) do

		

				if ability == v  then


					for k,v in pairs(jiaodu) do  
			            
			            local x1 = casterPoint.x + R * ( round_circular.x * math.cos(math.rad(v)) - round_circular.y * math.sin(math.rad(v)) )  
						local y1 = casterPoint.y + R * ( round_circular.y * math.cos(math.rad(v)) + round_circular.x * math.sin(math.rad(v)) ) 
			            local bamian_changdu_spawn  = Vector(x1,y1,targetPoint.z) 
									
			            Timers:CreateTimer(0.05,

			                function()
									  
			                    local tether = caster:FindAbilityByName(ability)   
							    caster:SetCursorPosition(bamian_changdu_spawn)
							    tether:OnSpellStart()
							    return nil
							end)
					end
							 
			    end						
	    end
end
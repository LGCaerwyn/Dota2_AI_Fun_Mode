require('timers')

function lion_emowushi( keys )
    if not IsServer() then return true end
    local caster = keys.caster
    if caster:PassivesDisabled() then return end

    local ability = keys.event_ability:GetAbilityName()
    local casterPoint = caster:GetAbsOrigin()
    local targetPoint = keys.event_ability:GetCursorPosition()
    
    if keys.target  ~= nil then
        targetPoint = keys.target:GetAbsOrigin()
    end

	local weizhixiangliang = casterPoint - targetPoint		
	local weizhixiangliang_fangxiang = weizhixiangliang:Normalized()

	if ability == "lion_impale"  then
        jiaodu = {45,90,135,225,270,315,360}   
		local spawnDistance   = 300
		local  round_circular = weizhixiangliang_fangxiang 
		local R = spawnDistance      

		for k,v in pairs(jiaodu) do  
            
            local x1 = casterPoint.x + R * ( round_circular.x * math.cos(math.rad(v)) - round_circular.y * math.sin(math.rad(v)) )  
			local y1 = casterPoint.y + R * ( round_circular.y * math.cos(math.rad(v)) + round_circular.x * math.sin(math.rad(v)) ) 
            local bamian_changdu_spawn  = Vector(x1,y1,targetPoint.z) 
						
            Timers:CreateTimer(0.05,

                function()
						  
                    local tether = caster:FindAbilityByName("lion_impale")   
				    caster:SetCursorPosition(bamian_changdu_spawn)
				    tether:OnSpellStart()
				    return nil
				end)
		end
    --[[
    --施放妖术和抽蓝也触发裂地尖刺
    elseif ability == "lion_voodoo" or ability == "lion_mana_drain" then
        local tether = caster:FindAbilityByName("lion_impale")   
    	caster:SetCursorPosition(targetPoint)
    	tether:OnSpellStart()
    ]]						 
    elseif  ability == "lion_finger_of_death" then
        local tether = caster:FindAbilityByName("lion_impale")   
        caster:SetCursorPosition(targetPoint)
        tether:OnSpellStart()
        tether:EndCooldown()
    end						

end

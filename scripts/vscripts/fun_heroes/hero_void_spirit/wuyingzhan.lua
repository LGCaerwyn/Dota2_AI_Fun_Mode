require('timers')

function wuyingzhan( keys )

    if not IsServer() then return end

	local ability = keys.ability
	local caster = keys.caster
    local target = keys.target
	local num = ability:GetSpecialValueFor("base_strike") + math.floor(caster:GetLevel() / ability:GetSpecialValueFor("per_strike_level"))
	local tick = ability:GetSpecialValueFor("tick")
	if target:TriggerSpellAbsorb(ability) then return end
	local hasUlti = true
	local tether
	--记录斩击次数，变为局部变量，防止拉比克与虚无之灵共享次数
	local v = nil
	local bb = nil
	local g = nil

	local buff = ability:ApplyDataDrivenModifier(caster, caster, "modifier_void_spirit_wuyingzhan", {})
	local debuff = ability:ApplyDataDrivenModifier(caster, target, "modifier_void_spirit_wuyingzhan_true_sight", {})

    local fruits = {}
    for i=1,num do
        a = math.floor(math.random (1,360))
		table.insert(fruits,a)
	end
	CenterCameraOnUnit(caster:GetPlayerID(), target)
	--******************************************************************
    --生效阶段
    --******************************************************************
    Timers:CreateTimer(function()
		
	    -------------------------------------------------------------------------------------------------
	    --多加了这一块代码，本身对单位的合法性判断不够严密，导致在斧王岛斩击过程中移除傀儡会让施法者卡主
	    if not IsValidEntity(target) then 

		    buff:SetDuration(0.1, true)
			--debuff:SetDuration(0.1, true)
			GridNav:DestroyTreesAroundPoint(caster:GetOrigin(), 350, true)
			v = nil
			bb = nil
			if hasUlti == false then
	            caster:RemoveAbility("void_spirit_astral_step")
	        end
			--print("终止原因：失效单位")
			return nil
		end
		------------------------------------------------------------------------------------------------

        local targetPoint = target:GetOrigin()
		local casterPoint = caster:GetOrigin()
		local weizhixiangliang = targetPoint - casterPoint
		local distance = weizhixiangliang:Length2D()
		local direction = weizhixiangliang:Normalized()
		local vecShip0 = direction
		 
	    --------------------------------------------------------------------
		--阵亡、失去视野、超出极限距离2000后终止技能
		--------------------------------------------------------------------
	    if not (caster:IsAlive() and target:IsAlive()) or target:IsInvisible()  or distance > 2000 then 
		    
		    if buff and not buff:IsNull() then
		        buff:SetDuration(0.1, true)
			end
		    if debuff and not debuff:IsNull() then
		        debuff:SetDuration(0.1, true)
			end
			GridNav:DestroyTreesAroundPoint(caster:GetOrigin(), 350, true)
			v = nil
			bb = nil
			if hasUlti == false then
	            caster:RemoveAbility("void_spirit_astral_step")
	        end
			--print("终止原因：失效单位")

			return nil
		end

		if v == nil then
		    v  = 1
	    elseif v <= #fruits then
		    v = v + 1
	    else
		    v = 1
	    end

		tether = caster:FindAbilityByName("void_spirit_astral_step")
	    --------------------------------------------------------------------
		--未拥有此技能时，技能等级取决于自身
		--------------------------------------------------------------------
		if tether == nil then
		    tether = caster:AddAbility("void_spirit_astral_step")
			if caster:GetLevel() >= 18 then
			    tether:SetLevel(3)
			elseif caster:GetLevel() >= 12 then
			    tether:SetLevel(2)
			elseif caster:GetLevel() >= 6 then
			    tether:SetLevel(1)
			end
			tether:SetHidden(true)
			hasUlti = false
		end

		--斩击的起始、终点与太虚之径的最大距离相关,上限1200。下限200，否则等级过低/未学习时会出现0向量导致模型动作错误。
		local travel = math.max(200,(tether:GetSpecialValueFor("max_travel_distance") + caster:GetCastRangeBonus())/2)  
		travel = math.min(travel , 1200)

		--目标点
		local x1 = targetPoint.x + travel * ( vecShip0.x * math.cos(math.rad(fruits[v])) - vecShip0.y * math.sin(math.rad(fruits[v])) )  
		local y1 = targetPoint.y + travel * ( vecShip0.y * math.cos(math.rad(fruits[v])) + vecShip0.x * math.sin(math.rad(fruits[v])) )  

		--起始点
		local x2 = targetPoint.x + travel * ( vecShip0.x * math.cos(math.rad(fruits[v]+180)) - vecShip0.y * math.sin(math.rad(fruits[v]+180)) )  
		local y2 = targetPoint.y + travel * ( vecShip0.y * math.cos(math.rad(fruits[v]+180)) + vecShip0.x * math.sin(math.rad(fruits[v]+180)) )  

		local start_vec = Vector(x2,y2,targetPoint.z)
		local end_vec = Vector(x1,y1,targetPoint.z)

		FindClearSpaceForUnit(caster, start_vec, true)
		--CenterCameraOnUnit(caster:GetPlayerID(), target)
		AddFOWViewer(caster:GetTeam(), targetPoint, 800, 1.5, false)

		caster:SetForwardVector(TG_Direction(end_vec, start_vec))
		caster:SetCursorPosition(end_vec)

		if caster:HasScepter() and not caster:PassivesDisabled() then
	        local team = caster:GetTeam()
		    local startPos = caster:GetOrigin()
		    local endPos = end_vec
		    local cacheUnit = nil
		    local width = tether:GetSpecialValueFor("radius")
		    local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		    local typeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
		    local flagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

	        local units = FindUnitsInLine(team, startPos, endPos, cacheUnit, width, teamFilter, typeFilter, flagFilter)

		    for _,v in ipairs(units) do
				if not v:IsDebuffImmune() and not v:IsMagicImmune() then
			        v:Purge(true, false, false, false, false)
			    end
			    ability:ApplyDataDrivenModifier(caster, v, "modifier_stunned", { duration = 0.1 })
		        if v:IsIllusion() and not v:IsStrongIllusion() and v:IsAlive() then
			        v:Kill(ability, caster)
			    end 
		    end
		end

		tether:OnSpellStart()       
        if bb == nil then
            bb =0
		end
				     
		bb = bb + 1
		g = bb +1

	    --------------------------------------------------------------------
		--次数达到上限终止技能
		--------------------------------------------------------------------
		if g > #fruits then
		    bb = nil
			v = nil
            buff:SetDuration(0.1, true)
			debuff:SetDuration(0.1, true)
			GridNav:DestroyTreesAroundPoint(end_vec, 350, true)
			--print("终止原因：次数上限")
			if hasUlti == false then
	            caster:RemoveAbility("void_spirit_astral_step")
	        end
            return nil
		else									 
			return tick
		end
	end
    )
end

------------------------------------------------------------------------------------------------------------------------------------------

function TG_Direction(fpos,spos)
  local DIR=( fpos - spos):Normalized()
  DIR.z=0
  return DIR
end

------------------------------------------------------------------------------------------------------------------------------------------

function TG_Direction2(fpos,spos)
  local DIR=( fpos - spos):Normalized()
  return DIR
end

function modifier_void_spirit_wuyingzhan_OnDestroy(keys)
    if not IsServer() then return true end
    local caster = keys.caster
	local ability = keys.ability
	local ability_dissimilate = caster:FindAbilityByName("void_spirit_dissimilate")
	local hasShard = caster:HasModifier("modifier_item_aghanims_shard")
	local dissimilate_castable = false
	local dissimilate_buff_duration = ability:GetSpecialValueFor("dissimilate_buff_duration")

	if ability_dissimilate and hasShard then
	    if ability_dissimilate:GetLevel() > 0 then
		    dissimilate_castable = true
		end
	end

    if dissimilate_castable and caster:IsAlive() then
	    ability_dissimilate:OnSpellStart()
	    if caster:HasScepter() and not caster:PassivesDisabled() then 
		    ability:ApplyDataDrivenModifier(caster, caster, "modifier_void_spirit_wuyingzhan_dissimilate_buff", { duration = dissimilate_buff_duration })
		end 
	end
end

--残阴附带额外效果
function void_spirit_wuyingzhan_ModifierGainedFilter(event)
    if not IsServer() then return true end

    if not event.entindex_caster_const then return result end
    if not event.entindex_parent_const then return result end
    if not event.name_const then return result end
	if not event.duration then return result end
    local caster = EntIndexToHScript(event.entindex_caster_const)
    local npc = EntIndexToHScript(event.entindex_parent_const)
    local modifier_name = event.name_const
    if caster == nil then return result end
    if npc == nil then return result end

    local special_bonus = caster:FindAbilityByName("void_spirit_wuyingzhan") 
    if special_bonus == nil then return result end
    if special_bonus:GetLevel() < 1 then return result end
	if not caster:HasScepter() or caster:PassivesDisabled() then return result end

    if modifier_name == "modifier_void_spirit_aether_remnant_pull" then
	    special_bonus:ApplyDataDrivenModifier(caster, npc, "modifier_void_spirit_wuyingzhan_aether_remnant_debuff", { duration = event.duration })
    end   

	return result
end

--共鸣脉冲附带额外效果
function void_spirit_wuyingzhan_DamageFilter(event, original_damage) 
    if not IsServer() then return true end
    if event.entindex_victim_const == nil or
	   event.entindex_attacker_const == nil or
	   event.entindex_inflictor_const == nil
	then
	    return true
	end
    local victim = EntIndexToHScript(event.entindex_victim_const)
	local attacker = EntIndexToHScript(event.entindex_attacker_const)
	local inflictor = EntIndexToHScript(event.entindex_inflictor_const)
	local fun_ability = attacker:FindAbilityByName("void_spirit_wuyingzhan")
	if fun_ability == nil then return true end

	if inflictor:GetName() == "void_spirit_resonant_pulse" and
       fun_ability:GetLevel() >= 1 and
	   attacker:HasScepter() and
	   not attacker:PassivesDisabled()
	then
	    --local buff_no_cleave = attacker:AddNewModifier(attacker, fun_ability, "modifier_void_spirit_astral_step_caster", nil)  --抑制分裂效果的修饰器，选择这个会让攻击继承太虚之径的暴击天赋
		local buff_no_cleave = attacker:AddNewModifier(attacker, fun_ability, "modifier_tidehunter_anchor_smash_caster", nil)	
        attacker:PerformAttack(victim, true, true, true, false, false, false, true)
		if buff_no_cleave then
		    buff_no_cleave:Destroy()
		end
		return true
	end
	return true
end


function modifier_void_spirit_wuyingzhan_passive_OnAbilityExecuted(keys)
    if not IsServer() then return true end

    local caster = keys.caster
	local ability = keys.ability
	local event_ability = keys.event_ability
	local ability_dissimilate = caster:FindAbilityByName("void_spirit_dissimilate")
	local ability_astral_step = caster:FindAbilityByName("void_spirit_astral_step")
    local dissimilate_buff_duration = ability:GetSpecialValueFor("dissimilate_buff_duration")
	local illusion_bonus_debuff = ability:GetSpecialValueFor("illusion_bonus_debuff")
	local debuff_dur = 0

	if not caster:HasScepter() or caster:PassivesDisabled() then return end 

	if event_ability == ability_dissimilate then
	     ability:ApplyDataDrivenModifier(caster, caster, "modifier_void_spirit_wuyingzhan_dissimilate_buff", { duration = dissimilate_buff_duration })
	end

	if event_ability == ability_astral_step then
	     
	    
	    local team = caster:GetTeam()
		local startPos = caster:GetOrigin()
		local endPos = ability_astral_step:GetCursorPosition()
		local cacheUnit = nil
		local width = ability_astral_step:GetSpecialValueFor("radius")
		local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		local typeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
		local flagFilter = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

	    local units = FindUnitsInLine(team, startPos, endPos, cacheUnit, width, teamFilter, typeFilter, flagFilter)

		for _,v in ipairs(units) do
		    if not v:IsDebuffImmune() and not v:IsMagicImmune() then
			    v:Purge(true, false, false, false, false)
			end    
			ability:ApplyDataDrivenModifier(caster, v, "modifier_stunned", { duration = 0.1 })
		    if v:IsIllusion() and not v:IsStrongIllusion() and v:IsAlive() then
			    for i =1, illusion_bonus_debuff do
				    debuff_dur = ability_astral_step:GetSpecialValueFor("pop_damage_delay") * (1 - v:GetStatusResistance())
			        v:AddNewModifier(caster, event_ability, "modifier_void_spirit_astral_step_debuff", { duration = debuff_dur })
				end
			end 
		end
	end
end
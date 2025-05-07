
function MoveUnits( keys )
    if not IsServer() then return true end
	local caster = keys.caster
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	ability.point_entity = target

	local speed = ability:GetLevelSpecialValueFor("pull_speed", ability_level)/33
	local radius = ability:GetLevelSpecialValueFor("far_radius", ability_level)


	local target_teams = ability:GetAbilityTargetTeam() 
	local target_types = ability:GetAbilityTargetType() 
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES --ability:GetAbilityTargetFlags() 


	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, radius, target_teams, target_types, target_flags, 0, false)

	for i,unit in ipairs(units) do

	--等角螺线，固定向径变化等于speed的情况
	local unit_location = unit:GetAbsOrigin()
	local vector_distance = unit_location - target_location
	local distance = vector_distance:Length2D()
	local a = distance
	--local b = math.rad(168.75)    --等角螺线的夹角，与牵引角度11.25有关,逆时针旋转时向中心靠近
	--local cot_b = 1/math.tan(b)   --余切
	--local sec_b = 1/math.cos(b)  --正割
    local rho = a - speed  --旋转固定距离后的向径长度，这里希望rho比a小，所以sec_b为负
	local rad = math.log(rho /a) /(-0.6127) --向径对应的极角,参数是黄金螺线参数的两倍

	local x1 = unit_location.x
	local y1 = unit_location.y
	local x2 = target_location.x
	local y2 = target_location.y
	unit_location.x = (x1 - x2) * math.cos(rad) - (y1 - y2) * math.sin(rad) + x2
	unit_location.y = (x1 - x2) * math.sin(rad) + (y1 - y2) * math.cos(rad) + y2

	local vector_distance_new = unit_location - target_location
	local direction = vector_distance_new:Normalized()

	if distance > speed then
		unit:SetAbsOrigin(target_location + direction * rho)
	else
		unit:SetAbsOrigin(target_location)
	end

	--[[
	--等角螺线，旋转固定弧长的情况，夹角固定为：180 - 11.25 = 168.75度,每秒弧长约33，每个tick弧长为1
	local unit_location = unit:GetAbsOrigin()
	local vector_distance = unit_location - target_location
	local distance = vector_distance:Length2D()

	local a = distance
	local b = math.rad(168.75)    --等角螺线的夹角，与牵引角度11.25有关,逆时针旋转时向中心靠近
	local cot_b = 1/math.tan(b)   --余切
	local sec_b = 1/math.cos(b)  --正割
    local rho = speed /sec_b + a  --旋转固定距离后的向径长度，这里希望rho比a小，所以sec_b为负
	local rad = math.log(rho /a) /cot_b --向径对应的极角，这里前一项为负，所以cot_b也为负，rad的单位是弧度

	--旋转角度为rad
	local x1 = unit_location.x
	local y1 = unit_location.y
	local x2 = target_location.x
	local y2 = target_location.y
	unit_location.x = (x1 - x2) * math.cos(rad) - (y1 - y2) * math.sin(rad) + x2
	unit_location.y = (x1 - x2) * math.sin(rad) + (y1 - y2) * math.cos(rad) + y2

	local vector_distance_new = unit_location - target_location
	local direction = vector_distance_new:Normalized()
	unit:SetAbsOrigin(target_location + direction * rho)
	]]--

	--[[
	    --等角螺线，固定旋转角度的情况，不需要变量speed，每个tick旋转0.52度
		local unit_location = unit:GetAbsOrigin()
		--第一步：将目标相对中心旋转至合适的角度
		local x1 = unit_location.x
		local y1 = unit_location.y
		local x2 = target_location.x
		local y2 = target_location.y
		unit_location.x = (x1 - x2) * math.cos(math.rad(0.52)) - (y1 - y2) * math.sin(math.rad(0.52)) + x2                   --math.sin(math.rad(11.25))     math.cos(math.rad(11.25))
		unit_location.y = (x1 - x2) * math.sin(math.rad(0.52)) + (y1 - y2) * math.cos(math.rad(0.52)) + y2
		
		--第二步，根据旋转角度，求出等角螺线上与中心的距离
		local vector_distance = unit_location - target_location 
		--local vector_distance = target_location - unit_location
		local distance = vector_distance:Length2D()
		--等角螺线参数，a代表极坐标中极角=0的初始位置，b是斐波那契螺线的参数
		--螺线顺时针旋转（负角）后，会向中心位置靠近
		a = distance
        b = 0.3063489
		--ρ，读作rho,表示距离中心的长度
		rho = a * math.exp(math.rad(-0.52) * b ) 

		local direction = vector_distance:Normalized()
		unit:SetAbsOrigin(target_location + direction * rho)
    }}--
		--[[
		if distance > speed then
			unit:SetAbsOrigin(unit_location + direction * speed)
		else
			unit:SetAbsOrigin(unit_location + direction * distance)
		end
		]]--
	end
end

function ChannelEnd(keys)
    if not IsServer() then return true end
	local ability = keys.ability
	local caster = keys.caster
	
	if ability.point_entity:IsNull() == false then
		ability.point_entity:RemoveModifierByName("modifier_black_hole_datadriven")
		--StopSoundOn("Hero_Enigma.Black_Hole", caster)
	end
	StopSoundOn("Hero_Enigma.Black_Hole", caster)
end


function GiveVision(keys)
    if not IsServer() then return true end
	caster = keys.caster
	ability = keys.ability
	local targetPoint = keys.target_points[1]
	local vision_radius = ability:GetLevelSpecialValueFor( "vision_radius", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local tether = caster:FindAbilityByName("enigma_midnight_pulse")
	local immune_duration = ability:GetLevelSpecialValueFor( "immune_duration", ability:GetLevel() - 1 )
	AddFOWViewer(caster:GetTeam(), ability:GetCursorPosition(), vision_radius, duration, false)

 	if caster:HasScepter() then
		caster:AddNewModifier(caster, ability, "modifier_elder_titan_echo_stomp_magic_immune", { duration = immune_duration })
	end

 	if caster:HasModifier("modifier_item_aghanims_shard") and tether then
	    if tether:GetLevel() >=1 then
		    caster:SetCursorPosition(targetPoint)
		    tether:OnSpellStart()
		end
	end
end

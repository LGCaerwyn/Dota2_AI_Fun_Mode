

function wuyingzhan( keys )
	-- body
	local ability = keys.ability
	local caster = keys.caster
--	local point = caster:GetCursorPosition()
    local target = keys.target
    local point = target:GetOrigin()
	local origin = caster:GetOrigin()

	local min_dist = 100
	local max_dist = 1000
	local radius = 400
	local delay = 2

	local direction = (point-origin)
	local dist = math.max( math.min( max_dist, direction:Length2D() ), min_dist )
	direction.z = 0
	direction = direction:Normalized()

	local target_point = GetGroundPosition( origin + direction*dist, nil )
    local targetPoint = point
	zhiqu = caster:GetOrigin()
	casterPoint = caster:GetOrigin()
	FindClearSpaceForUnit( caster, target_point, true )
--[[
	-- find units in line
	local enemies = FindUnitsInLine(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		origin,	-- point, start point
		target,	-- point, end point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES	-- int, flag filter
	)
--]]

--	PlayEffects1( origin, target_point )
local fruits = {}

for i=1,10 do
--	print(i)


a = math.floor(math.random (1,360))

table.insert(fruits,a)

--	print(fruits[i])

end

print(caster:GetAngles())




local weizhixiangliang = targetPoint - casterPoint					  --施法者指向目标的方向向量
jiaodu = {45,90,135,180,225,270,315,360}
a = 180
--jiao = {36,108,360,72,0,270,315,360}
--jiao = {300,60,215,0,120,300,60,215,0,120,300,60,215,0}
jiao = 	 {0,60,120,180,240,300}
jiao_2 = {180,240,300,360,60,120}
--jiao = {}
--	for k,v in pairs(jiaodu) do  
local weizhixiangliang_fangxiang = weizhixiangliang:Normalized()
local vecShip0 = weizhixiangliang_fangxiang
--	end




					Timers:CreateTimer(function()

local point = target:GetOrigin()
local targetPoint = point
local weizhixiangliang = targetPoint - casterPoint		
local weizhixiangliang_fangxiang = weizhixiangliang:Normalized()
local vecShip0 = weizhixiangliang_fangxiang

--[[
if v == nil then
	v  = 45
	elseif v <3600 then
		v = v + 45
	else
		v = 45
	end
--]]
if v == nil then
	v  = 1
	elseif v <= #fruits then
		v = v + 1
	else
		v = 1
	end


--caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)

local x1 = targetPoint.x + 700 * ( vecShip0.x * math.cos(math.rad(fruits[v])) - vecShip0.y * math.sin(math.rad(fruits[v])) )  --新添加
local y1 = targetPoint.y + 700 * ( vecShip0.y * math.cos(math.rad(fruits[v])) + vecShip0.x * math.sin(math.rad(fruits[v])) )  --新添加

ability:ApplyDataDrivenModifier(caster, caster, "modifier_void_spirit_wudizhan", {})


						--		local x1 = targetPoint.x + ( weizhixiangliang:Length2D() * math.cos(math.rad(0))  )
							--	local y1 = targetPoint.y + ( weizhixiangliang:Length2D() * math.sin(math.rad(0))  )
--	 print(v)


							--	local bamian =   targetPoint - Vector(x1,y1,targetPoint.z)   --对点指向圆心的方向向量
												
							--	local bamian_fangxiang  = bamian:Normalized() --对点指向圆心的单位方向向量
													 
							--	local bamian_fangxiang_changdu =   (Vector(x1,y1,targetPoint.z) - targetPoint):Normalized()
							--	print(weizhixiangliang_45_11)
							--	bamian_changdu  = (2 * spawnDistance) - bamian:Length2D()

							--	local bamian_changdu_spawn  = Vector(x1,y1,targetPoint.z) + ( bamian_changdu  * bamian_fangxiang_changdu)
							--	local bamianVec  = Vector( bamian_fangxiang.x, bamian_fangxiang.y, 0 ) 


										 
local x2 = targetPoint.x + 600 * ( vecShip0.x * math.cos(math.rad(fruits[v]+180)) - vecShip0.y * math.sin(math.rad(fruits[v]+180)) )  --新添加
local y2 = targetPoint.y + 600 * ( vecShip0.y * math.cos(math.rad(fruits[v]+180)) + vecShip0.x * math.sin(math.rad(fruits[v]+180)) )  --新添加

								FindClearSpaceForUnit( caster, Vector(x2,y2,targetPoint.z), true )	

local shifa = (Vector(x1,y1,targetPoint.z) - Vector(x2,y2,targetPoint.z)):Normalized()

print(shifa)
								local origin = caster:GetOrigin()


			caster:SetForwardVector(TG_Direction(Vector(x1,y1,targetPoint.z),Vector(x2,y2,targetPoint.z)))



							 local	tether = caster:FindAbilityByName("void_spirit_astral_step")   
					         caster:SetCursorPosition(Vector(x1,y1,targetPoint.z))



					         tether:OnSpellStart()
							 
							 
					--			FindClearSpaceForUnit( caster, Vector(x1,y1,targetPoint.z), true )



			--		local	 v = v + 45

			--				 print(v)
							 --	local target_point = Vector(x1,y1,targetPoint.z)
								

						 
								
							--	PlayEffects1( origin, target_point )
--[[
		local enemies = FindUnitsInLine(
		caster:GetTeamNumber(),	-- int, your team number
		origin,	-- point, start point
		target_point,	-- point, end point
		nil,	-- handle, cacheUnit. (not known)
		400,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES	-- int, flag filter
	)

	for _,enemy in pairs(enemies) do
		-- perform attack
		caster:PerformAttack( enemy, true, true, true, false, true, false, true )	

end

--]]





					 if bb == nil then
					     bb =0
					 end
				     
					 bb = bb + 1
					 g = bb + 1
				--	 print(g)
									 if g > #fruits then
										-- print(g)
										 bb = nil
			 						     v = nil

                                        caster:RemoveModifierByName("modifier_void_spirit_wudizhan")
			 							--	FindClearSpaceForUnit( caster, zhiqu, true )
			 							--	caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
										return nil
					 								
									 else									 
									 return 0.5
									 end
					end
					)






end





function PlayEffects1( origin, target_point )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step.vpcf"
	local sound_start = "Hero_VoidSpirit.AstralStep.Start"
	local sound_end = "Hero_VoidSpirit.AstralStep.End"

	--EmitSoundOnLocationWithCaster( origin, "Hero_Juggernaut.Attack", caster )
--EmitSoundOn("Hero_Juggernaut.Attack", self.parent)
	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControl( effect_cast, 0, origin )
	ParticleManager:SetParticleControl( effect_cast, 1, target_point )
	ParticleManager:ReleaseParticleIndex( effect_cast )


--[[


    local p1 = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_omni_dash.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControlEnt(p1, 0, caster, PATTACH_ABSORIGIN, nil, origin, true)
    ParticleManager:SetParticleControl(p1, 1, target_point)
    ParticleManager:SetParticleControl(p1, 2, target_point)
    ParticleManager:ReleaseParticleIndex(p1)
    --]]
--[[
    local p2 = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_omni_dash.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControlEnt(p2, 0, caster, PATTACH_ABSORIGIN, nil, origin, true)
    ParticleManager:SetParticleControl(p2, 1, target_point)
    ParticleManager:SetParticleControl(p2, 2, target_point)
    ParticleManager:ReleaseParticleIndex(p2)

--]]

--[[   local pfx_tgt = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_omni_slash_tgt.vpcf", PATTACH_WORLDORIGIN, nil)
 --   ParticleManager:SetParticleControl(pfx_tgt, 0, target_point)
    ParticleManager:SetParticleControl(pfx_tgt, 1, target_point)
    ParticleManager:ReleaseParticleIndex(pfx_tgt)
    local pfx_trail = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_omni_slash_trail.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(pfx_trail, 0, target_point)
    ParticleManager:SetParticleControl(pfx_trail, 1, target_point)
    ParticleManager:ReleaseParticleIndex(pfx_trail)

--]]





	-- Create Sound

	EmitSoundOnLocationWithCaster( origin, sound_start, caster )
	--EmitSoundOnLocationWithCaster( target_point, sound_end, caster )
end



function TG_Direction(fpos,spos)
  local DIR=( fpos - spos):Normalized()
  DIR.z=0
  return DIR
end

function TG_Direction2(fpos,spos)
  local DIR=( fpos - spos):Normalized()
  return DIR
end






TIMERS_THINK = 0.01

if Timers == nil then
  print ( '[Timers] creating Timers' )
  Timers = {}
  Timers.__index = Timers
end

function Timers:new( o )
  o = o or {}
  setmetatable( o, Timers )
  return o
end

function Timers:start()
  Timers = self
  self.timers = {}
  
  local ent = Entities:CreateByClassname("info_target") -- Entities:FindByClassname(nil, 'CWorld')
  ent:SetThink("Think", self, "timers", TIMERS_THINK)
end

function Timers:Think()
  if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
    return
  end

  -- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
  local now = GameRules:GetGameTime()

  -- Process timers
  for k,v in pairs(Timers.timers) do
    local bUseGameTime = true
    if v.useGameTime ~= nil and v.useGameTime == false then
      bUseGameTime = false
    end
    local bOldStyle = false
    if v.useOldStyle ~= nil and v.useOldStyle == true then
      bOldStyle = true
    end

    local now = GameRules:GetGameTime()
    if not bUseGameTime then
      now = Time()
    end

    if v.endTime == nil then
      v.endTime = now
    end
    -- Check if the timer has finished
    if now >= v.endTime then
      -- Remove from timers list
      Timers.timers[k] = nil
      
      -- Run the callback
      local status, nextCall = pcall(v.callback, GameRules:GetGameModeEntity(), v)

      -- Make sure it worked
      if status then
        -- Check if it needs to loop
        if nextCall then
          -- Change its end time

          if bOldStyle then
            v.endTime = v.endTime + nextCall - now
          else
            v.endTime = v.endTime + nextCall
          end

          Timers.timers[k] = v
        end

        -- Update timer data
        --self:UpdateTimerData()
      else
        -- Nope, handle the error
        Timers:HandleEventError('Timer', k, nextCall)
      end
    end
  end

  return TIMERS_THINK
end

function Timers:HandleEventError(name, event, err)
  print(err)

  -- Ensure we have data
  name = tostring(name or 'unknown')
  event = tostring(event or 'unknown')
  err = tostring(err or 'unknown')

  -- Tell everyone there was an error
  --Say(nil, name .. ' threw an error on event '..event, false)
  --Say(nil, err, false)

  -- Prevent loop arounds
  if not self.errorHandled then
    -- Store that we handled an error
    self.errorHandled = true
  end
end

function Timers:CreateTimer(name, args)
  if type(name) == "function" then
    args = {callback = name}
    name = DoUniqueString("timer")
  elseif type(name) == "table" then
    args = name
    name = DoUniqueString("timer")
  elseif type(name) == "number" then
    args = {endTime = name, callback = args}
    name = DoUniqueString("timer")
  end
  if not args.callback then
    print("Invalid timer created: "..name)
    return
  end


  local now = GameRules:GetGameTime()
  if args.useGameTime ~= nil and args.useGameTime == false then
    now = Time()
  end

  if args.endTime == nil then
    args.endTime = now
  elseif args.useOldStyle == nil or args.useOldStyle == false then
    args.endTime = now + args.endTime
  end

  Timers.timers[name] = args
end

function Timers:RemoveTimer(name)
  Timers.timers[name] = nil
end

function Timers:RemoveTimers(killAll)
  local timers = {}

  if not killAll then
    for k,v in pairs(Timers.timers) do
      if v.persist then
        timers[k] = v
      end
    end
  end

  Timers.timers = timers
end

Timers:start()
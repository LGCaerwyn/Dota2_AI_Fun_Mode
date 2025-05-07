


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

xiangliangdeqiuhe = {}

-- 向量的模
function xiangliangdeqiuhe.ta(weizhixiangliang)
    return math.sqrt(weizhixiangliang.x * weizhixiangliang.x + weizhixiangliang.y * weizhixiangliang.y  )
end


--math.rad(180) 3.14159265358




function ghostship_mark_allies( caster, ability, target )
	local allHeroes = HeroList:GetAllHeroes()
	local delay = ability:GetLevelSpecialValueFor( "tooltip_delay", ability:GetLevel() - 1 )
	local particleName = "particles/units/heroes/hero_kunkka/kunkka_ghostship_marker.vpcf"

	for k, v in pairs( allHeroes ) do
		if v:GetPlayerID() and v:GetTeam() == caster:GetTeam() then
			local fxIndex = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, v, PlayerResource:GetPlayer( v:GetPlayerID() ) )
			ParticleManager:SetParticleControl( fxIndex, 0, target )
			
			EmitSoundOnClient( "Ability.pre.Torrent", PlayerResource:GetPlayer( v:GetPlayerID() ) )
			

			Timers:CreateTimer( delay, function()
					ParticleManager:DestroyParticle( fxIndex, false )
					return nil
				end
			)
		end
	end
end


function ghostship_start_before( keys )

local ability = keys.ability
local caster = keys.caster
if caster:PassivesDisabled() then return end      --新增破被动效果
target = keys.target
local modifier = keys.Modifier_kunkka_x_marks
local modifier_start_x = keys.ModifierName_start_x
local cooldown = ability:GetCooldown(ability:GetLevel() - 1) * caster:GetCooldownReduction()

if ability:IsCooldownReady() then

if 	target:HasModifier(modifier) then


ability:ApplyDataDrivenModifier(caster, target,modifier_start_x, {})

ability:StartCooldown(cooldown)

end

end
end

function ghostship_start_traverse( keys )

	local caster = keys.caster
	local ability = keys.ability
	local casterPoint = caster:GetAbsOrigin()
	--local targetPoint = keys.target_points[1]
	
	targetPoint = target:GetAbsOrigin()
	local spawnDistance = ability:GetLevelSpecialValueFor( "ghostship_distance", ability:GetLevel() - 1 )
	local projectileSpeed = ability:GetLevelSpecialValueFor( "ghostship_speed", ability:GetLevel() - 1 )
	local radius = ability:GetLevelSpecialValueFor( "ghostship_width", ability:GetLevel() - 1 )
	local stunDelay = ability:GetLevelSpecialValueFor( "tooltip_delay", ability:GetLevel() - 1 )
	local stunDuration = ability:GetLevelSpecialValueFor( "stun_duration", ability:GetLevel() - 1 )
	local damage = ability:GetAbilityDamage()
	local damageType = ability:GetAbilityDamageType()
	local targetBuffTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY
	local targetImpactTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC -- + DOTA_UNIT_TARGET_MECHANICAL
	local targetFlag = DOTA_UNIT_TARGET_FLAG_NONE
	
	print("第二步开始执行")
	print(target:GetModelName().."第二步模型")
--向量粗处理	
	
	
	local weizhixiangliang = targetPoint - casterPoint
	
	local weizhixiangliang_fangxiang = weizhixiangliang:Normalized()
	local weizhixiangliang_fang = casterPoint - targetPoint
	
	local weizhixiangliang_fangxiang_1 = weizhixiangliang_fang:Normalized()
	
	      weizhixiangliang_changdu = (2 * spawnDistance) - weizhixiangliang:Length2D()

	local weizhixiangliang_changdu_spawn = casterPoint + ( weizhixiangliang_changdu * weizhixiangliang_fangxiang_1)
	local weizhiVec = Vector( weizhixiangliang_fangxiang.x, weizhixiangliang_fangxiang.y, 0 ) 
	
--	xiangliangdeqiuhe.ta(weizhixiangliang)
--[[
	for i= 0, 2 do
   print(xiangliangdeqiuhe[i])
end
	print(xiangliangdeqiuhe[ta])
	c =  math.cos(math.rad(45))
--]]	
--	b = ( c * xiangliangdeqiuhe[1] * xiangliangdeqiuhe[1] ) / weizhixiangliang
	

	
--	local b_fangxiang = b:Normalized()
		 

--	      b_changdu = (2 * spawnDistance) - b:Length2D()

--	local b_changdu_spawn = casterPoint + ( weizhixiangliang_changdu * weizhixiangliang_fangxiang * -1)
	
--45度

local X1 = targetPoint.x + ( weizhixiangliang:Length2D() * math.cos(math.rad(45))  )
local Y1 = targetPoint.y + ( weizhixiangliang:Length2D() * math.sin(math.rad(45))  )
print(math.sin(math.rad(90)) )
	
	local weizhixiangliang_45 =   targetPoint - Vector(X1,Y1,targetPoint.z) 
	
	local weizhixiangliang_fangxiang_45  = weizhixiangliang_45:Normalized()
		 
	local weizhixiangliang_45_11 =   (Vector(X1,Y1,targetPoint.z) - targetPoint):Normalized()
	print(weizhixiangliang_45_11)
	      weizhixiangliang_changdu_45  = (2 * spawnDistance) - weizhixiangliang_45:Length2D()

	local weizhixiangliang_changdu_spawn_45  = Vector(X1,Y1,targetPoint.z) + ( weizhixiangliang_changdu_45  * weizhixiangliang_45_11)
	local weizhiVec_45  = Vector( weizhixiangliang_fangxiang_45.x, weizhixiangliang_fangxiang_45.y, 0 ) 
	
--遍历

jiandu = {45,90,135,180,225,270,315,360}

for k,v in pairs(jiandu) do

local x1 = targetPoint.x + ( weizhixiangliang:Length2D() * math.cos(math.rad(v))  )
local y1 = targetPoint.y + ( weizhixiangliang:Length2D() * math.sin(math.rad(v))  )
print(math.sin(math.rad(90)) )
	
	local bamian =   targetPoint - Vector(x1,y1,targetPoint.z) 
	
	local bamian_fangxiang  = bamian:Normalized()
		 
	local bamian_fangxiang_changdu =   (Vector(x1,y1,targetPoint.z) - targetPoint):Normalized()
	print(weizhixiangliang_45_11)
	      bamian_changdu  = (2 * spawnDistance) - bamian:Length2D()

	local bamian_changdu_spawn  = Vector(x1,y1,targetPoint.z) + ( bamian_changdu  * bamian_fangxiang_changdu)
	local bamianVec  = Vector( bamian_fangxiang.x, bamian_fangxiang.y, 0 ) 
	

		print(k,v)

		local projectileTable_bamian  = {
		Ability = ability,
		EffectName = "particles/units/heroes/hero_kunkka/kunkka_ghost_ship.vpcf",
		vSpawnOrigin = bamian_changdu_spawn,
		--vSpawnOrigin = casterPoint,
		--fDistance = spawnDistance * 2,
		fDistance = spawnDistance * 2,
		fStartRadius = radius,
		fEndRadius = radius,
		fExpireTime = GameRules:GetGameTime() + 10,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		bProvidesVision = false,
		iUnitTargetTeam = targetBuffTeam,
		iUnitTargetType = targetType,
		vVelocity = bamianVec * projectileSpeed
	}
	ProjectileManager:CreateLinearProjectile( projectileTable_bamian )

	end	
	
	
	

	local forwardVec = targetPoint - casterPoint
		forwardVec = forwardVec:Normalized()
	local backwardVec = casterPoint - targetPoint
		backwardVec = backwardVec:Normalized()
	local spawnPoint = casterPoint + ( spawnDistance * backwardVec  )
	local impactPoint = casterPoint + ( spawnDistance * forwardVec )
	local velocityVec = Vector( forwardVec.x, forwardVec.y, 0 )
	print(backwardVec)
--反面	
	
	local forwardVec_fang = casterPoint - targetPoint
		forwardVec_fang = forwardVec_fang:Normalized()
	local backwardVec_fang = targetPoint - casterPoint
		backwardVec_fang = backwardVec_fang:Normalized()
	local spawnPoint_fang = targetPoint + ( spawnDistance * backwardVec_fang )
	local impactPoint_fang = casterPoint + ( spawnDistance * forwardVec_fang )
	local velocityVec_fang = Vector( forwardVec_fang.x, forwardVec_fang.y, 0 )
	print(weizhixiangliang_changdu_spawn)
	
print(weizhixiangliang_changdu_spawn_45)

	--ghostship_mark_allies( caster, ability, impactPoint )
	ghostship_mark_allies( caster, ability, targetPoint )

--[[
		local projectileTable_45  = {
		Ability = ability,
		EffectName = "particles/units/heroes/hero_kunkka/kunkka_ghost_ship.vpcf",
		vSpawnOrigin = weizhixiangliang_changdu_spawn_45,
		--vSpawnOrigin = casterPoint,
		--fDistance = spawnDistance * 2,
		fDistance = spawnDistance * 2,
		fStartRadius = radius,
		fEndRadius = radius,
		fExpireTime = GameRules:GetGameTime() + 10,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		bProvidesVision = true,
		iUnitTargetTeam = targetBuffTeam,
		iUnitTargetType = targetType,
		vVelocity = weizhiVec_45 * projectileSpeed
	}
	ProjectileManager:CreateLinearProjectile( projectileTable_45 )
	
	local projectileTable = {
		Ability = ability,
		EffectName = "particles/units/heroes/hero_kunkka/kunkka_ghost_ship.vpcf",
		vSpawnOrigin = weizhixiangliang_changdu_spawn,
		--vSpawnOrigin = casterPoint,
		--fDistance = spawnDistance * 2,
		fDistance = spawnDistance * 2,
		fStartRadius = radius,
		fEndRadius = radius,
		fExpireTime = GameRules:GetGameTime() + 10,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		bProvidesVision = true,
		iUnitTargetTeam = targetBuffTeam,
		iUnitTargetType = targetType,
		vVelocity = weizhiVec * projectileSpeed
	}
	ProjectileManager:CreateLinearProjectile( projectileTable )
	--]]
--[[	
	 Timers:CreateTimer(1, function()
	  
     ProjectileManager:CreateLinearProjectile( projectileTable )
	 
	 if bb == nil then
	 
	 bb =0
	 end
	 bb = bb + 1
	 g = bb + 1
	 print(g)
	 if g > 3 then
	 print(g)
	 bb = nil
	 
	 return nil
	
	 
	 else
	 

		return 1.0
		
		end
    end
	
  )

	--]]

	--[[
		local projectileTable_fang = {
		Ability = ability,
		EffectName = "particles/units/heroes/hero_kunkka/kunkka_ghost_ship.vpcf",
		vSpawnOrigin = spawnPoint_fang,
	--	vSpawnOrigin = casterPoint,
	--	fDistance = spawnDistance * 2,
		fDistance = spawnDistance * 2,
		fStartRadius = radius,
		fEndRadius = radius,
		fExpireTime = GameRules:GetGameTime() + 5,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		bProvidesVision = false,
		iUnitTargetTeam = targetBuffTeam,
		iUnitTargetType = targetType,
		vVelocity = velocityVec_fang * projectileSpeed
	}
	ProjectileManager:CreateLinearProjectile( projectileTable_fang )
	
	
	--]]
	

	Timers:CreateTimer( stunDelay, function()
			local units = FindUnitsInRadius(
				caster:GetTeamNumber(), targetPoint, caster, radius, targetImpactTeam,
				targetType, targetFlag, FIND_ANY_ORDER, false
			)
			

			local dummy = CreateUnitByName( "npc_dummy_blank", targetPoint, false, caster, caster, caster:GetTeamNumber() )	
	--		local dummy = CreateUnitByName( "npc_dummy_unit", impactPoint, false, caster, caster, caster:GetTeamNumber() )
			StartSoundEvent( "Ability.Ghostship.crash", dummy )
			dummy:ForceKill( true )
			

			for k, v in pairs( units ) do
				if not v:IsMagicImmune() then
					local damageTable = {
						victim = v,
						attacker = caster,
						damage = damage,
						damage_type = damageType
					}
					ApplyDamage( damageTable )
				end
				
				v:AddNewModifier( caster, nil, "modifier_stunned", { duration = stunDuration } )
			end
			
			return nil	
		end
	)
end


function ghostship_register_damage( keys )
	local target = keys.unit
	local damageTaken = keys.DamageTaken
	if not target.ghostship_damage then
		target.ghostship_damage = 0
	end
	
	target.ghostship_damage = target.ghostship_damage + damageTaken
end


function ghostship_spread_damage( keys )

	if not keys.target.ghostship_damage then
		keys.target.ghostship_damage = 0
	end


	local target = keys.target
	local ability = keys.ability
	local damageDuration = ability:GetLevelSpecialValueFor( "damage_duration", ability:GetLevel() - 1 )
	local damageInterval = ability:GetLevelSpecialValueFor( "damage_interval", ability:GetLevel() - 1 )
	local damageCurrentTime = 0.0
	local damagePerInterval = target.ghostship_damage * ( damageInterval / damageDuration )
	local minimumHealth = 1


	Timers:CreateTimer( damageInterval, function()

			local targetHealth = target:GetHealth()
			if targetHealth - damagePerInterval <= minimumHealth then
				target:SetHealth( minimumHealth )
			else
				target:SetHealth( targetHealth - damagePerInterval )
			end
			

			damageCurrentTime = damageCurrentTime + damageInterval
			

			if damageCurrentTime >= damageDuration then
				return nil
			else
				return damageInterval
			end
		end
	)
end

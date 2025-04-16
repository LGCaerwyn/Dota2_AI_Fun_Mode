require('tg_utils')
require('timers')


function ember_spirit_sword_soul( keys )



    local caster = keys.caster
    --local target = keys.target
    --local targetPoint = keys.target_points[1]
    local ability = keys.ability
    	-- body
    --local pos = caster:GetAbsOrigin()
    --local cur_pos = ability:GetCursorPosition()	
    --local dis = TG_Distance(pos,cur_pos)
    --local dir = TG_Direction(cur_pos,pos)

            --caster = self:GetCaster()

        local pos = caster:GetAbsOrigin()
        local caster_point =  caster:GetAbsOrigin()
        local caster_ForwardVector = caster:GetForwardVector()
        local target_points = caster_point + (caster_ForwardVector * 1050)
        local  caster_point_2 = caster_point + (caster_ForwardVector * 400)
       -- local duration = self:GetSpecialValueFor("duration")
      --  local cur_pos = self:GetCursorPosition()
        local cur_pos = target_points
        local dis = TG_Distance(pos,cur_pos)

    --  table_Angle_start = {0,60,120,180,240,300} --六边形
    --  table_Angle_end = {150,210,270,330,30,90}  --六边形

        -- table_Angle_start = {0,72,144,216,288}--五边形
    table_sword_soul = {1,2,3,4,5}--次数

    AddFOWViewer(caster:GetTeam(), caster_point_2, 750, 30, false)--提供视野
    GridNav:DestroyTreesAroundPoint(caster_point_2, 700, true)

    if table_esr == nil then  --记录剑魂

        table_esr = {}

         end
    local x = 1 --初始次数
    local b = 0 
          z = 0.35  --剑魂飞行时间
          time = 0.35 --每次飞魂间隔时间
          dt = 3.5    --剑魂存在时间 -0.7=2.8秒时间

    ability_SetActivated = caster:FindAbilityByName("ember_spirit_sword_soul")
    ability:SetActivated(false)  --即用即禁
if caster:GetUnitName() == "npc_dota_hero_rubick" then
   ability:SetActivated(true)  --即用即禁
 --   return
end
   -- ability:SetActivated(false)  --即用即禁

   
    --启用法阵特效
    local orpf = ParticleManager:CreateParticleForTeam( "particles/units/heroes/hero_doom_bringer/doom_bringer_doom_aura_fun.vpcf", PATTACH_WORLDORIGIN, caster, caster:GetTeamNumber() )
    ParticleManager:SetParticleControl(orpf, 0, caster_point_2)

    caster:AddNoDraw()  --开始消失

    --施加控制
    --caster:AddNewModifier(caster, caster, "modifier_fire_remnant_time", {duration = 3})
    ability:ApplyDataDrivenModifier( caster, caster, "modifier_ember_spirit_sword_soul_time", {duration = 3})
    




    Timers:CreateTimer(3, function() 

    ParticleManager:DestroyParticle(orpf, false)

    caster:RemoveNoDraw()  --复原
    caster:RemoveModifierByName("modifier_ember_spirit_hot_sword_soul_unlocking")
                return nil
                        
                        end
                    )

    --开始飞魂
    Timers:CreateTimer(function()


    -- EmitSoundOn("Hero_EmberSpirit.FireRemnant.Cast", caster)
     --EmitSoundOn("Hero_EmberSpirit.FireRemnant.Explode", caster)

    if table_sword_soul[x] == 1 then

        x = x + 1

            point = RotatePosition(caster_point, QAngle(0,0,0), target_points)
            point_2 = RotatePosition(caster_point, QAngle(0,144,0), target_points)
            --point_3 = RotatePosition(caster_point, QAngle(0,v+144,0), target_points)
            local ESR=CreateUnitByName("npc_dota_ember_spirit_remnant", point, true, nil, nil,caster:GetTeamNumber())

           -- ESR:AddNewModifier(caster, self, "modifier_kill", {duration = dt - (table_sword_soul[x] * 0.35)})
           -- ESR:AddNewModifier(caster, self, "modifier_fire_remnant_nobar", {})
            ability:ApplyDataDrivenModifier( caster, ESR, "modifier_kill", {duration = dt - (table_sword_soul[x] * 0.35)})
            ability:ApplyDataDrivenModifier( caster, ESR, "modifier_ember_spirit_sword_soul_nobar", {})

            table.insert (table_esr,#table_esr+1, ESR)
            local dis = TG_Distance(caster_point,target_points)
            local dir = TG_Direction(target_points,caster_point)
            PlayEffects1( caster_point, target_points )

        --  print(dis)
            EmitSoundOn("Hero_EmberSpirit.FireRemnant.Cast", caster)
            local pp =
            {
                Ability = ability,
                EffectName = "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant_trail.vpcf",
              --  vSpawnOrigin = caster:GetAbsOrigin(),
                vSpawnOrigin = caster_point,
              
                fDistance = dis,
                fStartRadius = 0,
                fEndRadius = 0,
                Source = caster,
                vVelocity = dir * (dis/z),
                bProvidesVision = false,
               -- ExtraData = {ESR=ESR:entindex()}
            }
            ProjectileManager:CreateLinearProjectile(pp)
            playdamage( caster , caster_point_2 ,ability ,dir)
      --      return nil
    ---[[       
    return time


        elseif table_sword_soul[x] == 2 then

            x = x + 1
            point = RotatePosition(caster_point_2, QAngle(0,72,0), target_points)
            point_2 = RotatePosition(caster_point_2, QAngle(0,288,0), target_points)
            --point_3 = RotatePosition(caster_point, QAngle(0,v+144,0), target_points)
            local ESR=CreateUnitByName("npc_dota_ember_spirit_remnant", point, true, nil, nil,caster:GetTeamNumber())
           -- ESR:AddNewModifier(caster, self, "modifier_kill", {duration = dt -  (table_sword_soul[x] * 0.35)})
           -- ESR:AddNewModifier(caster, self, "modifier_fire_remnant_nobar", {})
            ability:ApplyDataDrivenModifier( caster, ESR, "modifier_kill", {duration = dt - (table_sword_soul[x] * 0.35)})
            ability:ApplyDataDrivenModifier( caster, ESR, "modifier_ember_spirit_sword_soul_nobar", {})
            table.insert (table_esr,#table_esr+1, ESR)
            local dis = TG_Distance(point,point_2)
            local dir = TG_Direction(point,point_2)
            PlayEffects1( point_2, point )
            EmitSoundOn("Hero_EmberSpirit.FireRemnant.Cast", caster)
            local pp =
            {
                Ability = ability,
                EffectName = "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant_trail.vpcf",
              --  vSpawnOrigin = caster:GetAbsOrigin(),
                vSpawnOrigin = point_2,
              
                fDistance = dis,
                fStartRadius = 0,
                fEndRadius = 0,
                Source = caster,
                vVelocity = dir * (dis/z),
                bProvidesVision = false,
               -- ExtraData = {ESR=ESR:entindex()}
            }
            ProjectileManager:CreateLinearProjectile(pp)
           playdamage( caster , caster_point_2 ,ability ,dir)

            return time

            elseif table_sword_soul[x] == 3 then
                x = x + 1
            point = RotatePosition(caster_point_2, QAngle(0,72,0), target_points)
            point_2 = RotatePosition(caster_point_2, QAngle(0,216,0), target_points)
            --point_3 = RotatePosition(caster_point, QAngle(0,v+144,0), target_points)
            
            local ESR=CreateUnitByName("npc_dota_ember_spirit_remnant", point_2, true, nil, nil,caster:GetTeamNumber())
            --ESR:AddNewModifier(caster, self, "modifier_kill", {duration = dt - (table_sword_soul[x] * 0.35)})
            --ESR:AddNewModifier(caster, self, "modifier_fire_remnant_nobar", {})
            ability:ApplyDataDrivenModifier( caster, ESR, "modifier_kill", {duration = dt - (table_sword_soul[x] * 0.35)})
            ability:ApplyDataDrivenModifier( caster, ESR, "modifier_ember_spirit_sword_soul_nobar", {})
            table.insert (table_esr,#table_esr+1, ESR)
            local dis = TG_Distance(point,point_2)
            local dir = TG_Direction(point_2,point)
            PlayEffects1( point, point_2 )
            EmitSoundOn("Hero_EmberSpirit.FireRemnant.Cast", caster)
            local pp =
            {
                Ability = ability,
                EffectName = "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant_trail.vpcf",
              --  vSpawnOrigin = caster:GetAbsOrigin(),
                vSpawnOrigin = point,
              
                fDistance = dis,
                fStartRadius = 0,
                fEndRadius = 0,
                Source = caster,
                vVelocity = dir * (dis/z),
                bProvidesVision = false,
               -- ExtraData = {ESR=ESR:entindex()}
            }
            ProjectileManager:CreateLinearProjectile(pp)
            playdamage( caster , caster_point_2 ,ability ,dir)



            return time



            elseif table_sword_soul[x] == 4 then

            x = x + 1
            point = RotatePosition(caster_point_2, QAngle(0,288,0), target_points)
            point_2 = RotatePosition(caster_point_2, QAngle(0,144,0), target_points)
            --point_3 = RotatePosition(caster_point, QAngle(0,v+144,0), target_points)
            local ESR=CreateUnitByName("npc_dota_ember_spirit_remnant", point_2, true, nil, nil,caster:GetTeamNumber())
            --ESR:AddNewModifier(caster, self, "modifier_kill", {duration =  dt - (table_sword_soul[x] * 0.35)})
            --ESR:AddNewModifier(caster, self, "modifier_fire_remnant_nobar", {})
            ability:ApplyDataDrivenModifier( caster, ESR, "modifier_kill", {duration = dt - (table_sword_soul[x] * 0.35)})
            ability:ApplyDataDrivenModifier( caster, ESR, "modifier_ember_spirit_sword_soul_nobar", {})
            table.insert (table_esr,#table_esr+1, ESR)
            local dis = TG_Distance(point,point_2)
            local dir = TG_Direction(point_2,point)
            PlayEffects1( point, point_2 )
            EmitSoundOn("Hero_EmberSpirit.FireRemnant.Cast", caster)
            local pp =
            {
                Ability = ability,
                EffectName = "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant_trail.vpcf",
              --  vSpawnOrigin = caster:GetAbsOrigin(),
                vSpawnOrigin = point,
              
                fDistance = dis,
                fStartRadius = 0,
                fEndRadius = 0,
                Source = caster,
                vVelocity = dir * (dis/z),
                bProvidesVision = false,
               -- ExtraData = {ESR=ESR:entindex()}
            }
            ProjectileManager:CreateLinearProjectile(pp)
            playdamage( caster , caster_point_2 ,ability ,dir)

    return time

            else

            point = RotatePosition(caster_point_2, QAngle(0,144,0), target_points)
            point_2 = RotatePosition(caster_point_2, QAngle(0,288,0), target_points)
            --point_3 = RotatePosition(caster_point, QAngle(0,v+144,0), target_points)
            local ESR=CreateUnitByName("npc_dota_ember_spirit_remnant", point_2, true, nil, nil,caster:GetTeamNumber())
            --ESR:AddNewModifier(caster, self, "modifier_kill", {duration =  dt -(6 * 0.35)})
            --ESR:AddNewModifier(caster, self, "modifier_fire_remnant_nobar", {})
            ability:ApplyDataDrivenModifier( caster, ESR, "modifier_kill", {duration = dt - (6 * 0.35)})
            ability:ApplyDataDrivenModifier( caster, ESR, "modifier_ember_spirit_sword_soul_nobar", {})
            table.insert (table_esr,#table_esr+1, ESR)
            local dis = TG_Distance(point,point_2)
            local dir = TG_Direction(point_2,point)
            PlayEffects1( point, point_2 )
            EmitSoundOn("Hero_EmberSpirit.FireRemnant.Cast", caster)
            local pp =
            {
                Ability = ability,
                EffectName = "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant_trail.vpcf",
              --  vSpawnOrigin = caster:GetAbsOrigin(),
                vSpawnOrigin = point,
              
                fDistance = dis,
                fStartRadius = 0,
                fEndRadius = 0,
                Source = caster,
                vVelocity = dir * (dis/z),
                bProvidesVision = false,
               -- ExtraData = {ESR=ESR:entindex()}
            }
            ProjectileManager:CreateLinearProjectile(pp)
            playdamage( caster , caster_point_2 ,ability ,dir)
            return nil

            --]]
             end
    end
    )


end



function ember_spirit_sword_soul_OnUpgrade(keys)

local ability = keys.ability
local caster = keys.caster

if caster:GetUnitName() == "npc_dota_hero_rubick" then

    return
end
    ability_SetActivated = caster:FindAbilityByName("ember_spirit_sword_soul")
    ability:SetActivated(false)
end






function ember_spirit_sword_soul_OnProjectileHit_finish(keys)

--print(fireRemnantTB)
local ability = keys.ability
local caster = keys.caster



--table_esr[1]:AddNewModifier(caster, self, "modifier_fire_remnant_esr", {duration = 7})
ability:ApplyDataDrivenModifier( caster, table_esr[1], "modifier_ember_spirit_sword_soul_pf", {duration = 7})
table.remove(table_esr, 1)


end




function modifier_ember_spirit_sword_soul_pf(keys)

--print(fireRemnantTB)
local ability = keys.ability
local caster = keys.caster
local target = keys.target
local pos=target:GetAbsOrigin()
local modifier = target:FindModifierByName("modifier_ember_spirit_sword_soul_pf")
local model_esr = {5,6,8,9,15,23,24,25,26,27,37,40,41,82,83,84}
local rand = RandomInt(1,#model_esr)
   if IsServer() then
       
            local pf = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant.vpcf", PATTACH_CUSTOMORIGIN, nil)
            ParticleManager:SetParticleControl(pf, 0, pos)
            ParticleManager:SetParticleControlEnt(pf, 1, caster, PATTACH_CUSTOMORIGIN, "attach_hitloc", pos, false)
           -- ParticleManager:SetParticleControl(pf, 2, Vector(self.act[RandomInt(1, #self.act)], 0, 0))
           ParticleManager:SetParticleControl(pf, 2, Vector(model_esr[rand], 0, 0))
            ParticleManager:SetParticleControl(pf, 60, Vector(RandomInt(0, 255),RandomInt(0, 255),RandomInt(0, 255)))
                ParticleManager:SetParticleControl(pf, 61, Vector(1,0,0))
                modifier:AddParticle(pf, false, false, 4, false, false)
        end


end


function modifier_ember_spirit_sword_soul_pf_OnDeath(keys)


local caster = keys.caster
EmitSoundOn("Hero_EmberSpirit.FireRemnant.Explode", caster)

end






function PlayEffects1( origin, target )
    -- Get Resources
--  local particle_cast = "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step.vpcf"
local particle_cast = "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step_fun.vpcf"

    local sound_start = "Hero_VoidSpirit.AstralStep.Start"
    local sound_end = "Hero_VoidSpirit.AstralStep.End"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, caster )
    ParticleManager:SetParticleControl( effect_cast, 0, origin )
    ParticleManager:SetParticleControl( effect_cast, 1, target )
    ParticleManager:ReleaseParticleIndex( effect_cast )
-- ParticleManager:SetParticleControl(effect_cast, 60, Vector(RandomInt(0, 255),RandomInt(0, 255),RandomInt(0, 255)))
--ParticleManager:SetParticleControl(effect_cast, 61, Vector(1,0,0))
    -- Create Sound
    EmitSoundOnLocationWithCaster( origin, sound_start, caster)
    EmitSoundOnLocationWithCaster( target, sound_end, caster )
end


function playdamage( caster , caster_point_2 ,ability ,dir)
    -- body


targets = FindUnitsInRadius(caster:GetTeamNumber(), caster_point_2, caster, 650, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_HERO +DOTA_UNIT_TARGET_BASIC , 
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES , FIND_ANY_ORDER  , false)

local damage = ability:GetSpecialValueFor("sword_soul_damage") 
local percent_damage_per = ability:GetSpecialValueFor("percent_damage_per") * 0.01 
local max_percent_damage_per = ability:GetSpecialValueFor("max_percent_damage_per")

--local percent_damage_per = ability:GetSpecialValueFor("percent_damage_per") 

    if #targets >1 then


        if (#targets * percent_damage_per) + 1  > max_percent_damage_per then
            
          damage = damage * max_percent_damage_per

            else
                damage = damage * ((#targets-1) * percent_damage_per + 1.00)
        end
     end

print("伤害："..damage)

for k,target in pairs(targets) do
    --print(k,v)
	
	
    local victimHealth = target:GetHealth() -- 获取受害者当前生命值
    local victimMaxHealth = target:GetMaxHealth() -- 获取受害者最大生命值
   -- local x = GetPhysicalArmorValue()
  --  if (victimHealth - damage) < 0.5 * victimMaxHealth then
    if victimHealth  < 0.5 * victimMaxHealth then 
    per = 1.3 -- 如果受害者生命值少于50%，则将伤害增加30%
    else  
    per = 1
    end
	
	
    damagetable = {
    victim = target,
    attacker = caster, 
    ability = ability ,
    damage = damage * per,
    damage_type = DAMAGE_TYPE_PHYSICAL,
    damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK ,
            }
    ApplyDamage(damagetable)
           -- 

               -- print("执行伤害")

    target:EmitSound("Hero_PhantomAssassin.CoupDeGrace.Arcana")--依靠LUA升级的技能无法加载声音，需要其他技能预载入
    --local particleName = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/phantom_assassin_crit_arcana_swoop.vpcf"
    local particleName = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/phantom_assassin_crit_arcana_swoop_r.vpcf"
    local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(particle, 00, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), false)
    ParticleManager:SetParticleControl(particle, 01, target:GetAbsOrigin())
  --  ParticleManager:SetParticleControlForward(particle, 00, -1 * caster:GetForwardVector())--特效的方向存在小BUG，远程攻击者的特效与弹道方向有关，与自身朝向无关
  -- ParticleManager:SetParticleControlForward(particle, 01, -1 * caster:GetForwardVector())
    ParticleManager:SetParticleControlForward(particle, 00, -1 * dir)--特效的方向存在小BUG，远程攻击者的特效与弹道方向有关，与自身朝向无关
   ParticleManager:SetParticleControlForward(particle, 01, -1 * dir)
        if caster:HasScepter() then
                caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
                caster:PerformAttack( target, true, true, true, false, false, false, true )
                caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)

        end
end
    

end






--[[





EmitSoundOn("Hero_EmberSpirit.FireRemnant.Cast", caster)


local ember_spirit_sword_soul = CreateUnitByName("npc_dota_ember_spirit_remnant", targetPoint, true, nil, nil,caster:GetTeamNumber())
	
        ability:ApplyDataDrivenModifier(caster, ember_spirit_sword_soul, "modifier_kill", {duration = 7})
      --  ability:ApplyDataDrivenModifier(caster, self, "modifier_fire_remnant_hb", {})
 local ember_spirit_projectile =
        {
            Ability = ability,
            EffectName = "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant_trail.vpcf",
            vSpawnOrigin = caster:GetAbsOrigin(),
            fDistance = dis,
            fStartRadius = 0,
            fEndRadius = 0,
            Source = caster,
            vVelocity = dir * 3000,
            bProvidesVision = false,
            ExtraData = {ember_spirit_sword_soul=ember_spirit_sword_soul:entindex()}
        }
        ProjectileManager:CreateLinearProjectile(ember_spirit_projectile)


local ember_spirit_sword_soul_pos = ember_spirit_sword_soul:GetAbsOrigin()
        ember_spirit_sword_soul.act={81,82,74}
        Timers:CreateTimer( 1,function()


 local pf = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant.vpcf", PATTACH_CUSTOMORIGIN, nil)
            ParticleManager:SetParticleControl(pf, 0, ember_spirit_sword_soul_pos)
            ParticleManager:SetParticleControlEnt(pf, 1, ember_spirit_sword_soul, PATTACH_CUSTOMORIGIN, "attach_hitloc", ember_spirit_sword_soul_pos, false)
            ParticleManager:SetParticleControl(pf, 2, Vector(ember_spirit_sword_soul.act[RandomInt(1, #ember_spirit_sword_soul.act)], 0, 0))
            ParticleManager:SetParticleControl(pf, 60, Vector(RandomInt(0, 255),RandomInt(0, 255),RandomInt(0, 255)))
            ParticleManager:SetParticleControl(pf, 61, Vector(1,0,0))
            ember_spirit_sword_soul:AddParticle(pf, false, false, 4, false, false)
                                return nil
                          end
                         )












--[[
local x1 = targetPoint.x + 700 * ( vecShip0.x * math.cos(math.rad(fruits[v])) - vecShip0.y * math.sin(math.rad(fruits[v])) )  --新添加
local y1 = targetPoint.y + 700 * ( vecShip0.y * math.cos(math.rad(fruits[v])) + vecShip0.x * math.sin(math.rad(fruits[v])) )  --新添加


										 
local x2 = targetPoint.x + 600 * ( vecShip0.x * math.cos(math.rad(fruits[v]+180)) - vecShip0.y * math.sin(math.rad(fruits[v]+180)) )  --新添加
local y2 = targetPoint.y + 600 * ( vecShip0.y * math.cos(math.rad(fruits[v]+180)) + vecShip0.x * math.sin(math.rad(fruits[v]+180)) )  --新添加
local shifa = (Vector(x1,y1,targetPoint.z) - Vector(x2,y2,targetPoint.z)):Normalized()
--]]




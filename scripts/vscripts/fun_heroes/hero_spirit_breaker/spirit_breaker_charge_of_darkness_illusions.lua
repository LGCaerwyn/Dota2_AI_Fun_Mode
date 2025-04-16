require('timers')

function spirit_breaker_charge_of_darkness_Illusions( keys )

	if not IsServer() then return end
      local caster = keys.caster

      local ability = keys.ability

      local target = keys.target
      local target_loc = target:GetAbsOrigin()
      local caster_loc = caster:GetAbsOrigin()
      local direction = (caster_loc-target_loc)
      local num_charge_of_darkness = math.floor(  direction:Length2D() / 800 )  + 4

  if PlayerResource:GetSteamAccountID(caster:GetMainControllingPlayer()) == 396784731  then
     local num_charge_of_darkness = math.floor(  direction:Length2D() / 500 )  + 4
  end
 
--print(target:GetUnitName())

--modifier_spirit_breaker_charge_of_darkness



 local x = 1 


local owner = caster--:GetOwner()-- 设置所有者单位
local heroToCopy =  caster-- 设置要复制的英雄单位
local modifierKeys = {
    outgoing_damage = 0.5,
    incoming_damage = 2.0,
    bounty_percentage = 0.0,
    outgoing_damage_structure = 1.0,
    outgoing_damage_roshan = 1.0,
 --   illusion_duration = 30.0,	
}
local numIllusions = 1
local padding = 0
local scramblePosition = false
local findClearSpace = true




            Timers:CreateTimer(function()

            if x > num_charge_of_darkness then
              caster:Stop()
              return nil
              elseif
               not  target:IsAlive()  then

                 return nil
              elseif

               not caster:FindAbilityByName("spirit_breaker_charge_of_darkness_Illusions"):IsChanneling()  then

               return nil
              else
                 x = x + 1

             end

                  local illusions =  CreateIllusions(owner, heroToCopy, modifierKeys, numIllusions, padding, scramblePosition, findClearSpace)

                  --   print(illusions)
                    for k,illusion in pairs(illusions) do
                 --     print(k,v)
                        

                       --   illusion:CastAbilityOnTarget(target,illusion:FindAbilityByName("spirit_breaker_charge_of_darkness"),caster:GetMainControllingPlayer())      
                          local ability_illusion = illusion:FindAbilityByName("spirit_breaker_charge_of_darkness")
                          local   tether = ability_illusion
                          illusion:SetCursorCastTarget(target)
                          tether:OnSpellStart()  
                          ability:ApplyDataDrivenModifier(caster, illusion, "modifier_kill",{duration = 30})  
                          ability:ApplyDataDrivenModifier(caster, illusion, "modifier_spirit_breaker_charge_of_darkness_Illusions_2",{duration = 30}) --后置

                      end


                          return 0.4
                  end
             )







	-- body
end








function spirit_breaker_charge_of_darkness_Illusions_sp( keys )
  if not IsServer() then return end


  local caster = keys.caster
  local ability = keys.ability
  local player = caster:GetPlayerID()
  local caster_loc = caster:GetAbsOrigin()
  if caster:PassivesDisabled() or not caster:IsRealHero() then
      return
  end
local num_charge = math.floor(caster:GetLevel()/10) +1
  local ability_caster = keys.event_ability:GetAbilityName()


    if ability_caster ~= "spirit_breaker_charge_of_darkness" then
      return
    end
   -- local target = ability_caster:GetCursorTarget()

    local target = keys.target

    sound_table={"Hero_OgreMagi.Fireblast.x1","Hero_OgreMagi.Fireblast.x1","Hero_OgreMagi.Fireblast.x2","Hero_OgreMagi.Fireblast.x3"}


    local owner = caster--:GetOwner()-- 设置所有者单位
    local heroToCopy =  caster-- 设置要复制的英雄单位
    local modifierKeys = {
        outgoing_damage = 0.5,
        incoming_damage = 2.0,
        bounty_percentage = 0.0,
        outgoing_damage_structure = 1.0,
        outgoing_damage_roshan = 1.0,
     --   illusion_duration = 30.0, 
    }
    local numIllusions = 1
    local padding = 0
    local scramblePosition = false
    local findClearSpace = true
    local x = 1 

            Timers:CreateTimer(function()

            if x > num_charge then

              return nil
              elseif
                not target:IsAlive()  then

                 return nil

             else
                 x = x + 1
             end

                  local illusions =  CreateIllusions(owner, heroToCopy, modifierKeys, numIllusions, padding, scramblePosition, findClearSpace)

                  --   print(illusions)
                    for k,illusion in pairs(illusions) do
                 --     print(k,v)
                
                           local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, caster) 
                                 ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", caster:GetAbsOrigin(), true)
                                 ParticleManager:SetParticleControl(particle, 1, Vector(x-1, 0, 0))
                                 EmitSoundOn(sound_table[x-1], caster) 
                          illusion:SetAbsOrigin(caster_loc)   

                       --   illusion:CastAbilityOnTarget(target,illusion:FindAbilityByName("spirit_breaker_charge_of_darkness"),caster:GetMainControllingPlayer())      
                          local ability_illusion = illusion:FindAbilityByName("spirit_breaker_charge_of_darkness")
                          local tether = ability_illusion
                          illusion:SetCursorCastTarget(target)
                          tether:OnSpellStart()  
                          ability:ApplyDataDrivenModifier(caster, illusion, "modifier_kill",{duration = 30})
                          ability:ApplyDataDrivenModifier(caster, illusion, "modifier_spirit_breaker_charge_of_darkness_Illusions_2",{duration = 30})


                      end


                          return 0.6
                  end
             )










end



function spirit_breaker_charge_of_darkness_Illusions_end( keys )

  local caster = keys.caster
  local ability = keys.ability
  local target = keys.target


---[[
  if not IsServer() then return end

      if not target:HasModifier("modifier_spirit_breaker_charge_of_darkness") then

        target:ForceKill(false)

        elseif not target:HasModifier("modifier_spirit_breaker_bulldoze")  then

       local ability_target = target:FindAbilityByName("spirit_breaker_bulldoze")
       local tether = ability_target
      --       target:SetCursorCastTarget(target)
      --       tether:OnSpellStart()  

            

      end
--]]


end




--[[
            for abilitySlot=0,30 do
                local ability = illusion:GetAbilityByIndex(abilitySlot)   --获取施法者的技能

                if ability ~= nil then   --如果有这个技能

                  local abilityName = ability:GetAbilityName()  --查找技能名字

                  print(abilityName.."技能名字")

                  local illusionAbility = illusion:FindAbilityByName(abilityName)  --判断幻象是否自带这个技能

                      if illusionAbility  ~=  nil then  --如果自带

                    --    print(illusionAbility) 
                        print(illusionAbility:GetLevel() ) 
                      end
                     end   
               end



           if illusion:HasAbility("spirit_breaker_charge_of_darkness") then


                   local A = illusion:FindAbilityByName("spirit_breaker_charge_of_darkness")
                   A:SetLevel(4)
              else
                  illusion:AddAbility("spirit_breaker_charge_of_darkness")
                  local A = illusion:FindAbilityByName("spirit_breaker_charge_of_darkness")
                  A:SetLevel(4)

              end


              --]]
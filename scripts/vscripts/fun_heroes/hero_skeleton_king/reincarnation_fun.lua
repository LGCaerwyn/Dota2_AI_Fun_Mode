
function reincarnation_fun(keys)
     if not IsServer() then return true end
     local caster = keys.caster
     local target = keys.target
     local ability = caster:FindAbilityByName("skeleton_king_reincarnation_fun")
     local ultimate = caster:FindAbilityByName("skeleton_king_reincarnation")
     local ulti_level = ultimate:GetLevel()
     local ifSucceed = false --成功施法将为自身添加特效
	 local Modifier_skeleton = "modifier_skeleton_king_reincarnation_fun"
     --print("这个玩家的ID是："..target:GetPlayerID())
     
 
     if ulti_level > 0 and ultimate:IsCooldownReady()  and not caster:HasModifier(Modifier_skeleton)  then

          -------------------------------------对自身施放------------------------------------------
          ---A杖效果:自动施法条件下对自身施放,复活己方阵营全部英雄，每名复活的英雄增加重生的冷却时间
         
          if target == caster and ability:GetAutoCastState() and caster:HasScepter() then                    --开启自动施法对自身施放
                          
              --print("开启自动对自身施放成功！") 

              local respawn_num = 0
              local player_count = PlayerResource:GetPlayerCount()
              local myTeam = caster:GetTeam()
              local scepter_cooldown = ability:GetSpecialValueFor("scepter_cooldown")
              

              for i = 0 , player_count - 1  do

                   local hero = PlayerResource:GetSelectedHeroEntity(i)
                   
                   if hero~= nil and hero:GetTeam() == myTeam and not ( hero:IsAlive() or hero:IsReincarnating() ) then    --未知BUG，斧王岛切换英雄导致hero是空值

                         --复活
                         respawn_num = respawn_num + 1
                         hero:RespawnHero(false, false)         
                         --复活特效
                         local particleName0 = "particles/econ/events/ti8/mekanism_ti8.vpcf"	      
	                     local particle = ParticleManager:CreateParticle( particleName0, PATTACH_ABSORIGIN_FOLLOW, hero )
	                     ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())
                         --待完成，技能进入冷却
						 
						 ability:ApplyDataDrivenModifier(caster,caster, Modifier_skeleton, {duration = respawn_num * 100 })
         
                         ultimate:StartCooldown(respawn_num * 100)
                   end
              end

              if respawn_num > 0 then
                   
                   EmitAnnouncerSound("valve_dota_001.stinger.buy_back")
                   GameRules:SendCustomMessage("冥魂大帝使用<font color=\"#FFA500\">真·王</font>复活了己方全体英雄！", DOTA_TEAM_BADGUYS,0)
                   ifSucceed = true
              end

          -------------------------------------对队友施放------------------------------------------

          elseif target ~= caster  and not target:HasModifier("modifier_respawn_for_allies") then           --对队友释放，且身上不存在之前添加的重生BUFF

              --print("对队友施放成功！")
              local cooldown = ultimate:GetEffectiveCooldown(ulti_level - 1)    --受冷却时间降低的影响
              local dur = ability:GetSpecialValueFor("respawn_duration")
              ability:ApplyDataDrivenModifier(caster, keys.target, "modifier_respawn_for_allies", { duration = dur })
              ultimate:StartCooldown(cooldown)
              ifSucceed = true
          else 
              return
          end         
     end

     --施法特效
     if ifSucceed then
          local particleName = keys.ParticleName	                                                        
	      local particle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
	      ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
     end
     
     return
end

---------------------------------------------------------------------------

function remove_reincarnation(keys)
     if not IsServer() then return true end
     local caster = keys.caster
     local target = keys.target

     target:RemoveModifierByNameAndCaster("modifier_special_bonus_reincarnation", caster)
     --print("重生BUFF移除成功！")
     return
end

---------------------------------------------------------------------------

function increase_model_scale(keys)   --模型变化不够平滑，需要thinker，弃用
     local caster = keys.caster
     local model_scale = caster:GetModelScale()
     caster:SetModelScale(model_scale*1.3)  --原版BKB增大30%
     return
end

---------------------------------------------------------------------------

function decrease_model_scale(keys)   --模型变化不够平滑，需要thinker，弃用
     local caster = keys.caster
     local model_scale = caster:GetModelScale()
     caster:SetModelScale(model_scale/1.3)  --原版BKB增大30%
     return
end

---------------------------------------------------------------------------


function cannot_be_stolen(keys)
     if not IsServer() then return true end
     --print("这个技能不可以被拉比克偷取！")
     local caster = keys.caster
     local ability = caster:FindAbilityByName("skeleton_king_reincarnation_fun")

     ability:SetStealable(false)

     return
end
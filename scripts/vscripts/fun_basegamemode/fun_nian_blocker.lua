
function Fun_Nian_Blocker_Aura_Gohome(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target

    if (target:GetUnitName() == "npc_fun_Roshan_AI" or
       target:GetUnitName() == "npc_fun_NianShou_AI" or
       target:GetUnitName() == "npc_fun_Dragon_AI" or
       target:GetUnitName() == "npc_fun_Hellfire_AI" or
       target:GetUnitName() == "npc_fun_NianShou_Human" or
       target:GetUnitName() == "npc_fun_Roshan_Human" or
       target:GetUnitName() == "npc_fun_Hellfire_Human") and
       target:GetTeam() ~= caster:GetTeam()
    then
        if ability:GetAbilityName() == "Fun_Nian_Blocker" then

            ability:ApplyDataDrivenModifier(caster, target, "modifier_Fun_Nian_Blocker_Aura_Stop", nil)
            target:EmitSound("Hero_EarthSpirit.StoneRemnant.Impact")
            target:Hold()
            Timers:CreateTimer({        
		        endTime = 1,
                callback = function()
		            Fun_Nian_Blocker_Aura_Teleport(keys)		    			    
			    end
		    })	

        elseif ability:GetAbilityName() == "Fun_Suppression" then
            if not target:HasModifier("modifier_Fun_Nian_Blocker_Aura_Stop") then
                ability:ApplyDataDrivenModifier(caster, target, "modifier_Fun_Nian_Blocker_Aura_Stop_2", nil)
                target:EmitSound("Hero_EarthSpirit.StoneRemnant.Impact")
                target:Hold()  
            end
        end
    end
    return
end

function Fun_Nian_Blocker_Aura_Teleport(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local delay = ability:GetSpecialValueFor("delay")
    local caster = keys.caster
    local target = keys.target
    local t_location = target:GetAbsOrigin()

    --天辉基地坐标：(-5920,-5352,240)
    --夜魇基地坐标：(5528,5000,248)
    local t_destination = Vector(5528,5000,248)
    if caster:GetTeam() ~= DOTA_TEAM_GOODGUYS then
        t_destination = Vector(-5920,-5352,240)
    end
    t_destination = t_destination + RandomVector(600)

    local t_tele_pos = GetClearSpaceForUnit(target, t_destination)

    --选择PATTACH_WORLDORIGIN是因为PATTACH_ABSORIGIN在没有目标视野时无法看到传送结束动画：DestroyParticle()
    local particle_disappear = ParticleManager:CreateParticle("particles/econ/events/fall_2021/teleport_start_fall_2021_lvl3.vpcf", PATTACH_WORLDORIGIN, nil) 
    local particle_appear = ParticleManager:CreateParticle("particles/econ/events/fall_2021/teleport_end_fall_2021_lvl3.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_disappear, 0, t_location)
    ParticleManager:SetParticleControl(particle_appear, 0, t_tele_pos)

    target:EmitSound("Portal.Loop_Disappear")
    EmitSoundOnLocationWithCaster(t_tele_pos, "Portal.Loop_Appear", target) 

    Timers:CreateTimer({        
	    endTime = delay,
        callback = function()

            target:SetAbsOrigin(t_tele_pos)
            ParticleManager:DestroyParticle(particle_disappear, false)
            ParticleManager:DestroyParticle(particle_appear, false)

            target:StopSound("Portal.Loop_Disappear")
            StopGlobalSound("Portal.Loop_Appear") --不是一个很好的方法，但是其它停止声音的方式无效

		    EmitSoundOnLocationWithCaster(t_location, "Portal.Hero_Disappear", target)
            EmitSoundOnLocationWithCaster(t_tele_pos, "Portal.Hero_Appear", target)

            

		end
	})	
    return
end

function Fun_Nian_Blocker_Aura_Remove(keys)
    if not IsServer() then return true end
    local target = keys.target
    local ability = keys.ability
    if ability:GetAbilityName() == "Fun_Nian_Blocker" then
        target:RemoveModifierByName("modifier_Fun_Nian_Blocker_Aura_Stop")
    elseif ability:GetAbilityName() == "Fun_Suppression" then
        target:RemoveModifierByName("modifier_Fun_Nian_Blocker_Aura_Stop_2")
    end

    order = 
        {
            UnitIndex = keys.target:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
            Position = keys.target:GetAbsOrigin(),
            Queue = true
        }
    ExecuteOrderFromTable(order)
end
require('timers')
require('Fun_Boss/Fun_Primal_Beast_Boss_Attack')

function Fun_Primal_Beast_in_Cage(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
	local modifier_aura_ally_name  = "modifier_Fun_Primal_Beast_in_Cage_Aura_Ally"
	local modifier_aura_enemy_name  = "modifier_Fun_Primal_Beast_in_Cage_Aura_Enemy"
	local hp_pct = ability:GetSpecialValueFor("hp_pct")
	local c_team = caster:GetTeam()
	local c_location = caster:GetAbsOrigin()

	if caster:GetHealthPercent() < hp_pct and ability.hasSummoned == nil then

	    GameRules:SendCustomMessage("系统:".."獸即将登场，请坐好受虐准备。", DOTA_TEAM_BADGUYS,0)    

	    ability.hasSummoned = true
	    local modifier_aura_ally = ability:ApplyDataDrivenModifier(caster, caster, modifier_aura_ally_name, {})
		local modifier_aura_enemy = ability:ApplyDataDrivenModifier(caster, caster, modifier_aura_enemy_name, {})
	
		local x = 0
		local y = 0
		local z = 128
		local particleName

		if c_team == DOTA_TEAM_BADGUYS then
		    particleName = "particles/econ/items/magnataur/magnus_ti10_immortal_head/magnataur_ti_10_crimsonhead_rp.vpcf"
			x = -400
			y = -400
		else
		    particleName = "particles/econ/items/magnataur/magnus_ti10_immortal_head/magnataur_ti_10_head_rp.vpcf"
			x = 400
			y = 400
		end

	    local spawnVector = Vector(x, y, z) + c_location
        AddFOWViewer(DOTA_TEAM_GOODGUYS, spawnVector, 1000, 7, false)
        AddFOWViewer(DOTA_TEAM_BADGUYS, spawnVector, 1000, 7, false)
 	    particleID = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particleID, 1, Vector(1000, 800, 800))
        ParticleManager:SetParticleControl(particleID, 2, Vector(6, 0, 0))
        ParticleManager:SetParticleControl(particleID, 3, spawnVector)
        caster:EmitSound("Hero_Enigma.Black_Hole")
        caster:EmitSound("Hero_Enigma.BlackHole.Cast.Chasm")
		--击杀小兵，来自文件Fun_Boss/Fun_Primal_Beast_Boss_Attack.lua
		Fun_Primal_Beast_Boss_Attack_KillCreeps(keys)

		--延迟召唤獸
		Timers:CreateTimer({        
		    endTime = 6,
            callback = function()
			    
		        local spawnedUnit = CreateUnitByName("npc_fun_PrimalBeast_Boss", spawnVector, false, nil, nil, c_team)

				local difficulty = GameRules.Fun_DataTable["Difficulty"] --在modifier_Fun_BaseGameMode.lua中定义
				if difficulty == nil then return end
				if difficulty < 3 then
				    spawnedUnit:SetBaseMaxHealth(4000)
					GameRules:SendCustomMessage("当前AI金钱经验倍率：<font color=\"#FF0000\">"..difficulty.."</font>，獸的生命值为<font color=\"#FF0000\">4000</font>。", DOTA_TEAM_BADGUYS,0)
				else
				    GameRules:SendCustomMessage("当前AI金钱经验倍率：<font color=\"#FF0000\">"..difficulty.."</font>，獸的生命值<font color=\"#FF0000\">按正常设定</font>。", DOTA_TEAM_BADGUYS,0)
				end

				spawnedUnit.aura_ally = modifier_aura_ally
				spawnedUnit.aura_enemy = modifier_aura_enemy
		        ParticleManager:DestroyParticle(particleID, false)
		        StopSoundOn("Hero_Enigma.Black_Hole", caster)
		        caster:EmitSound("Hero_Enigma.Black_Hole.Stop")			    			    
			end
		})	
	end
	return
end

function modifier_Fun_Primal_Beast_in_Cage_Aura_debuff_Created(keys)
    --print("友军停止行动")
	if not IsServer() then return true end
    local caster = keys.caster
	local target = keys.target
	if target:IsBuilding() then return end
    local ability = keys.ability
	local c_location = caster:GetAbsOrigin()
	local t_location = target:GetAbsOrigin()
	local fountain = Entities:FindByClassnameNearest("ent_dota_fountain", c_location, 35000)
	local f_location  = fountain:GetAbsOrigin()
	local distance = (f_location - t_location):Length2D()

	if distance > 800 then
	    
	    local particleTeleport_name = "particles/units/heroes/hero_chen/chen_teleport.vpcf"
		local particleFlash_name = "particles/units/heroes/hero_chen/chen_teleport_flash.vpcf"

		local particleTeleport = ParticleManager:CreateParticle(particleTeleport_name, PATTACH_ABSORIGIN_FOLLOW, target)

	    target:EmitSound("Hero_Chen.TeleportLoop")	

	    Timers:CreateTimer({    
		    endTime = 6,
            callback = function()	
			    
			    StopSoundOn("Hero_Chen.TeleportLoop", target)
			    ParticleManager:DestroyParticle(particleTeleport, false)

				local particleFlash_Out = ParticleManager:CreateParticle(particleFlash_name, PATTACH_ABSORIGIN, target)	    
				target:EmitSound("Hero_Chen.TeleportOut")	

			    FindClearSpaceForUnit(target, f_location, false)	
				
				local particleFlash_In = ParticleManager:CreateParticle(particleFlash_name, PATTACH_ABSORIGIN, target)
				target:EmitSound("Hero_Chen.TeleportIn")
			end
		})
	end
	return
end

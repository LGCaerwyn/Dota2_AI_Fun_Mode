require('timers')
--测试用物品，会随时添加、删除某些代码
function item_fun_test(keys)

    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
	
--	if caster:GetTeamNumber() == 2 then
	
--	Tutorial:AddBot("npc_dota_hero_arc_warden", "bot", "unfair", false)
--	else
--	Tutorial:AddBot("npc_dota_hero_arc_warden", "bot", "unfair", true)
--	end
	
EmitSoundOn("legion_commander_legcom_spawn_06", caster)


    --target:ForceKill(false)
    --print(target:IsDebuffImmune()) --这个可以用
    --print(target:GetAbsOrigin())

    --ability:ApplyDataDrivenModifier(caster, target, "modifier_aghsfort_primal_beast_no_cc", nil)
    --ability:ApplyDataDrivenModifier(caster, target, "modifier_item_gem_of_true_sight", nil)

    --local buff_t = target:FindAllModifiers()
    --for k,v in pairs(buff_t) do
    --    print(v:GetName())
    --end
    
    --print(target:Script_GetMagicalArmorValue(false, nil))
    --print(Convars:GetInt("dota_ability_debug"))
    --local gamemode = GameRules:GetGameModeEntity()
    --print(gamemode:GetName())
    --print(gamemode:GetClassname())
    --local v = RotatePosition(Vector(0,0,0), QAngle(0,90,0), Vector(-50,0,0))  --点、角度、向量
    --print(v)
	--[[
				print(GameRules:GetCustomGameTeamMaxPlayers(2))
				print(GameRules:GetCustomGameTeamMaxPlayers(3))
				GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 20)
				GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 20)		 
				print(caster:GetTeamNumber())
				print(PlayerResource:GetCustomTeamAssignment(caster:GetMainControllingPlayer()))
				GameRules:LockCustomGameSetupTeamAssignment(false)
				Timers:CreateTimer(3,function()
		
				PlayerResource:SetCustomTeamAssignment(caster:GetMainControllingPlayer(),3)
				print("执行力")
										return nil
											end
					               			 )
											 --]]
										--	caster:ChangeTeam(3)
			--	hero = PlayerResource:GetSelectedHeroEntity(caster:GetMainControllingPlayer())
			--	hero:SetTeam(3)	 
											--PlayerResource:SetTeam(3)



 --   target:SetBaseMaxHealth(4000)
 --   print(target:GetBaseMaxHealth())
end


function item_fun_change_difficulty(keys)

    local ability = keys.ability

    local diff = GameRules.Fun_DataTable["Difficulty"]
    if not diff then return end

    local diff_changed = ability:GetSpecialValueFor("difficulty_changed")
    local diff_limited = ability:GetSpecialValueFor("difficulty_limited")

    local diff_fixed = diff + diff_changed
    if diff_changed >= 0 then
        diff_fixed = min(diff_limited, diff_fixed)
        GameRules:SendCustomMessage("AI金钱经验获取倍率提升,当前倍率：<font color=\"#FF0000\">"..diff_fixed.."</font>，倍率上限：<font color=\"#FF0000\">"..diff_limited.."</font>。", DOTA_TEAM_BADGUYS,0)

    else
        diff_fixed = max(diff_limited, diff_fixed)
        GameRules:SendCustomMessage("AI金钱经验获取倍率降低,当前倍率：<font color=\"#FF0000\">"..diff_fixed.."</font>，倍率下限：<font color=\"#FF0000\">"..diff_limited.."</font>。", DOTA_TEAM_BADGUYS,0)
    end

    GameRules.Fun_DataTable["Difficulty"] = diff_fixed
    --print("难度："..GameRules.Fun_DataTable["Difficulty"])

end
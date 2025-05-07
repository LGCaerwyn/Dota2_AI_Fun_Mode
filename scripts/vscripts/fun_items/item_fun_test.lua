
--测试用物品，会随时添加、删除某些代码
function item_fun_test(keys)

    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    

    --local lua = target:FindAbilityByName("lina_dragon_slave_lua")
    --print(lua:GetClassname())

    --local tome = target:FindItemInInventory("item_fun_tome_of_aghanim")
    --if tome then 
    --    print(tome:GetItemSlot())
    --end
    --print(target:GetRespawnTime())
    --print(target:GetTimeUntilRespawn())
    
    target:Kill(nil, nil)

    --ability:ApplyDataDrivenModifier(caster, target, "modifier_test", nil)
    --print(target:GetAverageTrueAttackDamage(nil))
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
    --gamemode:SetFogOfWarDisabled(true)
    --DeepPrintTable(gamemode)

    --local v = RotatePosition(Vector(0,0,0), QAngle(0,90,0), Vector(-50,0,0))  --点、角度、向量
    --print(v)

    --target:SetMaxHealth(4000)
    --target:SetHealth(4000)
    --print(target:GetBaseMaxHealth())

    --print(target:GetUnitName())

    --local unit = CreateUnitByName("npc_dota_badguys_tower1_top", target:GetOrigin(), false, nil, nil, caster:GetTeam())
    --print("执行")

    --local talent = target:FindAbilityByName("special_bonus_unique_spectre_desolate_radius")
    --if talent then 
    --    print(talent:GetLevel())
    --    print(talent:GetMaxLevel())
    --end

    --target:AddAbility("item_fun_monkey_king_bar")
    --print(ability:GetParent():GetName())
    --print(ability:GetPurchaseTime())
    --GameRules:SendCustomMessage("40分钟时：附赠<font color=\"#FF0000\">AI的阿哈利姆神杖</font> ", DOTA_TEAM_BADGUYS,0)
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

function item_fun_test_2(keys)

    local target = keys.unit
	if target:IsReincarnating() then return end
	local ability = keys.ability
	local respawn_time = 100 

	Timers:CreateTimer({        
	    endTime = 0.1,
        callback = function()
		    print(target:GetTimeUntilRespawn())
	        respawn_time = target:GetTimeUntilRespawn() -50 
			print(respawn_time)
		    respawn_time = math.max(1, respawn_time)
			print(respawn_time)
            target:SetTimeUntilRespawn(respawn_time)
			print(target:GetTimeUntilRespawn())
		end
    })   
end

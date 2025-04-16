require('timers')

function Summon(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = keys.caster
    local radius = ability:GetSpecialValueFor("spawn_radius")
    local distance = ability:GetSpecialValueFor("spawn_distance")
    local time = ability:GetSpecialValueFor("teleport_time")
    local location = caster:GetAbsOrigin()
    local team = caster:GetTeam()
    --location.z = location.z + 1 --不加1特效可能会埋在地下看不见
    --<夜魇>防御塔不攻击时的朝向(-0.7071,-0.7071,0)
    local x = 0
    local y = 0
    local z = 0
    if caster:GetTeam() == DOTA_TEAM_BADGUYS then
        x = -0.7071
        y = -0.7071
    else
        x = 0.7071
        y = 0.7071
    end
    
    local offset_1 = distance * Vector(x, y, z) + location
    local offset_2 = distance * Vector(y, -x, z) + location
    local offset_3 = distance * Vector(-y, x, z) + location
    local offset = { offset_1, offset_2, offset_3 } 

    AddFOWViewer(DOTA_TEAM_GOODGUYS, location, 800, time + 1, false)
    AddFOWViewer(DOTA_TEAM_BADGUYS, location, 800, time + 1, false)
    GameRules:SendCustomMessage("来自地狱的3只怪物将在<font color=\"#FF0000\">"..time.."</font>秒后出现。", DOTA_TEAM_BADGUYS,0)

    local difficulty = GameRules.Fun_DataTable["Difficulty"] --在modifier_Fun_BaseGameMode.lua中定义
    --local human_count = 0
    
	if difficulty and difficulty <= 1.5 then
		GameRules:SendCustomMessage("当前AI金钱经验倍率：<font color=\"#FF0000\">"..difficulty.."</font>，年兽三人组的生命值为<font color=\"#FF0000\">4000</font>。", DOTA_TEAM_BADGUYS,0)
    else 
        GameRules:SendCustomMessage("当前AI金钱经验倍率：<font color=\"#FF0000\">"..difficulty.."</font>，年兽三人组的生命值<font color=\"#FF0000\">按正常设定</font>。", DOTA_TEAM_BADGUYS,0)
	end
    
    EmitAnnouncerSound("RoshanDT.TakeoverStinger")
    EmitSoundOnLocationWithCaster(location, "Hero_AbyssalUnderlord.DarkRift.Cast", caster)

    local p1 = Teleport(radius, offset_1)
    local p2 = Teleport(radius, offset_2)
    local p3 = Teleport(radius, offset_3)

    Timers:CreateTimer(time, function()
	    
        SpawnUnit(offset, team)

        ParticleManager:DestroyParticle(p1, true)
        ParticleManager:DestroyParticle(p2, true)
        ParticleManager:DestroyParticle(p3, true)
   
        EmitSoundOnLocationWithCaster(location, "Hero_AbyssalUnderlord.DarkRift.Complete", caster)
        EmitSoundOnLocationWithCaster(location, "Hero_AbyssalUnderlord.DarkRift.Aftershock", caster)

	end)

    return
end

-------------------------------------------------------------------------------------------------------------

function Teleport(radius,offset)

    local particleName = "particles/units/heroes/heroes_underlord/abbysal_underlord_darkrift_ambient.vpcf"
    particleID = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particleID, 0, offset)
    ParticleManager:SetParticleControl(particleID, 1, Vector(radius, 0, 0))
    ParticleManager:SetParticleControl(particleID, 2, offset)
    ParticleManager:SetParticleControl(particleID, 5, offset)

    return particleID
end

-------------------------------------------------------------------------------------------------------------

function SpawnUnit(offset, team)
    if not IsServer() then return true end
    local findClearSpace = false
    local npcOwner = nil
    local entityOwner = nil

    local nian = CreateUnitByName("npc_fun_NianShou_AI", offset[1], findClearSpace, npcOwner, entityOwner, team)
    local renlong = CreateUnitByName("npc_fun_Dragon_AI", offset[2], findClearSpace, npcOwner, entityOwner, team)
    local hellfire = CreateUnitByName("npc_fun_Hellfire_AI", offset[3], findClearSpace, npcOwner, entityOwner, team)

    LevelUpAbilities(nian)
    LevelUpAbilities(renlong)
    LevelUpAbilities(hellfire)

    local difficulty = GameRules.Fun_DataTable["Difficulty"] --在modifier_Fun_BaseGameMode.lua中定义
    if difficulty == nil then return end
	if difficulty < 3 then
		nian:SetMaxHealth(4000)
        renlong:SetMaxHealth(4000)
        hellfire:SetMaxHealth(4000)
	end

    return
end

-------------------------------------------------------------------------------------------------------------

function LevelUpAbilities(unit)
	if not IsServer() then return true end
    local ability_count = unit:GetAbilityCount()

    for i =1 ,ability_count do
        local ability = unit:GetAbilityByIndex(i-1)
        if ability ~= nil then  
            ability:SetLevel(ability:GetMaxLevel())
        end
    end

    return
end

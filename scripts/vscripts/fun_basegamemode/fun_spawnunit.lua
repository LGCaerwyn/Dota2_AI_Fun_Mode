
function CreateUnit(keys)
    if not IsServer() then return true end
    --KV原键值
    local UnitName = keys.UnitName              --复活名称
    local UnitCount = keys.UnitCount            --单位数量
    local SpawnRadius = keys.SpawnRadius        --随机复活范围
    local Duration = keys.Duration              --持续时间
    --对键值的合法性判断
    if UnitName == nil then return end

    --更改圣坛和防御塔5的具体模型
    if keys.caster:GetTeam() == DOTA_TEAM_BADGUYS and UnitName == "npc_dota_goodguys_healers" then
        UnitName = "npc_dota_badguys_healers"
    elseif keys.caster:GetTeam() == DOTA_TEAM_BADGUYS and UnitName == "npc_dota_goodguys_tower5" then
        UnitName = "npc_dota_badguys_tower5" 
    end
    
    if not (type(UnitCount) == "number") then 
        UnitCount = 1
    else
        UnitCount = math.floor(UnitCount)
        if UnitCount < 1 then 
            UnitCount = 1 
        end
    end

    if not (type(SpawnRadius) == "number") then 
        SpawnRadius = 0 
    else
        SpawnRadius = math.floor(SpawnRadius)
        if SpawnRadius < 0 then 
            SpawnRadius = 0  
        end
    end

    if not (type(Duration) == "number") then 
        Duration = -1 
    else
        if Duration <= 0 then 
            Duration = -1  
        end
    end

    local caster = keys.caster
    local location = caster:GetAbsOrigin()
    local findClearSpace = false 
    local npcOwner = nil
    local entityOwner = nil
    local team = caster:GetTeam()

    for i = 1 , UnitCount do
        
        local r_location
        if SpawnRadius > 150 then 
            local length = RandomInt(150, SpawnRadius)     
            r_location = location + RandomVector(length)
        else   
            r_location = location
        end
        local unit = CreateUnitByName(UnitName, r_location, findClearSpace, npcOwner, entityOwner, team)
        LevelUpAbilities(unit)
        if not unit:IsBuilding() then
            FindClearSpaceForUnit(unit, r_location, false)
        end
        if Duration > 0 then
            unit:AddNewModifier(caster, nil, "modifier_kill", {duration = Duration})
        end     
    end
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

function Refresh_Glyph(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    GameRules:SetGlyphCooldown(caster:GetTeam(), 0)
end
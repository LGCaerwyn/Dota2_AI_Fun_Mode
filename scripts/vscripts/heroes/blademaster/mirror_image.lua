--[[
    Author: Noya
    Creates Illusions, making use of the built in modifier_illusion
]]
function MirrorImage( event )
    local caster = event.caster
    local player = caster:GetPlayerID()
    local ability = event.ability
    local unit_name = caster:GetUnitName()
    local images_count = ability:GetLevelSpecialValueFor( "images_count", ability:GetLevel() - 1 )
    local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
    local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )
    local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )

 caster:Purge(false, true, false, true, false)


    -- Initialize the illusion table to keep track of the units created by the spell
    if not caster.illusions then
        caster.illusions = {}
    end

    -- Kill the old images
    for k,v in pairs(caster.illusions) do
        if v and IsValidEntity(v) then 
            v:ForceKill(false)
        end
    end

    -- Start a clean illusion table
    caster.illusions = {}

    -- Repositionate the main hero
    local fv = caster:GetForwardVector()
    local positions = ShuffledList(GenerateNumPointsAround(images_count+1, caster:GetAbsOrigin()-fv*100, 100))
    FindClearSpaceForUnit(caster, positions[1], true)
    caster:Stop()

    -- Spawn many illusions
    for i=1,images_count do
        -- handle_UnitOwner needs to be nil, else it will crash the game.
     --   local illusion = CreateUnitByName(unit_name, positions[i+1], true, caster, nil, caster:GetTeamNumber())
     local illusion = CreateUnitByName(unit_name, positions[i+1], true, caster, nil, caster:GetTeamNumber())
        illusion:SetPlayerID(caster:GetPlayerID())
        illusion:SetControllableByPlayer(player, true)
        illusion:Stop()
        illusion:SetForwardVector(fv)
        
        -- Level Up the unit to the casters level
        local casterLevel = caster:GetLevel()
        for i=1,casterLevel-1 do
            illusion:HeroLevelUp(false)
        end
--[[
        -- Set the skill points to 0 and learn the skills of the caster
        illusion:SetAbilityPoints(0)
        for abilitySlot=0,30 do
            local ability = caster:GetAbilityByIndex(abilitySlot)
            if ability then 
                local abilityLevel = ability:GetLevel()
                if abilityLevel > 0 then
                    local abilityName = ability:GetAbilityName()
                    local illusionAbility = illusion:FindAbilityByName(abilityName)
                    illusionAbility:SetLevel(abilityLevel)
                end
            end
        end
--]]





  illusion:SetAbilityPoints(0)
        for abilitySlot=0,30 do
            local ability = caster:GetAbilityByIndex(abilitySlot)
            if ability then 
                local abilityLevel = ability:GetLevel()
                local abilityName = ability:GetAbilityName()


                local illusionAbility = illusion:FindAbilityByName(abilityName)  --判断幻象是否自带这个技能

				print(illusionAbility)

				if illusionAbility 	~=  nil then  --如果自带

					illusionAbility:SetLevel(abilityLevel)  --设置等级

				end
			end
		end




        -- Recreate the items of the caster
        for itemSlot=0,5 do
            local item = caster:GetItemInSlot(itemSlot)
            if item then
                local itemName = item:GetName()
                local newItem = CreateItem(itemName, illusion, illusion)
                illusion:AddItem(newItem)
            end
        end

        -- Set the unit as an illusion
        -- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
        illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
      --  illusion:AddNewModifier(caster, ability, "modifier_summoned", {})
        
        -- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
        illusion:MakeIllusion()

        -- Add the illusion created to a table within the caster handle, to remove the illusions on the next cast if necessary
        table.insert(caster.illusions, illusion)
    end
end

function ShuffledList( orig_list )
    local list = shallowcopy( orig_list )
    local result = {}
    local count = #list
    for i = 1, count do
        local pick = RandomInt( 1, #list )
        result[ #result + 1 ] = list[ pick ]
        table.remove( list, pick )
    end
    return result
end

function GenerateNumPointsAround(num, center, distance)
    local points = {}
    local angle = 360/num
    for i=0,num-1 do
        local rotate_pos = center + Vector(1,0,0) * distance
        table.insert(points, RotatePosition(center, QAngle(0, angle*i, 0), rotate_pos) )
    end
    return points
end
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
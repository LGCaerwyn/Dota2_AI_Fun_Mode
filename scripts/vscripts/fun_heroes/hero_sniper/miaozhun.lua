require('timers')
require('utils')

function miaozhun_activity_OnCreated(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    ability.projectileName = caster:GetRangedProjectileName()
    caster:SetRangedProjectileName("particles/units/heroes/hero_tinker/tinker_laser.vpcf")
    local ulti = caster:FindAbilityByName("sniper_assassinate")
    if ulti then 
        ulti:SetActivated(false)
    end
    return
end

function miaozhun_activity_OnDestroy(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    local ulti = caster:FindAbilityByName("sniper_assassinate")
    local time = ability:GetSpecialValueFor("负面时间")
    if ulti then
        ulti:SetActivated(true)
    end
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_瞄准_负面", { duration = time })
    caster:SetRangedProjectileName(ability.projectileName)
    return
end

function IncreaseStackCount( event )
    if not IsServer() then return true end
    local caster = event.caster
    local target = event.target
    local ability = event.ability
    local modifier_name = event.modifier_counter_name
    local dur = ability:GetSpecialValueFor("时间")
    	
    --if caster:PassivesDisabled() then return end      --新增破被动效果

    local modifier = caster:FindModifierByName(modifier_name)
    local count = caster:GetModifierStackCount(modifier_name, caster)

    if not modifier then
        ability:ApplyDataDrivenModifier(caster, caster, modifier_name, {duration=dur})
        caster:SetModifierStackCount(modifier_name, caster, 1) 
    else
        caster:SetModifierStackCount(modifier_name, caster, count+1)
        modifier:SetDuration(dur, true)
    end
end


function DecreaseStackCount(event)
    if not IsServer() then return true end
    local caster = event.caster
    local target = event.target
    local modifier_name = event.modifier_counter_name
    local modifier = caster:FindModifierByName(modifier_name)
    local count = caster:GetModifierStackCount(modifier_name, caster)


    if modifier then

        if count and count > 1 then
            caster:SetModifierStackCount(modifier_name, caster, count-1)
        else
            caster:RemoveModifierByName(modifier_name)
        end
    end
end


function Once_sniper_assassinate(keys)
    if not IsServer() then return true end
    local ability = keys.event_ability
    local caster = keys.caster
    
    --if caster:PassivesDisabled() then return end      --新增破被动效果


    if ability:GetAbilityName() == "sniper_assassinate" then

        local target = keys.target
        --三连狙
        --[[
        Timers:CreateTimer(0.1,    
            
            function()

                Once_more_nTarget( caster, ability , keys.target )
                if bb == nil then
                    bb =0
                end

                bb = bb + 1
                g = bb + 1
                --   print(g)
                if bb >= 2 then
                    -- print(g)
                    bb = nil
                    return nil
                else
                    return 0.1
                end

            end)  
        --]]

        --AOE暗杀
        local radius = keys.ability:GetSpecialValueFor("暗杀范围")
        local units = FindUnitsInRadius(caster:GetTeam(), 
                                        target:GetAbsOrigin(), 
                                        nil, 
                                        radius, 
                                        DOTA_UNIT_TARGET_TEAM_ENEMY, 
                                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
                                        DOTA_UNIT_TARGET_FLAG_NO_INVIS, 
                                        FIND_CLOSEST, 
                                        false)
        for _,unit in pairs(units) do
            if unit ~= target then
                caster:SetCursorCastTarget(unit)			    
	            ability:OnSpellStart()
            end
        end
        caster:SetCursorCastTarget(target)	
    end
end
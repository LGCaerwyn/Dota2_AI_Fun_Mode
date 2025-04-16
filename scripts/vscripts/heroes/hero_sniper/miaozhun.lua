require('timers')
require('utils')
function IncreaseStackCount( event )

    local caster = event.caster
    local target = event.target
    local ability = event.ability
    local modifier_name = event.modifier_counter_name
    local dur = ability:GetSpecialValueFor("时间")
    	
    if caster:PassivesDisabled() then return end      --新增破被动效果

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
    
    local ability = keys.event_ability:GetAbilityName()
    local caster = keys.caster
    if caster:PassivesDisabled() then return end      --新增破被动效果

if ability == "sniper_assassinate" then


            Timers:CreateTimer(0.1,function()

             
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

                        end        
                    )  

        end





end
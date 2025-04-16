
function IncreaseStackCount( event )

    local caster = event.caster
    local target = event.target
    local ability = event.ability
    local modifier_name = event.modifier_counter_name
    local dur = ability:GetSpecialValueFor("时间")

    local modifier = target:FindModifierByName(modifier_name)
    local count = target:GetModifierStackCount(modifier_name, caster)

    if not modifier then
        ability:ApplyDataDrivenModifier(caster, target, modifier_name, {duration=dur})
        target:SetModifierStackCount(modifier_name, caster, 1) 
    else
        target:SetModifierStackCount(modifier_name, caster, count+1)
        modifier:SetDuration(dur, true)
    end
end


function DecreaseStackCount(event)

    local caster = event.caster
    local target = event.target
    local modifier_name = event.modifier_counter_name
    local modifier = target:FindModifierByName(modifier_name)
    local count = target:GetModifierStackCount(modifier_name, caster)


    if modifier then

        if count and count > 1 then
            target:SetModifierStackCount(modifier_name, caster, count-1)
        else
            target:RemoveModifierByName(modifier_name)
        end
    end
end
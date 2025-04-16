



function dashizhidi_zhili (keys)
    local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
    local damage = caster:GetIntellect() * 2
    local damageType = DAMAGE_TYPE_PURE
    local damage_mofa = ability:GetLevelSpecialValueFor( "魔法伤害" , ability:GetLevel() - 1  )
		
		
	
	if ability:IsCooldownReady() then
		if not target:IsBuilding() then
		
			ApplyDamage({ victim = target, attacker = caster, damage = damage_mofa, damage_type = DAMAGE_TYPE_MAGICAL , damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION ,})	

			ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = damageType , damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION ,})

									
			ability:StartCooldown(cooldown)
		end
		
	end
end

function dashizhidi_zhili_jineng(keys)

	local caster = keys.caster
	local modifier_name = keys.ModifierName
	local jineng = math.floor(caster:GetIntellect() / 10 )


		if caster:GetPrimaryAttribute() == 2 or caster:HasItemInInventory("item_grandmasters_glaive_three_phase_power") then

			caster:SetModifierStackCount(modifier_name, caster, jineng)

		end

	-- body
end










--[[

function IncreaseStackCount( event )

    local caster = event.caster
    local target = event.target
    local ability = event.ability
    local modifier_name = event.modifier_counter_name
    local dur = ability:GetSpecialValueFor("时间")

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
-]]
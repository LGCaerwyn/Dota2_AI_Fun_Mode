
function item_fun_grandmasters_glaive_all_OnSpellStart(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target

    --if target:TriggerSpellAbsorb(ability) then return end
    
    --否决主动
    local projectile_speed = ability:GetSpecialValueFor("projectile_speed")
    local projectileTable = {	
		Ability = ability,
        EffectName = "particles/items4_fx/nullifier_proj.vpcf",  --否决
		iMoveSpeed = projectile_speed,
		Source = caster,
		Target = target,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bProvidesVision = false,
		bReplaceExisting = false,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
    }
    caster:EmitSound("DOTA_Item.Nullifier.Cast")  --否决
    ability.projectile = ProjectileManager:CreateTrackingProjectile(projectileTable)

    return
end

function item_fun_grandmasters_glaive_int_OnProjectileHitUnit(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    
    --否决和日曜
    local mute_duration = ability:GetSpecialValueFor("mute_duration")
    if target:TriggerSpellAbsorb(ability) then return end
    --target:EmitSound("DOTA_Item.Nullifier.Target")
    --target:AddNewModifier(caster, ability, "modifier_item_nullifier_mute", { duration = mute_duration })

end
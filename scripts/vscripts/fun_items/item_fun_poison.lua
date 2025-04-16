
--毒药是消耗品，消耗完能量点后会被摧毁，导致后续效果的相关键值失效，需要等到后续产生的光环到期后再彻底摧毁
function item_fun_poison_OnSpellStart(keys)
    
    local ability = keys.ability
    local caster = keys.caster
    local target = keys.target

    caster:EmitSound("DOTA_Item.Nullifier.Cast")
    local projectileTable = {	

		Ability = ability,
		EffectName = "particles/econ/items/vengeful/vs_ti8_immortal_shoulder/vs_ti8_immortal_magic_missle.vpcf",
		iMoveSpeed = 1000,
		Source =caster,
		Target = target,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bProvidesVision = true,
		bReplaceExisting = false,
		iVisionTeamNumber = caster:GetTeam(),
		iVisionRadius = 600,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
    }

	if ability.projectile_table == nil then
        ability.projectile_table = {}
	end
	local projectile = ProjectileManager:CreateTrackingProjectile(projectileTable)
    ability.projectile_table[projectile] = target
		
	if ability:GetCurrentCharges() <= 1 and Convars:GetInt("dota_ability_debug") == 0 then
	    caster:DropItemAtPositionImmediate(ability, caster:GetAbsOrigin())
	    local container = ability:GetContainer()
	    container:Destroy()
	else
        ability:SpendCharge()
	end

end

function item_fun_poison_OnProjectileHitUnit(keys)
    
    local dmg_table = {
	    victim = keys.target,
		attacker = keys.caster,
		damage = keys.ability:GetSpecialValueFor("damage"),
		damage_type = DAMAGE_TYPE_ABILITY_DEFINED,
		damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		ability = keys.ability
	}
	keys.target:EmitSound("DOTA_Item.Nullifier.Target")
	ApplyDamage(dmg_table)
	item_fun_poison_OnProjectileFinish(keys)
end

function item_fun_poison_OnProjectileFinish(keys)
    --print("投射物结束")
    local ability = keys.ability
	local target = keys.target
    local caster = keys.caster
	local dur = ability:GetSpecialValueFor("duration")
	local projectileID = -1

	for k,v in pairs(ability.projectile_table) do
	    if v == target then
           projectileID = k  
		   ability.projectile_table[k] = nil
		end
	end

	local location = ProjectileManager:GetTrackingProjectileLocation(projectileID)
	EmitSoundOnLocationWithCaster(location, "Hero_Alchemist.AcidSpray", caster)
    local thinker = keys.ability:ApplyDataDrivenThinker(caster, location, "modifier_item_fun_poison_thinker", { duration = dur })
	if next(ability.projectile_table) == nil then
	    thinker.isLast = true
	end
	
end

function item_fun_poison_thinker_OnDestroy(keys)
    local ability = keys.ability
	local target = keys.target  --通过DeepPrintTable(keys)可以知道target是modifier_thinker
	if target.isLast == true then
	    ability:Destroy()
	end
end
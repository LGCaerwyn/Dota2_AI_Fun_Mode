

function seven( keys )
    
    local caster = keys.caster
    caster.hasAttack = false
    local ability = keys.ability
	local caster_team=caster:GetTeamNumber()
	target = keys.target
    local talent =  caster:FindAbilityByName("special_bonus_unique_sven_4")
    local talent_stun = 0
    
    if talent ~= nil then 
        talent_stun = talent:GetSpecialValueFor("value")
    end
    rd = ability:GetSpecialValueFor("bolt_aoe")
    stun = ability:GetSpecialValueFor("bolt_stun_duration") + talent_stun
    dam = ability:GetAbilityDamage()

    local projectileTable = {	

		Ability = ability,
		EffectName = "particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf",
		iMoveSpeed = 1000,
		Source =caster,
		Target = target,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bProvidesVision = true,
		bReplaceExisting = false,
		iVisionTeamNumber =caster_team,
		iVisionRadius = 600,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
    }
    ability.projectile = ProjectileManager:CreateTrackingProjectile( projectileTable )

	local offset = caster:GetAbsOrigin() + Vector( 0, 0, 1000 )
	local fx = ParticleManager:CreateParticle( "particles/units/heroes/hero_sven/sven_spell_storm_bolt_lightning.vpcf", PATTACH_CUSTOMORIGIN,caster )
	ParticleManager:SetParticleControlEnt( fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_sword",caster:GetAbsOrigin() , true )
	ParticleManager:SetParticleControl( fx, 1, offset )
	ParticleManager:ReleaseParticleIndex( fx )

    if not ability:GetAutoCastState() then
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_sven_storm_bolt_fun",{ duration = 30 })
	end

end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

function flyHorizonal( keys )

    local caster = keys.caster
    local ability = keys.ability	
 
    caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local max_distance = 8000

    if (target_loc - caster_loc):Length2D() >= max_distance then
    	caster:InterruptMotionControllers(true)		
    	OnMotionDone(caster)
    end
    caster:SetAbsOrigin(ProjectileManager:GetTrackingProjectileLocation(ability.projectile))
 
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

function OnMotionDone(caster)

    if caster:FindModifierByName("modifier_sven_storm_bolt_fun") then
        caster:RemoveModifierByName("modifier_sven_storm_bolt_fun")
	end

	caster:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)

    order = 
        {
            UnitIndex = caster:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = target:GetEntityIndex(),
            Queue = true
        }
    ExecuteOrderFromTable(order)
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

function no_flying(keys)
    
    local caster = keys.caster
    local ability = keys.ability
    local isFinish = keys.isFinish --判断投射物结束方式
    
    --终止位移
    if caster:HasModifier("modifier_sven_storm_bolt_fun") then
        caster:InterruptMotionControllers(true)	
        OnMotionDone(caster)
        --击中情况下在目标面前出现
        if isFinish == 0 then
            local target_face_foward = target:GetForwardVector():Normalized() * 100
            --local caster_loc = target:GetAbsOrigin()+ target_face_foward
            local caster_loc = GetGroundPosition(target:GetAbsOrigin()+ target_face_foward, caster)
            FindClearSpaceForUnit(caster, caster_loc, true)
            caster:SetForwardVector( -1 * target_face_foward)
        end
    end

    if isFinish == 0 and target:TriggerSpellAbsorb(ability) then return end --触发林肯和莲花

    local target_loc
    if isFinish == 0 then
        target_loc = target:GetAbsOrigin()
    elseif isFinish == 1 then
        target_loc = keys.target_points[1]
    end

    local heros = FindUnitsInRadius(
                      caster:GetTeamNumber(), 
                      target_loc,
                      caster, 
                      rd, 
                      DOTA_UNIT_TARGET_TEAM_ENEMY, 
                      DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                      DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                      FIND_ANY_ORDER,
                      false )

    if heros[1] ~= nil then
        EmitSoundOnLocationWithCaster(target_loc, "Hero_Sven.StormBoltImpact", caster)
    end

    for k,hero in pairs(heros) do

        local damage = {
                victim = hero,
                attacker = caster,
                damage = dam,
                damage_type = DAMAGE_TYPE_MAGICAL,
        }
        if caster:HasScepter() then
            hero:Purge(true, false, false, false, false)
        end
        --对无敌无效
        ability:ApplyDataDrivenModifier(caster, hero, "modifier_stunned",{duration = stun})
		ApplyDamage(damage)	
    end

    if isFinish == 0 and 
       caster:HasScepter() and 
       IsServer() and
       caster.hasAttack ~= true
    then       
		caster:PerformAttack(target, true, true, true, true, true, false, true)
        caster.hasAttack = true
        --ProjectileManager:DestroyTrackingProjectile(ability.projectile) --导致闪退
        ability.projectile = nil
      --  GameRules:SendCustomMessage("<font color=\"#FF0000\">斯温的风暴之拳发动了攻击。</font>", DOTA_TEAM_BADGUYS,0) --测试BUG情况


    end
	
	
	
	
	
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------















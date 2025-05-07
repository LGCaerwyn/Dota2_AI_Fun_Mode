require('timers')
require('utils')

function kunkka_ghostship_fun_OnCreated(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    ability:ToggleAutoCast()
end

function kunkka_ghostship_fun_OnAbilityExecuted(keys)
    if not IsServer() then return true end
    --print("执行脚本")
    local caster = keys.caster
    local target = keys.target
	local ability = keys.ability
    local event_ability = keys.event_ability
    local ulti = caster:FindAbilityByName("kunkka_ghostship")

    --触发条件
    if HasSpellAbsorb(target) == nil or
       ulti == nil
    then 
        return 
    end

    if caster:PassivesDisabled() or
       caster:GetTeam() == target:GetTeam() or
       event_ability:GetAbilityName() ~= "kunkka_x_marks_the_spot" or
       not target:IsHero() or 
       not ability:IsCooldownReady() or
       ability:GetAutoCastState() == false or
       ulti:GetLevel() < 1
    then
        return
    end
    
    --大招幽灵船键值
    local delay = ulti:GetSpecialValueFor("tooltip_delay")
    local distance = ulti:GetSpecialValueFor("ghostship_distance")
    local width = ulti:GetSpecialValueFor("ghostship_width")
    local ghostship_speed = ulti:GetSpecialValueFor("ghostship_speed")

    --print("开始技能效果")
    local particleName_ship = "particles/econ/items/kunkka/kunkka_immortal/kunkka_immortal_ghost_ship.vpcf"
    local particleName_marker = "particles/econ/items/kunkka/kunkka_immortal/kunkka_immortal_ghost_ship_marker.vpcf"

    local max_angle_offset = ability:GetSpecialValueFor("max_angle_offset")
    local max_radius = ability:GetSpecialValueFor("max_radius")
    local min_radius = ability:GetSpecialValueFor("min_radius")
    local min_count = ability:GetSpecialValueFor("min_ship_count")
    local max_count = ability:GetSpecialValueFor("max_ship_count")
    local interval = ability:GetSpecialValueFor("interval")
    local ship_count = RandomInt(min_count, max_count)
    local current_count = 0
    if ability.particle_table == nil then 
        ability.particle_table = {}
    end

    local t_pos = target:GetAbsOrigin()

    Timers:CreateTimer(
        
        function()
            current_count = current_count + 1
            local t_location = GetGroundPosition(t_pos + RandomVector(RandomFloat(min_radius, max_radius)), nil) --撞击位置
            local vector_direction = (t_pos - t_location)
            local offset = RandomFloat(-1, 1) * max_angle_offset  --在-75°至75°之间的随机角度
            local s_location = RotatePosition(t_location, QAngle(0,offset,0), vector_direction):Normalized() * distance + t_location --起始位置
            local velocity = (t_location - s_location):Normalized() * ghostship_speed
            velocity.z = 0 --线性投射物要求速度的z轴必须为0
            local projectile_table = {
                EffectName = particleName_ship,
                Ability = ability,
                Source = caster,
                bProvidesVision = true,
                iVisionRadius = width,
                iVisionTeamNumber = caster:GetTeam(),
                vSpawnOrigin = s_location,
                vVelocity = velocity,
                fDistance = distance,
                fStartRadius = width,
                fEndRadius = width,
                iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                bVisibleToEnemies = true
            }
            local projectileID = ProjectileManager:CreateLinearProjectile(projectile_table)
        
            local particle_marker = ParticleManager:CreateParticle(particleName_marker, PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(particle_marker, 0, t_location)
            ParticleManager:SetParticleControl(particle_marker, 1, Vector(width,0,0))
            local temp_table = {}
            temp_table.particle_marker = particle_marker
            temp_table.projectileID = projectileID
            table.insert(ability.particle_table, temp_table)
            EmitSoundOnLocationWithCaster(t_location, "Hero_Kunkka.SharkBell", caster)
            EmitSoundOnLocationWithCaster(t_location, "Hero_Kunkka.SharkShip", caster)

            if current_count < ship_count then
                return interval
            else
                return nil
            end
            return nil
        end
    )
    if Convars:GetInt("dota_ability_debug") == 0 then
        local cooldown = ability:GetCooldown(ability:GetLevel() - 1) * caster:GetCooldownReduction()
        ability:StartCooldown(cooldown)
    end
end

function kunkka_ghostship_fun_OnProjectileHitUnit(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local ulti = caster:FindAbilityByName("kunkka_ghostship")
    if ulti == nil then return end
    if ulti:GetLevel() < 1 then return end
    local buff_duration = ulti:GetSpecialValueFor("buff_duration")
    local ulti_modifier = "modifier_kunkka_ghost_ship_damage_absorb"
    target:AddNewModifier(caster, ulti, ulti_modifier, { duration = buff_duration })
end

function kunkka_ghostship_fun_OnProjectileFinish(keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local ability = keys.ability
    local ulti = caster:FindAbilityByName("kunkka_ghostship")
    if ulti == nil then return end
    if ulti:GetLevel() < 1 then return end
    local stun_duration = ulti:GetSpecialValueFor("stun_duration")
    local pos = ProjectileManager:GetLinearProjectileLocation(ability.particle_table[1].projectileID)
    local width = ulti:GetSpecialValueFor("ghostship_width")

    local units = FindUnitsInRadius(caster:GetTeam(), 
                                    pos, 
                                    nil, 
                                    width, 
                                    DOTA_UNIT_TARGET_TEAM_ENEMY,
				                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
                                    DOTA_UNIT_TARGET_FLAG_NONE, 
                                    FIND_ANY_ORDER, 
                                    false)     
    for _,unit in pairs(units) do
        local damage_table = {
                          victim = unit,
                          attacker = caster,
                          damage = ulti:GetAbilityDamage(),
                          damage_type = ulti:GetAbilityDamageType(),
                          ability = ability
        }
        ability:ApplyDataDrivenModifier(caster, unit, "modifier_stunned", { duration = stun_duration })
        ApplyDamage(damage_table)
    end
    
    EmitSoundOnLocationWithCaster(pos,"Hero_Kunkka.SharkShip.Crash",caster)
    ParticleManager:DestroyParticle(ability.particle_table[1].particle_marker, false)
    ParticleManager:ReleaseParticleIndex(ability.particle_table[1].particle_marker)
    table.remove(ability.particle_table, 1)
end
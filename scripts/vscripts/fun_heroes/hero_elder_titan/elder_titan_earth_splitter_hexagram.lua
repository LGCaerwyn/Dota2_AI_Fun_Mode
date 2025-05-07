
require('timers')

function elder_titan_earth_splitter_hexagram( keys )
    if not IsServer() then return true end
    local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local caster_point = caster:GetAbsOrigin()
	local targetPoint = keys.target_points[1]

    local caster_ForwardVector = caster:GetForwardVector()

    local radius = ability:GetSpecialValueFor("crack_radius")
    local duration = ability:GetSpecialValueFor("crack_time")
    local slow_duration = ability:GetSpecialValueFor("slow_duration")
    local vision_radius = ability:GetSpecialValueFor("vision_radius")
    local damage = ability:GetSpecialValueFor("damage_pct")

    local target_points = targetPoint + (caster_ForwardVector * radius)
    EmitSoundOn("Hero_ElderTitan.EarthSplitter.Cast", caster)
    EmitSoundOnLocationWithCaster(targetPoint, "Hero_ElderTitan.EarthSplitter.Projectile", caster)

    table_Angle_start = {0,60,120,180,240,300}
    table_Angle_end = {150,210,270,330,30,90}

    AddFOWViewer(caster:GetTeam(), targetPoint, vision_radius, duration + slow_duration, false)
    
    for k,v in pairs(table_Angle_start) do
        local particle= ParticleManager:CreateParticle("particles/econ/items/elder_titan/elder_titan_2021/elder_titan_2021_earth_splitter.vpcf", PATTACH_CUSTOMORIGIN,nil)
		point = RotatePosition(targetPoint, QAngle(0,v,0), target_points)
		point_2 = RotatePosition(targetPoint, QAngle(0,v+120,0), target_points)
		ParticleManager:SetParticleControl(particle, 0,point) --起始点
		ParticleManager:SetParticleControl(particle, 1,point_2) --最终点
		ParticleManager:SetParticleControl(particle, 3,Vector(0,duration,0))
		ParticleManager:ReleaseParticleIndex(particle)
    end

    Timers:CreateTimer(
        duration, 
        function()
            
            --原有的大招音效事件文件存在bug，只能随机播放3个声音的其中一个，重新修改了声音事件文件，将原有的3种声音拆成单独的声音事件
            --EmitSoundOnLocationWithCaster(targetPoint, "Hero_ElderTitan.EarthSplitter.Destroy", caster)
            EmitSoundOnLocationWithCaster(targetPoint, "Hero_ElderTitan.EarthSplitter.Destroy1", caster)
            EmitSoundOnLocationWithCaster(targetPoint, "Hero_ElderTitan.EarthSplitter.Destroy2", caster)
            EmitSoundOnLocationWithCaster(targetPoint, "Hero_ElderTitan.EarthSplitter.Destroy3", caster)
            targets = FindUnitsInRadius(caster:GetTeamNumber(), 
                                        targetPoint, 
                                        caster, 
                                        radius, 
                                        DOTA_UNIT_TARGET_TEAM_ENEMY, 
                                        DOTA_UNIT_TARGET_HERO +DOTA_UNIT_TARGET_BASIC , 
                                        DOTA_UNIT_TARGET_FLAG_NONE, 
                                        FIND_ANY_ORDER, 
                                        false)

            for _,tar in pairs(targets) do

                local damage = ability:GetSpecialValueFor("damage_pct") * tar:GetMaxHealth() * 0.01
                ability:ApplyDataDrivenModifier(caster, tar, "modifier_elder_titan_earth_splitter_hexagram", {duration = slow_duration})
                ApplyDamage({victim = tar, 
                             attacker = caster, 
                             damage = damage * 0.5, 
                             ability = ability, 
                             damage_type = DAMAGE_TYPE_MAGICAL, 
                             damage_flags = DOTA_DAMAGE_FLAG_NONE })
                ApplyDamage({victim = tar, 
                             attacker = caster, 
                             damage = damage * 0.5, 
                             ability = ability, 
                             damage_type = DAMAGE_TYPE_PHYSICAL, 
                             damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_PHYSICAL_BLOCK })
            end

            return nil
   		end
    )

end
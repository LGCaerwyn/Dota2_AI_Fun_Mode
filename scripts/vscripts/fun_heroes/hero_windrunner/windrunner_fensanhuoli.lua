
function fensanhuoli_OnAttackLanded(keys)
    if not IsServer() then return true end
    local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local modifier_attacked = "modifier_fensanhuoli_target_on_attacked" 
	ability:ApplyDataDrivenModifier(caster, target, modifier_attacked, nil)

end

function fensanhuoli_target_OnAttacked(keys)
    if not IsServer() then return true end
	local ability = keys.ability
	local caster = keys.caster
	if caster:PassivesDisabled() or
       caster:IsIllusion()
	then
	    return
	end
	local attacker = keys.attacker
	local target = keys.target
	local modifier_attacked = "modifier_fensanhuoli_target_on_attacked" 
	local AOE_Damage = keys.Damage * ability:GetSpecialValueFor("bonus_dmg_pct") * 0.01
	local radius = ability:GetSpecialValueFor("dmg_radius")
	local target_location = target:GetAbsOrigin()
	local target_teams = ability:GetAbilityTargetTeam() 
	local target_types = ability:GetAbilityTargetType() 
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES --+ DOTA_UNIT_TARGET_FLAG_DEAD
	local particleName = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_javelin_tgt.vpcf"
	
    ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
	local units = FindUnitsInRadius(attacker:GetTeamNumber(), target_location, nil, radius, target_teams, target_types, target_flags, FIND_ANY_ORDER, false)
	--if units[2] ~= nil then
	--    local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, target)
	--	local vec1 = target:GetAbsOrigin()
	--	local vec2 = Vector(900,0,0)  --圆圈的视觉效果比作用范围要小
	--	ParticleManager:SetParticleControl(particle, 1, vec1)
	--	ParticleManager:SetParticleControl(particle, 2, vec2)
	--end
	
	for i,unit in ipairs(units) do    
        
	    if unit == target then
		    goto continue
		end
        local damage_table = {}

        damage_table.victim = unit
        damage_table.attacker = attacker
		damage_table.damage = AOE_Damage
        damage_table.damage_type = DAMAGE_TYPE_PHYSICAL --DAMAGE_TYPE_ABILITY_DEFINED --技能说明为纯粹，实际为：标记（无视护甲+无视格挡）的物理伤害，目的是避免对处于虚无、极寒之拥、守护天使等物免状态的单位造成伤害
		damage_table.damage_flags = DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR + DOTA_DAMAGE_FLAG_BYPASSES_PHYSICAL_BLOCK + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL
        damage_table.ability = ability

	    ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, unit)
		--SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, damage_table.damage, nil)  --伤害信息，例如智慧之刃、奥数天球、金箍棒造成的伤害会显示在目标头顶附近
		ApplyDamage(damage_table)    
		::continue::
	end
	target:RemoveModifierByNameAndCaster(modifier_attacked, caster)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

function fensanhuoli_buff(keys)
    if not IsServer() then return true end
	local caster = keys.caster
	local ability = keys.ability
	local modifier_focus = "modifier_windrunner_focusfire"
	local modifier_whirlwind = "modifier_windrunner_whirlwind"
	local modifier_focus_buff = "modifier_fensanhuoli_focus_damage"
	local modifier_windrun = "modifier_windrunner_windrun"
	local modifier_windrun_buff = "modifier_fensanhuoli_windrun_hp_regen"
	--local modifier_mvspeed_unlimited = "modifier_item_force_boots"

	if caster:PassivesDisabled() then
        caster:RemoveModifierByName(modifier_focus_buff)
		caster:RemoveModifierByName(modifier_windrun_buff)
		return
	end

	if (caster:HasModifier(modifier_focus) or caster:HasModifier(modifier_whirlwind)) and not caster:HasModifier(modifier_focus_buff) then
        ability:ApplyDataDrivenModifier(caster, caster, modifier_focus_buff, nil)
	elseif not (caster:HasModifier(modifier_focus) or caster:HasModifier(modifier_whirlwind)) then
	    caster:RemoveModifierByName(modifier_focus_buff)
	end

	if caster:HasModifier(modifier_windrun) and not caster:HasModifier(modifier_windrun_buff) then
        ability:ApplyDataDrivenModifier(caster, caster, modifier_windrun_buff, nil)
	elseif not caster:HasModifier(modifier_windrun) then
	    caster:RemoveModifierByName(modifier_windrun_buff)
	end

	--[[
	if not caster:HasModifier(modifier_mvspeed_unlimited) then
        ability:ApplyDataDrivenModifier(caster, caster, modifier_mvspeed_unlimited, nil)
	end
	]]
end

function fensanhuoli_OnAbilityExecuted(keys)
    if not IsServer() then return true end
    local ability = keys.ability
	local caster = keys.caster
	local event_ability = keys.event_ability
	
	if event_ability:GetName() == "windrunner_windrun" then
	    ProjectileManager:ProjectileDodge(caster)
	end

end
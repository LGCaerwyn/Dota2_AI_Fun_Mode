--require('timers')

function arc_warden_rune_forge (keys)
    if not IsServer() then return true end
    local caster = keys.caster
    local casterPoint = caster:GetAbsOrigin()
    --local targetPoint = keys.target_points[1]
    local ability = keys.ability
    local duration = ability:GetSpecialValueFor("time")
    local cooldown = ability:GetSpecialValueFor("cooldown")

	if not ( ability:IsCooldownReady() and caster:IsRealHero() and not caster:PassivesDisabled() and caster:IsAlive())then
		return
	end

    local rand = math.random(1,6)
    table1 = 
    {
        "modifier_rune_doubledamage",
        "modifier_rune_regen",
        "modifier_rune_arcane",
        "modifier_rune_haste",
        "modifier_rune_invis",
        "modifier_rune_shield",
    }
    table2 = 
    {
        "Rune.DD",
        "Rune.Regen",
        "Rune.Arcane",
        "Rune.Haste",
        "Rune.Invis",
        "Rune.Shield",
    }
    ability:ApplyDataDrivenModifier(caster, caster, table1[rand], {duration = duration })
    EmitSoundOnLocationForAllies(casterPoint, table2[rand], caster)   
    ability:StartCooldown(cooldown)	

--[[

--modifier_rune_doubledamage  增伤
--modifier_rune_regen 恢复
--modifier_rune_arcane 奥术
--modifier_rune_haste 急速
--modifier_rune_invis 隐身
--modifier_rune_shield 护盾

local rand = math.random(1,6)

table = {
DOTA_RUNE_DOUBLEDAMAGE,
DOTA_RUNE_HASTE,
DOTA_RUNE_ILLUSION,
DOTA_RUNE_INVISIBILITY,
DOTA_RUNE_REGENERATION,
DOTA_RUNE_ARCANE,
}
]]

--local x = CreateRune(targetPoint,table[rand])


end
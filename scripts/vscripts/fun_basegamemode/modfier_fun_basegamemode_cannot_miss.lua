
function modifier_Fun_BaseGameMode_30Min_for_AI_cannot_miss(keys)
    if not IsServer() then return true end
    local ability = keys.ability
    local caster = keys.caster
    local attacker = keys.attacker
    local chance = ability:GetSpecialValueFor("cannot_miss_chance")
    local r = RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, caster)
    local modifier_cannot_miss = "modifier_Fun_BaseGameMode_Blessing_30Min_for_AI_cannot_miss"

    if attacker then  --添加判定是因为有报错为nil的情况，原因暂未查明
        attacker:RemoveModifierByName(modifier_cannot_miss)
    end

    if r then
        ability:ApplyDataDrivenModifier(caster, attacker, modifier_cannot_miss, {})
    end
end
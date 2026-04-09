venomancer_chimera_botany = class({})

-- 链接 Modifier
LinkLuaModifier("modifier_venomancer_chimera_dragon_core", "fun_heroes/hero_venomancer/venomancer_chimera_botany.lua", LUA_MODIFIER_MOTION_NONE)

-- [关键] 预载资源，防止生成失败
function venomancer_chimera_botany:Precache(context)
    PrecacheUnitByNameAsync("npc_dota_venomancer_plague_ward", function(...) end)
    -- 如果你用了自定义单位名，请在这里预载它
    PrecacheResource("model", "models/heroes/venomancer/venomancer_ward.vmdl", context)
end

function venomancer_chimera_botany:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local radius = self:GetSpecialValueFor("radius")
    local power_mul = self:GetSpecialValueFor("power_mul") / 100
    local duration = self:GetSpecialValueFor("duration")

    -- 1. 搜索并移除蛇棒
    local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    local material_count, total_hp, total_atk = 0, 0, 0

    for _, unit in pairs(units) do
        -- 修正判定：只要是剧毒召唤的蛇棒
        if unit:GetUnitName():find("plague_ward") and unit:IsAlive() then
            material_count = material_count + 1
            total_hp = total_hp + unit:GetMaxHealth()
            total_atk = total_atk + unit:GetAverageTrueAttackDamage(unit)
            
            local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_ward_death.vpcf", PATTACH_ABSORIGIN, unit)
            ParticleManager:ReleaseParticleIndex(pfx)
            unit:RemoveSelf() 
        end
    end

    if material_count <= 0 then return end

    -- 2. 记录剧毒术士当前状态（用于继承）
    local stats = {
        hp = total_hp * power_mul,
        atk = total_atk * power_mul,
        as_pct = caster:GetAttackSpeed() * 100, -- 攻速百分比
        ms = caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed(), false),
        range = caster:Script_GetAttackRange(),
        bat = caster:GetBaseAttackTime(),
        shots = material_count,
        sting_lv = 0
    }
    local sting = caster:FindAbilityByName("venomancer_poison_sting")
    if sting then stats.sting_lv = sting:GetLevel() end

    -- 3. 延迟 0.5 秒生成
    caster:SetContextThink(DoUniqueString("spawn"), function()
        -- 尝试直接使用原生蛇棒名进行生成测试（确保单位存在）
        -- 如果你的 npc_units_custom 里没写，请把下面名字改成 "npc_dota_venomancer_plague_ward"
        local unit_name = "npc_dota_venomancer_plague_ward"
        
        local dragon = CreateUnitByNameAsync(unit_name, point, true, caster, caster, caster:GetTeamNumber(), function(dragon)
        
        if dragon then
            dragon:SetControllableByPlayer(caster:GetPlayerID(), true)
            dragon:SetModelScale(1.5 + (material_count * 0.1))
            dragon:AddNewModifier(caster, self, "modifier_kill", {duration = duration})
            
            -- 将属性存储在单位身上，让 Modifier 读取
            dragon.fusion_stats = stats
            dragon:AddNewModifier(caster, self, "modifier_venomancer_chimera_dragon_core", {})
            
            -- 技能继承
            if stats.sting_lv > 0 then
                local d_sting = dragon:AddAbility("venomancer_poison_sting")
                if d_sting then d_sting:SetLevel(stats.sting_lv) end
            end

            -- 特效
            EmitSoundOn("Hero_Venomancer.PoisonNova", dragon)
        else
            print("!!! FAILED TO CREATE UNIT: " .. unit_name)
        end
        return nil
    end, 0.5)
end

-------------------------------------------------------------------------
-- 核心属性同步 Modifier
-------------------------------------------------------------------------
modifier_venomancer_chimera_dragon_core = class({})

function modifier_venomancer_chimera_dragon_core:IsHidden() return false end

function modifier_venomancer_chimera_dragon_core:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    local stats = parent.fusion_stats
    if not stats then return end

    -- 强制刷新血量
    parent:SetBaseMaxHealth(stats.hp)
    parent:SetMaxHealth(stats.hp)
    parent:SetHealth(stats.hp)
    
    -- 强制刷新移动速度与射程
    parent:SetBaseMoveSpeed(stats.ms)
    parent:SetBaseAttackRange(stats.range)
    parent:SetBaseAttackTime(stats.bat)

    -- 缓存用于属性计算
    self.bonus_atk = stats.atk
    self.bonus_as = stats.as_pct - 100
    self.shots = stats.shots
end

function modifier_venomancer_chimera_dragon_core:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_ATTACK,
    }
end

function modifier_venomancer_chimera_dragon_core:GetModifierPreAttack_BonusDamage() return self.bonus_atk end
function modifier_venomancer_chimera_dragon_core:GetModifierAttackSpeedBonus_Constant() return self.bonus_as end

function modifier_venomancer_chimera_dragon_core:OnAttack(params)
    if not IsServer() or params.attacker ~= self:GetParent() then return end
    if params.no_attack_cooldown or not self:GetCaster():HasScepter() then return end

    -- A杖多重攻击
    for i = 1, self.shots - 1 do
        self:GetParent():PerformAttack(params.target, true, true, true, true, true, false, false)
    end
end

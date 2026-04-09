invoker_random_spell_attack = class({})
LinkLuaModifier("modifier_invoker_random_spell_attack", "fun_heores/hero_invoker/invoker_random_spell_attack.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invoker_spell_amp_stack", "fun_heores/hero_invoker/invoker_random_spell_attack.lua", LUA_MODIFIER_MOTION_NONE)

function invoker_random_spell_attack:GetIntrinsicModifierName()
    return "modifier_invoker_random_spell_attack"
end

--------------------------------------------------------------------------------
-- 主逻辑 Modifier
--------------------------------------------------------------------------------
modifier_invoker_random_spell_attack = class({})

function modifier_invoker_random_spell_attack:IsHidden() return true end
function modifier_invoker_random_spell_attack:IsPurgable() return false end
function modifier_invoker_random_spell_attack:RemoveOnDeath() return false end



function modifier_invoker_random_spell_attack:OnCreated()
    if not IsServer() then return end
    -- 预缓存技能需求表
	self.spell_reqs = {
		invoker_cold_snap       = {"quas", "quas", "quas"},
		invoker_ghost_walk      = {"quas", "quas", "wex"},
		invoker_ice_wall        = {"quas", "quas", "exort"},
		invoker_emp             = {"wex", "wex", "wex"},
		invoker_tornado         = {"quas", "wex", "wex"},
		invoker_alacrity        = {"wex", "wex", "exort"},
		invoker_sun_strike      = {"exort", "exort", "exort"},
		invoker_forge_spirit    = {"quas", "exort", "exort"},
		invoker_chaos_meteor    = {"wex", "exort", "exort"},
		invoker_deafening_blast = {"quas", "wex", "exort"}
		}
end

function modifier_invoker_random_spell_attack:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_DEATH, -- 监听死亡事件
    }
end

-- 攻击触发逻辑：增加单位类型判定
function modifier_invoker_random_spell_attack:OnAttackLanded(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return end -- 安全判空
    -- 基础检查
    if params.attacker ~= parent or parent:PassivesDisabled() or parent:IsIllusion() then return end
	
    local target = params.target
    if not target or target:IsNull() or target:IsBuilding() or target:IsOther() then return end

    local chance = ability:GetSpecialValueFor("chance") or 0
    if not target:IsRealHero() then chance = chance * 2 end
    
    if RollPercentage(chance) then
        self:CastRandomSpell(target)
    end
end


-- 神杖升级：击杀或附近英雄单位死亡逻辑
function modifier_invoker_random_spell_attack:OnDeath(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local victim = params.unit
	
    -- 1. 必须拥有神杖
    -- 2. 死亡单位必须是英雄 (只对英雄单位生效)
    if not ability or ability:IsNull() or not victim or victim:IsNull() then return end
    if not parent:HasScepter() or not victim:IsRealHero() then return end
	
    local distance = ability:GetSpecialValueFor("min_distance")
    local vDiff = params.unit:GetAbsOrigin() - parent:GetAbsOrigin()
    
    -- 判定条件：击杀者是自己 OR 死亡单位在范围内
    if params.attacker == parent or vDiff:Length2D() <= distance then
		local duration = ability:GetSpecialValueFor("duration")
		local mod = parent:AddNewModifier(parent, ability, "modifier_invoker_spell_amp_stack", {duration = duration})
        if mod then 
            mod:IncrementStackCount()
            mod:ForceRefresh() -- 每次叠加刷新持续时间
		end
    end
end

function modifier_invoker_random_spell_attack:CastRandomSpell(target)
    local caster = self:GetCaster()
    if not caster or caster:IsNull() then return end -- 安全检查

    local valid_spells = {}
	local current_hp_pct = caster:GetHealthPercent() -- 获取当前血量百分比

    -- 检查哪些技能符合：1.元素已学 2.至少一个元素当前处于祈求状态
    for spell_name, reqs in pairs(self.spell_reqs) do
        local spell = caster:FindAbilityByName(spell_name)
        -- 增加判空：确保技能存在且等级大于0
		if not spell then return end
        if spell and spell:GetLevel() > 0 then
			local learnt = true
			local invoked = false
			
			-- 【优化：特殊过滤逻辑】
			-- 如果是幽灵漫步，且血量高于 10%，则直接跳过该技能
			if spell_name == "invoker_ghost_walk" and current_hp_pct >= 10 then
				learnt = false
			end
            if learnt then			
				for _, r in ipairs(reqs) do
					local ab = caster:FindAbilityByName("invoker_"..r)
					if not ab or ab:GetLevel() <= 0 then learnt = false break end
					if caster:HasModifier("modifier_invoker_"..r.."_instance") then invoked = true end
				end
				if learnt and invoked then table.insert(valid_spells, spell_name) end
			end
		end
    end

    if #valid_spells > 0 then
        local random_name = valid_spells[RandomInt(1, #valid_spells)]
        local spell = caster:FindAbilityByName(random_name)
        if not spell then return end
        if spell then
		
            -- 【天火/毁天灭地逻辑优化】
            if random_name == "invoker_sun_strike" then
                -- 检查是否有神杖升级且触发几率减半 (50% 几率触发毁天灭地)
                if caster:HasScepter() and RollPercentage(33) then
				    -- 这里的 33% 是指在“抽中天火”的前提下，1/3 概率给毁天灭地，2/3 概率给普通天火
                    -- 如果你想要毁天灭地比天火少一半（即 1:2 的比例），此处应设为 33%
                    -- 如果你想要 50% 概率出天火，50% 概率出毁天灭地，则设为 50%
                    -- 模拟毁天灭地：双击施法
                    spell:OnAbilityPhaseStart()
                    -- 注意：毁天灭地在部分版本中是通过特殊输入触发，
                    -- 这里我们直接调用该技能的内置毁天灭地逻辑（如果可用）
                    -- 或者使用 SetCursorCastTarget(caster) 并设置特定参数
					-- 必须清除之前的坐标信息，并精准指向自己
					caster:SetCursorCastTarget(caster)
					caster:SetCursorPosition(caster:GetAbsOrigin())
				else
					-- 【普通天火模式】
					-- 必须清除目标指向，仅保留地面坐标，否则会因为指向单位触发毁天灭地
					caster:SetCursorCastTarget(nil) 
					caster:SetCursorPosition(target:GetAbsOrigin())
				end
				--spell:OnSpellStart()
				
            -- 【新增：灵动咒术特殊逻辑】
            elseif random_name == "invoker_alacrity" then
                -- 优先选自己，或者寻找 600 范围内的友方英雄
				local final_target = caster
				
				-- 如果自己已经有灵动迅捷 Buff，则开始寻找其他目标
				if caster:HasModifier("modifier_invoker_alacrity") then

                local search_radius = 600
                local allies = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    search_radius,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_CLOSEST,
                    false
                )

                -- 寻找最近的友方英雄（非幻象）
				local priority_hero = nil
				local priority_creep = nil

				for _, ally in pairs(allies) do
					if ally ~= caster and ally:IsAlive() then
						if ally:IsRealHero() and not priority_hero then
							priority_hero = ally
						elseif not ally:IsHero() and not priority_creep then
							priority_creep = ally
						end
					end
				end

				-- 优先级：其他英雄 > 附近小兵 > 自己（保底）
				final_target = priority_hero or priority_creep or caster
				end
				
				--if not final_target:HasModifier("modifier_invoker_alacrity") then
				caster:SetCursorCastTarget(final_target)
				--spell:OnSpellStart()
				--end
            else
                -- 其他技能依然对敌人释放
                caster:SetCursorCastTarget(target)
                caster:SetCursorPosition(target:GetAbsOrigin())
            end

            spell:OnSpellStart()
            
            -- 特效反馈
            local p = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_invoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
            ParticleManager:ReleaseParticleIndex(p)
        end
    end
end

--------------------------------------------------------------------------------
-- 神杖加成 Modifier (叠加法强)
--------------------------------------------------------------------------------
modifier_invoker_spell_amp_stack = class({})

function modifier_invoker_spell_amp_stack:IsHidden() return false end
function modifier_invoker_spell_amp_stack:IsPurgable() return false end

function modifier_invoker_spell_amp_stack:OnRefresh()
    if not IsServer() then return end
    self:OnCreated() -- 重新读取一次数值
end

function modifier_invoker_spell_amp_stack:OnCreated()
    --self.amp_per_stack = self:GetAbility():GetSpecialValueFor("spell_amp_per_stack")
end

function modifier_invoker_spell_amp_stack:DeclareFunctions()
    return { MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end

function modifier_invoker_spell_amp_stack:GetModifierSpellAmplify_Percentage()
    -- 加载时如果 Ability 没准备好，返回 0 避免闪退
    local ability = self:GetAbility()
    if not ability or ability:IsNull() then return 0 end
    
    local amp = ability:GetSpecialValueFor("spell_amp_per_stack")
    return self:GetStackCount() * amp
end
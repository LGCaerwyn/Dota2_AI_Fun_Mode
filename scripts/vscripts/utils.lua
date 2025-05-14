



--在Fun_BaseGameMode/modifier_Fun_BaseGameMode.lua中实现过
--判断此ID是否属于人类阵营
function is_Human_Team(playerID)
    if not IsServer() then return true end
    local playerTeam = PlayerResource:GetTeam(playerID)
    return __is_Human_Team(playerTeam)
end

--判断此阵营是否是人类阵营
function __is_Human_Team(DOTATeam_t)
    if not IsServer() then return true end
    if (DOTATeam_t == DOTA_TEAM_GOODGUYS and GameRules.Fun_DataTable["hasHumanPlayer_Radiant"] == true) or
       (DOTATeam_t == DOTA_TEAM_BADGUYS and GameRules.Fun_DataTable["hasHumanPlayer_Dire"] == true)
    then
        return true
    end   
    return false
end




--判断是否吃了魔晶

function Has_Aghanims_Shard(nTarget)
    if not IsServer() then return true end
  return  nTarget:HasModifier("modifier_item_aghanims_shard")

end


function Has_ultimate_scepter(nTarget)
    if not IsServer() then return true end
  return  nTarget:HasModifier("modifier_item_ultimate_scepter_consumed")

end


--modifier_item_ultimate_scepter

--modifier_item_ultimate_scepter_consumed


function Once_more_nTarget(caster, Once_more_ability ,nTarget )

    if not IsServer() then return true end
	local	tether = caster:FindAbilityByName(Once_more_ability)   

	caster:SetCursorCastTarget(nTarget)
					    
	tether:OnSpellStart()
						 
	-- body
end



function Once_more_no_nTarget( caster,Once_more_ability , nTarget_Position )

    if not IsServer() then return true end
	local	tether = caster:FindAbilityByName(Once_more_ability)   

	caster:SetCursorPosition(nTarget_Position)
					    
	tether:OnSpellStart()
						 
	-- body
end


--判断指向性技能能否作用于目标
--如果目标身上有技能抵挡属性，返回nil，否则返回目标
--裂魂人的位面空洞返回结果是裂魂人
--技能抵挡相关技能：
--    林肯法球
--    林肯法球（抵挡转移）
--    神镜盾
--    法术反制（敌法师）
--    法术抵挡（肉山）
--    位面空洞（裂魂人）
--    诱敌奇术（森海飞霞）
--    法术抵挡（旧痛苦女王天赋，暂未加入判定）

function HasSpellAbsorb(target)
    if not IsServer() then return nil end	
	if target == nil or target:IsNull() then return nil end

	if target:HasModifier("modifier_item_sphere_target") or
       target:HasModifier("modifier_antimage_counterspell") or
	   target:HasModifier("modifier_hoodwink_decoy_illusion")
	then
	    return nil
	end

	--带有冷却效果的，不这样写，如果没有相关技能，会报错（lua没法短路判断）
	local item_sphere = target:FindItemInInventory("item_sphere")
	local item_mirror_shield = target:FindItemInInventory("item_mirror_shield")
	local ability_roshan_spell_block = target:FindAbilityByName("roshan_spell_block")	
	if item_sphere then
	    if item_sphere:IsCooldownReady() and target:HasModifier("modifier_item_sphere") then
		    return nil
		end
	end
	if item_mirror_shield then
	    if item_mirror_shield:IsCooldownReady() and target:HasModifier("modifier_item_mirror_shield") then
		    return nil
		end
	end
	if ability_roshan_spell_block then
	    if ability_roshan_spell_block:IsCooldownReady() and target:HasModifier("modifier_roshan_spell_block") then
		    return nil
		end
	end

	if target:HasModifier("modifier_spirit_breaker_planar_pocket") then
	    local modifier_temp = target:FindModifierByName("modifier_spirit_breaker_planar_pocket")
		local unit = modifier_temp:GetCaster()
		return HasSpellAbsorb(unit) --裂魂人如果身上有林肯需要再次判断
	end
	return target
end


function IsEntitySafe( entity )
    return entity and IsValidEntity( entity ) and not entity:IsNull() 
end

function IsModifierSafe( entity )
    return entity and not entity:IsNull() 
end

modifier_invoker_random_spell_attack_upgrade_sb2023 = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_invoker_random_spell_attack_upgrade_sb2023:IsHidden()
    return false
end

function modifier_invoker_random_spell_attack_upgrade_sb2023:IsPurgeException()
    return false
end

function modifier_invoker_random_spell_attack_upgrade_sb2023:IsPurgable()
    return false
end

function modifier_invoker_random_spell_attack_upgrade_sb2023:IsPermanent()
    return true
end

function modifier_invoker_random_spell_attack_upgrade_sb2023:GetTexture()
    return "invoker_invoke"
end

function modifier_invoker_random_spell_attack_upgrade_sb2023:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_PROPERTY_TOOLTIP
    }
end

function modifier_invoker_random_spell_attack_upgrade_sb2023:OnCreated(kv)
    self.chance = 13
    
    if IsServer() then
        self.invokerSpellRandomID = RegisterCustomPseudoRandom(self:GetParent())

        self.invokerElements = {
            "invoker_quas",
            "invoker_wex",
            "invoker_exort",
        }

        self.invokerElementsModifier = {
            invoker_quas = "modifier_invoker_quas_instance",
            invoker_wex = "modifier_invoker_wex_instance",
            invoker_exort = "modifier_invoker_exort_instance",
        }

        self.invokerAbilities = {
            {
                ability = "invoker_cold_snap",
                required_elements = {"invoker_quas"},
                behavior = "unit_target"
            },

            -- {
            --     ability = "invoker_ghost_walk",
            --     required_elements = {"invoker_quas", "invoker_wex"},
            --     behavior = "no_target",
            --     skip_dummy_caster = true,
            -- },

            {
                ability = "invoker_ice_wall",
                required_elements = {"invoker_quas", "invoker_exort"},
                behavior = "no_target"
            },
            {
                ability = "invoker_emp",
                required_elements = {"invoker_wex"},
                behavior = "point_target"
            },
            {
                ability = "invoker_tornado",
                required_elements = {"invoker_wex", "invoker_quas"},
                behavior = "point_target"
            },
            {
                ability = "invoker_alacrity",
                required_elements = {"invoker_wex", "invoker_exort"},
                behavior = "self_target",
            },
            {
                ability = "invoker_deafening_blast",
                required_elements = {"invoker_wex", "invoker_exort", "invoker_quas"},
                behavior = "point_target"
            },
            {
                ability = "invoker_sun_strike",
                required_elements = {"invoker_exort"},
                behavior = "point_target"
            },
            {
                ability = "invoker_forge_spirit",
                required_elements = {"invoker_exort", "invoker_quas"},
                behavior = "no_target"
            },
            {
                ability = "invoker_chaos_meteor",
                required_elements = {"invoker_exort", "invoker_wex"},
                behavior = "point_target",
            },
        }

        self.dummyCaster = CreateUnitByName( "npc_dota_base_dummy_caster", self:GetParent():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber() )
        if self.dummyCaster then
            for _, abilityData in pairs(self.invokerAbilities) do
                local abilityName = abilityData["ability"]
                local elementNames = abilityData["required_elements"]

                if elementNames then
                    for _, elementName in pairs(elementNames) do
                        if elementName and not self.dummyCaster:HasAbility(elementName) then
                            local ability = self.dummyCaster:AddAbility(elementName)

                            --set all to level 1, ability values follow invoker abilities
                            if ability then
                                ability:SetLevel(1)
                                ability:RefreshIntrinsicModifier()
                            end
                        end
                    end
                end

                if abilityName and not self.dummyCaster:HasAbility(abilityName) then
                    local ability = self.dummyCaster:AddAbility(abilityName)

                    --set all to level 1, ability values follow invoker abilities
                    if ability then
                        ability:SetLevel(1)
                        ability:RefreshIntrinsicModifier()
                    end
                end
            end

            local parent = self:GetParent()
            local dummyController = self.dummyCaster:FindModifierByName("modifier_dummy_caster_base_controller")

            if dummyController then
                dummyController:SetUnitAbilityFollow(parent)
            else
                local dummyCaster = self.dummyCaster
                
                Timers:CreateTimer(0.5, function ()
                    if not parent or parent:IsNull() or not dummyCaster or dummyCaster:IsNull() then
                        return
                    end

                    local controller = dummyCaster:FindModifierByName("modifier_dummy_caster_base_controller")
                    if controller then
                        controller:SetUnitAbilityFollow(parent)
                    end
                end)
            end
        end

        self.abilityToCast = {}
        self:StartIntervalThink(0.5)
    end
end

function modifier_invoker_random_spell_attack_upgrade_sb2023:OnIntervalThink()
    local abilityToCastData = self.abilityToCast[1]

    if abilityToCastData then
        local target = abilityToCastData["target"]
        local targetPosition = abilityToCastData["target_position"]
        local parentPosition = self:GetParent():GetAbsOrigin()

        local abilityToCast = nil
        local isPointTarget = false
        local isUnitTarget = false
        local isSelfTarget = false

        local invokerAbilities = ShuffledList(self.invokerAbilities)

        for _, abilityData in pairs(invokerAbilities) do
            local randomAbilityName = abilityData["ability"]
            local requiredElements = abilityData["required_elements"]
            local behavior = abilityData["behavior"]

            if behavior == "unit_target" and (not target or target:IsNull() or not target:IsAlive()) then
                goto continue
            end

            if randomAbilityName and requiredElements then
                local ability = self:GetParent():FindAbilityByName(randomAbilityName)
                local dummyCasterAbility = self.dummyCaster:FindAbilityByName(randomAbilityName)

                if ability and ability:GetLevel() > 0 and dummyCasterAbility then
                    local requiredElementsCount = #requiredElements
                    local hasAtLeastOneRequiredModifier = false
                    local ownedElements = 0

                    for _, requiredElement in pairs(requiredElements) do
                        local element = self:GetParent():FindAbilityByName(requiredElement)

                        if element and element:GetLevel() > 0 then
                            ownedElements = ownedElements + 1
                        end

                        local requiredModifier = self.invokerElementsModifier[requiredElement]

                        if requiredModifier and self:GetParent():HasModifier(requiredModifier) then
                            hasAtLeastOneRequiredModifier = true
                        end
                    end

                    if hasAtLeastOneRequiredModifier and ownedElements >= requiredElementsCount then
                        abilityToCast = dummyCasterAbility

                        if behavior == "point_target" then
                            isPointTarget = true
                        elseif behavior == "unit_target" then
                            isUnitTarget = true
                        elseif behavior == "self_target" then
                            isSelfTarget = true
                        end

                        --Ability to cast found: End here
                        break
                    end
                end
            end

            ::continue::
        end

        if abilityToCast then
            local impactPosition = parentPosition + self:GetParent():GetForwardVector() * 50
            local distance = (targetPosition - parentPosition):Length2D()
    
            if distance > 150 then
                local direction = parentPosition - targetPosition
                direction.z = 0
                direction = direction:Normalized()
        
                impactPosition = targetPosition + direction * 100
            end
    
            if isPointTarget then
                self.dummyCaster:SetAbsOrigin(parentPosition)
                self.dummyCaster:SetForwardVector(self:GetParent():GetForwardVector())

                self.dummyCaster:SetCursorCastTarget(nil)
                self.dummyCaster:SetCursorPosition(impactPosition)
            elseif isUnitTarget then
                self.dummyCaster:SetCursorCastTarget(target)
            elseif isSelfTarget then
                self.dummyCaster:SetCursorCastTarget(self:GetParent())
            end
    
            --warning: Casting invoker_alacrity without target will crash game!
            if abilityToCast:GetAbilityName() == "invoker_alacrity" then
                local cursorTarget = self.dummyCaster:GetCursorCastTarget()

                if not cursorTarget or cursorTarget:IsNull() then
                    return
                end
            end

            abilityToCast:OnSpellStart()
        end

        table.remove(self.abilityToCast, 1)
    end
end

function modifier_invoker_random_spell_attack_upgrade_sb2023:OnTooltip()
    return self.chance
end

function modifier_invoker_random_spell_attack_upgrade_sb2023:OnAttack(params)
    if not IsServer() then
        return
    end

    if params.attacker ~= self:GetParent() then
        return
    end

    if self:GetParent():PassivesDisabled() then
        return
    end

    if params.target:IsNull() or params.target:IsBuilding() or params.target:IsOther() or 
        params.target:GetTeamNumber() == self:GetParent():GetTeamNumber() 
    then
        return
    end

    if params.no_attack_cooldown then
        return
    end

    if not self.dummyCaster or self.dummyCaster:IsNull() then
        return
    end

    if self.invokerSpellRandomID and RollCustomPseudoRandom(self.chance, self:GetParent(), self.invokerSpellRandomID, true) then
        table.insert(self.abilityToCast, {
            target = params.target,
            target_position = params.target:GetAbsOrigin(),
            time = GameRules:GetGameTime()
        })
    end
end
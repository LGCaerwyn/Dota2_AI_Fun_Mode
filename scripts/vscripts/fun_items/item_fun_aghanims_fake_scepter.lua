

function item_fun_Aghanims_Fake_Scepter_OnSpellStart( keys )

	local ability = keys.ability
	local caster = keys.caster
	local dur = ability:GetSpecialValueFor("duration")
		
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_fun_Aghanims_Fake_Scepter_transform", {duration = dur})
end

function ModelSwapStart( keys )
	local caster = keys.caster
	local model = keys.model
	
	if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end
	
	if 	caster_ModelScale == nil then 
	
		caster_ModelScale = caster:GetModelScale()
	end
	
	caster.caster_attack = caster:GetAttackCapability()
	
	caster:SetOriginalModel(model)
	
	--caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
end

function ModelSwapEnd( keys )
	local caster = keys.caster

	caster:SetModel(caster.caster_model)
	caster:SetOriginalModel(caster.caster_model)
	--caster:SetAttackCapability(caster.caster_attack)
end

function HideWearables( event )
	local hero = event.caster
	local ability = event.ability

	hero.hiddenWearables = {}
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) 
            table.insert(hero.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function ShowWearables( event )
	local hero = event.caster

	for i,v in pairs(hero.hiddenWearables) do
		v:RemoveEffects(EF_NODRAW)
	end
end




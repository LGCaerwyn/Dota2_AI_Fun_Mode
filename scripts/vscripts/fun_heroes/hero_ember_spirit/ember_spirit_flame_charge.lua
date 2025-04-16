

function ember_spirit_flame_charge( keys )
	-- body
	local ability = keys.ability
	local caster = keys.caster
	local point = ability:GetCursorPosition()
	local origin = caster:GetOrigin()


	local direction = (point-origin)
	--local dist = 500
	local min_dist = ability:GetSpecialValueFor("min_travel_distance") 
	local max_dist = ability:GetSpecialValueFor("max_travel_distance") 
	local damage = ability:GetSpecialValueFor("flame_charge_damage") 
	local radius = ability:GetSpecialValueFor("radius") 
	local duration_interval = ability:GetSpecialValueFor("interval") 
	local duration_interval_esr = duration_interval * 2
	local dist = math.max( math.min( max_dist, direction:Length2D() ), min_dist )
	direction.z = 0
	direction = direction:Normalized()

	local target = GetGroundPosition( origin + direction*dist, nil )
	
	


	

	caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)


	PlayEffects1( origin, target )
			local enemies = FindUnitsInLine(
				caster:GetTeamNumber(),	-- int, your team number
				origin,	-- point, start point
				target,	-- point, end point
				nil,	-- handle, cacheUnit. (not known)
				170,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES	-- int, flag filter
				)

			for _,enemy in pairs(enemies) do
				-- perform attack
					if #enemies ~=0 then
				    local pf = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
                    ParticleManager:SetParticleControl(pf, 0,enemy:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(pf)

                    damagetable = {
					victim = enemy,
					attacker = caster, 
					ability = ability ,
				    damage = damage,
				    damage_type = DAMAGE_TYPE_PHYSICAL,
							}

                    ApplyDamage(damagetable)

	   			 ability:ApplyDataDrivenModifier(caster, enemy, "modifier_stunned",{duration = 0.5})
                   end




				caster:PerformAttack( enemy, true, true, true, false, false, false, true )
			end
	local mainAbilityName	= "ember_spirit_flame_charge"
	local subAbilityName	= "ember_spirit_flame_charge_two"
	caster:SwapAbilities( mainAbilityName, subAbilityName, false, true ) --交换12
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_ember_spirit_flame_charge", {duration = duration_interval})

	if table_esr == nil then

		table_esr = {}

	else
		table_esr = nil
		table_esr = {}
		end
	local ESR=CreateUnitByName("npc_dota_ember_spirit_remnant", origin, true, nil, nil,caster:GetTeamNumber())
	 		--ESR:AddNewModifier(caster, self, "modifier_kill", {duration = 7})
	 		ability:ApplyDataDrivenModifier( caster, ESR, "modifier_kill", {duration = duration_interval_esr})
	 		ability:ApplyDataDrivenModifier( caster, ESR, "modifier_ember_spirit_flame_charge_pf", {duration = duration_interval_esr})
	 		ability:ApplyDataDrivenModifier( caster, ESR, "modifier_ember_spirit_flame_charge_nobar", {duration = duration_interval_esr})
	 		--ESR:AddNewModifier(caster, self, "modifier_fire_remnant_esr", {duration = 7})
	 		--ESR:AddNewModifier(caster, self, "modifier_fire_remnant_hb", {})
	 		table.insert (table_esr,#table_esr+1, ESR)
	FindClearSpaceForUnit( caster, target, true )
	caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
--	ability_SetActivated = caster:FindAbilityByName("ember_spirit_hot_sword_soul")
 --	ability_SetActivated:SetActivated(false)



end

function ember_spirit_flame_charge_OnUpgrade(keys)

	local ability = keys.ability
    local caster = keys.caster
    local A = caster:FindAbilityByName("ember_spirit_flame_charge_two")
    local B = caster:FindAbilityByName("ember_spirit_flame_charge_close")
      A:SetLevel(ability:GetLevel())
      B:SetLevel(ability:GetLevel())
end

function modifier_ember_spirit_flame_charge_OnDestroy( keys )
	-- body
	local ability = keys.ability
	local caster = keys.caster
	local mainAbilityName	= "ember_spirit_flame_charge_two"
	local subAbilityName	= "ember_spirit_flame_charge"


	-- teleport
	caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)

	--caster:AddNewModifier(caster, self, "modifier_activate_fire_remnant", {duration = 7})

	if not caster:HasModifier("modifier_ember_spirit_flame_charge_two") then

		caster:SwapAbilities( mainAbilityName, subAbilityName, false, true )
		table_esr[1]:RemoveSelf()
	end

	local cooldown = ability:GetCooldown(ability:GetLevel() - 1) * caster:GetCooldownReduction()
	ability:StartCooldown(cooldown)

end












function ember_spirit_flame_charge_two( keys )
	local ability = keys.ability
	local caster = keys.caster
	local point = ability:GetCursorPosition()
	local origin = caster:GetOrigin()


	local direction = (point-origin)
	--local dist = 500
	local min_dist = ability:GetSpecialValueFor("min_travel_distance") 
	local max_dist = ability:GetSpecialValueFor("max_travel_distance") 
	local damage = ability:GetSpecialValueFor("flame_charge_damage") 
	local radius = ability:GetSpecialValueFor("radius") 
	local duration_interval = ability:GetSpecialValueFor("interval") 
	local duration_interval_esr = duration_interval * 2
	local dist = math.max( math.min( max_dist, direction:Length2D() ), min_dist )
	direction.z = 0
	direction = direction:Normalized()

	local target = GetGroundPosition( origin + direction*dist, nil )

	
	PlayEffects1( origin, target )

	--caster.caster_attack = caster:GetAttackCapability()

	print( caster:GetAttackCapability())

	caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)



			local enemies = FindUnitsInLine(
				caster:GetTeamNumber(),	-- int, your team number
				origin,	-- point, start point
				target,	-- point, end point
				nil,	-- handle, cacheUnit. (not known)
				170,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES	-- int, flag filter
				)

			for _,enemy in pairs(enemies) do
				-- perform attack

					if #enemies ~=0 then
				    local pf = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
                    ParticleManager:SetParticleControl(pf, 0,enemy:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(pf)

                    damagetable = {
					victim = enemy,
					attacker = caster, 
					ability = ability ,
				    damage = damage,
				    damage_type = DAMAGE_TYPE_PHYSICAL,
							}

                    ApplyDamage(damagetable)

                   end


	   			ability:ApplyDataDrivenModifier(caster, enemy, "modifier_stunned",{duration = 0.5})

				caster:PerformAttack( enemy, true, true, true, false, false, false, true )
			end


	FindClearSpaceForUnit( caster, target, true )


	local mainAbilityName	= "ember_spirit_flame_charge_two"
	local subAbilityName	= "ember_spirit_flame_charge_close"
	caster:SwapAbilities( mainAbilityName, subAbilityName, false, true ) --交换23			
	--caster:AddNewModifier(caster, self, "modifier_activate_fire_remnant_two", {duration = 7})
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_ember_spirit_flame_charge_two", {duration = duration_interval})
	caster:RemoveModifierByName("modifier_ember_spirit_flame_charge")
	caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)

--	end
 --		ability_SetActivated = caster:FindAbilityByName("ember_spirit_hot_sword_soul")
 --	ability_SetActivated:SetActivated(true)

end

function modifier_ember_spirit_flame_charge_two_OnDestroy( keys )
	-- body
	local caster = keys.caster
	local mainAbilityName	= "ember_spirit_flame_charge_close"
	local subAbilityName	= "ember_spirit_flame_charge"
	local subAbilityName_two	= "ember_spirit_flame_charge_two"

	-- teleport
	

	--caster:AddNewModifier(caster, self, "modifier_activate_fire_remnant", {duration = 7}) then

	--if caster:HasModifier("modifier_activate_fire_remnant_two")

		caster:SwapAbilities( mainAbilityName, subAbilityName, false, true )
		caster:SwapAbilities( subAbilityName_two, mainAbilityName, false, false )
		caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
--	end
	local ability = caster:FindAbilityByName("ember_spirit_flame_charge")
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1) * caster:GetCooldownReduction()
	ability:StartCooldown(cooldown)
	table_esr[1]:RemoveSelf()
end


function ember_spirit_flame_charge_close(keys)

	-- body
		local caster = keys.caster
		if table_esr[1] == nil then


			return

		elseif not table_esr[1]:IsAlive() then

			return


		end

		
		local esr_pos = table_esr[1]:GetAbsOrigin()

		FindClearSpaceForUnit( caster, esr_pos, true )
		--caster:SetAbsOrigin(esr_pos)

	local mainAbilityName	= "ember_spirit_flame_charge_close"
	local subAbilityName	= "ember_spirit_flame_charge"
	local subAbilityName_two	= "ember_spirit_flame_charge_two"

--	caster:SwapAbilities( mainAbilityName, subAbilityName, true, true ) 

	--caster:SwapAbilities( subAbilityName_two, mainAbilityName, true, true )

	--table_esr[1]:RemoveSelf()
	caster:RemoveModifierByName("modifier_ember_spirit_flame_charge_two")

end





function PlayEffects1( origin, target )
	-- Get Resources
--	local particle_cast = "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step.vpcf"
	local particle_cast = "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step_fun.vpcf"

	local sound_start = "Hero_VoidSpirit.AstralStep.Start"
	local sound_end = "Hero_VoidSpirit.AstralStep.End"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControl( effect_cast, 0, origin )
	ParticleManager:SetParticleControl( effect_cast, 1, target )
	ParticleManager:ReleaseParticleIndex( effect_cast )
-- ParticleManager:SetParticleControl(effect_cast, 60, Vector(RandomInt(0, 255),RandomInt(0, 255),RandomInt(0, 255)))
--ParticleManager:SetParticleControl(effect_cast, 61, Vector(1,0,0))
	-- Create Sound
	EmitSoundOnLocationWithCaster( origin, sound_start, caster)
	EmitSoundOnLocationWithCaster( target, sound_end, caster )
end



function modifier_ember_spirit_sword_soul_pf(keys)

--print(fireRemnantTB)
local ability = keys.ability
local caster = keys.caster
local target = keys.target
local pos=target:GetAbsOrigin()
local modifier = target:FindModifierByName("modifier_ember_spirit_flame_charge_pf")
local model_esr = {5,6,8,9,15,23,24,25,26,27,37,40,41,82,83,84}
local rand = RandomInt(1,#model_esr)
   if IsServer() then
       
            local pf = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant.vpcf", PATTACH_CUSTOMORIGIN, nil)
            ParticleManager:SetParticleControl(pf, 0, pos)
            ParticleManager:SetParticleControlEnt(pf, 1, caster, PATTACH_CUSTOMORIGIN, "attach_hitloc", pos, false)
           -- ParticleManager:SetParticleControl(pf, 2, Vector(self.act[RandomInt(1, #self.act)], 0, 0))
           ParticleManager:SetParticleControl(pf, 2, Vector(model_esr[rand], 0, 0))
            ParticleManager:SetParticleControl(pf, 60, Vector(RandomInt(0, 255),RandomInt(0, 255),RandomInt(0, 255)))
                ParticleManager:SetParticleControl(pf, 61, Vector(1,0,0))
                modifier:AddParticle(pf, false, false, 4, false, false)
        end


end


function modifier_ember_spirit_sword_soul_pf_OnDeath(keys)


local caster = keys.caster
EmitSoundOn("Hero_EmberSpirit.FireRemnant.Explode", caster)

end



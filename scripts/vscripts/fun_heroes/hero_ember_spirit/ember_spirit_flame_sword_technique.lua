
require('timers')

function ember_spirit_flame_sword_technique(keys)
	-- body

		local ability = keys.ability
		local caster  = keys.caster

		local pos = caster:GetAbsOrigin()

		PlayEffects1( pos, caster)
		EmitSoundOn( "Hero_Disruptor.KineticField", caster )

		--caster:AddNewModifier(caster, self, "modifier_fire_remnant_time", {duration = 3})
		caster:Purge(false, true, false, true, true)

		ProjectileManager:ProjectileDodge(caster)

		ability:ApplyDataDrivenModifier( caster, caster, "modifier_ember_spirit_flame_sword_technique", {duration = 1})
		
		caster:AddNoDraw()	


		local damage = ability:GetSpecialValueFor("flame_sword_technique_damage") 
		local radius = ability:GetSpecialValueFor("radius") 
		GridNav:DestroyTreesAroundPoint(pos, 550, true)



			Timers:CreateTimer(1,function()
			PlayEffects2( pos, caster)
			EmitSoundOn( "Hero_Disruptor.KineticField.End", caster)
			caster:RemoveNoDraw()
						return nil
							end
	               			 )



	targets = FindUnitsInRadius(caster:GetTeamNumber(), pos, caster, radius, 
	            DOTA_UNIT_TARGET_TEAM_ENEMY, 
	            DOTA_UNIT_TARGET_HERO +DOTA_UNIT_TARGET_BASIC , 
	            DOTA_UNIT_TARGET_FLAG_NONE , FIND_ANY_ORDER  , false)


	for k,target in pairs(targets) do
		--print(k,v)
		damagetable = {
		victim = target,
		attacker = caster, 
	    damage = damage,
	    damage_type = DAMAGE_TYPE_MAGICAL,
				}

				ApplyDamage(damagetable)

	end




end



function PlayEffects1( origin, target)
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_disruptor/disruptor_kineticfield_formation.vpcf"

	-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, target )
		ParticleManager:SetParticleControl( effect_cast, 0, origin )
		ParticleManager:SetParticleControl( effect_cast, 1, Vector( 450, 0, 0 ) )
		ParticleManager:SetParticleControl( effect_cast, 2, Vector( 1, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex( effect_cast )
end


function PlayEffects2( origin, target)
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_disruptor/disruptor_kineticfield.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( effect_cast, 0, origin )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( 450, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( 3, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end
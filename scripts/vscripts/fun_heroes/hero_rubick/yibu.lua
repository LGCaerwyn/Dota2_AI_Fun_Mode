require('timers')
require('utils')
function yibu( keys )
if not IsServer() then return end
	local caster = keys.caster
	local ability = keys.ability
	local player = caster:GetPlayerID()
--	local target = keys.target

	if caster:PassivesDisabled() then

		return
	end




	
    local ability_caster = keys.event_ability:GetAbilityName()


    if ability_caster == "rubick_spell_steal" then

    	return
	end

--	print( keys.target )

	local casterPoint = caster:GetAbsOrigin()
--	print(casterPoint)

--	print("施法位置")
	local targetPoint = keys.event_ability:GetCursorPosition()

--	print(keys.event_ability:GetCursorPosition())
--	print("目标位置")


--	print( caster:FindAbilityByName(ability_caster):GetAbilityTargetType() )
--	print( caster:FindAbilityByName(ability_caster):GetAbilityTargetTeam() )
--	print( caster:FindAbilityByName(ability_caster):GetBehavior())

--	print( caster:FindAbilityByName(ability_caster):GetAbilityName() )
	local n = caster:FindAbilityByName(ability_caster):GetBehavior()
--	print(yushu(n))

		---[[
	if keys.target  ~= nil then


	else

	targetPoint = targetPoint

--	print("有目标")

--	print(targetPoint)		

	end
	


--[[
table_rubick = {"skywrath_mage_mystic_flare","sven_storm_bolt_fun",
"rubick_fade_bolt","arc_warden_magnetic_field","arc_warden_flux",
"magnataur_shockwave","magnataur_reverse_polarity","magnataur_skewer",
"enigma_black_hole","tidehunter_ravage","tidehunter_gush","primal_beast_pulverize","pugna_life_drain",


}

--]]
table_rubick = {
"antimage_mana_break","antimage_blink","antimage_counterspell",
"axe_berserkers_call","axe_battle_hunger","axe_counter_helix",
"bane_enfeeble","bane_brain_sap","bane_nightmare",
"bloodseeker_bloodrage","bloodseeker_blood_bath","bloodseeker_thirst",
"crystal_maiden_crystal_nova","crystal_maiden_frostbite","crystal_maiden_brilliance_aura",
"drow_ranger_frost_arrows","drow_ranger_wave_of_silence","drow_ranger_multishot",
"earthshaker_fissure","earthshaker_enchant_totem","earthshaker_aftershock",
"juggernaut_blade_fury","juggernaut_healing_ward","juggernaut_blade_dance",
"mirana_starfall","mirana_arrow","mirana_leap",
"nevermore_shadowraze2","nevermore_dark_lord","nevermore_necromastery",
"morphling_waveform","morphling_adaptive_strike_agi","morphling_adaptive_strike_str",
"phantom_lancer_spirit_lance","phantom_lancer_doppelwalk","phantom_lancer_phantom_edge",
"puck_illusory_orb","puck_waning_rift","puck_phase_shift",
"pudge_meat_hook","pudge_rot","pudge_flesh_heap",
"razor_plasma_field","razor_static_link","razor_unstable_current",
"sandking_burrowstrike","sandking_sand_storm","sandking_caustic_finale",
"storm_spirit_static_remnant","storm_spirit_electric_vortex","storm_spirit_overload",
"sven_storm_bolt","sven_great_cleave","sven_warcry",
"tiny_avalanche","tiny_toss","tiny_tree_grab","vengefulspirit_magic_missile","vengefulspirit_wave_of_terror","vengefulspirit_command_aura",
"windrunner_shackleshot","windrunner_powershot","windrunner_windrun",
"zuus_arc_lightning","zuus_lightning_bolt","zuus_static_field","kunkka_torrent","kunkka_tidebringer","kunkka_x_marks_the_spot",
"lina_dragon_slave","lina_light_strike_array","lina_fiery_soul",
"lich_frost_nova","lich_frost_shield","lich_sinister_gaze",
"lion_impale","lion_voodoo","lion_mana_drain","shadow_shaman_ether_shock","shadow_shaman_voodoo","shadow_shaman_shackles",
"slardar_sprint","slardar_slithereen_crush","slardar_bash","tidehunter_gush","tidehunter_kraken_shell","tidehunter_anchor_smash",
"witch_doctor_paralyzing_cask","witch_doctor_voodoo_restoration","witch_doctor_maledict",
"riki_smoke_screen","riki_blink_strike","riki_tricks_of_the_trade","enigma_malefice","enigma_demonic_conversion","enigma_midnight_pulse",
"tinker_laser","tinker_heat_seeking_missile","tinker_march_of_the_machines","sniper_shrapnel","sniper_headshot","sniper_take_aim",
"necrolyte_death_pulse","necrolyte_sadist","necrolyte_heartstopper_aura","warlock_fatal_bonds","warlock_shadow_word","warlock_upheaval",
"beastmaster_wild_axes","beastmaster_call_of_the_wild_boar","beastmaster_inner_beast","queenofpain_shadow_strike","queenofpain_blink","queenofpain_scream_of_pain",
"venomancer_venomous_gale","venomancer_poison_sting","venomancer_plague_ward",
"faceless_void_time_walk","faceless_void_time_dilation","faceless_void_time_lock",
"skeleton_king_hellfire_blast","skeleton_king_vampiric_aura","skeleton_king_mortal_strike",
"death_prophet_carrion_swarm","death_prophet_silence","death_prophet_spirit_siphon",
"phantom_assassin_stifling_dagger","phantom_assassin_phantom_strike","phantom_assassin_blur",
"pugna_nether_blast","pugna_decrepify","pugna_nether_ward",
"templar_assassin_refraction","templar_assassin_meld","templar_assassin_psi_blades",
"viper_poison_attack","viper_nethertoxin","viper_corrosive_skin",
"luna_lucent_beam","luna_moon_glaive","luna_lunar_blessing",
"dragon_knight_breathe_fire","dragon_knight_dragon_tail","dragon_knight_dragon_blood",
"dazzle_poison_touch","dazzle_shallow_grave","dazzle_shadow_wave",
"rattletrap_battery_assault","rattletrap_power_cogs","rattletrap_rocket_flare",
"leshrac_split_earth","leshrac_diabolic_edict","leshrac_lightning_storm",
"furion_sprout","furion_teleportation","furion_force_of_nature",
"life_stealer_rage","life_stealer_feast","life_stealer_ghoul_frenzy",
"dark_seer_vacuum","dark_seer_ion_shell","dark_seer_surge",
"clinkz_strafe","clinkz_searing_arrows","clinkz_wind_walk",
"omniknight_purification","omniknight_repel","omniknight_degen_aura",
"enchantress_impetus","enchantress_enchant","enchantress_natures_attendants",
"huskar_inner_fire","huskar_burning_spear","huskar_berserkers_blood",
"night_stalker_void","night_stalker_crippling_fear","night_stalker_hunter_in_the_night",
"broodmother_insatiable_hunger","broodmother_spin_web","broodmother_silken_bola",
"bounty_hunter_shuriken_toss","bounty_hunter_jinada","bounty_hunter_wind_walk",
"weaver_the_swarm","weaver_shukuchi","weaver_geminate_attack",
"jakiro_dual_breath","jakiro_ice_path","jakiro_liquid_fire",
"batrider_sticky_napalm","batrider_flamebreak","batrider_firefly",
"chen_penitence","chen_holy_persuasion","chen_divine_favor",
"spectre_spectral_dagger","spectre_desolate","spectre_dispersion",
"doom_bringer_devour","doom_bringer_scorched_earth","doom_bringer_infernal_blade",
"ancient_apparition_cold_feet","ancient_apparition_ice_vortex","ancient_apparition_chilling_touch",
"ursa_earthshock","ursa_overpower","ursa_fury_swipes",
"spirit_breaker_charge_of_darkness","spirit_breaker_bulldoze","spirit_breaker_greater_bash",
"gyrocopter_rocket_barrage","gyrocopter_homing_missile","gyrocopter_flak_cannon",
"alchemist_acid_spray","alchemist_unstable_concoction","alchemist_goblins_greed",

"invoker_chaos_meteor_ad","invoker_deafening_blast_ad","invoker_tornado_ad","invoker_emp_ad",
"invoker_alacrity_ad","invoker_cold_snap_ad","invoker_sun_strike_ad","invoker_forge_spirit_ad",
"invoker_ice_wall_ad","invoker_ghost_walk_ad",

"silencer_curse_of_the_silent","silencer_glaives_of_wisdom","silencer_last_word",
"obsidian_destroyer_arcane_orb","obsidian_destroyer_astral_imprisonment","obsidian_destroyer_equilibrium",
"lycan_summon_wolves","lycan_howl","lycan_feral_impulse",
"brewmaster_thunder_clap","brewmaster_cinder_brew","brewmaster_drunken_brawler",
"shadow_demon_disruption","shadow_demon_soul_catcher","shadow_demon_shadow_poison",
"lone_druid_spirit_bear","lone_druid_spirit_link","lone_druid_savage_roar",
"chaos_knight_chaos_bolt","chaos_knight_reality_rift","chaos_knight_chaos_strike",
"meepo_earthbind","meepo_poof","meepo_ransack",
"treant_natures_grasp","treant_leech_seed","treant_living_armor",
"ogre_magi_fireblast","ogre_magi_ignite","ogre_magi_bloodlust",
"undying_decay","undying_soul_rip","undying_tombstone",
"rubick_telekinesis","rubick_fade_bolt","rubick_arcane_supremacy",
"disruptor_thunder_strike","disruptor_glimpse","disruptor_kinetic_field",
"nyx_assassin_impale","nyx_assassin_mana_burn","nyx_assassin_spiked_carapace",
"naga_siren_mirror_image","naga_siren_ensnare","naga_siren_rip_tide",
"keeper_of_the_light_illuminate","keeper_of_the_light_radiant_bind","keeper_of_the_light_chakra_magic",
"wisp_tether","wisp_spirits","wisp_overcharge",
"visage_grave_chill","visage_soul_assumption","visage_gravekeepers_cloak",
"slark_dark_pact","slark_pounce","slark_essence_shift",
"medusa_split_shot","medusa_mystic_snake","medusa_mana_shield",
"troll_warlord_fervor","troll_warlord_whirling_axes_ranged","troll_warlord_whirling_axes_melee",
"centaur_hoof_stomp","centaur_double_edge","centaur_return",
"magnataur_shockwave","magnataur_empower","magnataur_skewer",
"shredder_whirling_death","shredder_timber_chain","shredder_reactive_armor",
"bristleback_viscous_nasal_goo","bristleback_quill_spray","bristleback_bristleback",
"tusk_ice_shards","tusk_snowball","tusk_tag_team",
"skywrath_mage_arcane_bolt","skywrath_mage_concussive_shot","skywrath_mage_ancient_seal",
"abaddon_death_coil","abaddon_aphotic_shield","abaddon_frostmourne",
"elder_titan_echo_stomp","elder_titan_ancestral_spirit","elder_titan_natural_order",
"legion_commander_overwhelming_odds","legion_commander_press_the_attack","legion_commander_moment_of_courage",
"ember_spirit_searing_chains","ember_spirit_sleight_of_fist","ember_spirit_flame_guard",
"earth_spirit_boulder_smash","earth_spirit_rolling_boulder","earth_spirit_geomagnetic_grip",
"terrorblade_reflection","terrorblade_conjure_image","terrorblade_metamorphosis",
"phoenix_icarus_dive","phoenix_fire_spirits","phoenix_sun_ray",		
"oracle_fortunes_end","oracle_fates_edict","oracle_purifying_flames",
"techies_land_mines","techies_stasis_trap","techies_suicide",
"winter_wyvern_arctic_burn","winter_wyvern_splinter_blast","winter_wyvern_cold_embrace",
"arc_warden_flux","arc_warden_magnetic_field","arc_warden_spark_wraith",
"abyssal_underlord_firestorm","abyssal_underlord_pit_of_malice","abyssal_underlord_atrophy_aura",
"monkey_king_boundless_strike","monkey_king_tree_dance","monkey_king_jingu_mastery",
"pangolier_swashbuckle","pangolier_shield_crash","pangolier_lucky_shot",
"dark_willow_bramble_maze","dark_willow_shadow_realm","dark_willow_cursed_crown",
"grimstroke_dark_artistry","grimstroke_ink_creature","grimstroke_spirit_walk",
"mars_spear","mars_gods_rebuke","mars_bulwark",
"void_spirit_aether_remnant","void_spirit_dissimilate","void_spirit_resonant_pulse",
"snapfire_scatterblast","snapfire_firesnap_cookie","snapfire_lil_shredder",
"hoodwink_acorn_shot","hoodwink_bushwhack","hoodwink_scurry",
"dawnbreaker_fire_wreath","dawnbreaker_celestial_hammer","dawnbreaker_luminosity",
"转转","瞄准","antimage_mana_void","axe_culling_blade","bane_fiends_grip","bloodseeker_rupture","crystal_maiden_freezing_field",
"drow_ranger_marksmanship","earthshaker_echo_slam","juggernaut_omni_slash","mirana_invis","nevermore_requiem",
"morphling_replicate","phantom_lancer_juxtapose","puck_dream_coil","pudge_dismember","razor_eye_of_the_storm",
"sandking_epicenter","storm_spirit_ball_lightning","sven_gods_strength","tiny_grow","vengefulspirit_nether_swap",
"windrunner_focusfire","zuus_thundergods_wrath","kunkka_ghostship","lina_laguna_blade","lich_chain_frost",
"lion_finger_of_death","shadow_shaman_mass_serpent_ward","slardar_amplify_damage","tidehunter_ravage","witch_doctor_death_ward",
"riki_backstab","enigma_black_hole","tinker_rearm","sniper_assassinate","necrolyte_reapers_scythe","warlock_rain_of_chaos","beastmaster_primal_roar",
"queenofpain_sonic_wave","venomancer_poison_nova","faceless_void_chronosphere","skeleton_king_reincarnation",
"death_prophet_exorcism","phantom_assassin_coup_de_grace","pugna_life_drain","templar_assassin_psionic_trap",
"viper_viper_strike","luna_eclipse","dragon_knight_elder_dragon_form","dazzle_bad_juju","rattletrap_hookshot",
"leshrac_pulse_nova","furion_wrath_of_nature","life_stealer_infest","dark_seer_wall_of_replica",
"clinkz_death_pact","omniknight_guardian_angel","enchantress_untouchable","huskar_life_break","night_stalker_darkness",
"broodmother_spawn_spiderlings","bounty_hunter_track","weaver_time_lapse","jakiro_macropyre","batrider_flaming_lasso",
"chen_hand_of_god","spectre_haunt","doom_bringer_doom","ancient_apparition_ice_blast","ursa_enrage","spirit_breaker_nether_strike",
"gyrocopter_call_down","alchemist_chemical_rage","silencer_global_silence","obsidian_destroyer_sanity_eclipse",
"lycan_shapeshift","brewmaster_primal_split","shadow_demon_demonic_purge","lone_druid_true_form","chaos_knight_phantasm",
"meepo_divided_we_stand","treant_overgrowth","ogre_magi_multicast","undying_flesh_golem","rubick_spell_steal",
"disruptor_static_storm","nyx_assassin_vendetta","naga_siren_song_of_the_siren","keeper_of_the_light_spirit_form",
"wisp_relocate","visage_summon_familiars","slark_shadow_dance","medusa_stone_gaze","troll_warlord_battle_trance",
"centaur_stampede","magnataur_reverse_polarity","shredder_chakram","bristleback_warpath","tusk_walrus_punch",
"skywrath_mage_mystic_flare","abaddon_borrowed_time","elder_titan_earth_splitter","legion_commander_duel",
"ember_spirit_fire_remnant","earth_spirit_magnetize","terrorblade_sunder","phoenix_supernova","oracle_false_promise",
"techies_remote_mines","winter_wyvern_winters_curse","arc_warden_tempest_double","abyssal_underlord_dark_rift",
"pangolier_gyroshell","dark_willow_terrorize","grimstroke_soul_chain",
"mars_arena_of_blood","void_spirit_astral_step","snapfire_mortimer_kisses","hoodwink_sharpshooter",
"dawnbreaker_solar_guardian","sven_storm_bolt_fun","monkey_king_huitianmiedi","centaur_zhanzhengjianta",
--"blademaster_bladestorm",

"blademaster_windwalk","blademaster_mirror_image_naga","necrolyte_reapers_scythe_fun",
"elder_titan_earth_splitter_hexagram","huoyanhuxi","juggernaut_omni_slash_fun",
}



--"monkey_king_wukongs_command",






for i=1 ,#table_rubick do

if ability_caster == table_rubick[i] then

	ability_yibu_Name = table_rubick[i]
	
	break

	elseif  i == #table_rubick then

		return
  	end


end


--[[
ability_yibu_Name
	if ability_caster == "skywrath_mage_mystic_flare"  or ability_caster == "法力虚空" then
	

	
	
	else 


	

	
	end
	
	--]]
	
	
	
	
	
    if  true then

		local unit_name = caster:GetUnitName()
		--local origin = target:GetAbsOrigin() + RandomVector(100)
		--local origin = targetPoint + RandomVector(100)
		local origin = casterPoint + RandomVector(250)


		
		local duration = 7
		-- caster:GetOwner()
		--local illusion = CreateUnitByName(unit_name, origin, true, caster, caster:GetOwner(), caster:GetTeamNumber())
		--local illusion = CreateUnitByName(unit_name, casterPoint, true, caster, caster:GetOwner(), caster:GetTeamNumber())

		local illusion = CreateUnitByName(unit_name, origin, true, caster, caster:GetOwner(), caster:GetTeamNumber())
		illusion:SetPlayerID(caster:GetPlayerID())
		illusion:SetControllableByPlayer(player, false)
		ability:ApplyDataDrivenModifier(caster, illusion, "modifier_yibu_buff",{duration = duration})
		

		local casterLevel = caster:GetLevel()
		for i=1,casterLevel-1 do
			illusion:HeroLevelUp(false)
		end

	
		illusion:SetAbilityPoints(0)
		for abilitySlot=0,30 do
			local ability = caster:GetAbilityByIndex(abilitySlot)   --获取施法者的技能
			if ability ~= nil then   --如果有这个技能
				local abilityLevel = ability:GetLevel()  --查找技能等级
				local abilityName = ability:GetAbilityName()  --查找技能名字

				print(abilityName.."技能名字")

				local illusionAbility = illusion:FindAbilityByName(abilityName)  --判断幻象是否自带这个技能

				print(illusionAbility)

				if illusionAbility 	~=  nil then  --如果自带

				illusionAbility:SetLevel(abilityLevel)  --设置等级

			else  illusion:AddAbility(ability_yibu_Name)

			local ability_ill = caster:FindAbilityByName(ability_yibu_Name)

			local abilityLevel_ill = ability_ill:GetLevel()

			local	 illusionAbility_ill = illusion:FindAbilityByName(ability_yibu_Name)
				illusionAbility_ill:SetLevel(abilityLevel_ill)

				end


			end
		end
		illusion:RemoveModifierByName("modifier_yibu")

			--	for k,v in pairs(modifier_illusion) do  
				
			--	end




				for itemSlot=0,5 do
				local item = caster:GetItemInSlot(itemSlot)
				if item ~= nil then
					local itemName = item:GetName()
					print(itemName)
				
					local newItem = CreateItem(itemName, illusion, illusion)
					illusion:AddItem(newItem)
				end
			end
---[[
			if Has_ultimate_scepter(caster) == true then
				print("吃了神杖")
				illusion:AddItemByName("item_ultimate_scepter_2")

			end

			if Has_Aghanims_Shard(caster) == true then
				print("吃了魔晶")
				illusion:AddItemByName("item_aghanims_shard")

			end


--]]
		
		
		illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = -80, incoming_damage = -100 })
	
		-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
		illusion:MakeIllusion()

		Timers:CreateTimer(0.2,function()
		-- This modifier is applied to every illusion to check if they die or expire
	--	ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_illusion_count", {Duration = duration})
	--	illusion:CastAbilityOnPosition(illusion:GetAbsOrigin(),illusion:FindAbilityByName("ability_caster"),caster:GetMainControllingPlayer())
		

		if  keys.target  ~= nil then 

		illusion:CastAbilityOnTarget(keys.target,illusion:FindAbilityByName(ability_yibu_Name),caster:GetMainControllingPlayer())
			
		elseif  yushu(n) == 1 then

		illusion:CastAbilityNoTarget(illusion:FindAbilityByName(ability_yibu_Name),caster:GetMainControllingPlayer())	

		
		else
		illusion:CastAbilityOnPosition(targetPoint,illusion:FindAbilityByName(ability_yibu_Name),caster:GetMainControllingPlayer())
			end
		
			print(type(modifier_illusion))
					end
					)
					
					
					
							Timers:CreateTimer(4,function()
print("结束")
								end
					)	
					
					
					
					
					
					
	end



end

function yushu(n)
	
x = math.floor(n / 2)

x = math.floor(x  / 2)

x = math.fmod(x ,2)

  return x

end

---------------------------------------------------------------------------
function cannot_be_stolen(keys)
     --print("这个技能不可以被拉比克偷取！")
     local caster = keys.caster
     local abilityName = keys.AbilityName --自定义参数
     local ability = caster:FindAbilityByName(abilityName)
     ability:SetStealable(false)
     return
end


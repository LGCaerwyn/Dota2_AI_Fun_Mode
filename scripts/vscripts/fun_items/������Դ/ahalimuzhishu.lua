 

function shengjijinneg( keys )
 	-- body
local tt = {







		npc_dota_hero_necrolyte = {"necrolyte_heartstopper_aura_fun","瘟疫法师","精通的竭心光环"},
		npc_dota_hero_antimage = {"antimage_mana_defend","敌法师","法术反制"},
		npc_dota_hero_magnataur = {"magnataur_dianshao","马格纳斯","精通的颠勺"},
		npc_dota_hero_axe = {"axe_jingtongdefanji","斧王","精通的反击螺旋"},
		npc_dota_hero_doom_bringer = {"doom_bringer_yanren","末日使者","精通的阎刃"},
		npc_dota_hero_monkey_king = {"monkey_king_huitianmiedi","齐天大圣","毁天灭地"},
		npc_dota_hero_enigma = {"heidong","谜团","闪耀黑洞",},
		npc_dota_hero_centaur = {"centaur_zhanzhengjianta","半人马战行者","战争践踏"},
		npc_dota_hero_phantom_assassin = {"永恒的恩赐解脱","幻影刺客","永恒的恩赐解脱"},
		npc_dota_hero_ancient_apparition = {"ancient_apparition_hanshuangzuzhou","远古冰魄","寒霜诅咒"},
		npc_dota_hero_sniper = {"sniper_miaozhun","狙击手","快速装填"},
		npc_dota_hero_brewmaster= {"huoyanhuxi","酒仙","火焰呼吸"},
		--npc_dota_hero_rubick= {"damodaoshi","大魔导师拉比克","大魔导师"},
		npc_dota_hero_zuus= {"tianshenxiafan","宙斯","天神下凡"},
		npc_dota_hero_tiny= {"tiny_qiquwaibiao","小小","崎岖外表"},
		npc_dota_hero_ember_spirit= {"ember_huoyanpohuai","灰烬之灵","炼焰灼"},
		npc_dota_hero_windrunner= {"windrunner_fensanhuoli","风行者","分散火力"},
		npc_dota_hero_kunkka = {"kunkka_ghostship_bamian","昆卡","幽灵舰队"},
		npc_dota_hero_juggernaut = {"juggernaut_jiansheng","主宰","剑圣"},
		npc_dota_hero_lina = {"lina_laguna_blade_fun","莉娜","精通的神灭斩"},
		npc_dota_hero_ogre_magi= {"ogre_magi_jubaogong","食人魔魔法师","聚宝功"},
		npc_dota_hero_lion={"lion_emowushi","莱恩","恶魔巫师"},
		npc_dota_hero_terrorblade={"terrorblade_banpanzhe","恐怖利刃","背叛者的饥渴"},
		npc_dota_hero_primal_beast={"aghsfort_primal_beast_boss_pummel_fun","獸","超究武神霸锤"},
		
		npc_dota_hero_silencer={"silencer_last_word_fun","沉默术士","忏悔之言"},
		npc_dota_hero_legion_commander={"legion_commander_all_duel","军团指挥官","群体决斗"},
		npc_dota_hero_skeleton_king={"skeleton_king_reincarnation_fun","冥魂大帝","永生大帝"},
		npc_dota_hero_drow_ranger ={"drow_ranger_marksmanship_fun","卓尔游侠","银影天仇"},
		
		npc_dota_hero_tinker ={"tinker_death_spin","修补匠","镭射风暴"},
		npc_dota_hero_void_spirit ={"void_spirit_wudizhan","虚无之灵","炁体源流"},
				
		npc_dota_hero_winter_wyvern={"winter_wyvern_zuanshihua","寒冬飞龙","钻石化"},
		npc_dota_hero_mars={"mars_arena_of_blood_fun_3","玛尔斯","超级竞技场"},
		npc_dota_hero_nevermore= {"nevermore_shadowraze_fun","影魔","毁灭三连"},
		npc_dota_hero_rubick= {"rubick_asynchronous_coincide","大魔导师拉比克","异步同位"},
}

 	local caster = keys.caster
	local heroes_name = caster:GetUnitName()
 	local ability = caster:FindAbilityByName(tt[heroes_name][1])
    ability:SetLevel(1)
	
	GameRules:SendCustomMessage(tt[heroes_name][2].. " : " .." 已学习技能： ".."<font color=\"#FF0000\">"..tt[heroes_name][3].."</font> ", DOTA_TEAM_BADGUYS,0)
--	GameRules:SendCustomMessage(tt[heroes_name][2].. " : " .." <font color=\"#FF0000\">"..tt[heroes_name][3].."</font> "..tt[heroes_name][3], DOTA_TEAM_BADGUYS,0)

--			"<h1><font color=\"#5bc0de\">被动：如意</font></h1>"
	--send(	mingzi[GetUnitName()[1]] : 已学习技能 )
	


		


 end
 
 
 
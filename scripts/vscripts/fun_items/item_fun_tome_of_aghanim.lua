 

function item_fun_tome_of_aghanim_OnSpellStart(keys)
    if not IsServer() then return true end
 	local caster = keys.caster
	local ability = keys.ability
	local cost = ability:GetCost()
	local isSuccessful = item_fun_tome_of_aghanim_AbilityUpgrade(caster)
	if not isSuccessful then
	    PlayerResource:ModifyGold(caster:GetPlayerOwnerID(), cost, true, DOTA_ModifyGold_SellItem)  --升级技能失败，返还金钱
	else
	    --caster:EmitSound("hud.equip.agh_scepter")
		local particleName = "particles/econ/events/fall_2021/hero_levelup_fall_2021.vpcf"
		local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle)
	    EmitSoundOnClient("hud.equip.agh_scepter", caster:GetPlayerOwner())

	end
 end

 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 function item_fun_tome_of_aghanim_AbilityUpgrade(hero)

	 if not hero:IsRealHero() then return true end
     local isSuccessful = false --判断是否成功升级技能
	 for _,_hero in pairs(abilities_table) do

	     if _hero["heros_name"] == hero:GetUnitName() then

		     for k,ability_name in pairs(_hero["abilities"]) do

			     local hero_ability = hero:FindAbilityByName(ability_name)

			     if hero_ability and hero_ability:GetLevel() < hero_ability:GetMaxLevel() then	

				     local level = hero_ability:GetLevel() + 1
				     hero_ability:SetLevel(level)
					 --GameRules:SendCustomMessage(_hero["heros_name_cn"].. " : " .." 已学习技能： ".."<font color=\"#FF0000\">".._hero["abilities_name_cn"][k].."</font> ", DOTA_TEAM_BADGUYS,0)
					 GameRules:SendCustomMessage(_hero["heros_name_cn"].. " : " .." 已学习技能： ".."<font color=\"#FF0000\">".._hero["abilities_name_cn"][k].."</font> ", DOTA_TEAM_BADGUYS,0)
					 isSuccessful = true
				 end
			 end
			 break
		 end
	 end
	 return isSuccessful
end

 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
abilities_table = {		
    --1、瘟疫法师
    {   heros_name = "npc_dota_hero_necrolyte",   heros_name_cn = "瘟疫法师",   abilities = {"special_bonus_unique_necrolyte_heartstopper_aura_fun"},    abilities_name_cn = {"精通的竭心光环"}   },
    --2、敌法师
	{   heros_name = "npc_dota_hero_antimage",    heros_name_cn = "敌法师",     abilities = {"antimage_mana_defend"},               abilities_name_cn = {"精通的法术反制"}   },
    --3、马格纳斯
	{   heros_name = "npc_dota_hero_magnataur",   heros_name_cn = "马格纳斯",   abilities = {"magnataur_dianshao"},                 abilities_name_cn = {"精通的颠勺"}       },
    --4、斧王
	{   heros_name = "npc_dota_hero_axe",         heros_name_cn = "斧王",       abilities = {"axe_jingtongdefanji"},                abilities_name_cn = {"精通的反击螺旋"}   },
    --5、末日使者
	{   heros_name = "npc_dota_hero_doom_bringer",heros_name_cn = "末日使者",   abilities = {"doom_bringer_yanren"},                abilities_name_cn = {"精通的阎刃"}       },
	--6、齐天大圣
	{   heros_name = "npc_dota_hero_monkey_king", heros_name_cn = "齐天大圣",   abilities = {"monkey_king_huitianmiedi"},           abilities_name_cn = {"毁天灭地"}         },
    --7、谜团
	{   heros_name = "npc_dota_hero_enigma",      heros_name_cn = "谜团",       abilities = {"heidong"},                            abilities_name_cn = {"闪耀黑洞"}         },
    --8、半人马战行者
	{   heros_name = "npc_dota_hero_centaur",     heros_name_cn = "半人马战行者",abilities = {"centaur_zhanzhengjianta"},           abilities_name_cn = {"战争践踏"}         },
    --9、幻影刺客
	{   heros_name = "npc_dota_hero_phantom_assassin", heros_name_cn = "幻影刺客",abilities = {"永恒的恩赐解脱"},                   abilities_name_cn = {"永恒的恩赐解脱"}   },
    --10、远古冰魄
	{   heros_name = "npc_dota_hero_ancient_apparition",heros_name_cn = "远古冰魄",abilities = {"ancient_apparition_hanshuangzuzhou"},abilities_name_cn = {"寒霜诅咒"}       },
    --11、狙击手
	{   heros_name = "npc_dota_hero_sniper",      heros_name_cn = "狙击手",     abilities = {"special_bonus_unique_sniper_miaozhun"}, abilities_name_cn = {"快速装填"}         },
	--12、酒仙
	{   heros_name = "npc_dota_hero_brewmaster",  heros_name_cn = "酒仙",       abilities = {"huoyanhuxi"},                         abilities_name_cn = {"火焰呼吸"}         },
	--13、宙斯
	{   heros_name = "npc_dota_hero_zuus",        heros_name_cn = "宙斯",       abilities = {"tianshenxiafan"},                     abilities_name_cn = {"天神下凡"}         },
	--14、小小
	{   heros_name = "npc_dota_hero_tiny",        heros_name_cn = "小小",       abilities = {"tiny_qiquwaibiao"},                   abilities_name_cn = {"崎岖外表"}         },
	--15、灰烬之灵
	{   heros_name = "npc_dota_hero_ember_spirit",heros_name_cn = "灰烬之灵",   abilities = {"ember_huoyanpohuai"},                 abilities_name_cn = {"炼焰灼"}           },
	--16、风行者
	{   heros_name = "npc_dota_hero_windrunner",  heros_name_cn = "风行者",     abilities = {"windrunner_fensanhuoli"},             abilities_name_cn = {"分散火力"}         },
	--17、昆卡
	{   heros_name = "npc_dota_hero_kunkka",      heros_name_cn = "昆卡",       abilities = {"kunkka_ghostship_fun"},               abilities_name_cn = {"搁浅之地"}         },
	--18、主宰
	{   heros_name = "npc_dota_hero_juggernaut",  heros_name_cn = "主宰",       abilities = {"juggernaut_omni_slash_fun"},               abilities_name_cn = {"无敌斩"}             },
	--juggernaut_omni_slash_fun
	--19、莉娜
	{   heros_name = "npc_dota_hero_lina",        heros_name_cn = "莉娜",       abilities = {"special_bonus_unique_lina_laguna_blade_fun"},              abilities_name_cn = {"重破斩"}           },
	--20、食人魔法师
	{   heros_name = "npc_dota_hero_ogre_magi",   heros_name_cn = "食人魔法师", abilities = {"ogre_magi_jubaogong"},                abilities_name_cn = {"聚宝功"}           },
	--21、恶魔巫师
	{   heros_name = "npc_dota_hero_lion",        heros_name_cn = "恶魔巫师",   abilities = {"lion_emowushi"},                      abilities_name_cn = {"恶魔巫师"}         },
	--22、恐怖利刃
    {   heros_name = "npc_dota_hero_terrorblade", heros_name_cn = "恐怖利刃",   abilities = {"terrorblade_Metamorphosis_fun", "terrorblade_beipanzhe"},      abilities_name_cn = {"恶魔变形", "背叛者的饥渴"} },
	--23、獸
	{   heros_name = "npc_dota_hero_primal_beast",heros_name_cn = "獸",         abilities = {"aghsfort_primal_beast_boss_pummel_fun"},abilities_name_cn = {"超究武神霸锤"}   },
	--24、沉默术士
	{   heros_name = "npc_dota_hero_silencer",    heros_name_cn = "沉默术士",   abilities = {"silencer_last_word_fun"},             abilities_name_cn = {"忏悔之言"}         },
	--25、军团指挥官
	{   heros_name = "npc_dota_hero_legion_commander",heros_name_cn = "军团指挥官",abilities = {"legion_commander_all_duel"},       abilities_name_cn = {"群体决斗"}         },
	--26、冥魂大帝
	{   heros_name = "npc_dota_hero_skeleton_king",heros_name_cn = "冥魂大帝",  abilities = {"skeleton_king_reincarnation_fun"},    abilities_name_cn = {"永生大帝"}         },
	--27、卓尔游侠
	{   heros_name = "npc_dota_hero_drow_ranger", heros_name_cn = "卓尔游侠",   abilities = {"drow_ranger_marksmanship_fun"},       abilities_name_cn = {"银影天仇"}         },
	--28、修补匠
  	{   heros_name = "npc_dota_hero_tinker",      heros_name_cn = "修补匠",     abilities = {"tinker_death_spin"},                  abilities_name_cn = {"镭射风暴"}         },  
	--29、虚无之灵
	{   heros_name = "npc_dota_hero_void_spirit", heros_name_cn = "虚无之灵",   abilities = {"void_spirit_wuyingzhan"},               abilities_name_cn = {"炁体源流"}         },
	--30、寒冬飞龙
	{   heros_name = "npc_dota_hero_winter_wyvern",heros_name_cn = "寒冬飞龙",  abilities = {"winter_wyvern_zuanshihua"},           abilities_name_cn = {"钻石化"}           },
	--31、玛尔斯
	{   heros_name = "npc_dota_hero_mars",        heros_name_cn = "玛尔斯",     abilities = {"mars_arena_of_blood_fun_3"},          abilities_name_cn = {"超级竞技场"}       },
	--32、影魔
	{   heros_name = "npc_dota_hero_nevermore",   heros_name_cn = "影魔",       abilities = {"nevermore_shadowraze_fun"},           abilities_name_cn = {"毁灭三连"}         },
	--33、拉比克
	{   heros_name = "npc_dota_hero_rubick",      heros_name_cn = "拉比克",     abilities = {"rubick_asynchronous_coincide"},       abilities_name_cn = {"异步同位"}         },
	--34、变体精灵
	{   heros_name = "npc_dota_hero_morphling",   heros_name_cn = "变体精灵",   abilities = {"morphling_tidal_wave_fun"},           abilities_name_cn = {"波浪打击"}         },
    --35、艾欧
	{   heros_name = "npc_dota_hero_wisp",        heros_name_cn = "艾欧",       abilities = {"wisp_overcharge_fun"},                abilities_name_cn = {"仁爱之友"}         },
    --36、美杜莎
	{   heros_name = "npc_dota_hero_medusa",      heros_name_cn = "美杜莎",     abilities = {"medusa_absorb_mana"},                 abilities_name_cn = {"法力吮吸"}         },
	--37、上古巨神
	{   heros_name = "npc_dota_hero_elder_titan", heros_name_cn = "上古巨神",   abilities = {"elder_titan_earth_splitter_hexagram"},abilities_name_cn = {"六芒裂地沟壑"}     },
	--38、天穹守望者
	{   heros_name = "npc_dota_hero_arc_warden",  heros_name_cn = "天穹守望者", abilities = {"arc_warden_rune_forge"},              abilities_name_cn = {"神符铸就"}         },
	--39、钢背兽
	{   heros_name = "npc_dota_hero_bristleback", heros_name_cn = "钢背兽",     abilities = {"bristleback_back"},                   abilities_name_cn = {"反击针刺"}         },
	--40、祈求者
	{   heros_name = "npc_dota_hero_invoker",     heros_name_cn = "祈求者",     abilities = {"invoker_again"},                      abilities_name_cn = {"祈艺大师"}         },


		--npc_dota_hero_rubick= {"damodaoshi","大魔导师拉比克","大魔导师"},
		--npc_dota_hero_lich = {"lich_chain_frost_fun","巫妖","连环霜冻（二）"},
		--npc_dota_hero_disruptor ={"far_seer_earthquake","干扰者","地震"}, 


}
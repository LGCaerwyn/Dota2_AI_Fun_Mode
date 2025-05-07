------------------------------------------------------------------------------------------------------------
--人类玩家的建筑数据，0代表不修改
building_Data_for_player = {

        fort = {
            HP = 10000,
            MP = 0,
            Armor = 48,
            Resistance = 0,
            HPRegen = 75,
            MPRegen = 0,
            Abilities = {"Fun_Borrowed_Time_v2","Fun_Nian_Blocker","Fun_Illusion_Breaker"}
        },

        tower1_top = {
            HP = 0,
            MP = 0,
            Armor = 0,
            Resistance = 0,
            HPRegen = 3,
            MPRegen = 0,
            Abilities = {"Fun_Guard_Aura","Fun_Degen_Aura","Fun_Reactive_Armor_Lv1"}
        },

        tower1_mid = {
            HP = 0,
            MP = 0,
            Armor = 0,
            Resistance = 0,
            HPRegen = 3,
            MPRegen = 0,
            Abilities = {"Fun_Support_Aura","Fun_Guard_Aura_v2"}
        },

        tower1_bot = {
            HP = 0,
            MP = 0,
            Armor = 0,
            Resistance = 0,
            HPRegen = 3,
            MPRegen = 0,
            Abilities = {"Fun_True_Sight_Eyes","Fun_Prospecting_Aura",}
        },

        tower2 = {
            HP = 0,
            MP = 0,
            Armor = 0,
            Resistance = 0,
            HPRegen = 5,
            MPRegen = 0,
            Abilities = {}
        },

        tower3 = {
            HP = 0,
            MP = 0,
            Armor = 0,
            Resistance = 0,
            HPRegen = 8,
            MPRegen = 0,
            Abilities = {"Fun_Guard_Roshan_Human","Fun_Illusion_Breaker"}
        },

        tower4 = {
            HP = 0,
            MP = 0,
            Armor = 0,
            Resistance = 0,
            HPRegen = 15,
            MPRegen = 0,
            Abilities = {"Fun_Expecto_Patronum","Fun_Reactive_Armor_Lv2","Fun_Illusion_Breaker"}
        },

        fountain = {
            HP = 0,
            MP = 0,
            Armor = 0,
            Resistance = 0,
            HPRegen = 0,
            MPRegen = 0,
            Abilities = {"Fun_Disillusion"}
        },
        rax = {
            HP = 0,
            MP = 0,
            Armor = 0,
            Resistance = 0,
            HPRegen = 0,
            MPRegen = 0,
            Abilities = {"Fun_Reactive_Armor_Lv2","Fun_Illusion_Breaker"}
        },
}

------------------------------------------------------------------------------------------------------------
--AI玩家的建筑数据，0代表不修改
building_Data_for_AI = {

        fort = {
            HP = 10000,
            MP = 0,
            Armor = 80,
            Resistance = 0,
            HPRegen = 110,
            MPRegen = 0,
            Abilities = {"Fun_Borrowed_Time_v2","Fun_Nian_Blocker","Fun_Primal_Beast_in_Cage"}
        },

        tower1_top = {
            HP = 0,
            MP = 0,
            Armor = 0,
            Resistance = 0,
            HPRegen = 5,
            MPRegen = 0,
            Abilities = {}
        },

        tower1_mid = {
            HP = 0,
            MP = 0,
            Armor = 0,
            Resistance = 0,
            HPRegen = 5,
            MPRegen = 0,
            Abilities = {}
        },

        tower1_bot = {
            HP = 0,
            MP = 0,
            Armor = 0,
            Resistance = 0,
            HPRegen = 5,
            MPRegen = 0,
            Abilities = {}
        },

        tower2 = {
            HP = 0,
            MP = 0,
            Armor = 0,
            Resistance = 0,
            HPRegen = 10,
            MPRegen = 0,
            Abilities = {}
        },

        tower3 = {
            HP = 0,
            MP = 0,
            Armor = 0,
            Resistance = 0,
            HPRegen = 15,
            MPRegen = 0,
            Abilities = {"Fun_Guard_Roshan_AI","black_dragon_splash_attack"}
        },

        tower4 = {
            HP = 0,
            MP = 0,
            Armor = 0,
            Resistance = 0,
            HPRegen = 30,
            MPRegen = 0,
            Abilities = {"Fun_NianShou_from_Hell","Fun_Lightning_Power"}
        },

        fountain = {
            HP = 0,
            MP = 0,
            Armor = 0,
            Resistance = 0,
            HPRegen = 0,
            MPRegen = 0,
            Abilities = {"Fun_Disillusion"}
        }
}
------------------------------------------------------------------------------------------------------------
--AI玩家的超级兵数据，0代表不修改
MegaCreeps_Data_for_AI = {

        melee_upgraded_mega = {
            HP = 1400,
            MP = 0,
            Armor = 6,
            Resistance = 35,
            HPRegen = 0,
            MPRegen = 0,
            BaseDamageMin = 72,
            BaseDamageMax = 88,
            ModelScale = 1.4,
            Abilities = {}
        },

        ranged_upgraded_mega = {
            HP = 1275,
            MP = 0,
            Armor = 2,
            Resistance = 15,
            HPRegen = 0,
            MPRegen = 0,
            BaseDamageMin = 82,
            BaseDamageMax = 92,
            ModelScale = 1.4,
            Abilities = {}
        },

        flagbearer_upgraded_mega = {
            HP = 1400,
            MP = 0,
            Armor = 6,
            Resistance = 50,
            HPRegen = 0,
            MPRegen = 0,
            BaseDamageMin = 72,
            BaseDamageMax = 88,
            ModelScale = 1.4,
            Abilities = {}
        },

        siege_upgraded_mega = {
            HP = 1300,
            MP = 0,
            Armor = 0,
            Resistance = 95,
            HPRegen = 0,
            MPRegen = 0,
            BaseDamageMin = 150,
            BaseDamageMax = 200,
            ModelScale = 1.0,
            Abilities = {}
        }

}
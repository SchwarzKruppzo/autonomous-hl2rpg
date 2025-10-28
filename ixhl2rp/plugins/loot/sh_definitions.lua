ix.LootContainer:Add("garbage", { -- garbage tier 0
	Name = "Мусор",
	Description = "",
	Model = {
		"models/props_junk/garbage128_composite001a.mdl",
		"models/props_junk/garbage128_composite001b.mdl",
		"models/props_junk/TrashCluster01a.mdl",
		"models/props_junk/garbage128_composite001d.mdl"
	},

	SearchText = "Поиск мусора...",
	SearchTime = 5,

	NotSolid = true,
	Hide = true,
	Respawn = 1000,
	Tool = false,

	OnSuccess = function(client)
		hook.Run("OnPlayerClearGarbage", client, client:GetCharacter())
	end,

	LootGroup = {
		garbage = {
			{ id = "junk_paintcan", weight = 5 },
			{ id = "junk_shoe", weight = 20 },
			{ id = "junk_bombastick", weight = 8 },
			{ id = "junk_drawerchunk", weight = 5 },
			{ id = "junk_doll", weight = 50 },
			{ id = "junk_pot", weight = 5 },
			{ id = "junk_briefcase", weight = 6 },
			{ id = "junk_zippo", weight = 50 },
			{ id = "junk_rolex", weight = 50 },
			{ id = "junk_calculator", weight = 50 },
			{ id = "junk_robustin", weight = 8 },
			{ id = "canned_dogfood", weight = 25 },
			{ id = "dirty_water", weight = 25 },
			{ id = "empty_can", weight = 50 },
			{ id = "junk_plasticcrate", weight = 6 },
			{ id = "junk_plasticbucket", weight = 6 },
			{ id = "empty_chinese_takeout", weight = 50 },
			{ id = "empty_carton", weight = 50 },
			{ id = "empty_tin_can", weight = 50 },
			{ id = "empty_plastic_can", weight = 50 },
			{ id = "empty_plastic_bottle", weight = 50 },
			{ id = "empty_glass_bottle", weight = 50 },
			{ id = "empty_jug", weight = 50 },
			{ id = "junk_cwuturtle", weight = 50 },
			{ id = "junk_clothes", weight = 50 },
			{ id = "junk_gloves", weight = 50 },
			{ id = "junk_metalpot", weight = 6 },
			{ id = "junk_metalbucket", weight = 6 },
			{ id = "junk_cid", weight = 50 },
			{ id = "junk_newspaper", weight = 50 },
			{ id = "junk_tire", weight = 3 },
			{ id = "junk_huladoll", weight = 50 },
			{ id = "box_of_needles", weight = 50 },
			{ id = "mat_oil", weight = 50 },
			{ id = "box_of_nails", weight = 50 },
			{ id = "mat_cloth", weight = 50 },
			{ id = "chain", weight = 50 },
			{ id = "electro_circuit", weight = 50 },
			{ id = "mat_wood", weight = 50 },
			{ id = "prewar_canned_food", weight = 14 },
			{ id = "old_fast_food", weight = 14 },
			{ id = "baked_beans", weight = 14 },
			{ id = "olive_oil", weight = 14 },
			{ id = "old_soda", weight = 14 },
			{ id = "spoiled_whiskey", weight = 14 },
			{ id = "spoiled_beer", weight = 14 },
			{ id = "junk_muffler", weight = 2 },
			{ id = "junk_woodchair", weight = 6 }
		}
	},
	Loot = {
		{ lootGroup = "garbage", min = 1, max = 3 },
	}
})

ix.LootContainer:Add("trash_cluster", {  -- garbage tier 1
	Name = "Мешок с мусором",
	Description = "",
	Model = "models/props_junk/trashcluster01a_corner.mdl",

	OpenSound = "foley/industrial/disassemble_crate1.mp3",
	CloseSound = "willardnetworks/inventory/inv_move4.mp3",

	SearchText = "Поиск мусора...",
	SearchTime = 5,

	Hide = false,
	Respawn = 3600,
	Tool = false,

	LootGroup = {
		small = {
			{ id = "junk_shoe", weight = 60 },
			{ id = "junk_vcr", weight = 10 },
			{ id = "junk_doll", weight = 50 },
			{ id = "junk_pot", weight = 50 },
			{ id = "junk_zippo", weight = 50 },
			{ id = "junk_rolex", weight = 50 },
			{ id = "junk_calculator", weight = 50 },
			{ id = "junk_keyboard", weight = 40 },
			{ id = "junk_lantern", weight = 10 },
			{ id = "junk_clock", weight = 50 },
			{ id = "junk_deskfan", weight = 50 },
			{ id = "junk_cardoor", weight = 5 },
			{ id = "junk_circuit", weight = 50 },
			{ id = "junk_chair", weight = 30 },
			{ id = "junk_plasticcrate", weight = 50 },
			{ id = "junk_plasticbucket", weight = 50 },
			{ id = "junk_suitcase", weight = 50 },
			{ id = "empty_chinese_takeout", weight = 60 },
			{ id = "empty_carton", weight = 60 },
			{ id = "empty_tin_can", weight = 60 },
			{ id = "empty_plastic_can", weight = 60 },
			{ id = "empty_plastic_bottle", weight = 50 },
			{ id = "empty_glass_bottle", weight = 60 },
			{ id = "canned_dogfood", weight = 35 },
			{ id = "dirty_water", weight = 35 },
			{ id = "junk_pipe", weight = 50 },
			{ id = "junk_metalbucket", weight = 50 },
			{ id = "junk_metalpot", weight = 50 },
			{ id = "junk_briefcase", weight = 50 },
			{ id = "junk_citizenradio", weight = 20 },
			{ id = "junk_clothes", weight = 50 },
			{ id = "junk_cid", weight = 50 },
			{ id = "junk_cwuturtle", weight = 50 },
			{ id = "mat_varnish", weight = 50 },
			{ id = "junk_tv", weight = 20 },
			{ id = "junk_newspaper", weight = 50 },
			{ id = "junk_huladoll", weight = 50 },
			{ id = "junk_gurevich", weight = 50 },
			{ id = "junk_pot2", weight = 50 },
			{ id = "junk_metalbucket2", weight = 50 },
			{ id = "empty_ration", weight = 50 },
			{ id = "junk_audiosystem", weight = 5 },
			{ id = "junk_muffler", weight = 5 },
			{ id = "chain", weight = 50 },
			{ id = "metal_armature", weight = 20 },
			{ id = "junk_gloves", weight = 60 }
		}
	},
	Loot = {
		{ lootGroup = "small", min = 1, max = 3 },
	}
})

ix.LootContainer:Add("dumpster", { -- garbage tier 2
	Name = "Металлический бак",
	Description = "",
	Model = "models/props_junk/trashdumpster01a.mdl",

	OpenSound = "foley/containers/metal_dumpster_open.mp3",
	CloseSound = "physics/metal/metal_grate_impact_hard2.wav",
	SearchTime = 5,

	Hide = false,
	Respawn = 3600,
	Tool = false,

	LootGroup = {
		big = {
			{ id = "junk_axel", weight = 2 },
			{ id = "junk_muffler", weight = 2 },
			{ id = "junk_carbattery", weight = 5 },
			{ id = "junk_monitor", weight = 5 },
			{ id = "junk_woodchair", weight = 5 },
			{ id = "junk_cupboard", weight = 5 },
			{ id = "junk_vcr", weight = 5 },
			{ id = "junk_engine", weight = 1 },
			{ id = "junk_cardoor", weight = 5 },
			{ id = "junk_metalgascan", weight = 5 },
			{ id = "junk_audiosystem", weight = 5 },
			{ id = "junk_suitcase", weight = 5 },
			{ id = "junk_radiator", weight = 3 },
			{ id = "junk_harddrive", weight = 5 },
			{ id = "junk_citizenradio", weight = 5 },
			{ id = "junk_tv", weight = 5 },
			{ id = "junk_pipe", weight = 5 },
			{ id = "junk_chair", weight = 5 },
			{ id = "junk_lamp", weight = 5 },
			{ id = "junk_drawerchunk", weight = 5 },
			{ id = "junk_bicycle", weight = 1 }
		},
		small = {
			{ id = "junk_tire", weight = 50 },
			{ id = "junk_clothes", weight = 70, min = 1, max = 2 },
			{ id = "junk_gloves", weight = 70, min = 1, max = 2 },
			{ id = "junk_circuit", weight = 40 },
			{ id = "junk_bombastick", weight = 40 },
			{ id = "junk_robustin", weight = 40 },
			{ id = "mat_varnish", weight = 40 },
			{ id = "junk_paintcan", weight = 40 },
			{ id = "junk_pot", weight = 40 },
			{ id = "junk_zippo", weight = 40 },
			{ id = "junk_lantern", weight = 40 },
			{ id = "junk_desklamp", weight = 40 },
			{ id = "junk_briefcase", weight = 30 },
			{ id = "junk_deskfan", weight = 40 },
			{ id = "junk_plasticcrate", weight = 40 },
			{ id = "canned_dogfood", weight = 35 },
			{ id = "dirty_water", weight = 35 },
			{ id = "junk_plasticbucket", weight = 40 },
			{ id = "junk_shoe", weight = 70, min = 1, max = 2 },
			{ id = "junk_clock", weight = 40 },
			{ id = "junk_clock2", weight = 40 },
			{ id = "junk_metalbucket", weight = 40 },
			{ id = "junk_metalpot", weight = 40 },
			{ id = "junk_metalbucket2", weight = 40 },
			{ id = "junk_newspaper", weight = 60 },
			{ id = "empty_can", weight = 60, min = 0, max = 2 },
			{ id = "empty_chinese_takeout", weight = 60, min = 0, max = 2 },
			{ id = "empty_carton", weight = 60, min = 0, max = 2 },
			{ id = "empty_tin_can", weight = 60, min = 0, max = 2 },
			{ id = "empty_plastic_can", weight = 60, min = 0, max = 2 },
			{ id = "empty_plastic_bottle", weight = 60, min = 0, max = 2 },
			{ id = "empty_glass_bottle", weight = 60, min = 0, max = 2 },
			{ id = "empty_jug", weight = 60, min = 0, max = 2 },
			{ id = "empty_ration", weight = 60, min = 0, max = 2 },
			{ id = "junk_propane", weight = 20 },
			{ id = "junk_cwuturtle", weight = 60 },
			{ id = "junk_pot2", weight = 60 },
			{ id = "junk_gurevich", weight = 20 },
			{ id = "junk_huladoll", weight = 30 }
		}
	},
	Loot = {
		{ lootGroup = "big", min = 1, max = 2 },
		{ lootGroup = "small", min = 1, max = 2 },
	}
})

ix.LootContainer:Add("crate", { -- rnp - utility
	Name = "Деревянный ящик",
	Description = "",
	Model = "models/props/de_nuke/crate_extrasmall.mdl",

	CrackSound = "physics/wood/wood_crate_break4.wav",
	OpenSound = "physics/wood/wood_box_impact_soft1.wav",
	CloseSound = "physics/wood/wood_box_impact_soft3.wav",
	SearchTime = 5,

	NoRate = true,

	Locked = true,
	Hide = false,
	Respawn = 3600,
	Tool = "crowbar",
	ToolDamage = 20,

	LootGroup = {
		crate = {
			{ id = "mat_cloth", weight = 50 },
			{ id = "mat_plastic", weight = 30 },
			{ id = "mat_wood", weight = 50 },
			{ id = "mat_leather", weight = 70 },
			{ id = "mat_resine", weight = 30 },
			{ id = "metal_scrap", weight = 50 },
			{ id = "metal_armature", weight = 20 },
			{ id = "electro_circuit", weight = 30 },
			{ id = "electro_battery", weight = 60 },
			{ id = "mat_varnish", weight = 50 },
			{ id = "metal_reclaimed", weight = 10, min = 1, max = 2 },
			{ id = "mat_cloth_reclaimed", weight = 15, min = 1, max = 2 },
			{ id = "electro_reclaimed", weight = 10, min = 1, max = 2 },
			{ id = "box_of_nails", weight = 50, min = 1, max = 2 },
			{ id = "box_of_needles", weight = 50, min = 2, max = 3 },
			{ id = "mat_oil", weight = 50, min = 1, max = 2 },
			{ id = "chain", weight = 50, min = 1, max = 2 },
			{ id = "mat_screws", weight = 50, min = 2, max = 4 },
			{ id = "mat_nuts", weight = 50, min = 2, max = 4 },
			{ id = "junk_radio", weight = 10 },
			{ id = "junk_citizenradio", weight = 10 },
			{ id = "junk_geiger", weight = 10 },
			{ id = "junk_vcr", weight = 10 },
			{ id = "junk_circuit", weight = 10 },
			{ id = "junk_robustin", weight = 60 },
			{ id = "junk_bombastick", weight = 60 },
			{ id = "junk_woodchair", weight = 5 },
			{ id = "junk_lamp", weight = 5 },
			{ id = "junk_cupboard", weight = 5 },
			{ id = "junk_engine", weight = 5 },
			{ id = "junk_carbattery", weight = 5 },
			{ id = "junk_metalgascan", weight = 5 },
			{ id = "junk_suitcase", weight = 5 },
			{ id = "junk_cardoor", weight = 5 },
			{ id = "junk_radiator", weight = 5 },
			{ id = "junk_monitor", weight = 5 },
			{ id = "junk_tv", weight = 5 },
			{ id = "tool_scissors", weight = 2 },
			{ id = "tool_screw", weight = 2 },
			{ id = "tool_hammer", weight = 2 }
		}
	},
	Loot = {
		{ lootGroup = "crate", count = 4 },
	}
})

ix.LootContainer:Add("food_box", { -- rnp - food package
	Name = "Коробка с припасами",
	Description = "",
	Model = "models/hls/alyxports/cardboard_box_1.mdl",

	OpenSound = "foley/containers/cardboardbox_contents_01.wav",
	CloseSound = "foley/containers/cardboardbox_contents_03.wav",
	SearchTime = 2,

	Hide = false,
	Respawn = 3600,
	Tool = false,

	LootGroup = {
		crate = {
			{ id = "prewar_canned_food", weight = 50 },
			{ id = "baked_beans", weight = 50 },
			{ id = "union_branded_instant_potatoes", weight = 50 },
			{ id = "union_branded_chinese_takeout", weight = 50 },
			{ id = "donuts", weight = 50 },
			{ id = "union_branded_bran_flakes", weight = 50 },
			{ id = "old_fast_food", weight = 50 },
			{ id = "union_branded_bag_of_peanuts", weight = 50 },
			{ id = "union_branded_crisps", weight = 50 },
			{ id = "salted_ringlets", weight = 50 },
			{ id = "cook_coffee", weight = 30 },
			{ id = "cook_egg", weight = 30 },
			{ id = "cook_flour", weight = 30 },
			{ id = "cook_spices", weight = 30 },
			{ id = "cook_sugar", weight = 30 },
			{ id = "cook_tea", weight = 30 },
			{ id = "cook_yeast", weight = 30 },
			{ id = "sweet_ringlets", weight = 50 },
			{ id = "union_branded_sardines", weight = 50 },
			{ id = "cola", weight = 50 },
			{ id = "old_soda", weight = 50 },
			{ id = "olive_oil", weight = 50 },
			{ id = "spoiled_whiskey", weight = 50 },
			{ id = "spoiled_beer", weight = 50 },
			{ id = "breens_water", weight = 50 },
			{ id = "canned_beef", weight = 50 },
			{ id = "canned_crab", weight = 50 },
			{ id = "canned_crisp", weight = 50 },
			{ id = "canned_dogfood", weight = 50 },
			{ id = "canned_fish", weight = 50 },
			{ id = "canned_ham", weight = 50 },
			{ id = "canned_peas", weight = 50 },
			{ id = "canned_squash", weight = 50 },
			{ id = "canned_veg_soup", weight = 50 },
			{ id = "canned_water", weight = 50 },
			{ id = "dirty_water", weight = 30 },
			{ id = "ration_tier_0", weight = 15 },
			{ id = "filter_standard", weight = 10 },
			{ id = "filter_medium", weight = 10 },
			{ id = "junk_cwuturtle", weight = 50 },
			{ id = "junk_metalpot", weight = 10 },
			{ id = "junk_pot2", weight = 10 },
			{ id = "junk_clothes", weight = 20 },
			{ id = "junk_gloves", weight = 15 },
			{ id = "junk_newspaper", weight = 5 },
			{ id = "junk_doll", weight = 5 },
			{ id = "junk_rolex", weight = 5 },
			{ id = "junk_bombastick", weight = 20 },
			{ id = "junk_robustin", weight = 20 },
			{ id = "junk_huladoll", weight = 10 },
		}
	},
	Loot = {
		{ lootGroup = "crate", min = 1, max = 4 },
	}
})

ix.LootContainer:Add("medical_box", { -- rnp - medical package
	Name = "Коробка с припасами (синяя)",
	Description = "",
	Model = "models/hls/alyxports/cardboard_box_3.mdl",

	OpenSound = "foley/containers/cardboardbox_contents_01.wav",
	CloseSound = "foley/containers/cardboardbox_contents_03.wav",
	SearchTime = 2,

	Hide = false,
	Respawn = 3600,
	Tool = false,

	LootGroup = {
		item1 = {
			{ id = "box_of_needles", weight = 60 },
			{ id = "empty_syringe", weight = 50 },
			{ id = "bottle_of_alcohol", weight = 60 },
			{ id = "mat_cloth", weight = 50 },
			{ id = "bandage", weight = 80 },
			{ id = "painkiller", weight = 80 },
			{ id = "healthvial", weight = 30 },
			{ id = "union_branded_orange", weight = 50 },
			{ id = "union_branded_melon", weight = 50 },
			{ id = "union_branded_banana", weight = 50 },
			{ id = "union_branded_bread", weight = 50 },
			{ id = "union_branded_pear", weight = 50 },
			{ id = "ketchup", weight = 25 },
			{ id = "red_pepper", weight = 50 },
			{ id = "union_branded_corn_cob", weight = 50 },
			{ id = "carrot", weight = 50 },
			{ id = "union_branded_potato", weight = 50 },
			{ id = "union_branded_apple", weight = 50 },
			{ id = "chem_mutroot", weight = 45 },
			{ id = "mat_acid", weight = 60, },
			{ id = "chem_opium", weight = 45 },
			{ id = "chem_rawbiogel", weight = 5 },
		}
	},
	Loot = {
		{ lootGroup = "item1", min = 1, max = 4 }
	}
})

ix.LootContainer:Add("supply_crate", { -- resource crate
	Name = "Заводской ящик",
	Description = "",
	Model = "models/hls/alyxports/wood_crate004.mdl",

	CrackSound = "physics/wood/wood_furniture_break2.wav",
	OpenSound = "physics/wood/wood_box_impact_soft1.wav",
	CloseSound = "physics/wood/wood_box_impact_soft3.wav",
	SearchTime = 5,

	NoRate = true,

	Locked = true,
	Hide = false,
	Respawn = 3600,
	Tool = "crowbar",
	ToolDamage = 20,

	LootGroup = {
		regular = {
			{ id = "junk_clothes", weight = 50 },
			{ id = "ration_tier_1", weight = 50 },
			{ id = "metal_scrap", weight = 50, min = 1, max = 2 },
			{ id = "mat_plastic", weight = 50, min = 1, max = 2 },
			{ id = "box_of_gunpowder", weight = 50, min = 1, max = 2 },
			{ id = "box_of_casings", weight = 50 },
			{ id = "electro_battery", weight = 50 },
			{ id = "mat_kevlar", weight = 40, min = 1, max = 2 },
			{ id = "box_of_needles", weight = 50 },
			{ id = "broken_armor_light", weight = 50 },
			{ id = "mat_oil", weight = 50 },
			{ id = "mat_leather", weight = 50, min = 1, max = 3 },
			{ id = "chain", weight = 50, min = 1, max = 2 },
			{ id = "electro_circuit", weight = 50 },
			{ id = "mat_varnish", weight = 50 },
			{ id = "mat_screws", weight = 50, min = 2, max = 4 },
			{ id = "mat_nuts", weight = 50, min = 2, max = 4 },
			{ id = "mat_cloth", weight = 50, min = 1, max = 3 },
			{ id = "cook_coffee", weight = 60 },
			{ id = "cook_egg", weight = 60 },
			{ id = "cook_flour", weight = 60 },
			{ id = "cook_spices", weight = 60 },
			{ id = "cook_sugar", weight = 60 },
			{ id = "cook_tea", weight = 60 },
			{ id = "cook_yeast", weight = 60 },
			{ id = "mat_resine", weight = 50, min = 1, max = 2 },
			{ id = "mat_wood", weight = 60, min = 1, max = 2 },
			{ id = "empty_can", weight = 50 },
			{ id = "empty_chinese_takeout", weight = 50 },
			{ id = "empty_carton", weight = 50 },
			{ id = "empty_tin_can", weight = 50 },
			{ id = "empty_plastic_can", weight = 50 },
			{ id = "empty_glass_bottle", weight = 50 },
			{ id = "empty_plastic_bottle", weight = 50 },
			{ id = "empty_jug", weight = 50 },
			{ id = "chem_mutroot", weight = 5 },
			{ id = "chem_detoxic", weight = 5 },
			{ id = "chem_antiseptic", weight = 5 },
			{ id = "chem_opium", weight = 5 },
			{ id = "chem_rawbiogel", weight = 5 },
			{ id = "chem_medpile", weight = 5 },
		},
	},
	Loot = {
		{ lootGroup = "regular", count = 4 }
	}
})

ix.LootContainer:Add("military_crate", { -- military tier 0
	Name = "Военный ящик",
	Description = "",
	Model = "models/kali/props/cases/hard case c.mdl",

	CrackSound = "foley/crushable/padlock_destroy_02.mp3",
	OpenSound = "foley/containers/hazmatcrate_open.mp3",
	CloseSound = "foley/containers/hazmatcrate_close.mp3",
	SearchTime = 5,

	NoRate = true,

	Locked = true,
	Hide = false,
	Respawn = 3600,
	Tool = "crowbar",
	ToolDamage = 30,

	LootGroup = {
		raw = {
			{ id = "box_of_gunpowder", weight = 70, min = 1, max = 2 },
			{ id = "box_of_casings", weight = 30 },
		},
		medicine = {
			{ id = "bandage", weight = 70 },
			{ id = "painkiller", weight = 50 },
			{ id = "healthvial", weight = 30 },
			{ id = "bloodbag", weight = 30 },
			{ id = "bottle_of_alcohol", weight = 70 },
			{ id = "empty_syringe", weight = 50 },
			{ id = "chem_antiseptic", weight = 10 },
			{ id = "chem_medpile", weight = 10 },
		},
		mil = {
			{ id = "broken_armor_light", weight = 70 },
			{ id = "junk_clothes", weight = 30 },
			{ id = "broken_pistol", weight = 10 },
		},
		regular = {
			{ id = "surgerymask", weight = 30 },
			{ id = "gasmask_early", weight = 10 },
			{ id = "filter_standard", weight = 13 },
			{ id = "junk_gloves", weight = 60 },
			{ id = "junk_geiger", weight = 30 },
			{ id = "junk_circuit", weight = 25 },
			{ id = "junk_lantern", weight = 25 },
			{ id = "broken_pistol", weight = 60 },
			{ id = "junk_shoe", weight = 70 },
			{ id = "junk_metalgascan", weight = 25 },
			{ id = "junk_citizenradio", weight = 50 },
			{ id = "broken_mp7", weight = 13 }
		},
	},
	Loot = {
		{ lootGroup = "raw", count = 1 },
		{ lootGroup = "medicine", min = 0, max = 1 },
		{ lootGroup = "mil", count = 1 },
		{ lootGroup = "regular", count = 3 }
	}
})

ix.LootContainer:Add("infection_crate", {  -- infestation control 1
    Name = "Контейнер контроля заражения",
    Description = "",
    Model = "models/hazmat_crate/hazmat_crate_body.mdl",

    CrackSound = "foley/crushable/padlock_destroy_02.mp3",
    OpenSound = "foley/containers/hazmatcrate_open.mp3",
    CloseSound = "foley/containers/hazmatcrate_close.mp3",
    SearchTime = 5,

    NoRate = true,

    Locked = true,
	Hide = false,
	Respawn = 3600,
	Tool = "crowbar",
	ToolDamage = 30,

	LootGroup = {
		raw = {
			{ id = "mat_acid", weight = 65 },
			{ id = "chem_mutroot", weight = 65 },
			{ id = "chem_detoxic", weight = 60 },
			{ id = "chem_opium", weight = 60 },
			{ id = "chem_rawbiogel", weight = 5 },
			{ id = "bandage", weight = 30 },
			{ id = "painkiller", weight = 40 },
			{ id = "healthvial", weight = 40 },
			{ id = "bottle_of_alcohol", weight = 20 },
			{ id = "empty_syringe", weight = 8 },
			{ id = "junk_circuit", weight = 20 },
			{ id = "mat_resine", weight = 20 },
			{ id = "ration_tier_1", weight = 20 },
			{ id = "junk_gloves", weight = 20 },
			{ id = "dirty_water", weight = 20 },
		},
	},
	Loot = {
		{ lootGroup = "raw", count = 4 },
	}
})


ix.LootContainer:Add("development", { -- military tier 0
	Name = "Военный ящик",
	Description = "",
	Model = "models/kali/props/cases/hard case c.mdl",

	CrackSound = "foley/crushable/padlock_destroy_02.mp3",
	OpenSound = "foley/containers/hazmatcrate_open.mp3",
	CloseSound = "foley/containers/hazmatcrate_close.mp3",
	SearchTime = 5,

	NoRate = true,

	Hide = false,
	Respawn = 3600,

	LootGroup = {
		raw = {
			{ id = "box_of_casings", weight = 100 }
		},
		medicine = {
			{ id = "junk_cardoor", weight = 100 }
		}
	},
	Loot = {
		{ lootGroup = "raw", count = 5 },
		{ lootGroup = "medicine", count = 1 },
	}
})


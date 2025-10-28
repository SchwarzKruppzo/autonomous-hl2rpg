local PLUGIN = PLUGIN
local Loyalty = ix.Loyalty

Loyalty.ANTI_CITIZEN = Loyalty:AddLevel("Анти-социальный (уровень G)", {
	cost = 10,
	rationItem = false,
	maxCredits = 50,
	cityBanned = true, -- city jobs, property & vendors are banned for this person.
	rewardXP = 14000, -- first time level reward
})

Loyalty.LOW_CITIZEN = Loyalty:AddLevel("Низший класс (уровень D)", {
	cost = 30,
	rationItem = false,
	maxCredits = 100,
	demoteThreshold = -30, -- social credits below this value result in automatic demotion to previous level.
	rewardXP = 7000,
})

Loyalty.CITIZEN = Loyalty:AddLevel("Обычные граждане (уровень 0)", {
	cost = 50,
	rationItem = "ration_tier_0",
	maxCredits = 200,
	demoteThreshold = -50,
	rewardXP = 0,
})

Loyalty.LEVEL_1 = Loyalty:AddLevel("Сторонник 1-го уровня (красный)", {
	cost = 75,
	rationItem = "ration_tier_1",
	maxCredits = 300,
	demoteThreshold = -75,
	rewardXP = 7000,
})

Loyalty.LEVEL_2 = Loyalty:AddLevel("Сторонник 2-го уровня (жёлтый)", {
	cost = 95,
	rationItem = "ration_tier_1",
	maxCredits = 600,
	demoteThreshold = -75,
	rewardXP = 16000,
	licenses = {
		"tier2_housing",
		"shop_renting",
		"alcohol_use",
		"tobacco_use",
	}
})

Loyalty.LEVEL_3 = Loyalty:AddLevel("Лоялист 1-го уровня (синий)", {
	cost = 110,
	rationItem = "ration_tier_2",
	maxCredits = 800,
	demoteThreshold = -100,
	tradeDiscount = 0.05,
	rewardXP = 32000,
})

Loyalty.LEVEL_4 = Loyalty:AddLevel("Лоялист 2-го уровня (зелёный)", {
	requireApplication = true,
	rationItem = "ration_tier_3",
	maxCredits = 5000,
	demoteThreshold = false,
	tradeDiscount = 0.1,
	rewardXP = 64000,
	licenses = {
		"tier3_housing",
		"shop_renting",
		"alcohol_use",
		"tobacco_use",
	}
})

Loyalty.LEVEL_5 = Loyalty:AddLevel("Почетный лоялист (белый)", {
	requireApplication = true,
	rationItem = "ration_tier_3",
	maxCredits = 10000,
	demoteThreshold = false,
	tradeDiscount = 0.2,
	rewardXP = 96000,
})

Loyalty.LEVEL_6 = Loyalty:AddLevel("Высший лоялист (фиолетовый)", {
	requireApplication = true,
	rationItem = "ration_tier_3",
	maxCredits = 100000,
	demoteThreshold = false,
	tradeDiscount = 0.3,
	rewardXP = 128000,
})
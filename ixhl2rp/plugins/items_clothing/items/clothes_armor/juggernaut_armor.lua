ITEM.name = "Снаряжение Джаггернаута 'VLK'"
ITEM.description = ""
ITEM.model = "models/props_c17/SuitCase001a.mdl"
ITEM.category = "Уникальное"
ITEM.width = 2
ITEM.height = 2
ITEM.equip_inv = 'torso'
ITEM.equip_slot = nil
ITEM.genderReplacement = {
	[GENDER_MALE] = "models/earlbolat_customs/secondtime/vlk_male_2.mdl",
	[GENDER_FEMALE] = "models/earlbolat_customs/secondtime/vlk_female_1.mdl"
}
ITEM.RadResist = 30
ITEM.rarity = 4
ITEM.IsArmored = true
ITEM.armor = {
	class = 3,
	max_durability = 1000,
	density = 0.75,
	coverage = {
		[HITGROUP_HEAD] = 0.3,
		[HITGROUP_CHEST] = 1,
		[HITGROUP_STOMACH] = 1,
		[HITGROUP_LEFTARM] = 0.3,
		[HITGROUP_RIGHTARM] = 0.3,
		[HITGROUP_LEFTLEG] = 0.3,
		[HITGROUP_RIGHTLEG] = 0.3,
	},
	penetration = {
		bullet = 0.75,
		impulse = 1,
		buckshot = 0.7,
		explosive = 1,
		burn = 1,
		poison = 0,
		slash = 1,
		club = 1,
		fists = 0.1
	},
	damage = {
		bullet = 0.8,
		impulse = 1,
		buckshot = 3,
		explosive = 1,
		burn = 1,
		poison = 1,
		slash = 1.25,
		club = 4,
		fists = 1
	}
}
ITEM.contraband = true
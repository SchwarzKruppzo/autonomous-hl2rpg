ITEM.name = "Униформа Армии Возмездия"
ITEM.description = ""
ITEM.model = "models/props_c17/SuitCase001a.mdl"
ITEM.category = "Уникальное"
ITEM.width = 2
ITEM.height = 2
ITEM.equip_inv = 'torso'
ITEM.equip_slot = nil
ITEM.genderReplacement = {
	[GENDER_MALE] = "models/kruppzo/retribution_male.mdl",
	[GENDER_FEMALE] = "models/kruppzo/retribution_male.mdl"
}
ITEM.RadResist = 30
ITEM.rarity = 4
ITEM.IsArmored = true
ITEM.armor = {
	class = 2,
	max_durability = 1250,
	density = 0.8,
	coverage = {
		[HITGROUP_HEAD] = 1,
		[HITGROUP_CHEST] = 1,
		[HITGROUP_STOMACH] = 1,
		[HITGROUP_LEFTARM] = 0.5,
		[HITGROUP_RIGHTARM] = 0.5,
		[HITGROUP_LEFTLEG] = 0.5,
		[HITGROUP_RIGHTLEG] = 0.5,
	},
	penetration = {
		bullet = 1,
		impulse = 1,
		buckshot = 0.75,
		explosive = 0.75,
		burn = 1,
		poison = 0,
		slash = 1,
		club = 1,
		fists = 0.1
	},
	damage = {
		bullet = 0.75,
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
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
	class = 1,
	max_durability = 500,
	density = 0.75,
	coverage = {
		[HITGROUP_CHEST] = 1,
		[HITGROUP_LEFTARM] = 0.3,
		[HITGROUP_RIGHTARM] = 0.3,
	},
	penetration = {
		bullet = 1,
		impulse = 1,
		buckshot = 1,
		explosive = 1,
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
		slash = 2,
		club = 5,
		fists = 1
	}
}
ITEM.contraband = true
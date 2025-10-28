ITEM.name = "Общевойсковой Защитный Костюм"
ITEM.description = "Довоенный комплект защиты из двухслойного демрона и комплекса СИБЗ разработанный для действий в условиях агрессивных сред. Не смотря на свой возраст отлично сохранился."
ITEM.model = "models/props_c17/SuitCase001a.mdl"
ITEM.category = "Уникальное"
ITEM.width = 2
ITEM.height = 2
ITEM.equip_inv = 'torso'
ITEM.equip_slot = nil
ITEM.genderReplacement = {
	[GENDER_MALE] = "models/vintagethief/beres.mdl",
	[GENDER_FEMALE] = "models/vintagethief/beres.mdl"
}
ITEM.RadResist = 100
ITEM.rarity = 4
ITEM.IsArmored = true
ITEM.armor = {
	class = 3,
	max_durability = 5000,
	density = 0.75,
	coverage = {
		[HITGROUP_HEAD] = 1,
		[HITGROUP_CHEST] = 1,
		[HITGROUP_STOMACH] = 1,
		[HITGROUP_LEFTARM] = 0.75,
		[HITGROUP_RIGHTARM] = 0.75,
		[HITGROUP_LEFTLEG] = 0.75,
		[HITGROUP_RIGHTLEG] = 0.75,
	},
	penetration = {
		bullet = 0.75,
		impulse = 0.75,
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
		buckshot = 2,
		explosive = 1,
		burn = 1,
		poison = 1,
		slash = 1.25,
		club = 4,
		fists = 1
	}
}
ITEM.contraband = true
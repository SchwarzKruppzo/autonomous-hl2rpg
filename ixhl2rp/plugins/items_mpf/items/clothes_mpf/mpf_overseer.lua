ITEM.name = "Комплект брони смотрителя Надзора"
ITEM.description = ""
ITEM.category = "Одежда (ОТА)"
ITEM.genderReplacement = {
	[GENDER_MALE] = "models/kruppzo/mpf_overseer.mdl",
	[GENDER_FEMALE] = "models/kruppzo/mpf_overseer.mdl"
}
ITEM.primaryVisor = Vector(0.15, 0.75, 2)
ITEM.secondaryVisor = Vector(0.15, 0.75, 2)
ITEM.rarity = 3
ITEM.armor = {
	class = 3,
	max_durability = 1500,
	density = 0.85,
	coverage = {
		[HITGROUP_HEAD] = 1,
		[HITGROUP_CHEST] = 1,
		[HITGROUP_STOMACH] = 1,
		[HITGROUP_LEFTARM] = 0.3,
		[HITGROUP_RIGHTARM] = 0.3,
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
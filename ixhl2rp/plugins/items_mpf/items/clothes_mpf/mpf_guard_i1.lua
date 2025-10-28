ITEM.name = "Униформа охраны ГО с визором"
ITEM.description = "Стандартная униформа охраны Гражданской Обороны с визором."
ITEM.genderReplacement = {
	[GENDER_MALE] = "models/cellar/custom/metropolice/guard.mdl",
	[GENDER_FEMALE] = "models/cellar/custom/metropolice/guard.mdl"
}
ITEM.uniform = 0
ITEM.primaryVisor = Vector(0.75, 0.75, 0.75)
ITEM.secondaryVisor = Vector(0.5, 0.5, 0.5)
ITEM.specialization = "g"
ITEM.bodyGroups = {
	[2] = 1,
	[6] = 3,
	[8] = 1
}
ITEM.armor = {
	class = 2,
	max_durability = 750,
	density = 0.75,
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
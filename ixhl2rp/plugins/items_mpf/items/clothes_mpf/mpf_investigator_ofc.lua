ITEM.name = "Униформа офицера-следователя ГО"
ITEM.description = "Униформа офицера-следователя Гражданской Обороны с улучшенным респиратором и визором."
ITEM.genderReplacement = {
	[GENDER_MALE] = "models/cellar/characters/metropolice/male.mdl",
	[GENDER_FEMALE] = "models/cellar/characters/metropolice/female.mdl"
}
ITEM.uniform = 3
ITEM.primaryVisor = Vector(0.03, 0.03, 0.2)
ITEM.secondaryVisor = Vector(0.03, 0.03, 0.2)
ITEM.specialization = "i"
ITEM.bodyGroups = {
	[2] = 1,
	[6] = 4
}
ITEM.armor = {
	class = 3,
	max_durability = 750,
	density = 0.75,
	coverage = {
		[HITGROUP_HEAD] = 0.5,
		[HITGROUP_CHEST] = 1,
		[HITGROUP_STOMACH] = 1,
		[HITGROUP_LEFTARM] = 0.5,
		[HITGROUP_RIGHTARM] = 0.5,
		[HITGROUP_LEFTLEG] = 0.5,
		[HITGROUP_RIGHTLEG] = 0.5,
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
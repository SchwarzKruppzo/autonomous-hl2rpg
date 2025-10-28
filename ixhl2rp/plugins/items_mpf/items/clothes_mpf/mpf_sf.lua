ITEM.name = "Униформа офицера-спецназа ГО"
ITEM.description = "Униформа офицера-спецназа Гражданской Обороны с разгрузкой и бронемаской."
ITEM.genderReplacement = {
	[GENDER_MALE] = "models/cellar/characters/metropolice/male.mdl",
	[GENDER_FEMALE] = "models/cellar/characters/metropolice/female.mdl"
}
ITEM.uniform = 2
ITEM.primaryVisor = Vector(1, 5, 1)
ITEM.secondaryVisor = Vector(0.1, 0.5, 0.1)
ITEM.bodyGroups = {
	[1] = 1, -- coat
	[2] = 1, -- neck
	[3] = 4, -- mask
	[4] = 1, -- vest
}
ITEM.armor = {
	class = 2,
	max_durability = 1500,
	density = 0.85,
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
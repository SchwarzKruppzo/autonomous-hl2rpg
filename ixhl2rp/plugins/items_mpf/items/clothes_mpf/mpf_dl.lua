ITEM.name = "Униформа дивизионного лидера ГО"
ITEM.description = "Униформа дивизионного лидера Гражданской Обороны с бронемаской."
ITEM.genderReplacement = {
	[GENDER_MALE] = "models/cellar/characters/metropolice/male.mdl",
	[GENDER_FEMALE] = "models/cellar/characters/metropolice/female.mdl"
}
ITEM.uniform = 4
ITEM.primaryVisor = Vector(10, 0, 0)
ITEM.secondaryVisor = Vector(5, 0.1, 0)
ITEM.specialization = nil
ITEM.bodyGroups = {
	[1] = 1, -- coat
	[2] = 1, -- neck
	[3] = 4, -- mask
	[4] = 2, -- vest
	[5] = 1, -- boots
}
ITEM.armor = {
	class = 3,
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
ITEM.name = "Униформа поддержки ГО"
ITEM.description = "Стандартная униформа поддержки Гражданской Обороны."
ITEM.genderReplacement = {
	[GENDER_MALE] = "models/cellar/characters/metropolice/male.mdl",
	[GENDER_FEMALE] = "models/cellar/characters/metropolice/female.mdl"
}
ITEM.uniform = 2
ITEM.primaryVisor = Vector(0.1, 0.5, 0.1)
ITEM.secondaryVisor = Vector(0.1, 0.5, 0.1)
ITEM.specialization = "s"
ITEM.bodyGroups = {
	[1] = 0, -- coat
	[2] = 0, -- neck
	[3] = 0, -- mask
	[4] = 0, -- vest
	[5] = 0, -- boots
}
ITEM.armor = {
	class = 1,
	max_durability = 1000,
	density = 0.75,
	coverage = {
		[HITGROUP_HEAD] = 1,
		[HITGROUP_CHEST] = 1,
		[HITGROUP_STOMACH] = 0.25,
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
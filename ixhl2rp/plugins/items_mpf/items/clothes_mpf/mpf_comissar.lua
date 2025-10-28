ITEM.name = "Униформа комиссара ГО"
ITEM.description = "Униформа комиссара Гражданской Обороны с улучшенным респиратором и визором."
ITEM.genderReplacement = {
	[GENDER_MALE] = "models/cellar/characters/metropolice/male.mdl",
	[GENDER_FEMALE] = "models/cellar/characters/metropolice/female.mdl"
}
ITEM.uniform = 4
ITEM.primaryVisor = Vector(2, 0, 0)
ITEM.secondaryVisor = Vector(5, 0.1, 0)
ITEM.specialization = nil
ITEM.bodyGroups = {
	[1] = 1, -- coat
	[2] = 1, -- neck
	[3] = 2, -- mask
	[5] = 1, -- boots
}
ITEM.armor = {
	class = 2,
	max_durability = 1000,
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
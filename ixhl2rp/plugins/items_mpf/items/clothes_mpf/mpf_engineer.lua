ITEM.name = "Униформа инженера ГО"
ITEM.description = "Стандартная униформа инженера Гражданской Обороны."
ITEM.genderReplacement = {
	[GENDER_MALE] = "models/cellar/characters/metropolice/male.mdl",
	[GENDER_FEMALE] = "models/cellar/characters/metropolice/female.mdl"
}
ITEM.uniform = 5
ITEM.primaryVisor = Vector(0, 0, 0)
ITEM.secondaryVisor = Vector(0.8, 0.1, -0.25)
ITEM.specialization = "e"
ITEM.armor = {
	class = 1,
	max_durability = 750,
	density = 0.75,
	coverage = {
		[HITGROUP_HEAD] = 0.5,
		[HITGROUP_CHEST] = 1,
		[HITGROUP_STOMACH] = 0.5,
		[HITGROUP_LEFTARM] = 0.5,
		[HITGROUP_RIGHTARM] = 0.5,
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
ITEM.name = "Униформа Интернированного"
ITEM.description = "Стандартная униформа интернированного сотрудника Гражданской Обороны."
ITEM.genderReplacement = {
	[GENDER_MALE] = "models/cellar/characters/custom_metropolice/male.mdl",
	[GENDER_FEMALE] = "models/cellar/characters/custom_metropolice/female.mdl"
}
ITEM.ReplaceOnDeath = "Бронежилет Гражданской Обороны"
ITEM.uniform = 0
ITEM.primaryVisor = Vector(0, 0, 0)
ITEM.secondaryVisor = Vector(0.5, 0.05, 0.05)
ITEM.specialization = nil
ITEM.armor = {
	class = 1,
	max_durability = 750,
	density = 0.75,
	coverage = {
		[HITGROUP_HEAD] = 0.5,
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
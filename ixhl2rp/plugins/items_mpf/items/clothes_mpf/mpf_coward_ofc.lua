ITEM.name = "Униформа офицера-надзирателя ГО"
ITEM.description = "Униформа офицера-надзирателя Гражданской Обороны."
ITEM.genderReplacement = {
	[GENDER_MALE] = "models/cellar/characters/custom_metropolice/male.mdl",
	[GENDER_FEMALE] = "models/cellar/characters/custom_metropolice/female.mdl"
}
ITEM.ReplaceOnDeath = "Черная_безрукавка_с_бронежилетом_ГО"
ITEM.WeaponSkillBuff = 3
ITEM.uniform = 0
ITEM.primaryVisor = Vector(0.5, 0.05, 0.05)
ITEM.secondaryVisor = Vector(0.5, 0.05, 0.05)
ITEM.specialization = nil
ITEM.armor = {
	class = 2,
	max_durability = 500,
	density = 0.75,
	coverage = {
		[HITGROUP_HEAD] = 0.5,
		[HITGROUP_CHEST] = 1,
		[HITGROUP_STOMACH] = 1,
		[HITGROUP_LEFTARM] = 0.3,
		[HITGROUP_RIGHTARM] = 0.3,
		[HITGROUP_LEFTLEG] = 0.3,
		[HITGROUP_RIGHTLEG] = 0.3,
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
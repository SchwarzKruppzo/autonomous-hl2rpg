ITEM.name = "R-78"
ITEM.description = "[Уникальный внешний вид для Револьвер .357]"
ITEM.model = "models/weapons/w_azn_trigund.mdl"
ITEM.class = "riff_357"
ITEM.weaponCategory = "secondary"
ITEM.category = "Уникальное"
ITEM.rarity = 2
ITEM.width = 2
ITEM.height = 1
ITEM.Attack = 14
ITEM.DistanceSkillMod = {
	[1] = 5,
	[2] = 0,
	[3] = -2,
	[4] = -5
}
ITEM.Info = {
	Type = nil,
	Skill = "guns",
	Distance = {
		[1] = 5,
		[2] = 0,
		[3] = -2,
		[4] = -5
	},
	Dmg = {
		Attack = nil,
		AP = ITEM.Attack,
		Limb = 120,
		Shock = {100, 3000},
		Blood = {75, 750},
		Bleed = 95
	}
}
ITEM.iconCam = {
	pos = Vector(5.4911828041077, -225.66163635254, -10.414468765259),
	ang = Angle(-1.8909651041031, 91.945999145508, 0),
	fov = 3.8896982478868,
}
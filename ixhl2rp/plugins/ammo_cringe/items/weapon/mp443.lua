ITEM.name = "MP-443"
ITEM.description = "[Уникальный внешний вид для USP Match]"
ITEM.model = "models/weapons/tfa_ins2/mp443/w_mp443.mdl"
ITEM.class = "arccw_usp_mp443"
ITEM.category = "Уникальное"
ITEM.weaponCategory = "sidearm"
ITEM.width = 2
ITEM.height = 1
ITEM.iconCam = {
	pos = Vector(12.534174919128, -189.28843688965, 61.362155914307),
	ang = Angle(18.468564987183, 453.90878295898, 0),
	fov = 4.3062882137585,
}
ITEM.Attack = 3
ITEM.DistanceSkillMod = {
	[1] = 7,
	[2] = 3,
	[3] = 0,
	[4] = -7
}
ITEM.Info = {
	Type = nil,
	Skill = "guns",
	Distance = {
		[1] = 5,
		[2] = 3,
		[3] = 0,
		[4] = -7
	},
	Dmg = {
		Attack = nil,
		AP = ITEM.Attack,
		Limb = 26,
		Shock = {111, 2200},
		Blood = {25, 100},
		Bleed = 50
	}
}
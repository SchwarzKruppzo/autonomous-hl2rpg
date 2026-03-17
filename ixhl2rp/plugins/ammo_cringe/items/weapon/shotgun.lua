ITEM.name = "item.shotgun"
ITEM.description = "item.shotgun.desc"
ITEM.model = "models/weapons/w_shotgun.mdl"
ITEM.class = "arccw_spas12"
ITEM.weaponCategory = "primary"
ITEM.classes = {CLASS_EOW}
ITEM.width = 3
ITEM.height = 2
ITEM.iconCam = {
    pos = Vector(0, 200, 1),
    ang = Angle(0, 270, 0),
    fov = 10
}

ITEM.Attack = 9
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
		Limb = 34,
		Shock = {555, 25000},
		Blood = {250, 500},
		Bleed = 75
	}
}
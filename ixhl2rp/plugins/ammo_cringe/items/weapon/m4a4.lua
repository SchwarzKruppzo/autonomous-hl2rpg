ITEM.name = "M4A4"
ITEM.description = "Популярная американская штурмовая винтовка на базе системы AR-15."
ITEM.model = "models/weapons/arccw_go/v_rif_m4a1.mdl"
ITEM.class = "arccw_m4a4"
ITEM.weaponCategory = "primary"
ITEM.rarity = 2
ITEM.width = 4
ITEM.height = 2
ITEM.Attack = 15
ITEM.DistanceSkillMod = {
	[1] = 5,
	[2] = 5,
	[3] = 3,
	[4] = -1
}
ITEM.Info = {
	Type = nil,
	Skill = "guns",
	Distance = {
		[1] = 5,
		[2] = 5,
		[3] = 3,
		[4] = -1
	},
	Dmg = {
		Attack = nil,
		AP = ITEM.Attack,
		Limb = 30,
		Shock = {88, 1050},
		Blood = {30, 300},
		Bleed = 50
	}
}
ITEM.iconCam = {
	pos = Vector(-15.58028793335, 393.27853393555, 6.0283694267273),
	ang = Angle(1.7500630617142, 274.62145996094, 0),
	fov = 4.8111057794116,
}


ITEM.name = "item.stunpistol"
ITEM.description = "item.stunpistol.desc"
ITEM.model = "models/weapons/bordelzio/arccw/hkvp70/wmodel/w_hk_vp70.mdl"
ITEM.class = "arccw_traumapistol"
ITEM.weaponCategory = "sidearm"
ITEM.width = 2
ITEM.height = 1
ITEM.Attack = 1
ITEM.DistanceSkillMod = {
	[1] = 10,
	[2] = 5,
	[3] = -4,
	[4] = -9
}
ITEM.Info = {
	Type = nil,
	Skill = "guns",
	Distance = {
		[1] = 10,
		[2] = 5,
		[3] = -4,
		[4] = -9
	},
	Dmg = {
		Attack = nil,
		AP = ITEM.Attack,
		Limb = 1,
		Shock = {375, 4500},
		Blood = {1, 1},
		Bleed = 0
	}
}
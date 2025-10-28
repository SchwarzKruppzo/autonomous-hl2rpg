ITEM.name = "Импульсная винтовка Патруля Mk. I"
ITEM.description = "Это оружие явно было сконструировано из неземных материалов. Прочный корпус, необычный патрон, который невозможно собрать кустарными способами и огромная убойная мощь - это то, что делает это оружие по-истине великолепным инструментом убийства."
ITEM.model = "models/weapons/w_irifle.mdl"
ITEM.class = "arccw_ar2"
ITEM.weaponCategory = "primary"
ITEM.rarity = 2
ITEM.width = 4
ITEM.height = 2
ITEM.hasLock = true
ITEM.icon_model = "models/weapons/tfa_mmod/w_irifle.mdl"
ITEM.iconCam = {
	pos = Vector(60.106246948242, -803.26910400391, 172.6411895752),
	ang = Angle(11.997188568115, 93.719779968262, 0),
	fov = 2.6968534692095,
}
ITEM.Attack = 18
ITEM.DistanceSkillMod = {
	[1] = 5,
	[2] = 3,
	[3] = 3,
	[4] = -2
}
ITEM.Info = {
	Type = nil,
	Skill = "impulse",
	Distance = {
		[1] = 5,
		[2] = 3,
		[3] = 3,
		[4] = -2
	},
	Dmg = {
		Attack = nil,
		AP = ITEM.Attack,
		Limb = 60,
		Shock = {90, 1500},
		Blood = {35, 350},
		Bleed = 0
	}
}



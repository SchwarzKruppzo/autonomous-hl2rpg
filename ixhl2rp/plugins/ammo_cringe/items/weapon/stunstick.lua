ITEM.name = "item.stunstick"
ITEM.description = "item.stunstick.desc"
ITEM.model = "models/weapons/w_stunbaton.mdl"
ITEM.class = "arccw_stunstick"
ITEM.weaponCategory = "melee"
ITEM.width = 3
ITEM.height = 1
ITEM.iconCam = {
	pos = Vector(0, 200, 0),
	ang = Angle(0, 270, 0),
	fov = 8,
}
ITEM.Info = {
	Type = 1,
	Skill = "meleeguns",
	Dmg = {
		Attack = 1,
		Limb = 10,
		Shock = {28, 2000},
		Blood = {6, 25},
		Bleed = 5
	}
}
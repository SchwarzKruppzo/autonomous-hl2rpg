ITEM.name = "Рубаха с бронежилетом ОТА"
ITEM.model = "models/cmbfdr/items/shirt_rebeloverwatch.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(283.96502685547, -2.7559235095978, 189.72630310059),
	ang = Angle(33.174201965332, 179.3546295166, 0),
	fov = 2.9430843245987,
}
ITEM.CanBreakDown = false
ITEM.description = "iCloth19Desc"
ITEM.equip_inv = 'torso'
ITEM.equip_slot = nil
ITEM.bodyGroups = {
	[1] = 19
}
ITEM.armor = {
	class = 3,
	max_durability = 1350,
	density = 0.8,
	coverage = {
		[HITGROUP_CHEST] = 1,
		[HITGROUP_STOMACH] = 1,
		[HITGROUP_LEFTARM] = 0.5,
		[HITGROUP_RIGHTARM] = 0.5,
	},
	penetration = {
		bullet = 0.75,
		impulse = 1,
		buckshot = 0.7,
		explosive = 1,
		burn = 1,
		poison = 0,
		slash = 1,
		club = 1,
		fists = 0.1
	},
	damage = {
		bullet = 0.8,
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
ITEM.contraband = true
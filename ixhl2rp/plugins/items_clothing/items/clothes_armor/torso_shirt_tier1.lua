ITEM.name = "Зеленая рубаха-безрукавка с бронежилетом"
ITEM.model = "models/cmbfdr/items/shirt_rebel1.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(283.96502685547, -2.7559235095978, 189.72630310059),
	ang = Angle(33.174201965332, 179.3546295166, 0),
	fov = 2.9430843245987,
}
ITEM.CanBreakDown = false
ITEM.description = "iCloth18Desc"
ITEM.equip_inv = 'torso'
ITEM.equip_slot = nil
ITEM.bodyGroups = {
	[1] = 18
}
ITEM.armor = {
	class = 1,
	max_durability = 750,
	density = 0.75,
	coverage = {
		[HITGROUP_CHEST] = 1,
		[HITGROUP_STOMACH] = 1
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
ITEM.contraband = true
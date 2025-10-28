ITEM.name = "Зеленая рубаха с бронежилетом MOLLE"
ITEM.model = "models/cmbfdr/items/shirt_rebel_molle.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(283.96502685547, -2.7559235095978, 189.72630310059),
	ang = Angle(33.174201965332, 179.3546295166, 0),
	fov = 2.9430843245987,
}
ITEM.CanBreakDown = false
ITEM.description = "iCloth21Desc"
ITEM.equip_inv = 'torso'
ITEM.equip_slot = nil
ITEM.bodyGroups = {
	[1] = 21
}
ITEM.armor = {
	class = 2,
	max_durability = 750,
	density = 0.75,
	coverage = {
		[HITGROUP_CHEST] = 1,
		[HITGROUP_STOMACH] = 1,
		[HITGROUP_LEFTARM] = 0.3,
		[HITGROUP_RIGHTARM] = 0.3,
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
ITEM.contraband = true
ITEM.name = "Сварочная маска"
ITEM.uniqueID = "weldingmask"
ITEM.model = "models/cellar/items/weldingmask.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Не смотря на свою громоздкость является не только полезным инструментом при сварке разных вещей, но еще и не плохо защищает лицо от ударов кулаком или другими вещами. Обзор, правда, в этой маске такой себе."
ITEM.equip_inv = 'mask'
ITEM.equip_slot = nil
ITEM.bodyGroups = {
	[5] = 5,
}
ITEM.Stats = {
	[HITGROUP_GENERIC] = 0,
	[HITGROUP_HEAD] = 2,
	[HITGROUP_CHEST] = 0,
	[HITGROUP_STOMACH] = 0,
	[4] = 0,
	[5] = 0,
}
ITEM.iconCam = {
	pos = Vector(95.092430114746, -0.14055043458939, 169.05578613281),
	ang = Angle(60.31583404541, 179.7126159668, 0),
	fov = 4.219171245722,
}
ITEM.contraband = true
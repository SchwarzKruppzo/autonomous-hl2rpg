ITEM.name = "Небольшая сумка"
ITEM.description = "Небольшая самодельная сумка. Сомневаюсь, что она сможет выдержать что-то."
ITEM.model = "models/cellar/prop_pack_regular.mdl"
ITEM.iconCam = {
	pos = Vector(-101.23272705078, -12.317017555237, 271.6901550293),
	ang = Angle(69.209274291992, 6.8816394805908, 0),
	fov = 4.2366720866849,
}
ITEM.width = 3
ITEM.height = 2
ITEM.inventory_data = {
	width = 3,
	height = 4,
	type = 'item_container',
	multislot = true
}

function ITEM:GetOutfitData()
	return {
		slot = "backpack",
		model = "models/cellar/pack_regular.mdl"
	}
end
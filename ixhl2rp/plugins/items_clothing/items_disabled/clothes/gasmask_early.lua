ITEM.name = "item.gasmask_early"
ITEM.description = "item.gasmask_early.desc"
ITEM.model = Model("models/cellar/items/respirator.mdl")
ITEM.bodyGroups = {
	[5] = 3
}
ITEM.iconCam = {
	pos = Vector(290.53433227539, 244.05331420898, 178.25257873535),
	ang = Angle(24.995698928833, 220, 5.7281365394592),
	fov = 0.93548554788614,
}
ITEM.equip_inv = 'mask'
ITEM.equip_slot = nil
ITEM.filters = {
	["filter_standard"] = true
}
ITEM.isGasmask = true
ITEM.contraband = true
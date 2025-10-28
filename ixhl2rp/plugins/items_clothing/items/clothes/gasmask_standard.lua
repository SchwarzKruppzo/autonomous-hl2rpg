ITEM.name = "Противогаз ГП-5"
ITEM.description = "iGasmaskDesc"
ITEM.model = Model("models/tnb/items/gasmask.mdl")
ITEM.rarity = 1
ITEM.bodyGroups = {
	[5] = 6
}
ITEM.equip_inv = 'mask'
ITEM.equip_slot = nil
ITEM.filters = {
	["filter_medium"] = true,
	["filter_standard"] = true
}
ITEM.isGasmask = true
ITEM.iconCam = {
	pos = Vector(-4.9198527336121, -257.72015380859, 72.303321838379),
	ang = Angle(14.979078292847, 88.836845397949, 0),
	fov = 2.2327247131098,
}
ITEM.contraband = true
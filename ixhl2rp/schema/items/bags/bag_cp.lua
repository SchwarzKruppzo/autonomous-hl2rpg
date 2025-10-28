ITEM.name = "Рюкзак Гражданской Обороны"
ITEM.description = ""
ITEM.model = "models/cellar/prop_pack_cp.mdl"
ITEM.rarity = 2
ITEM.width = 3
ITEM.height = 4
ITEM.inventory_data = {
	width = 7,
	height = 4,
	type = 'item_container',
	multislot = true
}
ITEM.iconCam = {
	pos = Vector(0, 0, 200),
	ang = Angle(89.804817199707, -0.057920835912228, 0),
	fov = 4.3062882137585,
}

function ITEM:GetOutfitData()
    return {
        slot = "backpack",
        model = "models/cellar/pack_cp.mdl"
    }
end
ITEM.name = "item.bag_cp"
ITEM.description = "item.bag_cp.desc"
ITEM.model = "models/cellar/prop_pack_cp.mdl"
ITEM.rarity = 2
ITEM.width = 3
ITEM.height = 4
ITEM.inventory_data = {
	width = 4,
	height = 6,
	type = 'item_container',
	multislot = true,
    regions = {
        {x=1, y=1, w=2, h=6},  -- large left pocket
        {x=3, y=1, w=2, h=2},  -- top right
        {x=3, y=3, w=1, h=1},  -- small mid-left
        {x=4, y=3, w=1, h=1},  -- small mid-right
        {x=3, y=4, w=2, h=3},  -- bottom right
    }
}
ITEM.iconCam = {
	pos = Vector(0, 0, 200),
	ang = Angle(89.804817199707, -0.057920835912228, 0),
	fov = 4.3062882137585,
}

ITEM.displayID = "backpack_cp"
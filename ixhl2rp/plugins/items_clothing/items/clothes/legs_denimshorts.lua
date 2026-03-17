ITEM.name = "item.legs_denimshorts"
ITEM.model = "models/cmbfdr/items/pants_citizen.mdl"
ITEM.skin = 3
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(31.341981887817, -0.18476867675781, 291.82946777344),
	ang = Angle(83.76683807373, 179.64495849609, 0),
	fov = 4.0238345864177,
}
ITEM.rarity = 3
ITEM.description = "item.legs_denimshorts.desc"
ITEM.equip_inv = 'legs'
ITEM.equip_slot = nil
--ITEM.bodyGroups = {
--	[1] = 31
--}


ITEM.displayID = ix.Appearance:New("denim_shorts", {
    slot = ix.Appearance.Slot.Legs,
    layer = ix.Appearance.Layer.Bottom,
    bodyMask = "Legs_Visible",
    variants = {
        female = {
            model = "models/autonomous/female_legs_bundle1.mdl",
            bodyGroups = { [0] = 2 }
        },
    }
})


ITEM.BreakDown = true
ITEM.BreakDownType = "cloth"
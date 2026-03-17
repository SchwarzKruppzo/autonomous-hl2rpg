ITEM.name = "item.legs_suitjacket"
ITEM.model = "models/tnb/halflife2/citizens/items/world_suitjacket_legs.mdl"
ITEM.skin = 3
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(31.341981887817, -0.18476867675781, 291.82946777344),
	ang = Angle(83.76683807373, 179.64495849609, 0),
	fov = 4.0238345864177,
}
ITEM.rarity = 3
ITEM.description = "item.legs_suitjacket.desc"
ITEM.equip_inv = 'legs'
ITEM.equip_slot = nil


--ITEM.bodyGroups = {
--	[2] = 7
--}

ITEM.displayID = ix.Appearance:New("suitjacket_legs", {
    slot = ix.Appearance.Slot.Legs,
    layer = ix.Appearance.Layer.Bottom,
    variants = {
        male = {
            model = "models/tnb/halflife2/male_legs_suitjacket.mdl"
        },
        female = {
            model = "models/tnb/halflife2/female_legs_suitjacket.mdl"
        },
    }
})

ITEM.BreakDown = true
ITEM.BreakDownType = "cloth"
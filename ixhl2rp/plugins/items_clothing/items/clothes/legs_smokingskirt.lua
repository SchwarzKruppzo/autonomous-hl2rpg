ITEM.name = "item.legs_smokingskirt"
ITEM.description = "item.legs_smokingskirt.desc"
ITEM.model = "models/props_c17/BriefCase001a.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.rarity = 2
ITEM.equip_inv = 'legs'
ITEM.equip_slot = nil

ITEM.displayID = ix.Appearance:New("test_skirt", {
    slot = ix.Appearance.Slot.Legs,
    layer = ix.Appearance.Layer.Bottom,
    bodyMask = "Legs_Visible",
    variants = {
        female = {
            model = "models/autonomous/female_legs_bundle1.mdl",
            bodyGroups = { [2] = 1 }
        },
    }
})
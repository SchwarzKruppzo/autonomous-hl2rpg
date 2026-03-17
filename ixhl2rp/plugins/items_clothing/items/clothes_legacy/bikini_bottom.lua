ITEM.name = "item.bikini_bottom"
ITEM.model = "models/props_lab/box01a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "item.bikini_bottom.desc"

ITEM.displayID = ix.Appearance:New("bikini_bottom", {
    slot = ix.Appearance.Slot.UnderwearBottom,
    layer = ix.Appearance.Layer.Bottom,
    variants = {
        female = {
            model = "models/autonomous/female_underwear_bundle1.mdl",
			bodyGroups = { [1] = 1 }
        },
    }
})
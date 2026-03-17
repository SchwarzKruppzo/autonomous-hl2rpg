ITEM.name = "item.bikini_top"
ITEM.model = "models/props_lab/box01a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "item.bikini_top.desc"

ITEM.displayID = ix.Appearance:New("bikini_top", {
    slot = ix.Appearance.Slot.UnderwearTop,
    layer = ix.Appearance.Layer.Top,
    variants = {
        female = {
            model = "models/autonomous/female_underwear_bundle1.mdl",
			bodyGroups = { [0] = 1 }
        },
    }
})
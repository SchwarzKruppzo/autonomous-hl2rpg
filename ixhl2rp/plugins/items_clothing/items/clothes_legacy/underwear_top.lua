ITEM.name = "item.underwear_top"
ITEM.model = "models/props_lab/box01a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "item.underwear_top.desc"

ITEM.displayID = ix.Appearance:New("default_bra", {
    slot = ix.Appearance.Slot.UnderwearTop,
    layer = ix.Appearance.Layer.Top,
    variants = {
        female = {
            model = "models/autonomous/female_underwear_bundle1.mdl",
			bodyGroups = { [0] = 2 }
        },
    }
})
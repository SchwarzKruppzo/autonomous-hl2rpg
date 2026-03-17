ITEM.name = "item.underwear_bottom"
ITEM.model = "models/props_lab/box01a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "item.underwear_bottom.desc"

ITEM.displayID = ix.Appearance:New("default_panties", {
    slot = ix.Appearance.Slot.UnderwearBottom,
    layer = ix.Appearance.Layer.Bottom,
    variants = {
        female = {
            model = "models/autonomous/female_underwear_bundle1.mdl",
			bodyGroups = { [1] = 2 }
        },
    }
})
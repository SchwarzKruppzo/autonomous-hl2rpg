ITEM.name = "item.stockings"
ITEM.description = "item.stockings.desc"
ITEM.model = "models/props_combine/breenglobe.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.rarity = 2

ITEM.displayID = ix.Appearance:New("test_stockings", {
    clientside = true,
    slot = ix.Appearance.Slot.Socks,
    variants = {
        female = {
            model = "models/autonomous/female_legs_bundle1.mdl",
            bodyGroups = { [0] = 3 }
        },
    }
})
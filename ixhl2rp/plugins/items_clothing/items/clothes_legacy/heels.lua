ITEM.name = "item.heels"
ITEM.description = "item.heels.desc"
ITEM.model = "models/hunter/blocks/cube025x025x025.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.rarity = 2

ITEM.displayID = ix.Appearance:New("test_heels", {
    clientside = true,
    slot = ix.Appearance.Slot.Boots,
    variants = {
        female = {
            model = "models/autonomous/female_legs_bundle1.mdl",
            bodyGroups = { [1] = 2 },
            params = {
                heels = 1
            }
        },
    }
})


ITEM.name = "item.torso_smoking"
ITEM.model = "models/props_c17/BriefCase001a.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.rarity = 2
ITEM.description = "item.torso_smoking.desc"
ITEM.equip_inv = 'torso'
ITEM.equip_slot = nil
--ITEM.bodyGroups = {
--	[1] = 31
--}


ITEM.displayID = ix.Appearance:New("smoking_suit", {
    slot = ix.Appearance.Slot.Torso,
    layer = ix.Appearance.Layer.Top,
    bodyMask = "Torso_OnlyHands_Opened",
    variants = {
        female = {
            model = "models/autonomous/female_torso_bundle1.mdl",
            bodyGroups = { [0] = 1 }
        },
    }
})


ITEM.BreakDown = true
ITEM.BreakDownType = "cloth"
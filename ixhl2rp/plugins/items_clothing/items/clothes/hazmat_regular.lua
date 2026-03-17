ITEM.name = "item.hazmat_regular"
ITEM.description = "item.hazmat_regular.desc"
ITEM.model = "models/props_c17/SuitCase001a.mdl"
ITEM.equip_inv = 'torso'
ITEM.equip_slot = nil
ITEM.width = 2
ITEM.height = 2
--ITEM.genderReplacement = {
--	[GENDER_MALE] = "models/cellar/characters/hazmat/hazard_male.mdl",
--	[GENDER_FEMALE] = "models/cellar/characters/hazmat/hazard_female.mdl"
--}
ITEM.rarity = 2
ITEM.contraband = true

ITEM.displayID = ix.Appearance:New("hazmat", {
    slot = ix.Appearance.Slot.Suit,
    layer = ix.Appearance.Layer.Main,
    variants = {
        male = {
            model = "models/cellar/characters/hazmat/hazard_male.mdl"
        },
        female = {
            model = "models/cellar/characters/hazmat/hazard_female.mdl"
        },
    }
})
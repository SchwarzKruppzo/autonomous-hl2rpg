ITEM.name = "item.torso_loyaljacket_everva"
ITEM.model = "models/cellar/prop_torso_loyalistjacket.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(193.35394287109, 0.41338610649109, 414.09881591797),
	ang = Angle(64.944976806641, 179.9291229248, 0),
	fov = 3.6862534639468,
}
ITEM.rarity = 2
ITEM.description = "item.torso_loyaljacket_everva.desc"
ITEM.equip_inv = 'torso'
ITEM.equip_slot = nil
--ITEM.bodyGroups = {
--	[1] = 31
--}


ITEM.displayID = ix.Appearance:New("everva_torso", {
	slot = ix.Appearance.Slot.Torso,
	layer = ix.Appearance.Layer.Top,
	bodyMask = "Torso_OnlyHands",
	variants = {
		male = {
			model = "models/cellar/male_torso_loyalistjacket.mdl"
		},
		female = {
			model = "models/cellar/female_torso_loyalistjacket.mdl"
		},
	}
})

ITEM.BreakDown = true
ITEM.BreakDownType = "cloth"
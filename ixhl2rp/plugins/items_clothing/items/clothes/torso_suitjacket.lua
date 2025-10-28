ITEM.name = "Черный пиджак с пальто"
ITEM.model = "models/tnb/halflife2/citizens/items/world_suitjacket.mdl"
ITEM.skin = 3
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(31.341981887817, -0.18476867675781, 291.82946777344),
	ang = Angle(83.76683807373, 179.64495849609, 0),
	fov = 4.0238345864177,
}
ITEM.rarity = 3
ITEM.description = "Стильный черный пиджак, дополненный длинным пальто, который отлично подходит для города. Идеально сочетается с классическими брюками и обувью."
ITEM.equip_inv = 'torso'
ITEM.equip_slot = nil
ITEM.bodyGroups = {
	[1] = 31
}

function ITEM:GetOutfitData()
    return {
        slot = "torso",
        model = {
        	[GENDER_MALE] = "models/tnb/halflife2/male_torso_suitjacket.mdl",
            [GENDER_FEMALE] = "models/tnb/halflife2/female_torso_suitjacket.mdl",
        }
    }
end

ITEM.BreakDown = true
ITEM.BreakDownType = "cloth"
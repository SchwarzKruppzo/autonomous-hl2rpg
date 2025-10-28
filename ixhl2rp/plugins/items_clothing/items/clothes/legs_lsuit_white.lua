ITEM.name = "Белые брюки"
ITEM.model = "models/props_c17/BriefCase001a.mdl"
ITEM.skin = 3
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(31.341981887817, -0.18476867675781, 291.82946777344),
	ang = Angle(83.76683807373, 179.64495849609, 0),
	fov = 4.0238345864177,
}
ITEM.rarity = 3
ITEM.description = "Легкие белые брюки, идеально подходящие для теплой погоды. Комфортный крой и универсальный стиль."
ITEM.equip_inv = 'legs'
ITEM.equip_slot = nil
ITEM.bodyGroups = {
	[2] = 7
}

function ITEM:GetOutfitData()
    return {
        slot = "legs",
        model = {
        	[GENDER_MALE] = "models/tnb/halflife/male_legs_suit.mdl",
            [GENDER_FEMALE] = "models/tnb/halflife/female_legs_suit.mdl",
        }
    }
end

ITEM.BreakDown = true
ITEM.BreakDownType = "cloth"
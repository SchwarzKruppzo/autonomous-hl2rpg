ITEM.name = "Белый пиджак"
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
ITEM.description = "Стильный белый пиджак, идеально подходящий для официальных мероприятий. Изготовлен из качественного материала и отлично сидит на фигуре."
ITEM.equip_inv = 'torso'
ITEM.equip_slot = nil
ITEM.bodyGroups = {
	[1] = 31
}

function ITEM:GetOutfitData()
    return {
        slot = "torso",
        model = {
        	[GENDER_MALE] = "models/tnb/halflife/male_torso_suit.mdl",
            [GENDER_FEMALE] = "models/tnb/halflife/female_torso_suit.mdl",
        }
    }
end

ITEM.BreakDown = true
ITEM.BreakDownType = "cloth"
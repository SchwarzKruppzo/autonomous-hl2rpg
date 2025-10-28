ITEM.name = "Оливковая рубашка \"Ingotex-13\""
ITEM.model = "models/cellar/prop_torso_coveralls_loyal.mdl"
ITEM.skin = 3
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(31.341981887817, -0.18476867675781, 291.82946777344),
	ang = Angle(83.76683807373, 179.64495849609, 0),
	fov = 4.0238345864177,
}
ITEM.rarity = 1
ITEM.description = "Оливкового цвета рубашка от корпорации \"Ingotex-13\", созданная из качественных материалов. Имеется значок Вселенского Союза."
ITEM.equip_inv = 'torso'
ITEM.equip_slot = nil
ITEM.bodyGroups = {
	[1] = 31
}

function ITEM:GetOutfitData()
    return {
        slot = "torso",
        skin = 3,
        model = {
        	[GENDER_MALE] = "models/cellar/male_torso_coveralls_loyal.mdl",
            [GENDER_FEMALE] = "models/cellar/female_torso_coveralls_loyal.mdl",
        }
    }
end

ITEM.BreakDown = true
ITEM.BreakDownType = "cloth"
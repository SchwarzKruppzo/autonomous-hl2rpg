ITEM.name = "Пуховик \"Everva\""
ITEM.model = "models/cellar/prop_torso_loyalistjacket.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(193.35394287109, 0.41338610649109, 414.09881591797),
	ang = Angle(64.944976806641, 179.9291229248, 0),
	fov = 3.6862534639468,
}
ITEM.rarity = 2
ITEM.description = "Темно-синего цвета пуховик произведенный корпорацией \"Everva\" из качественных материалов и предусмотренный для высших слоев лояльного общества Вселенского Союза. Имеется соответствующий значок. В нем достаточно тепло и удобно."
ITEM.equip_inv = 'torso'
ITEM.equip_slot = nil
ITEM.bodyGroups = {
	[1] = 31
}

function ITEM:GetOutfitData()
    return {
        slot = "torso",
        model = {
        	[GENDER_MALE] = "models/cellar/male_torso_loyalistjacket.mdl",
            [GENDER_FEMALE] = "models/cellar/female_torso_loyalistjacket.mdl",
        }
    }
end

ITEM.BreakDown = true
ITEM.BreakDownType = "cloth"
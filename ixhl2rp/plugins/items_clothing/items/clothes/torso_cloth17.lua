ITEM.name = "Зеленый пуховик"
ITEM.model = "models/cellar/prop_torso_raincoat.mdl"
ITEM.iconCam = {
	pos = Vector(209.25494384766, -1.0392966270447, 336.08325195313),
	ang = Angle(57.927131652832, 179.62501525879, 0),
	fov = 3.7355467375341,
}
ITEM.skin = 2
ITEM.width = 2
ITEM.height = 2
ITEM.description = "Удобный, но помятый пуховик зеленого цвета. Имеет пару карманов для рук на животе и неплохо согревает."
ITEM.equip_inv = 'torso'
ITEM.equip_slot = nil
ITEM.bodyGroups = {
	[1] = 31
}

function ITEM:GetOutfitData()
	return {
		slot = "torso",
		skin = 2,
		model = {
			[GENDER_MALE] = "models/cellar/male_torso_raincoat.mdl",
			[GENDER_FEMALE] = "models/cellar/female_torso_raincoat.mdl",
		},
		fit = 1
	}
end

ITEM.BreakDown = true
ITEM.BreakDownType = "cloth"
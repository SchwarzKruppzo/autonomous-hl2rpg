ITEM.name = "Темно-синие штаны \"Ingotex-13\""
ITEM.model = "models/cellar/prop_pants_boots_loyal.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
    pos = Vector(201.15960693359, 0.36107802391052, 232.11555480957),
    ang = Angle(49.165325164795, 179.98989868164, 0),
    fov = 3.4063269571752,
}
ITEM.rarity = 1
ITEM.description = "Темно-синего цвета походные штаны от корпорации \"Ingotex-13\", созданные из качественных материалов."
ITEM.equip_inv = 'legs'
ITEM.equip_slot = nil
ITEM.bodyGroups = {
    [2] = 7,
}

function ITEM:GetOutfitData()
    return {
        slot = "legs",
        model = {
        	[GENDER_MALE] = "models/cellar/male_legs_coveralls_loyal.mdl",
            [GENDER_FEMALE] = "models/cellar/female_legs_coveralls_loyal.mdl",
        }
    }
end

ITEM.BreakDown = true
ITEM.BreakDownType = "cloth"
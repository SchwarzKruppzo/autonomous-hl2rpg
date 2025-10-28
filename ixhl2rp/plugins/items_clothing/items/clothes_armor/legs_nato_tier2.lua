ITEM.name = "Довоенные штаны с бронепластинами"
ITEM.model = "models/cellar/prop_legs_nato.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.description = ""
ITEM.equip_inv = 'legs'
ITEM.equip_slot = nil
ITEM.bodyGroups = {
	[2] = 7,
}
ITEM.rarity = 1
ITEM.iconCam = {
    pos = Vector(-3.2253472805023, -271.79052734375, 326.21942138672),
    ang = Angle(49.733085632324, 89.282318115234, 0),
    fov = 2.2571822456483,
}
ITEM.armor = {
    class = 2,
    max_durability = 500,
    density = 0.75,
    coverage = {
        [HITGROUP_LEFTLEG] = 0.5,
        [HITGROUP_RIGHTLEG] = 0.5,
    },
    penetration = {
        bullet = 0.7,
        impulse = 1,
        buckshot = 0.7,
        explosive = 1,
        burn = 1,
        poison = 0,
        slash = 1,
        club = 1,
        fists = 0.1
    },
    damage = {
        bullet = 0.8,
        impulse = 1,
        buckshot = 3,
        explosive = 1,
        burn = 1,
        poison = 1,
        slash = 1.25,
        club = 4,
        fists = 1
    }
}
ITEM.contraband = true

function ITEM:GetOutfitData()
    return {
        slot = "legs",
        model = {
            [GENDER_MALE] = "models/cellar/male_legs_nato.mdl",
            [GENDER_FEMALE] = "models/cellar/female_legs_nato.mdl",
        }
    }
end
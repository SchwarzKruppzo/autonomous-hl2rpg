ITEM.name = "Каска"
ITEM.model = "models/cellar/prop_helmet_nato.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
    pos = Vector(170.83224487305, -3.1775050163269, -31.036396026611),
    ang = Angle(-11.637926101685, 178.93601989746, 0),
    fov = 3.542275575055,
}
ITEM.description = ""
ITEM.equip_inv = 'head'
ITEM.equip_slot = nil
ITEM.bodyGroups = {
    [4] = 0,
}
ITEM.noRepair = true
ITEM.destroyable = true
ITEM.armor = {
    class = 2,
    max_durability = 350,
    density = 0.75,
    coverage = {
        [HITGROUP_HEAD] = 1,
    },
    penetration = {
        bullet = 0.75,
        impulse = 1,
        buckshot = 0.5,
        explosive = 0.75,
        burn = 1,
        poison = 0,
        slash = 1,
        club = 1,
        fists = 0.5
    },
    damage = {
        bullet = 2,
        impulse = 2,
        buckshot = 1,
        explosive = 0.5,
        burn = 1,
        poison = 1,
        slash = 2,
        club = 4,
        fists = 1
    }
}
ITEM.contraband = true

function ITEM:GetOutfitData()
    return {
        slot = "helmet",
        model = {
            [GENDER_MALE] = "models/cellar/male_helmet_nato.mdl",
            [GENDER_FEMALE] = "models/cellar/female_helmet_nato.mdl",
        }
    }
end
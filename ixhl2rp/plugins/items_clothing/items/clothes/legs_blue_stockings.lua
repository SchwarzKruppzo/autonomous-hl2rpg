ITEM.name = "Синяя юбка с колготками"
ITEM.model = "models/props_c17/SuitCase_Passenger_Physics.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.description = ""
ITEM.equip_inv = 'legs'
ITEM.equip_slot = nil
ITEM.bodyGroups = {
	[2] = 7,
}
ITEM.rarity = 2
ITEM.gender = GENDER_FEMALE

function ITEM:GetOutfitData()
    return {
        slot = "legs",
        model = {
            [GENDER_FEMALE] = "models/cellar/female_legs_stocks.mdl",
        }
    }
end

ITEM.BreakDown = true
ITEM.BreakDownType = "cloth"
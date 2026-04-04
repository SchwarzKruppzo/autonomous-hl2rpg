ITEM.name = "item.glass6"
ITEM.description = "item.glass6.desc"
ITEM.model = Model("models/cellar/liquid/glass6.mdl")

ITEM.volume = 150
ITEM.sip_amount = 50

ITEM.Liquid_PhysData = {
	[1] = {
		boneID = 2, 
		heightZ = 2.632,
		scaleXY = {
			{0, -1},
			{0.05, 0}
		}
	},
	[2] = {
		boneID = 1, 
		heightZ = 0,
		scaleXY = {
			{0, -1},
			{0.05, 0}
		},
		noHeightZ = true,
	}
}

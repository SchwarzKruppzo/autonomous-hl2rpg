ITEM.name = "item.glass9"
ITEM.description = "item.glass9.desc"
ITEM.model = Model("models/cellar/liquid/glass9.mdl")

ITEM.volume = 150
ITEM.sip_amount = 50

ITEM.Liquid_PhysData = {
	[1] = {
		boneID = 1, 
		heightZ = -3.368,
		scaleXY = {
			{0, -1},
			{1, 0}
		}
	},
	[2] = {
		boneID = 2, 
		heightZ = 0,
		scaleXY = {
			{0, -1},
			{0.1, 0}
		},
		noHeightZ = true,
	}
}

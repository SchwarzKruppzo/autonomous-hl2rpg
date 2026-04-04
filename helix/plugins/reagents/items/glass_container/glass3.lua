ITEM.name = "item.glass3"
ITEM.description = "item.glass3.desc"
ITEM.model = Model("models/cellar/liquid/glass3.mdl")

ITEM.volume = 300
ITEM.sip_amount = 50

ITEM.Liquid_PhysData = {
	[1] = {
		boneID = 2, 
		heightZ = -3.559,
		scaleXY = {
			{0, -1},
			{0.005, -0.1548},
			{1, 0}
		}
	},
	[2] = {
		boneID = 1, 
		heightZ = 0,
		scaleXY = {
			{0, -1},
			{0.005, 0}
		},
		noHeightZ = true,
	}
}

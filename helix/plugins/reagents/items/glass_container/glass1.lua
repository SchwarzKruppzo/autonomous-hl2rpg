ITEM.name = "item.glass1"
ITEM.description = "item.glass1.desc"
ITEM.model = Model("models/cellar/liquid/glass1.mdl")

ITEM.volume = 200
ITEM.sip_amount = 50

ITEM.Liquid_InvertHeightZ = true
ITEM.Liquid_PhysData = {
	[1] = {
		boneID = 3, 
		heightZ = -4.259,
		{
			{0, -1},
			{0.1, -0.275},
			{0.424, 0.14616},
			{1, 0}
		}
	},
	[2] = {
		boneID = 2, 
		heightZ = -1.378,
		scaleXY = {
			{0, -1},
			{0.1, -0.8},
			{0.424, -0.15},
			{1, 0}
		},
		noHeightZ = false,
		scaleZ = {
			{0, -0.7},
			{0.424, -0.7},
			{1, 0}
		}
	},
	[3] = {
		boneID = 1, 
		heightZ = 0,
		{
			{0, -1},
			{0.1, 0}
		},
		noHeightZ = true
	}
}

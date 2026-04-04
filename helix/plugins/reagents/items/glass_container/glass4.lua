ITEM.name = "item.glass4"
ITEM.description = "item.glass4.desc"
ITEM.model = Model("models/cellar/liquid/glass4.mdl")

ITEM.volume = 500
ITEM.sip_amount = 50

ITEM.Liquid_InvertHeightZ = true
ITEM.Liquid_ScaleXZY = true
ITEM.Liquid_PhysData = {
	[1] = {
		boneID = 2, 
		heightZ = -3.506,
		scaleXY = {
			{0, -1},
			{0.11, -0.01906},
			{0.58, 0.08639},
			{1, 0}
		}
	},
	[2] = {
		boneID = 1, 
		heightZ = 0,
		scaleXY = {
			{0, -1},
			{0.12, -0.28631},
			{0.58, -0.14288},
			{1, 0}
		},
		noHeightZ = true,
	}
}

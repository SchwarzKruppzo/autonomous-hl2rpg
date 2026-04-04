ITEM.name = "item.glass2"
ITEM.description = "item.glass2.desc"
ITEM.model = Model("models/cellar/liquid/glass2.mdl")

ITEM.volume = 60
ITEM.sip_amount = 10

ITEM.Liquid_PhysData = {
	[1] = {
		boneID = 2, 
		heightZ = 2.548,
		scaleXY = {
			{0, -1},
			{0.005, -0.15817},
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

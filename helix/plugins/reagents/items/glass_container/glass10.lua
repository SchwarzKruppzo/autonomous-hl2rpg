ITEM.name = "item.glass10"
ITEM.description = "item.glass10.desc"
ITEM.model = Model("models/cellar/liquid/glass10.mdl")

ITEM.volume = 250
ITEM.sip_amount = 50

ITEM.Liquid_PhysData = {
	[1] = {
		boneID = 2, 
		heightZ = -7.427,
		scaleXY = {
			{0, -1},
			{0.1, 0}
		}
	},
	[2] = {
		boneID = 1, 
		heightZ = 0,
		scaleXY = {
			{0, -1},
			{0.1, 0}
		},
		noHeightZ = true,
	}
}

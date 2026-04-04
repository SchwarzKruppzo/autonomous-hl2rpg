ITEM.name = "item.glass5"
ITEM.description = "item.glass5.desc"
ITEM.model = Model("models/cellar/liquid/glass5.mdl")

ITEM.volume = 180
ITEM.sip_amount = 50

ITEM.Liquid_PhysData = {
	[1] = {
		boneID = 3, 
		heightZ = -5.521,
		scaleXY = {
			{0, -1},
			{0.15, -0.4},
			{0.25, -0.1},
			{0.361, 0}
		},
		noHeightZ = false,
		scaleZ = {
			{0, -1},
			{0.25, -0.8},
			{1, 0}
		}
	},
	[2] = {
		boneID = 2, 
		heightZ = -1.998,
		scaleXY = {
			{0, -1},
			{0.361, -0.45},
			{1, 0}
		},
		noHeightZ = false,
		scaleZ = {
			{0, -1},
			{0.361, -0.95},
			{1, 0}
		}
	},
	[3] = {
		boneID = 1, 
		heightZ = 0,
		scaleXY = {
			{0, -1},
			{1, 0}
		},
		noHeightZ = true
	}
}

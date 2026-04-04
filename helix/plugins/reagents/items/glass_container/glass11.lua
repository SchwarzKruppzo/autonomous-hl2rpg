ITEM.name = "item.glass11"
ITEM.description = "item.glass11.desc"
ITEM.model = Model("models/cellar/liquid/pitcher.mdl")

ITEM.volume = 2000
ITEM.sip_amount = 50

ITEM.Liquid_PhysData = {
	[1] = {
		boneID = 1, 
		heightZ = -9.206,
		scaleXY = {
			{0, -1},
			{0.138, 0.18274},
			{0.39, 0.26656},
			{0.91, -0.05327},
			{1, 0}
		}
	},
	[2] = {
		boneID = 2, 
		heightZ = -8.394,
		scaleXY = {
			{0, -1},
			{0.138, 0.35},
			{0.39, 0.32723},
			{1, 0}
		}
	},
	[3] = {
		boneID = 3, 
		heightZ = -3.599,
		scaleXY = {
			{0, -1},
			{0.138, -0.1},
			{1, 0}
		}
	},
	[4] = {
		boneID = 4, 
		heightZ = 0,
		scaleXY = {
			{0, -1},
			{0.138, 0},
		},
		noHeightZ = true
	},
}

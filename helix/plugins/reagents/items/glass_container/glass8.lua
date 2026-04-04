ITEM.name = "item.glass8"
ITEM.description = "item.glass8.desc"
ITEM.model = Model("models/cellar/liquid/glass8.mdl")

ITEM.volume = 450
ITEM.sip_amount = 50

ITEM.Liquid_PhysData = {
	[1] = {
		boneID = 2, 
		heightZ = -5.214,
		scaleXY = {
			{0, -1},
			{0.1, 0.15},
			{0.588, 0.33007},
			{1, 0}
		}
	},
	[2] = {
		boneID = 1, 
		heightZ = 0,
		scaleXY = {
			{0, -1},
			{0.1, -0.65},
			{0.588, -0.025},
			{1, 0}
		},
		noHeightZ = true,
	}
}

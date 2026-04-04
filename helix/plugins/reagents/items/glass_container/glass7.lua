ITEM.name = "item.glass7"
ITEM.description = "item.glass7.desc"
ITEM.model = Model("models/cellar/liquid/glass7.mdl")

ITEM.volume = 400
ITEM.sip_amount = 50

ITEM.Liquid_PhysData = {
	[1] = {
		boneID = 3, 
		heightZ = -3.227,
		scaleXY = {
			{0, -1},
			{0.115, -0.3},
			{0.4, -0.05},
			{1, 0}
		}
	},
	[2] = {
		boneID = 2, 
		heightZ = -3.227,
		scaleXY = {
			{0, -1},
			{0.2, -0.1},
			{1, 0}
		}
	},
	[3] = {
		boneID = 1, 
		heightZ = 0,
		scaleXY = {
			{0, -1},
			{0.2, -0.9},
			{0.4, -0.225},
			{1, 0}
		},
		noHeightZ = true
	}
}

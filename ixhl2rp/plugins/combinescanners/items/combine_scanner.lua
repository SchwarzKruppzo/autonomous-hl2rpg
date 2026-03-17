local PLUGIN = PLUGIN

ITEM.name = "item.combine_scanner"
ITEM.description = "item.combine_scanner.desc"
ITEM.model = "models/Combine_Scanner.mdl"
ITEM.rarity = 2
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(65.359474182129, -22.143999099731, -10.739000320435),
	ang = Angle(-10, 160.00001525879, 1.457099642721e-05),
	fov = 24.117647058824,
}

ITEM.functions.activateScanner = {
	name = "scannerActivate",
	OnRun = function(item)
		return PLUGIN:ActivateScannerAsItem(item)
	end,
	OnCanRun = function(item)
		return !!item.entity
	end
}

ITEM.contraband = true
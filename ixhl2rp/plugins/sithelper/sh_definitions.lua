local PLUGIN = PLUGIN

local AnimHelper = ix.AnimHelper
local defaultSitOffset = { Vector(20, 0, -19) }

AnimHelper:Register("stances_sit01", {
	label = "Сесть 1",
	offset = defaultSitOffset
})

AnimHelper:Register("stances_sit02", {
	label = "Сесть 2",
	offset = defaultSitOffset
})

AnimHelper:Register("stances_sit03", {
	label = "Сесть 3",
	offset = defaultSitOffset
})

AnimHelper:Register("stances_sit04", {
	label = "Сесть 4",
	offset = defaultSitOffset
})

AnimHelper:Register("stances_sit05", {
	label = "Сесть 5",
	offset = defaultSitOffset
})

AnimHelper:Register("stances_sit06", {
	label = "Сесть 6",
	offset = defaultSitOffset
})

local femaleOffset = Vector(20, 0, -19)
local femaleBbox = { mins = Vector(-5, -5, 0), maxs = Vector(5, 5, 2) }
AnimHelper:Register("stances_sit07", {
	label = "Сесть 7",
	offset = {
		vector_origin,
		cellarFemale = femaleOffset,
		cellarFemaleMPF = femaleOffset,
	},
	bbox = {
		{ mins = Vector(-18, -18, 0), maxs = Vector(18, 18, 36) },
		cellarFemale = femaleBbox,
		cellarFemaleMPF = femaleBbox,
	}
})

AnimHelper:Register("stances_sit08", {
	label = "Сесть 8",
	offset = {
		Vector(20, 0, 0)
	}
})

AnimHelper:Register("stances_sit09", {
	label = "Сесть 9",
	offset = {
		Vector(20, 0, 0)
	}
})

AnimHelper:Register("stances_sitground", {
	label = "На земле",
	offset = {
		Vector(12, 0, 0)
	},
	bbox = {
		{ mins = Vector(-5, -5, 0), maxs = Vector(5, 5, 2) }
	},
})

AnimHelper:Register("stances_sitwall", {
	label = "У стены",
	offset = {
		Vector(12, 0, 0)
	},
	bbox = {
		{ mins = Vector(-5, -5, 0), maxs = Vector(5, 5, 32) }
	},
})


AnimHelper:Register("stances_stand01", {
	label = "Стоять 1"
})

AnimHelper:Register("stances_stand02", {
	label = "Стоять 2"
})

AnimHelper:Register("stances_stand03", {
	label = "Стоять 3"
})

AnimHelper:Register("stances_lean01", {
	label = "Опереться 1"
})

AnimHelper:Register("stances_lean02", {
	label = "Опереться 2"
})


AnimHelper:Register("stances_down01", {
	label = "Лечь 1"
})

AnimHelper:Register("stances_down02", {
	label = "Лечь 2"
})

AnimHelper:Register("stances_down03", {
	label = "Лечь 3"
})

AnimHelper:Register("stances_arrest", {
	label = "Арестован"
})


AnimHelper:Register("stances_check", {
	label = "Искать"
})


PLUGIN.AnimOptions = {
	{
		label = "Сесть",
		options = {
			"stances_sit01", 
			"stances_sit02",
			"stances_sit03", 
			"stances_sit04", 
			"stances_sit05", 
			"stances_sit06",
			"stances_sit07",
			"stances_sit08",
			"stances_sit09",
			"stances_sitground",
			"stances_sitwall",
			"stances_check"
		}
	},
	{
		label = "Стоять",
		options = {
			"stances_stand01", 
			"stances_stand02",
			"stances_stand03", 
		}
	},
	{
		label = "Опереться",
		options = {
			"stances_lean01", 
			"stances_lean02",
		}
	},
	{
		label = "Лечь",
		options = {
			"stances_down01", 
			"stances_down02",
			"stances_down03", 
			"stances_arrest"
		}
	}
}
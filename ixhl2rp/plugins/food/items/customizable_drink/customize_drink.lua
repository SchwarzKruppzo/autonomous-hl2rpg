ITEM.name = "Test Customize"
ITEM.description = "banan"
ITEM.model = "models/foodnhouseholditems/mcdburger.mdl"

ITEM.stats.container = false

ITEM.properties = { -- we'll keep this as an array to retain order
	{"name", ix.type.string, "My Customizable Item"},
	{"description", ix.type.string, "A brand-spankin' new item."},
	{"model", ix.type.string, "models/props_junk/watermelon01.mdl"},
	{"skin", ix.type.number, 0, 0, 100},
	{"material", ix.type.string, ""},
	{"rarity", ix.type.number, 0, 0, 4},
	{"width", ix.type.number, 1, 0, 6},
	{"height", ix.type.number, 1, 0, 6},
	{"uses", ix.type.number, 10, 0, 10},
	{"hunger", ix.type.number, 0, 0, 100},
	{"thirst", ix.type.number, 0, 0, 100},
	{"stamina", ix.type.number, 0, 0, 100},
}
FACTION.name = "faction.vortigaunt"
FACTION.info = "faction.vortigaunt.info"
FACTION.description = "faction.vortigaunt.desc"
FACTION.color = Color(86, 102, 13, 255)
FACTION.icon = Material("autonomous/factions/vortigaunt.png")
FACTION.models = {"models/autonomous/characters/vortigaunt_slave.mdl"}
FACTION.showCreationMenu = true
FACTION.genders = {1}
FACTION.isDefault = false
FACTION.bCanUseRations = true
FACTION.bAllowDatafile = true
FACTION.weapons = {"ix_vortbroom"}

FACTION.eyeColors = {
	{"красный", Color(242, 15, 15)},
	{"жёлтый", Color(242, 242, 15)},
	{"оранжевый", Color(242, 111, 15)}
}

FACTION.ageSelector = {
	"юный (0 - 50)",
	"молодой (50 - 250)",
	"зрелый (250 - 1000)",
	"мудрый (1000 - 2000)",
	"старый (2000 - 10000)"
}

function FACTION:GetRationType(client)
	return "ration_tier_0"
end

function FACTION:GetModels(client, gender)
	return self.models
end

FACTION_VORTIGAUNT = FACTION.index

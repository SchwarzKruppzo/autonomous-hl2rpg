FACTION.name = "Вортигонты"
FACTION.info = [[Раса вортигонтов - беженцы с других далеких миров. Оказавшись в пограничном мире Зен в ходе Каскадного Резонанса в попытках убежать от Альянса - они оказались у него под носом, когда тот поразил планету Земля. Узники своей совести, они виновники сотен убитых невинных людей. Вортигонтам хватает мудрости чтобы осознать свою вину, ведя себя смиренно даже не смотря на сохраняющуюся ненависть к своей расе.

В это тяжелое время возможности вортигонтов ограничены. Большая часть их расы была порабощена и переведена под власть Надзора для выполнения разных унизительных задач, пока оставшиеся на воле потеряли связь с единым разумом своей расы из-за подавителей установленных в каждом центре связи Надзора.]]

FACTION.description = "Таинственное существо из мира Зен. Его мудрость и знания могут стать мощным оружием."
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

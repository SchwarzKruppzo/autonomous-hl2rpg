FACTION.name = "Гражданин"
FACTION.info = [[Гражданские - основная масса человечества, истощенного Портальными Штормами и Семичасовой войной. Большая часть гражданских не имели возможности взяться за оружие, являясь простыми рабочими, программистами или же чиновниками не имеющими фактической власти. Обеспеченные пищей, водой - и что самое главное безопасностью они трудятся во благо Альянса.. либо же борятся с ним, помня о Старом Мире.
Жизнь в Секторе-4, к сожалению, во многом сравнима с трудовым лагерем. Плохое жилье, тяжелый труд, ужасные условия труда и постоянное присутствие военных. Для большинства местных жителей - труд во благо Альянса возможность приобрести "золотой билет" и переехать в Сектор-1, куда более богатый и процветающий. Для приезжих - возможность заработать большие деньги и вернуться в родной сектор богатым лоялистом.]]
FACTION.description = "A regular human citizen enslaved by the Universal Union."
FACTION.color = Color(150, 125, 100, 255)
FACTION.icon = Material("autonomous/factions/citizen.png")
FACTION.showCreationMenu = true
FACTION.isDefault = true
FACTION.bHumanVoices = true
FACTION.bCanUseRations = true
FACTION.bAllowDatafile = true
FACTION.models = {
	[1] = {
		"models/cellar/characters/oldcitizens/male_01.mdl",
		"models/cellar/characters/oldcitizens/male_02.mdl",
		"models/cellar/characters/oldcitizens/male_03.mdl",
		"models/cellar/characters/oldcitizens/male_04.mdl",
		"models/cellar/characters/oldcitizens/male_05.mdl",
		"models/cellar/characters/oldcitizens/male_06.mdl",
		"models/cellar/characters/oldcitizens/male_07.mdl",
		"models/cellar/characters/oldcitizens/male_08.mdl",
		"models/cellar/characters/oldcitizens/male_09.mdl",
		"models/cellar/characters/oldcitizens/male_10.mdl",
		"models/cellar/characters/oldcitizens/male_11.mdl",
		"models/cellar/characters/oldcitizens/male_12.mdl",
		"models/cellar/characters/oldcitizens/male_13.mdl",
		"models/cellar/characters/oldcitizens/male_14.mdl",
		"models/cellar/characters/oldcitizens/male_15.mdl",
		"models/cellar/characters/oldcitizens/male_16.mdl",
		"models/cellar/characters/oldcitizens/male_17.mdl",
		"models/cellar/characters/oldcitizens/male_18.mdl"
	},
	[2] = {
		"models/cellar/characters/oldcitizens/female_01.mdl",
		"models/cellar/characters/oldcitizens/female_02.mdl",
		"models/cellar/characters/oldcitizens/female_03.mdl",
		"models/cellar/characters/oldcitizens/female_04.mdl",
		"models/cellar/characters/oldcitizens/female_05.mdl",
		"models/cellar/characters/oldcitizens/female_06.mdl",
		"models/cellar/characters/oldcitizens/female_07.mdl",
		"models/cellar/characters/oldcitizens/female_08.mdl",
		"models/cellar/characters/oldcitizens/female_09.mdl",
		"models/cellar/characters/oldcitizens/female_10.mdl",
		"models/cellar/characters/oldcitizens/female_11.mdl",
		"models/cellar/characters/oldcitizens/female_12.mdl",
		"models/cellar/characters/oldcitizens/female_13.mdl",
		"models/cellar/characters/oldcitizens/female_14.mdl",
		"models/cellar/characters/oldcitizens/female_15.mdl",
		"models/cellar/characters/oldcitizens/female_16.mdl",
		"models/cellar/characters/oldcitizens/female_17.mdl",
		"models/cellar/characters/oldcitizens/female_18.mdl",
	},
}
FACTION.npcRelations = {
	["npc_strider"] = D_HT,
	["npc_metropolice"] = D_NU
}

function FACTION:GetModels(client, gender)
	return self.models[gender]
end

function FACTION:GetRationType(character)
	return Schema:GetCitizenRationTypes(character)
end

function FACTION:OnSpawn(client, firstTime)
	if firstTime then
		local character = client:GetCharacter()
		
		character:CreateIDCard("card")
	end
end

function FACTION:GenerateName(gender)
	local isMale = gender == 1
	local firstname = GetHumanFirstNames(isMale)[isMale and math.random(1, HUMAN_NAMES_MALE) or math.random(1, HUMAN_NAMES_FEMALE)]
	local lastname = GetHumanLastNames()[math.random(1, HUMAN_LASTNAMES)]

	return firstname:sub(1, 1):upper() .. firstname:sub(2):lower() .. " " .. lastname:sub(1, 1):upper() .. lastname:sub(2):lower()
end

FACTION_CITIZEN = FACTION.index

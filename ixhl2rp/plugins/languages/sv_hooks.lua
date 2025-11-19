local PLUGIN = PLUGIN

util.AddNetworkString("lang.change")

netstream.Hook("QueryDeleteLanguageSuccess", function(client)
	local character = client:GetCharacter()

	if !character then
		return
	end

	local learningLanguages = character:GetLearningLanguages() or {}

	table.Empty(learningLanguages)
	character:SetLearningLanguages(learningLanguages)
end)

local shouts = {
	"vo/outland_01/intro/ol01_vortcall01.wav",
	"vo/outland_01/intro/ol01_vortcall02c.wav",
	"vo/outland_01/intro/ol01_vortresp01.wav",
	"vo/outland_01/intro/ol01_vortresp04.wav"
}

netstream.Hook("ForceShoutAnim", function(client, speaker)
	if client != speaker then -- cringe
		return
	end

	speaker:EmitSound(table.Random(shouts), 150)
end)

net.Receive("lang.change", function(len, client)
	local lang = net.ReadString()

	client:SetLocalVar("lang", lang or nil)
end)

function PLUGIN:PrePlayerLoadedCharacter(client)
	client:SetLocalVar("lang", nil)
end

function PLUGIN:PlayerLoadedCharacter(client, character, currentChar)
	if client:Team() != FACTION_VORTIGAUNT then
		local knownLang = character:GetLanguages()

		if !knownLang or table.IsEmpty(knownLang) then
			client.selectingLang = true
			netstream.Start(client, "lang.select")
		end
	end
end

function PLUGIN:OnCharacterCreated(client, character)
	local defaultLang
/*
	if character:GetFaction() == FACTION_VORTIGAUNT then
		defaultLang = "vort"
	elseif character:GetFaction() == FACTION_ZOMBIE then
		defaultLang = "xen"
	elseif character:GetFaction() == FACTION_OTA or character:GetFaction() == FACTION_SYNTH then
		defaultLang = "imp"
	end*/

	if defaultLang then
		local knownLang = character:GetLanguages() or {}

		table.insert(knownLang, defaultLang)

		character:SetLanguages(knownLang)
	end
end

netstream.Hook("lang.select", function(client, value)
	if !client.selectingLang then
		return
	end

	local character = client:GetCharacter()

	if !value then
		local langs = {}
		for k, v in pairs(ix.languages.stored) do
			if v.notSelectable then continue end
		
			langs[#langs + 1] = v.uniqueID
		end

		value = langs[math.random(1, #langs)]
	end
	
	local language = ix.languages:FindByID(value)

	if language then
		local knownLanguages = character:GetLanguages()

		if !table.HasValue(knownLanguages, value) then
			table.insert(knownLanguages, value)
		end

		character:SetLanguages(knownLanguages)
	end

	client.selectingLang = nil
end)
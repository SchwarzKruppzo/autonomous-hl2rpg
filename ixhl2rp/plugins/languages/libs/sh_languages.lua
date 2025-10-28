
local ix = ix
local PLUGIN = PLUGIN

ix.languages = ix.languages or {}
ix.languages.stored = ix.languages.stored or {}

--[[
	Begin defining the language class base for other languages to inherit from.
--]]

--[[ Set the __index meta function of the class. --]]
--luacheck: globals CLASS_TABLE
local CLASS_TABLE = {__index = CLASS_TABLE}

CLASS_TABLE.name = "Language Base"
CLASS_TABLE.uniqueID = "language_base"
CLASS_TABLE.gibberish = {}
CLASS_TABLE.color = Color(102, 204, 255)
CLASS_TABLE.format = "%s says in language \"%s\""

-- Called when the language is converted to a string.
function CLASS_TABLE:__tostring()
	return "LANGUAGE["..self.name.."]"
end

--[[
	A function to override language base data. This is
	just a nicer way to set a value to go along with
	the method of querying.
--]]
function CLASS_TABLE:Override(varName, value)
	self[varName] = value
end

-- A function to register a new language.
function CLASS_TABLE:Register()
	return ix.languages:Register(self)
end

function CLASS_TABLE:PlayerCanSpeakLanguage(client)
	return ix.languages:PlayerCanSpeakLanguage(self.uniqueID, client)
end

--[[
	End defining the base language class.
	Begin defining the language utility functions.
--]]

-- A function to get all languages.
function ix.languages:GetAll()
	return self.stored
end

-- A function to get a new language.
function ix.languages:New(language)
	local object = {}
		setmetatable(object, CLASS_TABLE)
		CLASS_TABLE.__index = CLASS_TABLE
	return object
end

local function CanSay(self, speaker, text)
	local language = ix.languages:FindByID(self.langID)

	if (language:PlayerCanSpeakLanguage(speaker)) then
		return true
	end

	speaker:NotifyLocalized("Я не знаю этот язык..")
	return false
end

local OnChatAdd
if (CLIENT) then
	OnChatAdd = function(speaker, text, langID, sayType)
		local language = ix.languages:FindByID(langID)
		local icon = language.icon or nil
		if icon then
			icon = ix.util.GetMaterial(icon)
		end

		text = ix.chat.Format(text)

		if language:PlayerCanSpeakLanguage(LocalPlayer()) then
			if langID == "vort" and IsValid(speaker) and speaker:Team() == FACTION_VORTIGAUNT then
				if sayType and string.find(sayType, "shout") then
					PLUGIN:DoVortShout(speaker)
				end
			end

			return icon, " на "..language.chat, text
		else
			if language.gibberish then
				if istable(language.gibberish) then
					if !table.IsEmpty(language.gibberish) then
						local gibberish = language.gibberish
						local recreateLast = false
						local endText = string.utf8sub(text, -1)  -- Is it shout, question or period? If yes save it to recreate it after gibberish.
						if (endText == "." or endText == "!" or endText == "?") then
							recreateLast = true
						end

						local splitWords = string.Split(text, " ")
						text = ""

						for _, _ in pairs(splitWords) do
							if math.random(0,5) == 3 then
								text = text..gibberish[math.random( #gibberish )].."'"
							else
								text = text..gibberish[math.random( #gibberish )].." "
							end
						end

						-- Remove space at end
						text = string.TrimRight(text)
						-- Make a period at the ending.
						if (recreateLast) then
							text = (text..endText)
						end

						endText = string.utf8sub(text, -1)
						if (endText != "." and endText != "!" and endText != "?") then
							text = (text..".")
						end

						-- Make capital at start
						local editCapital = string.utf8sub(text, 1, 1)
						text = (string.utf8upper(editCapital)..string.utf8sub(text, 2, string.utf8len(text)))

						return icon, " на "..language.chat, text
					end
				end
			end

			return icon, " что-то на "..language.chat, ""
		end
	end
end

ix.languages.OnChatAdd = OnChatAdd

-- A function to register a new language.
function ix.languages:Register(language)
	language.uniqueID = string.utf8lower(string.gsub(language.uniqueID or string.gsub(language.name, "%s", "_"), "['%.]", ""))
	self.stored[language.uniqueID] = language

	if language.uniqueID == "vort" then
		local languageClassShout = {}
		languageClassShout.sayType = "shouts"
		languageClassShout.format = " \"%s\""
		languageClassShout.CanHear = ix.config.Get("chatRange", 280) * 20
		languageClassShout.indicator = "chatYelling"
		languageClassShout.prefix = "/vortshout"
		languageClassShout.description = "Взывает на языке Вортов, может покрыть собой половину игровой карты."
		languageClassShout.langID = language.uniqueID
		languageClassShout.CanSay = CanSay
		languageClassShout.color = Color(150, 125, 175)

		if (CLIENT) then
			languageClassShout.OnChatAdd = function(self, speaker, text, anonymous, info)
				local icon, langPrefix, text = ix.languages.OnChatAdd(speaker, text, "vort", "shout")

				local name = anonymous and
					L"someone" or hook.Run("GetCharacterName", speaker, "y") or
					(IsValid(speaker) and speaker:Name() or "Console")

				chat.AddText(icon or "", self.color, ix.util.GetMaterial("cellar/chat/broadcast.png"), name, " взывает", langPrefix or "", color_white, string.format(self.format, text))
			end
		end

		ix.chat.Register("vortshout", languageClassShout)

		if (CLIENT) then
			ix.command.list["vortshout"].OnCheckAccess = function(_, client) return language:PlayerCanSpeakLanguage(client) end
			ix.command.list["vortshout"].combineBeep = true
		end
	end
end

-- A function to get a language by its name.
function ix.languages:FindByID(identifier)
	if (identifier and identifier != 0 and type(identifier) != "boolean") then
		if (self.stored[identifier]) then
			return self.stored[identifier]
		end

		local lowerName = string.utf8lower(identifier)
		local language = nil

		for _, v in pairs(self.stored) do
			local languageName = v.name

			if (string.find(string.utf8lower(languageName), lowerName)
			and (!language or string.utf8len(languageName) < string.utf8len(language.name))) then
				language = v
			end
		end

		return language
	end
end

-- Called when the language is initialized
function ix.languages:Initialize()
	local languages = self:GetAll()

	for _, v in pairs(languages) do
		if (v.OnSetup) then
			v:OnSetup()
		end
	end
end

-- Called when a player attempts to speak a language
function ix.languages:PlayerCanSpeakLanguage(language, client)
	if (client:GetMoveType() == MOVETYPE_NOCLIP and !client:InVehicle()) then return true end
	local clientFaction = client:Team()
	if clientFaction then
		if (ix.faction.Get(clientFaction).allLanguages) then
			return true
		end
	end

	local languages = client:GetCharacter():GetLanguages()
	if (languages) then
		if (!table.IsEmpty(languages) and table.HasValue(languages, language)) then
			return true
		end
	end

	return false
end

ix.command.Add("CharCheckLanguage", {
	description = "Проверить языки персонажа.",
	adminOnly = true,
	arguments = {
		ix.type.character
	},
	alias = "CharLanguages",
	OnRun = function(self, client, target)
		if (SERVER) then
			local knownLanguages = target:GetLanguages()
			local langs = ""

			for k, v in pairs(knownLanguages) do
				local lang = ix.languages:FindByID(v)

				langs = langs .. lang.name .. ((k != #knownLanguages) and ", " or "")
			end

			client:ChatNotify(target:GetName() .. " знает следующие языки: "..langs)
		end
	end
})

ix.command.Add("CharSetLanguage", {
	description = "Добавить указанный язык в пользование персонажа.",
	adminOnly = true,
	arguments = {ix.type.character, ix.type.text},
	alias = "CharSetBilingual",
	OnRun = function(self, client, character, lang)
		if (character) then
			local language = ix.languages:FindByID(lang)
			if (language) then
				local knownLanguages = character:GetLanguages()
				if (table.HasValue(knownLanguages, language.uniqueID)) then
					client:NotifyLocalized("Этот персонаж уже знает "..language.name.."!")
					return false
				else
					table.insert(knownLanguages, language.uniqueID)
					character:SetLanguages(knownLanguages)
					client:NotifyLocalized("Вы добавили персонажу "..character:GetName().." язык "..language.name)
				end
			else
				client:NotifyLocalized("Этот язык несуществует!")
				return false
			end
		else
			client:NotifyLocalized("Указанный персонаж не найден!")
			return false
		end
	end
})

ix.command.Add("CharRemoveLanguage", {
	description = "Забрать указанный язык из пользования персонажа.",
	adminOnly = true,
	arguments = {ix.type.character, ix.type.text},
	OnRun = function(self, client, character, lang)
		if (character) then
			local language = ix.languages:FindByID(lang)
			if (language) then
				local knownLanguages = character:GetLanguages()
				if (!table.HasValue(knownLanguages, language.uniqueID)) then
					client:NotifyLocalized("Этот персонаж не знает "..language.name.."!")
					return false
				else
					table.RemoveByValue(knownLanguages, language.uniqueID)
					character:SetLanguages(knownLanguages)
					client:NotifyLocalized("Вы забрали язык "..language.name.." из использования персонажем "..character:GetName()..".")
				end
			else
				client:NotifyLocalized("Этот язык несуществует!")
				return false
			end
		else
			client:NotifyLocalized("Указанный персонаж не найден!")
			return false
		end
	end
})

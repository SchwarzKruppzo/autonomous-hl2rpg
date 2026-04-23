
PLUGIN.name = "Radios"
PLUGIN.author = "Gr4Ss"
PLUGIN.description = "Adds various radios and radio channels."

ix.char.RegisterVar("radioChannels", {
	field = "radio_channels",
	fieldType = ix.type.text,
	default = {},
	isLocal = true,
	Net = {
		Transmit = ix.transmit.owner
	},
	bNoDisplay = true
})

ix.config.Add("radioNoclipEavesdrop", false, "Whether or not players in observer can eavesdrop radio conversations.", nil, {
	category = "Chat"
})

ix.option.Add("radioHideFreq", ix.type.bool, false, {
	category = "radioCategory",
})

ix.Net:AddEntityVar("on", nil, ix.Net.Type.All)
ix.Net:AddEntityVar("freq", nil, ix.Net.Type.All)
ix.Net:AddEntityVar("tuningEnabled", nil, ix.Net.Type.All)
ix.Net:AddEntityVar("item", nil, ix.Net.Type.All)
ix.Net:AddPlayerVar("radioChannel", false, nil, ix.Net.Type.String)


--[[
	-- radio
	radioNotOn = "Your radio isn't on!",
	radioRequired = "You need a radio to do this!",
	radioAlreadyOn = "You already have a radio that is turned on!",
	radioFreqFormat = "You have specified an invalid radio frequency format!",
	radioFreqSet = "You have set your radio frequency to %s.",
]]

local typeTextKeys = {
	[1] = "radioSpeaks",
	[2] = "radioShouts",
	[3] = "radioWhispers"
}

local typeTextStyles = {
	[2] = {
		size = 24,
		bold = true
	},
	[3] = {
		size = 11,
	}
}

function PLUGIN:InitializedChatClasses()
	local iconDefault = ix.util.GetMaterial("cellar/chat/radio_hand.png")

	ix.chat.Register("radio", {
		color = Color(75, 150, 50),
		format = "radioFormat",
		bReceiveVoices = true,
		indicator = "chatRadioing",
		SelectStyle = function(class, speaker, data)
			return typeTextStyles[data.typeText]
		end,
		OnChatAdd = function(class, speaker, text, bAnonymous, data)
			local langIcon, langPrefix

			if data.lang then
				langIcon, langPrefix, text = ix.languages.OnChatAdd(speaker, text, data.lang)
			end

			local name = hook.Run("GetCharacterName", speaker, class.uniqueID) or IsValid(speaker) and speaker:Name()

			if (table.Count(data.transmitTable) == 1) then
				local targetChannel = next(data.transmitTable)
				local channelNumber = data.transmitTable[targetChannel]

				if (!isbool(channelNumber)) then
					data.channel = ix.radio:FormatRadioChannel(targetChannel, channelNumber)
				end
			end

			local channelTable = ix.radio:FindByID(data.channelID)
			local icon = iconDefault

			if channelTable then
				icon = channelTable.icon or icon
			end

			data.useSound = true
			hook.Run("AdjustRadioTransmit", data)

			local hideFreq = ix.option.Get("radioHideFreq", false)
			local channel = string.upper(data.channel)

			if hideFreq then
				channel = "???.?"
			end

			local typeText = L(typeTextKeys[data.typeText] or typeTextKeys[1])
			chat.AddText(langIcon or "", data.color or class.color, icon, string.format("[%s] ", channel),
				ix.chat.Link("player", name, speaker:GetCharacter():GetID()), L(class.format, typeText, L("radioVia"), langPrefix or "", text))


			if (data.useSound and isstring(data.sound)) then
				surface.PlaySound(data.sound)
			end

			return text
		end
	})

	-- radio eavesdrop
	ix.chat.Register("radio_eavesdrop", {
		color = Color(255, 255, 150),
		format = "radioFormatEavesdrop",
		SelectStyle = function(class, speaker, data)
			return typeTextStyles[data.typeText]
		end,
		OnChatAdd = function(class, speaker, text, bAnonymous, data)
			local langIcon, langPrefix

			if data.lang then
				langIcon, langPrefix, text = ix.languages.OnChatAdd(speaker, text, data.lang)
			end

			local name = hook.Run("GetCharacterName", speaker, class.uniqueID) or IsValid(speaker) and speaker:Name()

			data.useSound = false
			hook.Run("AdjustRadioEavesdrop", data)

			local typeText = L(typeTextKeys[data.typeText] or typeTextKeys[1])
			chat.AddText(langIcon or "", class.color, ix.util.GetMaterial("cellar/chat/eaves_radiohand.png"),
				ix.chat.Link("player", name, speaker:GetCharacter():GetID()), L(class.format, typeText, L("radioVia"), langPrefix or "", text))

			if (data.useSound and isstring(data.sound)) then
				surface.PlaySound(data.sound)
			end

			return text
		end
	})
end
PLUGIN:InitializedChatClasses()
ix.util.Include("meta/sv_player.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_channels.lua")
ix.util.Include("sh_commands.lua")

local PLUGIN = PLUGIN

PLUGIN.name = "Request Device"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

function PLUGIN:InitializedChatClasses()
	ix.chat.Register("request", {
		color = Color(255, 165, 32),
		format = "Запрос от %s, #%s - \"%s\"",
		bReceiveVoices = true,
		CanHear = function(class, speaker, listener)
			return listener:IsCombine() or listener:IsCityAdmin()
		end,
		OnChatAdd = function(class, speaker, text, bAnonymous, info)
			chat.AddText(class.color, ix.util.GetMaterial("cellar/chat/request.png"), string.format(class.format, info.name, info.cid, text))

			-- TODO: add waypoint

			Schema:AddCombineDisplayMessage("@cRequest")
		end
	})

	ix.chat.Register("request_eavesdrop", {
		color = Color(255, 255, 150),
		format = "%s запрашивает \"%s\"",
		CanHear = function(class, speaker, listener)
			if ix.chat.classes.request:CanHear(speaker, listener) then
				return false
			end

			local chatRange = ix.config.Get("chatRange", 280)

			return (!speaker:IsCombine() and !listener:IsCombine())
			and (speaker:GetPos() - listener:GetPos()):LengthSqr() <= (chatRange * chatRange)
		end,
		OnChatAdd = function(class, speaker, text)
			local name = hook.Run("GetCharacterName", speaker, class.uniqueID) or IsValid(speaker) and speaker:Name()

			chat.AddText(class.color, ix.util.GetMaterial("cellar/chat/eaves_request.png"), string.format(class.format, name, text))
		end
	})

	ix.chat.Register("request_loopback", {
		color = Color(255, 165, 32),
		format = "Устройство запроса передает \"%s\"",
		OnChatAdd = function(class, speaker, text)
			chat.AddText(class.color, ix.util.GetMaterial("cellar/chat/request.png"), string.format(class.format, text))

			if LocalPlayer() != speaker then
				surface.PlaySound("npc/scanner/scanner_scan4.wav")
			end
		end
	})
end

PLUGIN:InitializedChatClasses()

do
	local function Request(client, text)
		local item = client.ixRequestDevice

		if client.lastRequestTime and client.lastRequestTime > CurTime() then
			return
		end

		if item and item:GetOwner() == client then
			local name, citizenID = "UNKNOWN", "?????"
			local cidItemID = client:GetFirstAtSlot(1, 1, 'cid')
			local cid

			if cidItemID then
				cid = ix.Item.instances[cidItemID]

				if cid then
					name = cid:GetData("name") or name
					citizenID = cid:GetData("cid") or citizenID
				end
			end

			ix.chat.Send(client, "request", text, nil, nil, {
				name = name,
				cid = citizenID
			})

			ix.chat.Send(client, "request_eavesdrop", text)

			client.lastRequestTime = CurTime() + 5
		end
	end

	if SERVER then
		netstream.Hook("ixRequest", Request)
	end

	ix.command.Add("Request", {
		arguments = ix.type.text,
		alias = "запрос",
		indicator = "chatRDevice",
		OnRun = function(self, client, message)
			local itemID = client:GetFirstAtSlot(1, 1, 'ears')
			local device

			if itemID then
				device = ix.Item.instances[itemID]
			end

			if device then
				if !client:IsRestricted() then
					client.ixRequestDevice = device

					Request(client, message)
				else
					return "@notNow"
				end
			else
				return "@needRequestDevice"
			end
		end
	})

	ix.command.Add("ReplyRequest", {
		arguments = {
			ix.type.string,
			ix.type.text
		},
		alias = "уз",
		OnRun = function(self, client, cid, message)
			if !client:IsCombine() and !client:IsCityAdmin() then
				return
			end

			local devices = {}
			local found

			for _, ply in ipairs(player.GetAll()) do
				local character = ply:GetCharacter()
				if !character then continue end

				local itemID = ply:GetFirstAtSlot(1, 1, 'ears')

				if itemID then
					table.insert(devices, ply)
				end
			end

			for _, ply in ipairs(devices) do
				local itemID = ply:GetFirstAtSlot(1, 1, 'cid')
				local card = ix.Item.instances[itemID]

				if card and card:GetData("cid") == cid then
					found = ply
					break
				end
			end

			if IsValid(found) then
				ix.chat.Send(client, "request_loopback", message, false, {client, found}, {target = found})
			else
				return "@rdNotFound"
			end
		end
	})
end

ix.lang.AddTable("english", {
	rdNotFound = "Request device with assigned CID is not found!",
})

ix.lang.AddTable("russian", {
	rdNotFound = "Устройство запроса с таким CID не найдено или превышено время отклика!",
})
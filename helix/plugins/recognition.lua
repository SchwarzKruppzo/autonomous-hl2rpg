
PLUGIN.name = "Recognition"
PLUGIN.author = "Chessnut"
PLUGIN.description = "Adds the ability to recognize people."

ix.Net:AddPlayerVar("hide", false, nil, ix.Net.Type.CharacterID)

do
	local character = ix.meta.character

	function character:DoesRecognize(id)
		if (!isnumber(id) and id.GetID) then
			id = id:GetID()
		end

		return hook.Run("IsCharacterRecognized", self, id)
	end

	function PLUGIN:IsCharacterRecognized(char, id)
		if (char.id == id) then
			return true
		end

		local other = ix.char.loaded[id]

		if (other) then
			local client = other:GetPlayer()
			
			if client then
				if client:GetNetVar("hide", 0) == id then
					return false
				end
			end
			
			local faction = ix.faction.indices[other:GetFaction()]

			if (faction and faction.isGloballyRecognized) then
				if client and client:IsCityAdmin() then
					return true
				end

				return char:IsCityAdmin() or char:IsCombine() or (Schema:GetFactionGroup(char:GetFaction()) == Schema:GetFactionGroup(other:GetFaction()))
			end
		end

		local owner = LocalPlayer()

		if owner.recognize[id] and owner.recognize[id] != "" then
			return true
		end
	end
end

if (CLIENT) then
	ix.recognize = ix.recognize or {}
	ix.recognize_init = ix.recognize_init or false

	CHAT_RECOGNIZED = CHAT_RECOGNIZED or {}
	CHAT_RECOGNIZED["ic"] = true
	CHAT_RECOGNIZED["y"] = true
	CHAT_RECOGNIZED["w"] = true
	CHAT_RECOGNIZED["me"] = true

	function PLUGIN:IsRecognizedChatType(chatType)
		if (CHAT_RECOGNIZED[chatType]) then
			return true
		end
	end

	function PLUGIN:GetCharacterDescription(client)
		if (client:GetCharacter() and client != LocalPlayer() and LocalPlayer():GetCharacter() and
			!LocalPlayer():GetCharacter():DoesRecognize(client:GetCharacter()) and !hook.Run("IsPlayerRecognized", client)) then
			return L"noRecog"
		end
	end

	function PLUGIN:ShouldAllowScoreboardOverride(client)
		if (ix.config.Get("scoreboardRecognition")) then
			return true
		end
	end

	function PLUGIN:GetCharacterName(client, chatType)
		local owner = LocalPlayer()
		owner.recognize = owner.recognize or {}

		if (client != owner) then
			local character = client:GetCharacter()
			local ourCharacter = LocalPlayer():GetCharacter()

			if (ourCharacter and character and !ourCharacter:DoesRecognize(character) and !hook.Run("IsPlayerRecognized", client)) then
				if (chatType and hook.Run("IsRecognizedChatType", chatType)) then
					local description = character:GetDescription()

					if (#description > 40) then
						description = description:utf8sub(1, 37).."..."
					end

					return "["..description.."]"
				elseif (!chatType) then
					return L"unknown"
				end
			else
				local faction = ix.faction.indices[client:Team()]

				if (faction and faction.isGloballyRecognized) then
					if client and client:IsCityAdmin() then
						return character:GetName()
					end

					return (owner:IsCityAdmin() or owner:IsCombine() or (Schema:GetFactionGroup(owner:Team()) == Schema:GetFactionGroup(client:Team()))) and character:GetName()
				end

				return owner.recognize[character:GetID()]
			end
		else
			return owner:Name()
		end
	end

	function PLUGIN:CharacterLoaded()
		local client = LocalPlayer()
		local character = client:GetCharacter()
		local id = character:GetID()

		if !ix.recognize_init then
			ix.recognize = ix.data.Get("recognition", {}, false, true)

			ix.recognize_init = true
		end
		
		if ix.recognize[id] then
			client.recognize = table.Copy(ix.recognize[id])
		else
			client.recognize = {}
		end
	end

	net.Receive("recognize.menu", function()
		if ix.gui.recognize then
			return
		end

		local client = LocalPlayer()
		local character = client:GetCharacter()

		if !character then return end
		local target = client:GetEyeTraceNoCursor().Entity

		if !target:IsPlayer() or (target:GetPos():Distance(client:GetShootPos()) > 128) then return end

		local targetCharacter = target:GetCharacter()

		if target:GetNetVar("hide", 0) == targetCharacter:GetID() then return end
		if target:Team() == FACTION_MPF or target:Team() == FACTION_OTA then return end

		ix.gui.recognize = true

		local name = hook.Run("GetCharacterName", target, "ic")

		Derma_StringRequest("Запомнить персонажа", "Как вы хотите запомнить персонажа "..name.."?", "", function(text)
			ix.gui.recognize = nil

			client.recognize = client.recognize or {}
			client.recognize[targetCharacter:GetID()] = text

			local id = character:GetID()
			ix.recognize[id] = ix.recognize[id] or {}
			ix.recognize[id] = table.Copy(client.recognize)

			ix.data.Set("recognition", ix.recognize, false, true)

			surface.PlaySound("buttons/button17.wav")
		end, function() 
			ix.gui.recognize = nil
		end)
	end)
else
	util.AddNetworkString("recognize.menu")

	function PLUGIN:ShowSpare1(client)
		if (client:GetCharacter()) then
			net.Start("recognize.menu")
			net.Send(client)
		end
	end
end

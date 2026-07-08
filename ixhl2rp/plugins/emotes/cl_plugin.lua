do
	local meta = FindMetaTable("Player")

	function meta:Emote(chatType, emoteType, ...)
		local args = {...}
		chatType = string.lower(chatType)

		local class = ix.chat.classes[chatType]

		if class and class:CanSay(self, text) != false then
			for k, v in pairs(args) do
				if v:sub(1, 1) != "@" then continue end
				args[k] = L(v:sub(2))
			end

			if self == LocalPlayer() then
				emoteType = "l"..emoteType
				ix.chat.Send(self, chatType, L(emoteType, unpack(args)))
			else
				ix.chat.Send(self, chatType, L(emoteType, self:Name(), unpack(args)))
			end
		end
	end
end

net.Receive("ixEmote", function(len)
	local client = net.ReadEntity()

	if !IsValid(client) then
		return
	end

	local chatType = net.ReadString()
	local emoteType = net.ReadString()
	local args = net.ReadTable()

	client:Emote(chatType, emoteType, unpack(args))
end)
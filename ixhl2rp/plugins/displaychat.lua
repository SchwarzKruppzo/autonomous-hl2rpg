local PLUGIN = PLUGIN

PLUGIN.name = "Display Chat Messages"
PLUGIN.description = "Displays what other characters saying above their heads (toggleable)."
PLUGIN.author = "anonymous"
PLUGIN.version = 1.5

ix.option.Add("chatDisplayEnabled", ix.type.bool, true, {
	category = "Чат над головой"
})

ix.option.Add("chatDisplayLength", ix.type.number, 256, {
	category = "Чат над головой",
	min = 10, max = 2048
})

ix.option.Add("chatDisplayDurationPerSymbol", ix.type.number, 0.5, {
	category = "Чат над головой",
	min = 0.01, max = 1, decimals = 2
})

if (SERVER) then return end

local stored = PLUGIN.chatDisplay or {}
PLUGIN.chatDisplay = stored

function PLUGIN:MessageReceived(client, messageInfo)
	if (IsValid(client) and client != LocalPlayer() and ix.option.Get("chatDisplayEnabled", false)) then
		if (hook.Run("ShouldChatMessageDisplay2", client, messageInfo) != false) then
			local class = ix.chat.classes[messageInfo.chatType]
			local maxLen = ix.option.Get("chatDisplayLength")
			local text = messageInfo.text
			local textLen = string.utf8len(text)
			local duration = math.max(2, math.min(textLen, maxLen) * ix.option.Get("chatDisplayDurationPerSymbol"))
			
			stored[client] = {
				text = textLen > maxLen and utf8.sub(text, 1, ix.option.Get("chatDisplayLength")).."..." or text,
				color = class and class.color or color_white,
				fadeTime = duration
			}
		end
	end
end

local whitelist = {
	["request"] = true,
	["radio_eavesdrop"] = true,
	["mel"] = true,
	["mec"] = true,
	["med"] = true,
	["ic"] = true,
	["me"] = true,
	["w"] = true,
	["y"] = true,
	["roll"] = true
}

hook.Add("ShouldChatMessageDisplay2", "displaychat", function(client, messageInfo)
	if (messageInfo.anonymous) then
		return false
	end

	if (!whitelist[messageInfo.chatType]) then
		return false
	end

	if (LocalPlayer():EyePos():DistToSqr(client:EyePos()) >= 300 * 300) then
		return false
	end
end)

function PLUGIN:HUDPaint()
	if (ix.option.Get("chatDisplayEnabled", false) and stored and !table.IsEmpty(stored)) then
		local client = LocalPlayer()
		local clientPos = client:EyePos()
		local scrW = ScrW()
		local cx, cy = scrW * 0.5, ScrH() * 0.5
		local curTime = CurTime()
		local toRem = {}

		for k, v in pairs(stored) do
			if (IsValid(k)) then
				local targetPos = hook.Run("GetTypingIndicatorPosition", k)
				local pos = targetPos:ToScreen()
				local distSqr = clientPos:DistToSqr(targetPos)

				if (distSqr <= 300 * 300) then
					local camMult = (1 - math.Distance(cx, cy, pos.x, pos.y) / scrW * 1.5)
					local distanceMult = (1 - distSqr * 0.003 * 0.003) -- 0.003 == 1/300
					local alpha = 255 * camMult * distanceMult * math.min(v.fadeTime, 1)
					local col1, col2 = ColorAlpha(v.color, alpha), Color(0, 0, 0, alpha)
					local font = "ixGenericFont"

				surface.SetFont(font)

				local fullW, fullH = surface.GetTextSize(v.text)
				local lines = ix.util.WrapText(v.text, scrW * 0.25, font)
				local offset = 4
				local curY = pos.y - ((fullH + offset) * #lines) / 2

				for k1, v1 in pairs(lines) do
					local w, h = surface.GetTextSize(v1)

					draw.SimpleTextOutlined(v1, font, pos.x - w / 2, curY, col1, nil, nil, 1, col2)

					curY = curY + h + offset
				end

				v.fadeTime = v.fadeTime - FrameTime()

					if (v.fadeTime <= 0) then
						table.insert(toRem, k)
					end
				else
					table.insert(toRem, k)
				end
			else
				table.insert(toRem, k)
			end
		end

		for k, v in pairs(toRem) do
			stored[v] = nil
		end
	end
end

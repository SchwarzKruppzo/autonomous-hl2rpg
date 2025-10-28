local chatBorder = 32
local indentFromChat = 4
local flagMargin = 2

local PANEL = {}

function PANEL:Init()
	self.flag = self:Add("DImageButton")
	self.flag:Dock(FILL)
	self.flag:DockMargin(flagMargin, flagMargin, flagMargin, flagMargin)
	self.flag.DoClick = function(this)
		if IsValid(self.frame) then
			self.frame:Remove()
			self.frame = nil
		end

		local client = LocalPlayer()
		local character = client:GetCharacter()

		if character then
			local languages = character:GetLanguages()
			local chatLanguages = {}

			for k, id in pairs(languages) do
				local info = ix.languages:FindByID(id)

				chatLanguages[#chatLanguages + 1] = {name = info.name, icon = info.icon, tag = id}
			end

			chatLanguages[#chatLanguages + 1] = {name = "По-умолчанию", icon = "flags16/gb.png", tag = nil}

			if !table.IsEmpty(chatLanguages) then
				local menu = DermaMenu()
				for k, v in ipairs(chatLanguages) do
					local option = menu:AddOption(v.name, function()
						net.Start("lang.change")
							if v.tag then
								net.WriteString(v.tag)
							end
						net.SendToServer()

						self:ChangeFlagIcon(v.tag)
					end)

					if v.icon then
						option:SetIcon(v.icon)
					end
				end
				menu:Open()
			end
		end
	end

	self:SetAlpha(0)
	self.alpha = 0

	self:SetSize(chatBorder, chatBorder * 0.75)
	self:CorrectPosition()
end

function PANEL:CorrectPosition(chatX, chatY, chatW, chatH)	
	if (!chatX or !chatY or !chatW or !chatH) then
		local chatbox = ix.gui.chat

		chatX, chatY = chatbox:GetPos()
		chatW, chatH = chatbox:GetSize()
	end

	local selfW, selfH = self:GetSize()

	local overChatX = chatX + chatW + indentFromChat
	local chatLevelX = chatX + chatW - selfW
	local underChatY = chatY + chatH + indentFromChat

	if (overChatX + selfW <= ScrW()) then
		self:SetPos(overChatX, chatY + chatH - selfH)
	elseif (underChatY + selfH <= ScrH()) then
		self:SetPos(chatLevelX, underChatY)
	else
		self:SetPos(chatLevelX, chatY - selfH - indentFromChat)
	end
end

function PANEL:ChangeFlagIcon(lang)
	local icon = "flags16/gb.png"

	if lang then
		local info = ix.languages:FindByID(lang)
		icon = info.icon
	end

	self.flag:SetMaterial(icon)
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(color_black:Unpack())
	self:DrawOutlinedRect()

	local newAlpha = ix.gui.chat.alpha

	if (self.alpha != newAlpha) then
		self:SetAlpha(newAlpha)

		self.alpha = newAlpha
	end
end

vgui.Register("ixLanguageChatButton", PANEL, "Panel")
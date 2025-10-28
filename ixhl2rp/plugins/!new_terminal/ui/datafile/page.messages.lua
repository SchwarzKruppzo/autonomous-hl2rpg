local PANEL = {}

PANEL.colors = {
	base = ix.Palette.combineblue,
	bg1 = ix.Palette.combineblue:Alpha(25),
	bg2 = ix.Palette.combineblue:Alpha(50),
	timestamp = ix.Palette.combineblue:Alpha(64),
	author = ix.Palette.combineblue:Alpha(175),
	read = ix.Palette.combineyellow:Alpha(225),
	hover = ix.Palette.combineblue:Alpha(64),
}
function PANEL:Init()
	self:SetText("")
	self:SetAlpha(0)

	local timestamp = self:Add("DLabel")
	timestamp:SetFont("cmb.terminal.medium12")
	timestamp:SetContentAlignment(3)
	timestamp:SetText("")
	timestamp:SizeToContents()

	local topPanel = self:Add("Panel")
	topPanel:Dock(TOP)
	topPanel:DockMargin(30, 4, 0, 0)

	local title = topPanel:Add("DLabel")
	title:SetFont("cmb.terminal.light17")
	title:Dock(LEFT)
	title:DockMargin(0, 0, 15, 0)
	title:SetText("")
	title:SizeToContents()

	local author = self:Add("DLabel")
	author:SetFont("cmb.terminal.medium12")
	author:Dock(TOP)
	author:DockMargin(30, 2, 0, 0)
	author:SetText("")
	author:SizeToContents()


	self.author = author
	self.top = topPanel
	self.title = title
	self.timeStamp = timestamp
	self.hoverClr = self.colors.hover

	self.id = 0
	self.isSender = false
	self.isRead = false

	local click = self:Add("DButton")
	click:SetText("")
	click:SetAlpha(0)

	self.click = click

	self.click.OnCursorEntered = function(this)
		self:CursorEntered()
	end

	self.click.OnCursorExited = function()
		self:CursorExited()
	end
end

function PANEL:Setup(id, data)
	local clr = self.colors

	self.id = data.id


	if id == 1 then
		self.isRead = true
	end

	self.timeStamp:SetText(os.date("%d/%m/%y - %H:%M:%S", data.timestamp))
	self.timeStamp:SetTextColor(self.isRead and color_black or clr.timestamp)
	self.timeStamp:SizeToContents()

	self.title:SetText(data.title)
	self.title:SetTextColor(self.isRead and color_black or ix.Palette.combinegreen)
	self.title:SizeToContents()

	self.hoverClr = self.colors.hover
	if self.isRead then
		self.title:SetFont("cmb.terminal.medium16z")
		--self.hoverClr = table.Copy(ix.Palette.combineyellow)
	end

	self.top:SizeToChildren(false, true)

	self.author:SetText("ОТ: "..data.sender_name:utf8upper())
	self.author:SetTextColor(self.isRead and color_black or clr.author)
	self.author:SizeToContents()

	self:SetAlpha(255)
end

function PANEL:PerformLayout(w, h)
	self.click:SetSize(w, h)

	self.timeStamp:SetY(self.author:GetY())
	self.timeStamp:AlignRight(10)
end

function PANEL:OnMousePressed(code)
	self.pressed = true
	self.BaseClass.OnMousePressed(self, code)
end

function PANEL:OnMouseReleased(code)
	self.pressed = false
	self.BaseClass.OnMouseReleased(self, code)
end

function PANEL:CursorEntered()
	self.hovered = true
end

function PANEL:CursorExited()
	self.hovered = false
end

function PANEL:Paint(w, h)
	local clr = self.colors
	local bgColor = ((self.id % 2) == 1) and clr.bg1 or clr.bg2

	if self.isRead then
		bgColor = clr.read
	end

	ix.DX.Draw(0, 0, 0, w, h, bgColor)

	if self.isRead then
		surface.SetDrawColor(ix.Palette.combineyellow)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	local ft = FrameTime()

	self.hoverAlpha = math.Approach((self.hoverAlpha or 0), self.hovered and 1 or 0, ft * 5)
	local hoverAlpha = math.ease.OutCubic(self.hoverAlpha)

	self.hoverClr.a = 64 * self.hoverAlpha
	
	render.OverrideBlend(true, 4, 1, BLENDFUNC_ADD, 4, 1, BLENDFUNC_ADD)
		ix.DX.Draw(0, 0, 0, w, h, self.hoverClr)
	render.OverrideBlend(false)
end

vgui.Register("terminal.message", PANEL, "Panel")

hook.Add("TerminalAddDatafilePage", "9_Messages", function(pages)
	table.insert(pages, {
		title = "СООБЩЕНИЯ",
		frame = function(datafilePage, container)
			local tab = container:Add("Panel")
			tab:Dock(FILL)
			tab:InvalidateParent(true)

			local container = tab:Add("Panel")
			container:DockMargin(0, 0, 0, 5)
			container:Dock(FILL)
			container.PerformLayout = function(_, w, h)
				_.maxTall = h
			end

			local btnBottom = tab:Add("Panel")
			btnBottom:SetTall(32)
			btnBottom:Dock(BOTTOM)
			btnBottom:DockMargin(0, 5, 0, 0)

			
			local filter = btnBottom:Add("terminal.button.cmb")
			filter:Dock(RIGHT)
			filter:DockMargin(0, 0, 0, 0)
			filter:SetFont("cmb.terminal.medium16")
			filter:SetText("ФИЛЬТР")
			filter:SizeToContentsX(64)
			filter.OnClick = function(_)
				
			end

			local nextPage = btnBottom:Add("terminal.button.cmb")
			nextPage:Dock(RIGHT)
			nextPage:DockMargin(5, 0, 5, 0)
			nextPage:SetFont("cmb.terminal.symbol16")
			nextPage:SetText(">")
			nextPage:SizeToContentsX(32)
			nextPage.OnClick = function(_)
				netstream.Start("civil.terminal.messages", tab.currentPage + 1)
			end

			local prevPage = btnBottom:Add("terminal.button.cmb")
			prevPage:Dock(RIGHT)
			prevPage:DockMargin(0, 0, 0, 0)
			prevPage:SetFont("cmb.terminal.symbol16")
			prevPage:SetText("<")
			prevPage:SizeToContentsX(32)
			prevPage.OnClick = function(_)
				netstream.Start("civil.terminal.messages", tab.currentPage - 1)
			end
			
			local pageSelector = btnBottom:Add("terminal.button.cmb")
			pageSelector:Dock(FILL)
			pageSelector.noBorder = true
			pageSelector:DockMargin(0, 0, 0, 0)
			pageSelector:SetFont("cmb.terminal.medium16")
			pageSelector:SetText("СТРАНИЦА 0 / 0")
			pageSelector:SizeToContentsX(32)
			pageSelector.OnClick = function(_)
				
			end

			tab.pageBtn = pageSelector
			tab.messages = container

			return tab
		end,
		receive = function(datafilePage, container, data)
			local tab = container.currentPanel
			local msgContainer = tab.messages

			local page = data[2]
			local maxPages = data[3]
			local messages = data[4]
			local tall = msgContainer.maxTall / 5

			tab.currentPage = page
			tab.pageBtn:SetText(string.format("СТРАНИЦА %s / %s", page, maxPages))

			msgContainer:Clear()

			for k, v in ipairs(messages) do
				local panel = msgContainer:Add("terminal.message")
				panel:SetTall(tall)
				panel:Dock(TOP)
				panel:DockMargin(0, 1, 0, 1)
				panel:Setup(k, v)
			end
		end
	})
end)
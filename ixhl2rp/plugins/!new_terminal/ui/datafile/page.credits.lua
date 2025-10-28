local function AddLabel(parent, content, font, clr, align)
	local text = parent:Add("DLabel")
	text:Dock(TOP)
	text:SetFont(font or "cmb.terminal.light30")
	text:SetText(content)
	text:SetContentAlignment(align or 5)
	text:SizeToContents()
	text:SetTextColor(clr or ix.Palette.combineblue)

	return text
end

local PANEL = {}
local green = ix.Palette.combinegreen
local red = ix.Palette.combinered
PANEL.colors = {
	[true] = {
		base = green,
		bg1 = green:Alpha(25),
		bg2 = green:Alpha(50),
		timestamp = green:Alpha(64),
		name = green:Alpha(100)
	},
	[false] = {
		base = red,
		bg1 = red:Alpha(25),
		bg2 = red:Alpha(50),
		timestamp = red:Alpha(64),
		name = red:Alpha(100)
	},
}
function PANEL:Init()
	self:SetText("")
	self:SetAlpha(0)

	local timestamp = self:Add("DLabel")
	timestamp:SetFont("cmb.terminal.medium12")
	timestamp:SetContentAlignment(3)
	timestamp:SetText("")
	timestamp:SizeToContents()

	local value = self:Add("DLabel")
	value:SetFont("cmb.terminal.light24")
	value:SetContentAlignment(6)
	value:SetText("")
	value:SizeToContents()

	local sender = self:Add("DLabel")
	sender:SetFont("cmb.terminal.light14")
	sender:SetContentAlignment(7)
	sender:SetText("")
	sender:SizeToContents()

	local reason = self:Add("DLabel")
	reason:SetFont("cmb.terminal.medium14")
	reason:SetContentAlignment(4)
	reason:SetText("")
	reason:SizeToContents()

	self.reason = reason
	self.sender = sender
	self.amount = value
	self.timeStamp = timestamp

	self.id = 0
	self.isSender = false
end

function PANEL:Setup(id, data)
	local amount = data[1]
	local reason = data[2]
	local name = data[3]
	local isSender = data[4]
	local time = data[5]

	local clr = self.colors[!isSender]

	self.id = id
	self.isSender = isSender

	self.timeStamp:SetText(os.date("%d/%m/%y - %H:%M:%S", time))
	self.timeStamp:SetTextColor(clr.timestamp)
	self.timeStamp:SizeToContents()

	self.amount:SetText(string.format("%s%s", isSender and "-" or "+", amount))
	self.amount:SetTextColor(clr.base)
	self.amount:SizeToContents()

	self.sender:SetText(name)
	self.sender:SetTextColor(clr.name)
	self.sender:SizeToContents()

	self.reason:SetText(reason)
	self.reason:SetTextColor(clr.base)
	self.reason:SizeToContents()

	self:SetAlpha(255)
end

function PANEL:PerformLayout(w, h)
	self.amount:CenterVertical(0.4)
	self.amount:AlignRight(10)

	self.timeStamp:AlignRight(2)
	self.timeStamp:AlignBottom(2)

	self.sender:SetX(15)

	self.reason:CenterVertical(0.6)
	self.reason:SetX(15)

	self.sender:MoveAbove(self.reason)
end

function PANEL:Paint(w, h)
	local isSender = self.isSender
	local clr = self.colors[!isSender]

	ix.DX.Draw(0, 0, 0, w, h, ((self.id % 2) == 1) and clr.bg1 or clr.bg2)
end

vgui.Register("terminal.transaction", PANEL, "DButton")

hook.Add("TerminalAddDatafilePage", "2_Credits", function(pages)
	table.insert(pages, {
		title = "КРЕДИТЫ",
		frame = function(datafilePage, container)
			local creditsTab = container:Add("Panel")
			creditsTab:Dock(FILL)
			creditsTab:InvalidateParent(true)

			local right = creditsTab:Add("Panel")
			right:SetWide(container:GetWide() * 0.45)
			right:Dock(RIGHT)

			local location = right:Add("terminal.frame.info")
			location:Dock(TOP)
			location:SetTall(110)
			location:DockMargin(0, 0, 0, 5)
			location:AddLabel("ВАШ БАЛАНС", "cmb.test.2", ix.Palette.combineblue:Alpha(128))
			local money = location:AddLabel("1616", nil, ix.Palette.combinegreen):DockMargin(0, 15, 0, 0)
			location:AddLabel("КРЕДИТОВ", "cmb.test.2", ix.Palette.combinegreen)


			local location = right:Add("terminal.frame.info")
			location:Dock(FILL)
			location:DockMargin(0, 0, 0, 0)
			location:AddLabel("БАЛАНС КАРТЫ", "cmb.test.2", ix.Palette.combineblue:Alpha(128))
			local cardMoney = location:AddLabel("500", nil, ix.Palette.combinegreen):DockMargin(0, 15, 0, 0)
			location:AddLabel("КРЕДИТОВ", "cmb.test.2", ix.Palette.combinegreen)

			local btnRight = right:Add("Panel")
			btnRight:SetTall(32)
			btnRight:Dock(BOTTOM)
			btnRight:DockMargin(0, 5, 0, 0)

			local transfer = btnRight:Add("terminal.button.cmb")
			transfer:Dock(LEFT)
			transfer:DockMargin(0, 0, 0, 0)
			transfer:SetFont("cmb.terminal.medium16")
			transfer:SetText("ПЕРЕВОД")
			transfer:SizeToContentsX(32)
			transfer.OnClick = function(_)
				
			end

			local deposit = btnRight:Add("terminal.button.cmb")
			deposit:Dock(LEFT)
			deposit:DockMargin(2, 0, 2, 0)
			deposit:SetFont("cmb.terminal.medium16")
			deposit:SetText("ПОПОЛНИТЬ")
			deposit:SizeToContentsX(32)
			deposit.OnClick = function(_)
				
			end

			local withdraw = btnRight:Add("terminal.button.cmb")
			withdraw:Dock(FILL)
			withdraw:DockMargin(0, 0, 0, 0)
			withdraw:SetFont("cmb.terminal.medium16")
			withdraw:SetText("СНЯТЬ")
			withdraw:SizeToContentsX()
			withdraw.OnClick = function(_)
				
			end

			local left = creditsTab:Add("Panel")
			left:DockMargin(0, 0, 15, 0)
			left:Dock(FILL)

			AddLabel(left, "ИСТОРИЯ ТРАНЗАКЦИЙ", "cmb.terminal.light14", ix.Palette.combinegreen:Alpha(90), 4)

			local div = left:Add("terminal.frame.divider")
			div:SetColor(ix.Palette.combinegreen:Alpha(90))
			div:Dock(TOP)
			div:DockMargin(0, 2, 0, 0)

			local transactionContainer = left:Add("Panel")
			transactionContainer:DockMargin(0, 0, 0, 5)
			transactionContainer:Dock(FILL)
			transactionContainer.PerformLayout = function(_, w, h)
				_.maxTall = h
			end


			local loadingBG = ix.Palette.combinegreen:Alpha(48)
			local loading = transactionContainer:Add("Panel")
			loading:Dock(FILL)
			loading.Paint = function(_, w, h)
				ix.DX.Draw(0, 0, 0, w, h, loadingBG)
			end

			local loadingText = loading:Add("DLabel")
			loadingText:SetFont("cmb.terminal.light17")
			loadingText:SetContentAlignment(5)
			loadingText:SetTextColor(ix.Palette.combinegreen)
			loadingText:SetText("ЗАГРУЗКА...")
			loadingText:Dock(FILL)
	

			local btnLeft = left:Add("Panel")
			btnLeft:SetTall(32)
			btnLeft:Dock(BOTTOM)
			btnLeft:DockMargin(0, 5, 0, 0)

			local prevPage = btnLeft:Add("terminal.button.cmb")
			prevPage:Dock(LEFT)
			prevPage:DockMargin(0, 0, 0, 0)
			prevPage:SetFont("cmb.terminal.symbol16")
			prevPage:SetText("<")
			prevPage:SizeToContentsX(32)
			prevPage.OnClick = function(_)
				netstream.Start("civil.terminal.transactions", creditsTab.currentPage - 1)
			end

			local filter = btnLeft:Add("terminal.button.cmb")
			filter:Dock(RIGHT)
			filter:DockMargin(0, 0, 0, 0)
			filter:SetFont("cmb.terminal.medium16")
			filter:SetText("ФИЛЬТР")
			filter:SizeToContentsX(32)
			filter.OnClick = function(_)
				
			end

			local nextPage = btnLeft:Add("terminal.button.cmb")
			nextPage:Dock(RIGHT)
			nextPage:DockMargin(0, 0, 5, 0)
			nextPage:SetFont("cmb.terminal.symbol16")
			nextPage:SetText(">")
			nextPage:SizeToContentsX(32)
			nextPage.OnClick = function(_)
				netstream.Start("civil.terminal.transactions", creditsTab.currentPage + 1)
			end

			local pageSelector = btnLeft:Add("terminal.button.cmb")
			pageSelector:Dock(FILL)
			pageSelector.noBorder = true
			pageSelector:DockMargin(0, 0, 0, 0)
			pageSelector:SetFont("cmb.terminal.medium16")
			pageSelector:SetText("СТРАНИЦА 0 / 0")
			pageSelector:SizeToContentsX(32)
			pageSelector.OnClick = function(_)
				
			end

			creditsTab.transactions = transactionContainer
			creditsTab.pageBtn = pageSelector

			return creditsTab
		end,
		receive = function(datafilePage, container, data)
			local creditsTab = container.currentPanel
			local logContainer = creditsTab.transactions

			local page = data[2]
			local maxPages = data[3]
			local transactions = data[4]
			local tall = logContainer.maxTall / 4

			creditsTab.currentPage = page
			creditsTab.pageBtn:SetText(string.format("СТРАНИЦА %s / %s", page, maxPages))

			logContainer:Clear()

			for k, v in ipairs(transactions) do
				local panel = logContainer:Add("terminal.transaction")
				panel:SetTall(tall)
				panel:Dock(TOP)
				panel:DockMargin(0, 1, 0, 1)
				panel:Setup(k, v)
			end
		end
	})
end)
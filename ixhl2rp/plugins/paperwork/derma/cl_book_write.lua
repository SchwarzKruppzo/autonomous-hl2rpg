local PANEL = {}

AccessorFunc(PANEL, "bEditable", "Editable", FORCE_BOOL)
AccessorFunc(PANEL, "itemID", "ItemID", FORCE_NUMBER)

function PANEL:LoadPage(id)
	self.data = self.data or {}

	self.data[id] = self.data[id] or ""
	self.data[id + 1] = self.data[id + 1] or ""

	self.text:SetText(self.data[id])
	self.text2:SetText(self.data[id + 1])

	self.page_left:SetText(L("book.gui.pagecounter", id, string.utf8len(self.data[id])))
	self.page_right:SetText(L("book.gui.pagecounter", id + 1, string.utf8len(self.data[id + 1])))
end

function PANEL:SetFont(font)
	self.font = font

	self.text:SetFont(self.font.."Preview")
	self.text2:SetFont(self.font.."Preview")
end

function PANEL:Init()
	if IsValid(ix.gui.bookwriting) then
		ix.gui.bookwriting:Remove()
		ix.gui.bookwriting = nil
	end

	local w, h = ix.UI.Scale(1280), ix.UI.Scale(980)

	self:SetSize(w, h)
	self:Center()
	self:SetBackgroundBlur(false)
	self:SetDeleteOnClose(true)
	self:SetTitle(L"book.gui.editTitle")

	self.currentPage = 1
	self.font = "BookAlegreya"

	self.close = self:Add("DButton")
	self.close:Dock(BOTTOM)
	self.close:DockMargin(0, 5, 0, 0)
	self.close:SetText(L"book.gui.saveAndClose")
	self.close.DoClick = function()
		local data = self.data
		local font = self.font
		
		Derma_StringRequest(L"book.gui.saveTitle", L"book.gui.saveDesc", L"book.gui.untitled", function(text)
			express.Send("book.write", {text, data, font})
		end)

		self:Close()
	end

	self.save = self:Add("DButton")
	self.save:Dock(BOTTOM)
	self.save:DockMargin(0, 45, 0, 0)
	self.save:SetText(L"book.gui.save")
	self.save.DoClick = function()
		express.Send("book.save", {self.font, self.data})

		self:Close()
	end

	self.preview = self:Add("DButton")
	self.preview:Dock(BOTTOM)
	self.preview:DockMargin(0, 5, 0, 0)
	self.preview:SetText(L"book.gui.preview")
	self.preview.DoClick = function()
		local preview = vgui.Create("cellar.ui.book")
		preview:OpenBook(self.data, self.font)
	end

	self.selectFont = self:Add("DButton")
	self.selectFont:Dock(BOTTOM)
	self.selectFont:DockMargin(0, 5, 0, 0)
	self.selectFont:SetText(L"book.gui.font")
	self.selectFont.DoClick = function()
		local selector = vgui.Create("cellar.book.font")
		selector.callback = function(font)
			local self = ix.gui.bookwriting

			self.font = font

			self.text:SetFontInternal(font.."Preview")
			self.text2:SetFontInternal(font.."Preview")
		end
	end

	self.max = self:Add("DLabel")
	self.max:Dock(TOP)
	self.max:SetText(L"book.gui.maxpages")

	local left = self:Add("Panel")
	left:SetWide(w * 0.5)
	left:Dock(LEFT)

	local right = self:Add("Panel")
	right:Dock(FILL)

	self.text = left:Add("DTextEntry")
	self.text:SetMultiline(true)
	self.text:SetFont(self.font.."Preview")
	self.text:Dock(FILL)
	self.text:SetText("")
	self.text.OnChange = function(this)
		local text = this:GetText()

		if (text:len() > 1600) then
			local newText = text:sub(1, 1600)

			text = newText
			self.text:SetText(newText)
			self.text:SetCaretPos(newText:len())

			surface.PlaySound("common/talk.wav")
		end

		self.page_left:SetText(L("book.gui.pagecounter", self.currentPage, string.utf8len(text)))

		self.data[self.currentPage] = text
	end

	self.text2 = right:Add("DTextEntry")
	self.text2:SetMultiline(true)
	self.text2:SetFont(self.font.."Preview")
	self.text2:Dock(FILL)
	self.text2:SetText("")
	self.text2.OnChange = function(this)
		local text = this:GetText()

		if (text:len() > 1600) then
			local newText = text:sub(1, 1600)

			text = newText
			self.text2:SetText(newText)
			self.text2:SetCaretPos(newText:len())

			surface.PlaySound("common/talk.wav")
		end

		self.page_right:SetText(L("book.gui.pagecounter", self.currentPage, string.utf8len(text)))

		self.data[self.currentPage + 1] = text
	end

	self.page_left = left:Add("DLabel")
	self.page_left:Dock(TOP)
	self.page_left:SetText(L("book.gui.pagecounter", 1, 0))

	self.page_right = right:Add("DLabel")
	self.page_right:Dock(TOP)
	self.page_right:SetText(L("book.gui.pagecounter", 2, 0))

	self.page1 = left:Add("DButton")
	self.page1:Dock(BOTTOM)
	self.page1:DockMargin(0, 4, 0, 0)
	self.page1:SetText(L"book.gui.prevpage")
	self.page1.DoClick = function()
		self.currentPage = math.max(self.currentPage - 2, 1)

		self:LoadPage(self.currentPage)
	end

	self.page2 = right:Add("DButton")
	self.page2:Dock(BOTTOM)
	self.page2:DockMargin(0, 4, 0, 0)
	self.page2:SetText(L"book.gui.nextpage")
	self.page2.DoClick = function()
		self.currentPage = math.min(self.currentPage + 2, 15)

		self:LoadPage(self.currentPage)
	end

	self:MakePopup()

	ix.gui.bookwriting = self
end

vgui.Register("cellar.book.write", PANEL, "DFrame")
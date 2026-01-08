local textureFlags = bit.bor(512, bit.bor(16, 256))
local PANEL = {}

PANEL.MaxPageWidth = 577
PANEL.texPages = PANEL.texPages or {}
PANEL.mdlPages = {
	Material("models/cellar/books/page1"),
	Material("models/cellar/books/page2"),
	Material("models/cellar/books/page3"),
	Material("models/cellar/books/page4")
}


local pos, ang = Vector(), Angle()
local mdlang = Angle(ang)
mdlang:RotateAroundAxis(ang:Right(), 90)
mdlang:RotateAroundAxis(ang:Forward(), 180)

local ANIM_OPEN = 1
local ANIM_NEXT = 2
local ANIM_PREV = 3

function PANEL:Init()
	if !PANEL.firstInit then
		for i = 1, 4 do
			PANEL.texPages[i] = GetRenderTargetEx("bcuiBookPage"..i, 1024, 1024, RT_SIZE_LITERAL, MATERIAL_RT_DEPTH_NONE, 0, 0, IMAGE_FORMAT_RGBA8888)
			PANEL.mdlPages[i]:SetTexture("$basetexture", PANEL.texPages[i])
		end

		PANEL.firstInit = true
	end

	if IsValid(ix.gui.book) then
		ix.gui.book:OnClose()
		ix.gui.book:Remove()
	end

	ix.gui.book = self

	self:SetSize(ScrW(), ScrH())
	self:MakePopup()

	self.left = self:Add("DLabel")
	self.left:SetText("")
	self.left:Dock(LEFT)
	self.left:SetWide(ScrW() / 2)
	self.left:SetMouseInputEnabled(true)
	self.left.DoClick = function()
		self:PrevPage()
	end

	self.right = self:Add("DLabel")
	self.right:SetText("")
	self.right:Dock(FILL)
	self.right:SetMouseInputEnabled(true)
	self.right.DoClick = function()
		self:NextPage()
	end

	self.hint = self:Add("DLabel")
	self.hint:SetFont("ixMediumFont")
	self.hint:SetText(L"book.gui.hint")
	self.hint:SizeToContents()
	self.hint:Center()
	self.hint:AlignBottom(16)

	self.lastAnimation = -1
	self.lastUse = 0
	self.drawPages = {}

	for i = 1, 4 do 
		self.drawPages[i] = 0
	end

	if !IsValid(self.model) then
		self.model = ClientsideModel(Model("models/cellar/ui_book.mdl"), RENDERGROUP_BOTH)
		self.model:SetNoDraw(true)
	end

	self.hidden = true

	self:ClearPages()

	hook.Add("PostRenderVGUI", "cellar.ui.book", function()
		if !IsValid(ix.gui.book) or !IsValid(ix.gui.book.model) or ix.gui.book.hidden then
			return
		end
		
		cam.Start3D(pos, ang, 60, 0, 0, nil, nil, 1, 128)
			cam.IgnoreZ(true)
				render.SuppressEngineLighting(true)
					ix.gui.book.model:SetPos(pos - mdlang:Up() * 48 - mdlang:Right() * 9)
					ix.gui.book.model:SetAngles(mdlang)
					ix.gui.book.model:FrameAdvance(FrameTime())
					ix.gui.book.model:DrawModel()
				render.SuppressEngineLighting(false)
			cam.IgnoreZ(false)
		cam.End3D()
	end)

	hook.Add("PreRender", "cellar.ui.book", function()
		if input.IsKeyDown(KEY_ESCAPE) then
			if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
				if IsValid(ix.gui.book) then
					gui.HideGameUI()
					ix.gui.book:CloseBook()
				end
			end
		end
	end)
end

function PANEL:OnKeyCodePressed(key)
	if key == KEY_TAB then
		self:CloseBook()
	end
end

function PANEL:PlayAnim(anim)
	if !IsValid(ix.gui.book.model) then
		return
	end

	ix.gui.book.model:ResetSequence(anim)
	ix.gui.book.model:SetCycle(0)
	ix.gui.book.model:SetPlaybackRate(1)

	return ix.gui.book.model:SequenceDuration(ix.gui.book.model:LookupSequence(anim))
end

do
	local paper = CreateMaterial("mq0genBookPage", "UnlitGeneric", {
		["$basetexture"] = "models/cellar/books/page_left2",
		["$ignorez"] = 1
	})

	local paper_left = Material("models/cellar/books/page_left.png")
	local paper_right = Material("models/cellar/books/page_right.png")

	function PANEL:ClearPages()
		for i = 1, 4 do 
			render.PushRenderTarget(self.texPages[i])
				render.Clear(0, 0, 0, 255)
			render.PopRenderTarget()
		end
	end

	function PANEL:GeneratePage(pageID, data, tex)
		local mark = markup.Parse("<colour=0,0,0,255><font="..self.font..">"..data.."</font>", self.MaxPageWidth)

		render.PushRenderTarget(isnumber(pageID) and self.texPages[pageID] or pageID)
			render.Clear(0, 0, 0, 0)

			cam.Start2D()
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(tex and paper_right or paper_left)
				surface.DrawTexturedRect(0, 0, 1024, 1024)

				render.PushFilterMag(TEXFILTER.ANISOTROPIC)
				render.PushFilterMin(TEXFILTER.ANISOTROPIC)

				mark:Draw(64, 64)
				
				draw.Text({
					text = isnumber(pageID) and pageID or (!tex and self.currentPage or (self.currentPage + 1)),
					font = self.font,
					pos = {325, 950},
					color = color_black
				})

				render.PopFilterMag()
				render.PopFilterMin()
			cam.End2D()
		render.PopRenderTarget()
	end
end

function PANEL:OpenBook(bookData, font, skin)
	self.hidden = false
	self.bookData = bookData
	self.font = font
	self.model:SetSkin(skin or 0)
	self.currentPage = 1



	for i = 1, 4 do
		PANEL.mdlPages[i]:SetTexture("$basetexture", PANEL.texPages[i])
		
		self.drawPages[i] = self.texPages[i]

		if i <= #bookData then 
			self:GeneratePage(i, self.bookData[i] or "", i % 2 == 0)
		end
	end

	local delay = self:PlayAnim("open")
	self.lastUse = delay and CurTime() + delay

	self.lastAnim = ANIM_OPEN
end

function PANEL:NextPage()
	if CurTime() < self.lastUse then 
		return 
	end

	if (self.currentPage + 2) > #self.bookData then
		return
	end
	
	self.currentPage = self.currentPage + 2

	if self.lastAnim == ANIM_NEXT then
		for i = 1, 4 do
			PANEL.mdlPages[i]:SetTexture("$basetexture", self.drawPages[i])
		end

		self:GeneratePage(self.drawPages[3], self.bookData[self.currentPage], false)
		self:GeneratePage(self.drawPages[4], self.bookData[self.currentPage + 1], true)
	end

	local tex1, tex2, tex3, tex4 = self.drawPages[1], self.drawPages[2], self.drawPages[3], self.drawPages[4]
	self.drawPages = {tex3 ,tex4, tex1, tex2}

	local delay = self:PlayAnim("nextpage")
	self.lastUse = delay and CurTime() + delay

	self.lastAnim = ANIM_NEXT
end

function PANEL:PrevPage()
	if CurTime() < self.lastUse then 
		return 
	end

	if self.currentPage == 1 then
		return
	end

	self.currentPage = self.currentPage - 2

	if self.lastAnim == ANIM_PREV then
		for i = 1, 4 do
			PANEL.mdlPages[i]:SetTexture("$basetexture", self.drawPages[i])
		end

		local tex1, tex2, tex3, tex4 = self.drawPages[1], self.drawPages[2], self.drawPages[3], self.drawPages[4]
		self.drawPages = {tex3, tex4, tex1, tex2}

		self:GeneratePage(self.drawPages[3], self.bookData[self.currentPage], false)
		self:GeneratePage(self.drawPages[4], self.bookData[self.currentPage + 1], true)
	end

	local delay = self:PlayAnim("prevpage")
	self.lastUse = delay and CurTime() + delay

	self.lastAnim = ANIM_PREV
end

function PANEL:CloseBook()
	if self.isClosing then
		return
	end
	
	self.isClosing = true

	local delay = self:PlayAnim("close")
	local tex1, tex2, tex3, tex4 = self.drawPages[1], self.drawPages[2], self.drawPages[3], self.drawPages[4]

	if self.lastAnim == ANIM_PREV then
		//self.drawPages = {tex3, tex4, tex1, tex2}
	end
	
	for i = 1, 4 do
		self.mdlPages[i]:SetTexture("$basetexture", self.drawPages[i])
	end

	timer.Simple(delay, function()
		if !IsValid(ix.gui.book) then return end
		
		ix.gui.book:OnClose()
		ix.gui.book:Remove()
		ix.gui.book = nil
	end)
end

function PANEL:OnClose()
	hook.Remove("PostRenderVGUI", "cellar.ui.book")
	hook.Remove("PreRender", "cellar.ui.book")

	ix.gui.book.model:Remove()
end

vgui.Register("cellar.ui.book", PANEL, "EditablePanel")
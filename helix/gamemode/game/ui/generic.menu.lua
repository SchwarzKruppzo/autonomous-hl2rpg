local PANEL = {}
AccessorFunc(PANEL, "m_pMenu", "Menu")

local BG_COLOR = Color(0, 200 * 0.2, 255 * 0.2)
local BG_DETAIL = Color(0, 200, 255, 255)
local BG_DETAIL2 = Color(0, 200, 255, 16)
local BG_DETAIL3 = Color(0, 0, 0, 255)
local TEXT_COLOR = Color(0, 210, 255)
local OPTION_HEIGHT = ix.UI.Scale(22)

do
	surface.CreateFont('simple.option.button', {
		font = 'Blender Pro Bold',
		extended = true,
		size = ix.UI.Scale(16),
		weight = 500,
		antialias = true,
	})
end

function PANEL:Init()
	self:SetText('')
	self:SetFont('simple.option.button')
	self:SetTextColor(TEXT_COLOR)

	self:SetContentAlignment(5)
	--self:SetTextInset(32, 0) -- Room for icon on left

end

function PANEL:SetSubMenu(menu)
	self.SubMenu = menu

	if !IsValid(self.SubMenuArrow) then
		self.SubMenuArrow = vgui.Create("DPanel", self)
		self.SubMenuArrow.Paint = function(panel, w, h) derma.SkinHook("Paint", "MenuRightArrow", panel, w, h) end
	end
end

function PANEL:SetImage(img)
	if !img then
		if IsValid(self.img) then
			self.img:Remove()
		end

		return
	end

	if !IsValid(self.img) then
		self.img = self:Add("DImage")
	end

	self.img:SetImage(img)
	self.img:SizeToContents()

	self:InvalidateLayout()
end

function PANEL:SetMaterial(img)
	if !img then
		if IsValid(self.img) then
			self.img:Remove()
		end

		return
	end

	if !IsValid(self.img) then
		self.img = self:Add("DImage")
	end

	self.img:SetImage(img)
	self.img:SizeToContents()

	self:InvalidateLayout()
end

function PANEL:AddSubMenu()
	local SubMenu = ix.SimpleMenu(true, self)
	SubMenu:SetVisible(false)
	SubMenu:SetParent(self)

	self:SetSubMenu(SubMenu)

	return SubMenu
end

function PANEL:OnCursorEntered()
	if IsValid(self.ParentMenu) then
		self.ParentMenu:OpenSubMenu(self, self.SubMenu)
		return
	end

	self:GetParent():OpenSubMenu(self, self.SubMenu)
end

function PANEL:OnCursorExited()
end

function PANEL:Paint(w, h)
	self.stateAlpha = math.Approach((self.stateAlpha or 0), (self:IsHovered() or self.m_MenuClicking) and 1 or 0, FrameTime() * 10)
	local a = 0

	if (self.stateAlpha or 0) > 0 then
		a = math.ease.OutCubic(self.stateAlpha)
	end

	local b = (self.m_MenuClicking and 2 or a)
	local c = 128 + (127 * b)

	self:SetTextColor(ColorAlpha(TEXT_COLOR, c))

	surface.SetDrawColor(BG_COLOR)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(ColorAlpha(BG_DETAIL, c))
	surface.DrawRect(0, 0, OPTION_HEIGHT * 0.3, h)

	if !self.isFirst then
		surface.SetDrawColor(BG_DETAIL2)
		surface.DrawRect(0, 0, w, 1, BG_DETAIL2)
	end

	render.OverrideBlend(true, 4, 1, BLENDFUNC_ADD, 4, 1, BLENDFUNC_ADD)
		if (self.stateAlpha or 0) > 0 then
			surface.SetDrawColor(32, 190, 255, 32 * b)
			surface.DrawRect(0, 0, w, h)
		end
	render.OverrideBlend(false)
end

function PANEL:OnMousePressed(mousecode)
	self.m_MenuClicking = true

	DButton.OnMousePressed(self, mousecode)
end

function PANEL:OnMouseReleased(mousecode)
	DButton.OnMouseReleased(self, mousecode)

	if self.m_MenuClicking and mousecode == MOUSE_LEFT then
		self.m_MenuClicking = false
		CloseDermaMenus()
	end
end

function PANEL:DoClickInternal()
	if self.m_pMenu then
		self.m_pMenu:OptionSelectedInternal( self )
	end
end

function PANEL:PerformLayoutImage()
	if IsValid(self.img) then
		local targetSize = math.min(self:GetWide() - 4, self:GetTall() - 4)

		local imgW, imgH = self.img.ActualWidth, self.img.ActualHeight
		local zoom = math.min(targetSize / imgW, targetSize / imgH, 1)
		local newSizeX = math.ceil(imgW * zoom)
		local newSizeY = math.ceil(imgH * zoom)

		self.img:SetWide(newSizeX)
		self.img:SetTall(newSizeY)

		self.img:SetPos(OPTION_HEIGHT * 0.3 + 2, (self:GetTall() - self.img:GetTall()) * 0.5)

		self:SetTextInset(32, 0)
	end
end

function PANEL:PerformLayout(w, h)
	self:SizeToContents()
	self:SetWide(self:GetWide() + 30)

	local w = math.max(self:GetParent():GetWide(), self:GetWide())

	self:SetSize(w, OPTION_HEIGHT)

	if IsValid(self.SubMenuArrow) then
		self.SubMenuArrow:SetSize(15, 15)
		self.SubMenuArrow:CenterVertical()
		self.SubMenuArrow:AlignRight(4)
	end

	self:PerformLayoutImage()

	DButton.PerformLayout(self, w, h)
end

vgui.Register('simple.option.button', PANEL, 'DButton')


local PANEL = {}
AccessorFunc( PANEL, "m_bBorder",			"DrawBorder" )
AccessorFunc( PANEL, "m_bDeleteSelf",		"DeleteSelf" )
AccessorFunc( PANEL, "m_iMinimumWidth",		"MinimumWidth" )
AccessorFunc( PANEL, "m_bDrawColumn",		"DrawColumn" )
AccessorFunc( PANEL, "m_iMaxHeight",		"MaxHeight" )
AccessorFunc( PANEL, "m_pOpenSubMenu",		"OpenSubMenu" )

local OPTION_WIDTH = ix.UI.Scale(150)
function PANEL:Init()
	self:SetIsMenu(true)
	self:SetDrawBorder(true)
	self:SetPaintBackground(true)
	self:SetMinimumWidth(OPTION_WIDTH)
	self:SetDrawOnTop(true)
	self:SetMaxHeight(ScrH() * 0.9)
	self:SetDeleteSelf(true)

	self:SetPadding(0)

	RegisterDermaMenuForClose(self)
end

function PANEL:AddPanel(pnl)
	self:AddItem(pnl)
	pnl.ParentMenu = self
end

function PANEL:AddOption(strText, funcFunction)
	local pnl = vgui.Create('simple.option.button', self)
	pnl:SetMenu(self)
	pnl:SetText(strText:utf8upper())

	if funcFunction then pnl.DoClick = funcFunction end

	self:AddPanel(pnl)

	return pnl
end

function PANEL:AddSpacer()
	local pnl = vgui.Create('DPanel', self)
	pnl.Paint = function( p, w, h )
		derma.SkinHook("Paint", "MenuSpacer", p, w, h )
	end

	pnl:SetTall(1)

	self:AddPanel(pnl)

	return pnl
end

function PANEL:AddSubMenu(strText, funcFunction)
	local pnl = vgui.Create('simple.option.button', self)
	local SubMenu = pnl:AddSubMenu(strText, funcFunction)
	pnl:SetText(strText:utf8upper())

	if funcFunction then pnl.DoClick = funcFunction end

	self:AddPanel(pnl)

	return SubMenu, pnl
end

function PANEL:Hide()
	local openmenu = self:GetOpenSubMenu()
	if openmenu then
		openmenu:Hide()
	end

	self:SetVisible(false)
	self:SetOpenSubMenu(nil)
end

function PANEL:OpenSubMenu(item, menu)
	local openmenu = self:GetOpenSubMenu()
	if IsValid(openmenu) and openmenu:IsVisible() then
		if menu and openmenu == menu then return end

		self:CloseSubMenu(openmenu)
	end

	if !IsValid(menu) then return end

	local x, y = item:LocalToScreen(self:GetWide(), 0)
	menu:Open(x, y, false, item)
	menu:SetAlpha(0)
	menu:AlphaTo(255, 0.2)

	self:SetOpenSubMenu(menu)
end

function PANEL:CloseSubMenu(menu)
	menu:Hide()
	self:SetOpenSubMenu(nil)
end

function PANEL:Paint(w, h)
end

function PANEL:ChildCount()
	return #self:GetCanvas():GetChildren()
end

function PANEL:GetChild(num)
	return self:GetCanvas():GetChildren()[num]
end

function PANEL:PerformLayout(w, h)
	local w = self:GetMinimumWidth()

	-- Find the widest one
	for k, pnl in ipairs(self:GetCanvas():GetChildren()) do
		pnl:InvalidateLayout(true)
		w = math.max(w, pnl:GetWide())
	end

	self:SetWide( w )

	local y = 0 -- for padding

	for k, pnl in ipairs(self:GetCanvas():GetChildren()) do
		pnl:SetWide(w)
		pnl:SetPos(0, y)
		pnl:InvalidateLayout(true)

		y = y + pnl:GetTall()
	end

	y = math.min(y, self:GetMaxHeight())

	self:SetTall(y)

	derma.SkinHook("Layout", "Menu", self)

	DScrollPanel.PerformLayout(self, w, h)
end

function PANEL:Open(x, y, skipanimation, ownerpanel)
	RegisterDermaMenuForClose(self)

	local maunal = x and y

	x = x or gui.MouseX()
	y = y or gui.MouseY()

	local OwnerHeight = 0
	local OwnerWidth = 0

	if ownerpanel then
		OwnerWidth, OwnerHeight = ownerpanel:GetSize()
	end

	self:InvalidateLayout(true)

	local w = self:GetWide()
	local h = self:GetTall()

	self:SetSize(w, h)

	if y + h > ScrH() then y = ((maunal and ScrH()) or (y + OwnerHeight)) - h end
	if x + w > ScrW() then x = ((maunal and ScrW()) or x) - w end
	if y < 1 then y = 1 end
	if x < 1 then x = 1 end

	local p = self:GetParent()
	if IsValid(p) and p:IsModal() then
		x, y = p:ScreenToLocal(x, y)

		if y + h > p:GetTall() then y = p:GetTall() - h end
		if x + w > p:GetWide() then x = p:GetWide() - w end
		if y < 1 then y = 1 end
		if x < 1 then x = 1 end

		self:SetPos(x, y)
	else
		self:SetPos(x, y)

		self:MakePopup()
	end

	self:SetVisible(true)
	self:SetKeyboardInputEnabled(false)
end

function PANEL:OptionSelectedInternal(option)
	self:OptionSelected(option, option:GetText())
end

function PANEL:OptionSelected(option, text)
end
vgui.Register('simple.option', PANEL, 'DScrollPanel')

function ix.SimpleMenu(parentmenu, parent)
	if !parentmenu then CloseDermaMenus() end

	local menux = vgui.Create('simple.option', parent)

	return menux
end

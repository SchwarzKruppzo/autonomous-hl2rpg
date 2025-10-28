local PANEL = {}
local Scale = ix.UI.Scale
DEFINE_BASECLASS('DButton')

local styles = {
	[1] = {
		outline = Color(0, 190, 255, 48),
		outline2 = Color(0, 190, 255, 16),
		corners = Color(0, 225, 255, 255),
		text = Color(0, 225, 255, 255),
		hover = Color(32, 160, 190),
	},
	[2] = {
		outline = Color(255, 0, 0, 48),
		outline2 = Color(255, 0, 0, 16),
		corners = Color(255, 0, 0, 255),
		text = Color(255, 64, 64, 255),
		hover = Color(190, 32, 32),
	},
}

function PANEL:DrawCorners(x, y, w, h, size)
	surface.SetDrawColor(self.style.outline)
	surface.DrawOutlinedRect(x, y, w, h)

	local offset = 2
	surface.SetDrawColor(self.style.outline2)
	surface.DrawOutlinedRect(x + offset, y + offset, w - offset * 2, h - offset * 2)

	surface.SetDrawColor(self.style.corners)

	surface.DrawLine(x, y, x + size, y)
	surface.DrawLine(x, y, x, y + size)

	x, y = w - 1, y

	surface.DrawLine(x, y, x - size, y)
	surface.DrawLine(x, y, x, y + size)

	x, y = 0, h - 1

	surface.DrawLine(x, y, x + size, y)
	surface.DrawLine(x, y, x, y - size)

	x, y = w - 1, h - 1

	surface.DrawLine(x, y, x - size, y)
	surface.DrawLine(x, y, x, y - size)
end

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	self:SetText("TEST")
	self:SetFont("tabmenu.btn.small")
	
	self:SetCursor("hand")
	self:SetStyle(1)


	self.entered = false
	self.padding = Scale(10) * 2
	self.corner_size = 2
end

function PANEL:SetStyle(id)
	if !styles[id] then return end
	
	self.style = styles[id]

	self:SetTextColor(self.style.text)
end

function PANEL:OnCursorEntered()
	if self:GetDisabled() then return end

	self.entered = true
end

function PANEL:OnCursorExited()
	if self:GetDisabled() then return end

	self.entered = false
end

function PANEL:OnMousePressed(code)
	if self:GetDisabled() then
		return
	end

	LocalPlayer():EmitSound("Helix.Press")

	if code == MOUSE_LEFT then
		self:DoClick(self)
	end
end

function PANEL:SizeToContents()
	surface.SetFont(self:GetFont())
	local w, h = surface.GetTextSize(self:GetText())

	self:SetWidth(w + self.padding)
end

function PANEL:Paint(w, h)
	self:DrawCorners(0, 0, w, h, self.corner_size)
	
	local ft = FrameTime()

	self.hoverAlpha = math.Approach((self.hoverAlpha or 0), self.entered and 1 or 0, ft * 5)
	local hoverAlpha = math.ease.OutCubic(self.hoverAlpha)

	render.OverrideBlend(true, 4, 1, BLENDFUNC_ADD, 4, 1, BLENDFUNC_ADD)
		surface.SetDrawColor(self.style.hover.r, self.style.hover.g, self.style.hover.b, 128 * hoverAlpha)
		surface.DrawRect(0, 0, w, h)
	render.OverrideBlend(false)
end

vgui.Register('ui.tab.frame.button', PANEL, 'DButton')


local PANEL = {}
local Scale = ix.UI.Scale
DEFINE_BASECLASS('DFrame')

do
	surface.CreateFont('tab.frame.title', {
		font = 'Blender Pro Book',
		extended = true,
		size = Scale(18),
		weight = 500,
		antialias = true,
	})
	surface.CreateFont('tab.frame.close', {
		font = 'Blender Pro Heavy',
		extended = true,
		size = Scale(14),
		weight = 500,
		antialias = true,
	})
end

local function DrawTitleCorners(x, y, w, h, size)
	surface.SetDrawColor(0, 190, 255, 48)
	surface.DrawOutlinedRect(x, y, w, h)

	local offset = 2
	surface.SetDrawColor(0, 190, 255, 16)
	surface.DrawOutlinedRect(x + offset, y + offset, w - offset * 2, h - offset * 2)

	surface.SetDrawColor(0, 225, 255, 255)

	surface.DrawLine(x, y, x + size, y)
	surface.DrawLine(x, y, x, y + size)

	x, y = w - 1, y

	surface.DrawLine(x, y, x - size, y)
	surface.DrawLine(x, y, x, y + size)

	x, y = 0, h - 1

	surface.DrawLine(x, y, x + size, y)
	surface.DrawLine(x, y, x, y - size)

	x, y = w - 1, h - 1

	surface.DrawLine(x, y, x - size, y)
	surface.DrawLine(x, y, x, y - size)
end

function ix.util.TabFocus(panel, parent)
	panel.isTabFrame = parent

	for k, v in pairs(panel:GetChildren()) do
		ix.util.TabFocus(v, parent)
	end
end

local newpanel
function DebugTabMenu()
	return newpanel
end

function ix.util.TabRequestFocus(x)
	if x.isTabFrame and newpanel != x.isTabFrame then
		for id, panel in pairs(ix.gui.menu.frames) do
			panel:AlphaTo(panel == x.isTabFrame and 255 or 100, 0.1)
		end
		newpanel = x.isTabFrame
		x.isTabFrame:MoveToFront()
	end
end

function PANEL:Init()
	self:ShowCloseButton(false)
	self:SetDraggable(true)
	self:SetSizable(true)

	self:DockPadding(0, 0, 0, 0)

	self.btnMinim:Remove()
	self.btnMaxim:Remove()
	self.btnClose:Remove()

	self.lblTitle:SetFont('tab.frame.title')
	self.lblTitle:SetAlpha(255)
	self.lblTitle:SetPos(0, 0)
	self.lblTitle:SetTall(22)
	self.lblTitle:SetTextColor(Color(0, 225, 255))

	self.close = self:Add('ui.tab.frame.button')
	self.close:SetStyle(2)
	self.close:SetText('ЗАКРЫТЬ')
	self.close:SetTall(22)
	self.close:SetAlpha(255)
	self.close:SizeToContents()
	self.close.DoClick = function()
		RememberCursorPosition()
		
		if self.frameID then
			ix.gui.menu:CloseFrame(self.frameID)
		else
			self:Remove()
		end
	end
end

function PANEL:PerformLayout(width, height)
	self.close:AlignRight(0)

	self.lblTitle:SetWide(width)
	self.lblTitle:SetX(Scale(8))
end

do
	local shadow = Material('cellar/slot_shadow.png')

	function PANEL:Paint(w, h) 
		ix.util.DrawBlur(self, 2)

		local y = 23

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(shadow)
		surface.DrawTexturedRect(0, 0, w, h)

		surface.SetDrawColor(16, 32, 48, 255 * 0.75)
		surface.DrawRect(0, 0, w, h)

		DrawTitleCorners(0, 0, w - self.close:GetWide() - 2, 22, 2)

		surface.SetDrawColor(0, 190 * 0.5, 255 * 0.5, 255 * 0.5)
		surface.DrawOutlinedRect(0, y, w, h - y)
	end
end

function PANEL:OnFocusChanged(gained)
	self:SetAlpha(gained and 255 or 100)
end

function PANEL:OnMousePressed()
	local parent = self:GetParent()

	if IsValid(parent) then
		if parent.OnFrameFocus then
			parent:OnFrameFocus(self)
		end
		
		parent.isDraggingWindow = true
	end
	
	BaseClass.OnMousePressed(self)
end

function PANEL:OnMouseReleased()
	local parent = self:GetParent()

	if IsValid(parent) then
		parent.isDraggingWindow = false
	end

	BaseClass.OnMouseReleased(self)
end

vgui.Register('ui.tab.frame', PANEL, 'DFrame')
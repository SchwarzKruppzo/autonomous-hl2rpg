local PANEL = {}
local style = {
	bg = Color(64, 255, 100, 32),
	corners = Color(72, 255, 72),
	outline = Color(64, 255, 100, 96),
	outline2 = Color(64, 255, 64, 16),
	text = Color(64, 225, 96, 255)
}

function PANEL:Init()
	self:SetText('')
	self:SetFont("craft.button")
	self:SetTextColor(style.text)

	self:SetContentAlignment(5)
end

function PANEL:DrawCorners(x, y, w, h, size)
	surface.SetDrawColor(style.bg)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(style.outline)
	surface.DrawOutlinedRect(x, y, w, h)

	local offset = 2
	surface.SetDrawColor(style.outline2)
	surface.DrawOutlinedRect(x + offset, y + offset, w - offset * 2, h - offset * 2)

	surface.SetDrawColor(style.corners)

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

function PANEL:Paint(w, h)
	self.stateAlpha = math.Approach((self.stateAlpha or 0), (self:IsHovered() or self.m_MenuClicking) and 1 or 0, FrameTime() * 10)
	local a = 0

	if (self.stateAlpha or 0) > 0 then
		a = math.ease.OutCubic(self.stateAlpha)
	end

	local b = (self.m_MenuClicking and 2 or a)
	local c = 250 + (5 * b)

	style.text.a = c
	
	self:SetTextColor(style.text)

	self:DrawCorners(0, 0, w, h, h * 0.25)


	render.OverrideBlend(true, 4, 1, BLENDFUNC_ADD, 4, 1, BLENDFUNC_ADD)
		if (self.stateAlpha or 0) > 0 then
			surface.SetDrawColor(64, 200, 150, 64 * b)
			surface.DrawRect(0, 0, w, h)
		end
	render.OverrideBlend(false)
end

function PANEL:OnCursorEntered()
	surface.PlaySound("helix/ui/rollover.wav")
end

function PANEL:OnMousePressed(mousecode)
	self.m_MenuClicking = true

	DButton.OnMousePressed(self, mousecode)
end

function PANEL:OnMouseReleased(mousecode)
	DButton.OnMouseReleased(self, mousecode)

	if self.m_MenuClicking and mousecode == MOUSE_LEFT then
		self.m_MenuClicking = false
	end
end

vgui.Register("ui.craft.button", PANEL, "DButton")
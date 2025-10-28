local PANEL = {}

local BG_COLOR = Color(255, 190, 32)
local BG_DETAIL = Color(0, 200, 255, 255)
local TEXT_COLOR = Color(72, 64, 0, 255)

function PANEL:Init()
	self:SetText('')
	self:SetFont("craft.button")
	self:SetTextColor(TEXT_COLOR)

	self:SetContentAlignment(5)
end

function PANEL:Paint(w, h)
	self.stateAlpha = math.Approach((self.stateAlpha or 0), (self:IsHovered() or self.m_MenuClicking) and 1 or 0, FrameTime() * 10)
	local a = 0

	if (self.stateAlpha or 0) > 0 then
		a = math.ease.OutCubic(self.stateAlpha)
	end

	local b = (self.m_MenuClicking and 2 or a)
	local c = 250 + (5 * b)

	self:SetTextColor(ColorAlpha(TEXT_COLOR, c))

	surface.SetDrawColor(BG_COLOR)
	surface.DrawRect(0, 0, w, h)



	render.OverrideBlend(true, 4, 1, BLENDFUNC_ADD, 4, 1, BLENDFUNC_ADD)
		if (self.stateAlpha or 0) > 0 then
			surface.SetDrawColor(255, 200, 64, 64 * b)
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
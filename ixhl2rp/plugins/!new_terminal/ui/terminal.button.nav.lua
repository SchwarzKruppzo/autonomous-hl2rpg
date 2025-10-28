local PANEL = {}
PANEL.colors = {
	regular = ix.Palette.combineblue,
	hover_text = ix.Palette.combinegreen,
	hover = ix.Palette.combineblue:Alpha(64),
	textDisabled = ix.Palette.combineblue:Alpha(25)
}

DEFINE_BASECLASS("DButton")

AccessorFunc(PANEL, "borderSize", "BorderSize", FORCE_NUMBER)

function PANEL:Init()
	self:SetFont(Monolith.Fonts.TerminalLight22)

	self.hoverClr = ix.Palette.combineblue:Alpha(0)
	self.hoverClr2 = ix.Palette.combineblue:Alpha(0)

	self:UpdateColors(false)
end

function PANEL:UpdateColors(isHover)
	local isDisabled = self:GetDisabled()
	local isActive = self.active

	if isActive then
		self:SetTextColor(self.colors.hover_text)
	else
		self:SetTextColor((isHover and self.colors.hover_text) or (isDisabled and self.colors.textDisabled or self.colors.regular))
	end
end

function PANEL:OnMousePressed(code)
	self.pressed = true
	self.BaseClass.OnMousePressed(self, code)
end

function PANEL:OnMouseReleased(code)
	self.pressed = false
	self.BaseClass.OnMouseReleased(self, code)
end

function PANEL:OnCursorEntered()
	self.hovered = true
	self:UpdateColors(true)
end

function PANEL:OnCursorExited()
	self.hovered = false
	self:UpdateColors(false)
end

function PANEL:DoClick()
	if (self.nextPress or 0) > CurTime() then return end

	if !self.noSound then
		surface.PlaySound("combine_tech/civic_station/station_menu_select.mp3")
	end

	self.nextPress = CurTime() + 0.05

	if self.OnClick then
		self:OnClick()
	end
end

function PANEL:Paint(w, h)
	local ft = FrameTime()
	local isDisabled, isPressed, isActive = self:GetDisabled(), self.pressed, self.active
	local borderSize = isDisabled and 0 or self:GetBorderSize()

	if isActive then
		self.hoverClr.a = 64
		self.hoverClr2.a = 255

		ix.DX.Draw(0, 0, 0, w, h, self.hoverClr)
	else
		self.hoverAlpha = math.Approach((self.hoverAlpha or 0), self.hovered and 1 or 0, ft * 5)
		local hoverAlpha = math.ease.OutCubic(self.hoverAlpha)

		self.hoverClr.a = 64 * self.hoverAlpha
		self.hoverClr2.a = 255 * self.hoverAlpha
	end

	ix.DX.Draw(0, 0, 0, w, h, self.hoverClr)

	surface.SetDrawColor(self.hoverClr2)
	surface.DrawRect(0, h - 2, w, 2)

end

vgui.Register("terminal.button.nav", PANEL, "DButton")
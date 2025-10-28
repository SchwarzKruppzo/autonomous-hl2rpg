local PANEL = {}

function PANEL:Init()
	self:SetColor(ix.Palette.combinegreen)
	self:SetTall(1)
end

function PANEL:SetColor(clr)
	self.color = clr
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(self.color)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("terminal.frame.divider", PANEL, "Panel")

PANEL = {}

function PANEL:Init()
	self:SetColor(ix.Palette.combineblue)

	self.container = self:Add("Panel")
end

function PANEL:AddLabel(content, font, clr)
	local text = self.container:Add("DLabel")
	text:Dock(TOP)
	text:SetFont(font or "cmb.terminal.light30")
	text:SetText(content)
	text:SetContentAlignment(5)
	text:SizeToContents()
	text:SetTextColor(clr or ix.Palette.combineblue)

	self.container:InvalidateLayout(true)
	self.container:SizeToChildren(false, true)

	return text
end

function PANEL:SetColor(clr)
	self.color_bg = clr:Alpha(25)
	self.color = clr
end

function PANEL:GetColor()
	return self.color, self.color_bg
end

function PANEL:PerformLayout(w)
	self.container:SetWide(w)
	self.container:Center()
end

function PANEL:Paint(w, h)
	ix.DX.Draw(0, 0, 0, w, h, self.color_bg)

	if !self.noBorder then
		surface.SetDrawColor(self.color)
		surface.DrawRect(0, 0, w, 5)
	end

	surface.SetDrawColor(ix.Palette.combineblue:Alpha(64))
	surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("terminal.frame.info", PANEL, "Panel")
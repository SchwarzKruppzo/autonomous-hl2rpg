function PLUGIN:OnContextMenuOpen()
	if (IsValid(self.ui.panel)) then
		self.ui.panel:MakePopup()
	end
end

function PLUGIN:OnContextMenuClose()
	if (IsValid(self.ui.panel)) then
		self.ui.panel:SetMouseInputEnabled(false)
		self.ui.panel:SetKeyboardInputEnabled(false)
	end
end

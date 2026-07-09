if (SERVER) then
	return
end

local PANEL = {}

function PANEL:Init()
	local data = ix.gui.omniIDEditorData or {}

	self.toolID = ix.gui.omniIDEditorToolID
	self.targetID = ix.gui.omniIDEditorItemID
	self.sources = ix.gui.omniIDEditorSources or {}

	self:SetSize(380, 360)
	self:Center()
	self:SetTitle(L("omnitool.cardEditorTitle"))
	self:MakePopup()

	self.info = self:Add("DLabel")
	self.info:Dock(TOP)
	self.info:DockMargin(8, 8, 8, 4)
	self.info:SetText(Format("%s [%s]", data.name or "nobody", data.number or ""))
	self.info:SizeToContents()

	self.access = self:Add("DListView")
	self.access:Dock(FILL)
	self.access:DockMargin(8, 0, 8, 8)
	self.access:SetMultiSelect(false)
	local header = self.access:AddColumn(L("omnitool.cardAccessColumn")).Header

	header.DoRightClick = function()
		if (IsValid(self.contextMenu)) then
			self.contextMenu:Remove()
		end

		self.contextMenu = DermaMenu()
		self.contextMenu:AddOption(L("omnitool.addAccess"), function()
			Derma_StringRequest(L("omnitool.addAccessTitle"), "", "", function(value)
				if (!IsValid(self) or !IsValid(self.access)) then
					return
				end

				value = string.Trim(value)

				if (#value == 0) then
					return
				end

				for _, line in ipairs(self.access:GetLines()) do
					if (line:GetValue(1) == value) then
						return
					end
				end

				self.access:AddLine(value)
			end)
		end):SetImage("icon16/cog_add.png")
		self.contextMenu:Open()
	end

	self.access.OnRowRightClick = function(_, index)
		if (IsValid(self.contextMenu)) then
			self.contextMenu:Remove()
		end

		self.contextMenu = DermaMenu()
		self.contextMenu:AddOption(L("omnitool.removeAccess"), function()
			if (!IsValid(self) or !IsValid(self.access)) then
				return
			end

			self.access:RemoveLine(index)
		end):SetImage("icon16/cog_delete.png")
		self.contextMenu:Open()
	end

	self.controls = self:Add("DPanel")
	self.controls:Dock(BOTTOM)
	self.controls:DockMargin(8, 0, 8, 8)
	self.controls:SetTall(28)
	self.controls.Paint = nil

	self.copy = self.controls:Add("DButton")
	self.copy:Dock(LEFT)
	self.copy:SetWide(180)
	self.copy:SetText(L("omnitool.copyAccess"))
	self.copy.DoClick = function()
		if (IsValid(self.contextMenu)) then
			self.contextMenu:Remove()
		end

		self.contextMenu = DermaMenu()

		if (#self.sources == 0) then
			local option = self.contextMenu:AddOption(L("omnitool.noSourceCards"))
			option:SetDisabled(true)
		else
			for _, source in ipairs(self.sources) do
				local sourceData = source
				local title = Format("%s [%s]", sourceData.name or "nobody", sourceData.number or "")

				self.contextMenu:AddOption(title, function()
					if (!IsValid(self)) then
						return
					end

					self:SetAccess(sourceData.access)
				end):SetImage("icon16/vcard.png")
			end
		end

		self.contextMenu:Open()
	end

	self.apply = self.controls:Add("DButton")
	self.apply:Dock(RIGHT)
	self.apply:SetWide(120)
	self.apply:SetText(L("omnitool.applyAccess"))
	self.apply.DoClick = function()
		local access = {}

		for _, line in ipairs(self.access:GetLines()) do
			access[#access + 1] = line:GetValue(1)
		end

		netstream.Start("ixOmniCitizenIDEdit", self.toolID, self.targetID, {
			access = access
		})

		self:Close()
	end

	self:SetAccess(data.access)
end

function PANEL:SetAccess(access)
	self.access:Clear()

	for _, value in ipairs(access or {}) do
		self.access:AddLine(value)
	end
end

function PANEL:OnRemove()
	if (IsValid(self.contextMenu)) then
		self.contextMenu:Remove()
	end

	if (ix.gui.omniIDEditor == self) then
		ix.gui.omniIDEditor = nil
	end

	ix.gui.omniIDEditorData = nil
	ix.gui.omniIDEditorSources = nil
	ix.gui.omniIDEditorToolID = nil
	ix.gui.omniIDEditorItemID = nil
end

vgui.Register("ixOmniIDEditor", PANEL, "DFrame")

netstream.Hook("ixOmniCitizenIDEdit", function(toolID, itemID, data, sources)
	if (IsValid(ix.gui.omniIDEditor)) then
		ix.gui.omniIDEditor:Remove()
	end

	ix.gui.omniIDEditorToolID = toolID
	ix.gui.omniIDEditorItemID = itemID
	ix.gui.omniIDEditorData = istable(data) and data or {}
	ix.gui.omniIDEditorSources = istable(sources) and sources or {}
	ix.gui.omniIDEditor = vgui.Create("ixOmniIDEditor")
end)

local PANEL = {}

function PANEL:Init()
	local item = ix.gui.idEditorItem

	self:SetSize(320, 480)
	self:MakePopup()
	self:CenterVertical()
	self:SetTitle(L("cideditor.title"))

	local label = self:Add("DLabel")
	label:Dock(TOP)
	label:SetText(L("cideditor.assignedTo"))
	label:SizeToContents()

	self.name = self:Add("DTextEntry")
	self.name:Dock(TOP)
	self.name:SetText(item["name"] or "nobody")

	local label = self:Add("DLabel")
	label:Dock(TOP)
	label:SetText(L("cideditor.cidLabel"))
	label:SizeToContents()

	self.cid = self:Add("DTextEntry")
	self.cid:Dock(TOP)
	self.cid:SetText(item["cid"] or "0000")

	self.cidBtn = self:Add("DButton")
	self.cidBtn:Dock(TOP)
	self.cidBtn:SetText(L("cideditor.generateCid"))
	self.cidBtn.DoClick = function(this)
		self.cid:SetText(Schema:ZeroNumber(math.random(1, 99999), 5))
	end

	local label = self:Add("DLabel")
	label:Dock(TOP)
	label:SetText(L("cideditor.regidLabel"))
	label:SizeToContents()

	self.regid = self:Add("DTextEntry")
	self.regid:Dock(TOP)
	self.regid:SetText(item["number"] or "")

	self.regidBtn = self:Add("DButton")
	self.regidBtn:Dock(TOP)
	self.regidBtn:SetText(L("cideditor.generateRegid"))
	self.regidBtn.DoClick = function(this)
		self.regid:SetText(string.format("%s-%d",string.gsub(math.random(100000000, 999999999), "^(%d%d%d)(%d%d%d%d)(%d%d)", "%1:%2:%3"), Schema:ZeroNumber(math.random(1, 99), 2)))
	end

	local label = self:Add("DLabel")
	label:Dock(TOP)
	label:SetText(L("cideditor.availableAccesses"))
	label:SizeToContents()

	local menu

	self.accesss = self:Add("DListView")
	self.accesss:Dock(FILL)
	self.accesss:DockMargin(0, 4, 0, 0)
	local header = self.accesss:AddColumn("Access Name").Header
	header:SetTextColor(color_black)

	self.accesss:SetMultiSelect(false)

	header.DoRightClick = function()
		if (IsValid(menu)) then
			menu:Remove()
		end

		menu = DermaMenu()
		menu:AddOption(L("cideditor.addAccess"), function()
			Derma_StringRequest(L("cideditor.addAccessTitle"), "", "all", function(text)
				for _, line in pairs(self.accesss:GetLines()) do
					if text == line:GetValue(1) then
						return
					end
				end
				
				self.accesss:AddLine(text)
			end)
		end):SetImage("icon16/cog_add.png")
		menu:Open()
	end
	self.accesss.OnRowRightClick = function(this, index, line)
		if (IsValid(menu)) then
			menu:Remove()
		end

		menu = DermaMenu()

		menu:AddOption(L("cideditor.removeAccess"), function()
			this:RemoveLine(index)
		end):SetImage("icon16/cog_delete.png")
		menu:Open()
	end

	for k, v in pairs(item["access"] or {}) do
		self.accesss:AddLine(k)
	end

	self.apply = self:Add("DButton")
	self.apply:Dock(BOTTOM)
	self.apply:SetText(L("cideditor.applyChanges"))
	self.apply.DoClick = function(this)
		local data = {}
		data["name"] = self.name:GetText()
		data["cid"] = self.cid:GetText()
		data["number"] = self.regid:GetText()
		data["access"] = {}

		for _, line in pairs(self.accesss:GetLines()) do
			data["access"][#data["access"] + 1] = line:GetValue(1)
		end

		netstream.Start("ixCitizenIDEdit", ix.gui.idEditorItemID, data)
		self:Close()
	end
end

function PANEL:OnRemove()
	if (IsValid(ix.gui.idEditor)) then
		ix.gui.idEditor:Remove()
	end
end

vgui.Register("ixIDEditor", PANEL, "DFrame")

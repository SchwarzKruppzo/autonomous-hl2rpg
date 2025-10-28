local PANEL = {}
local scale = ix.UI.Scale

PANEL.isMini = true

ix.gui.can_craft = nil

function PANEL:CacheRecipeNeeds(stationID, stationInventory)
	local client = LocalPlayer()

	if !ix.gui.can_craft then
		ix.gui.can_craft = {}

		for _, recipe in pairs(ix.Craft.recipes) do
			local canCraft = true

			if recipe.station then
				if istable(recipe.station) then
					canCraft = false

					for k, v in ipairs(recipe.station) do
						if stationID and stationID == v then
							canCraft = true
							break
						end
					end
				else
					if (!stationID or stationID != recipe.station) then
						canCraft = false
					end
				end
			end

			if canCraft then
				for k, itemID in ipairs(recipe.tools or {}) do
					if !client:HasItem(itemID) and (stationID and !stationInventory:HasItem(itemID) or false) then
						canCraft = false
						break
					end
				end

				if recipe.isBreakdown then
					local hasInInv = client:HasItem(recipe.requirements, "main")
					local hasInStash = (stationID and stationInventory:HasItem(recipe.requirements) or false)
					
					canCraft = hasInStash or hasInInv
				else
					for uniqueID, amount in pairs(recipe.requirements or {}) do
						local count = 0
						local stored = ix.Item:Get(uniqueID)

						if stored.stackable_legacy then
							for k, v in ipairs(client:GetInventory("main"):GetItems()) do
								if v.uniqueID == uniqueID then
									count = count + v:GetValue()
								end
							end

							if stationID then
								for k, v in ipairs(stationInventory:GetItems()) do
									if v.uniqueID == uniqueID then
										count = count + v:GetValue()
									end
								end
							end

							if count < amount then
								canCraft = false
								break
							end
						else
							count = count + client:GetInventory("main"):GetItemsCount(uniqueID)

							if stationID then
								count = count + stationInventory:GetItemsCount(uniqueID)
							end

							if recipe.any and recipe.any[uniqueID] then
								for k, v in pairs(recipe.any[uniqueID]) do
									count = count + client:GetInventory("main"):GetItemsCount(k)

									if stationID then
										count = count + stationInventory:GetItemsCount(k)
									end
								end
							end

							if count < amount then
								canCraft = false
								break
							end
						end
					end
				end
			end

			ix.gui.can_craft[recipe.uniqueID] = canCraft
		end
	end
end

function PANEL:Paint(w, h)
	if !ix.gui.can_craft then
		self:CacheRecipeNeeds(self.station and self.station.uniqueID, self.station and ix.Inventory:Get(self.inventoryID))
	end

	if !self.isMini then
		surface.SetDrawColor(16, 32, 48, 255 * 0.9)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 190 * 0.5, 255 * 0.5, 255 * 0.5)
		surface.DrawOutlinedRect(0, 0, w, h)
	end
end

function PANEL:BuildCraftPanel()
	ix.gui.craftFrame = self

	local top = self.second:Add("Panel")
	top:Dock(TOP)
	top:DockMargin(0, 0, 0, 0)

	local itemTitle = top:Add("DLabel")
	itemTitle:Dock(TOP)
	itemTitle:DockMargin(0, 10, 0, 0)
	itemTitle:SetContentAlignment(5)
	itemTitle:SetTextColor(Color(0, 225, 255))
	itemTitle:SetFont("craft.item.title")
	itemTitle:SetText("USP MATCH")
	itemTitle:SetVisible(false)

	self.craftTitle = itemTitle

	local iconFrame = top:Add("Panel")
	iconFrame:Dock(TOP)
	iconFrame:SetSize(self.second:GetWide())
	iconFrame:SetVisible(false)

	local itemIcon = iconFrame:Add("craft.preview")
	itemIcon:Rebuild('uspmatch', 64)
	itemIcon:SetVisible(true)
	iconFrame:SetTall(itemIcon:GetTall() + 20)
	itemIcon:Center()

	self.iconFrame = iconFrame
	self.itemIcon = itemIcon

	local resultAmount = itemIcon:Add("DLabel")
	resultAmount:SetFont("ui.craft.large")
	resultAmount:SetText("")
	resultAmount:SetContentAlignment(6)
	resultAmount:SetVisible(true)
	resultAmount:SizeToContents()
	resultAmount:AlignRight(0)
	resultAmount:AlignBottom(0)

	self.itemCount = resultAmount

	local itemLevelUp = top:Add("DLabel")
	itemLevelUp:SetFont("craft.item.key")
	itemLevelUp:Dock(TOP)
	itemLevelUp:SetVisible(false)
	itemLevelUp:SetText("")
	itemLevelUp:SetContentAlignment(5)
	itemLevelUp:SetTextColor(Color(100, 255, 100, 255))
	itemLevelUp:SizeToContents()

	self.itemXP = itemLevelUp

	local skill = top:Add("DLabel")
	skill:SetFont("craft.item.key")
	skill:SetText("")
	skill:SetTextColor(Color(255, 255, 255, 255))
	skill:SetContentAlignment(5)
	skill:SetVisible(false)
	skill:Dock(TOP)
	skill:DockMargin(0, 0, 0, 32)
	skill:SizeToContents()

	self.itemSkill = skill

	local stationsPanel = top:Add("Panel")
	stationsPanel:Dock(TOP)
	stationsPanel:DockMargin(15, 0, 0, 0)
	stationsPanel:SetTall(scale(20))
	stationsPanel:SetVisible(false)
		local stationsTitle = stationsPanel:Add("DLabel")
		stationsTitle:SetFont("craft.item.key")
		stationsTitle:SetText("РАБОЧЕЕ МЕСТО: ")
		stationsTitle:SetTextColor(Color(0, 225, 255, 255))
		stationsTitle:Dock(LEFT)
		stationsTitle:SizeToContents()

		local station = stationsPanel:Add("DLabel")
		station:SetFont("craft.item.value")
		station:SetText("")
		station:SetTextColor(Color(255, 255, 255, 255))
		station:Dock(LEFT)
		station:SizeToContents()

		self.stationsPanel = stationsPanel
		self.stations = station

	local toolsPanel = top:Add("Panel")
	toolsPanel:Dock(TOP)
	toolsPanel:DockMargin(15, 0, 0, 0)
	toolsPanel:SetTall(scale(20))
	toolsPanel:SetVisible(false)
		local toolsTitle = toolsPanel:Add("DLabel")
		toolsTitle:SetFont("craft.item.key")
		toolsTitle:SetText("ИНСТРУМЕНТЫ: ")
		toolsTitle:SetTextColor(Color(0, 225, 255, 255))
		toolsTitle:Dock(LEFT)
		toolsTitle:SizeToContents()

		self.toolsPanel = toolsPanel

	local componentsTitle = top:Add("DLabel")
	componentsTitle:SetFont("craft.item.key")
	componentsTitle:Dock(TOP)
	componentsTitle:DockMargin(15, 10, 0, 0)
	componentsTitle:SetVisible(false)
	componentsTitle:SetText("КОМПОНЕНТЫ:")
	componentsTitle:SetTextColor(Color(0, 225, 255, 255))
	componentsTitle:SizeToContents()

	self.componentsTitle = componentsTitle

	self.components = top:Add("DTileLayout")
	self.components:SetBaseSize(32)
	self.components:Dock(TOP)
	self.components:DockMargin(15, 5, 0, 0)
	self.components:SetSpaceY(0)
	self.components:SetSpaceX(0)

	top:InvalidateLayout(true)
	top:SizeToChildren(true, true)

	self.top = top
end

function PANEL:PaintOver(w, h)
	if self.anim then
		local delta = (UnPredictedCurTime() - self.animStart) / self.animTime
		
		if delta > 1 then
			self.anim = false
		end
		
		surface.SetDrawColor(0, 0, 0, 255 * (1 - math.ease.InOutCubic(delta)))
		surface.DrawRect(0, 0, w, h)
	end
end

function PANEL:Setup()
	if self.isMini then
		self:Dock(FILL)
		self:InvalidateParent(true)
	else
		self:SetSize(ScrW(), ScrH())
		self:MakePopup()

		self.anim = true
		self.animStart = UnPredictedCurTime()
		self.animTime = 0.3
	end

	local container = self:Add("ui.craft.container", 1)
	container:Setup(self.isMini, self.inventoryID)

	self:BuildCraftPanel()
end

function PANEL:OnKeyCodePressed(key)
	if key == KEY_TAB then
		if self.OnClose then
			self:OnClose()
		end
		
		self:Remove()
	end
end

vgui.Register("ui.craft", PANEL, "EditablePanel")

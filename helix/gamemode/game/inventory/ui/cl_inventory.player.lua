local slots = {
	[1] = 'backpack'
}

local PANEL = {}
PANEL.slot_padding = 1

function PANEL:Init()
	self:RequestFocus()
	self.slot_panels = {}

	self.horizontal_scroll = vgui.Create('DHorizontalScroller', self)
	self.horizontal_scroll.OnMouseWheeled = function(pnl, dlta)
		if !input.IsKeyDown(KEY_LSHIFT) then return false end

		pnl.OffsetX = pnl.OffsetX + dlta * -30
		pnl:InvalidateLayout(true)

		return true
	end

	self.scroll = vgui.Create('DScrollPanel', self)
	self.scroll:GetVBar().OnMouseWheeled = function(pnl, dlta)
		if input.IsKeyDown(KEY_LSHIFT) then return false end

		return pnl:AddScroll(dlta * -2)
	end

	self.horizontal_scroll:AddPanel(self.scroll)
end

function PANEL:PerformLayout(w, h)
	local slot_size_w, slot_size_h = self:GetSlotSize()
	local slot_padding = self:GetSlotPadding()
	local width = (slot_size_w + slot_padding) - slot_padding
	local height = (slot_size_h + slot_padding) - slot_padding

	if height > h then
		width = width + math.scale_x(16) + slot_padding
	end

	self.scroll:SetWide(self.max_width)
	self.horizontal_scroll:SetSize(w, h)
end

function PANEL:Paint(w, h)

end

function PANEL:SizeToContents()
	self:SetSize(self.max_width + 10, self.max_height + 5)
end

function PANEL:Rebuild()
	dragndrop.Clear()
	self.scroll:Clear()

	local slot_size_w, slot_size_h = self:GetSlotSize()

	self.max_width = 0
	self.max_height = 0

	for i = 1, #slots do
		self.slot_panels[i] = {}

		local container = vgui.Create('EditablePanel', self.scroll)
		container:Dock(TOP)
		container:DockMargin(0, 0, 0, 16)
		container.container = true

		local inv = LocalPlayer():GetInventory(slots[i])
		local slot = inv:CreatePanel(container)
		slot:SetSlotSize(slot_size_w * 2, slot_size_h * 2)
		slot:Rebuild()
		slot:SizeToContents()
		slot:SetTitle("РЮКЗАК")
		slot.OnRebuild = nil

		local instance_ids = inv:GetSlot(1, 1)

		if container.sub_panel and IsValid(container.sub_panel) then
			container.sub_panel:Remove()
		end

		if instance_ids and #instance_ids > 0 then
			local item = ix.Item.instances[instance_ids[1]]
			if item and item.inventory_data then
				local inventory
				for k, v in pairs(ix.Inventory:All()) do
					if v.instance_id == item.id then
						inventory = v
						break
					end
				end
				if inventory then
					local panel = vgui.Create('ui.inv', container)
					panel:SetSlotSize(slot_size_w, slot_size_h)
					panel:SetInventoryID(inventory.id)
					panel:Rebuild()
					panel:SizeToContents()
					panel:MoveRightOf(slot, 8)

					slot.OnRebuild = function()
						self:Rebuild()
					end
					
					container.sub_panel = panel
					inventory.panel = panel
				end
			end
		end

		container:InvalidateLayout(true)
		container:SizeToChildren(true, true)

		self.scroll:AddItem(container)
		self.max_width = math.max(self.max_width, container:GetWide())
		self.max_height = self.max_height + container:GetTall()+ (i != height and 16 or 0)
	end
end

function PANEL:SetSlotSize(size, height)
	if !height then
		self.slot_size_w = size
		self.slot_size_h = size
	else
		self.slot_size_w = size
		self.slot_size_h = height
	end
end

function PANEL:GetSlotSize()
	return self.slot_size_w, self.slot_size_h
end

function PANEL:GetSlotPadding()
	return self.slot_padding
end

vgui.Register('ui.player.inventory', PANEL, 'EditablePanel')
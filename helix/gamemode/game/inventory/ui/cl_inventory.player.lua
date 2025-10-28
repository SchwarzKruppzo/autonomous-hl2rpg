local slotTitles = {
	[1] = 'torso',
	[2] = 'legs',
	[3] = 'backpack'
}

local PANEL = {}
PANEL.title = ''
PANEL.slot_padding = 1
PANEL.draw_inventory_slots = false

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

	local parent = self:GetParent()

	if IsValid(parent) then
		/*
		parent:Receiver('ix.item', function(receiver, dropped, is_dropped, menu_index, mouse_x, mouse_y)
			LocalPlayer():ChatPrint("TEST3")

			local dropped = dropped[1]

			if is_dropped then
			
			else
				local drop_slot = ix.inventory_drop_slot

				if IsValid(drop_slot) then
					drop_slot.is_hovered = false
					ix.inventory_drop_slot = nil
				end
			end
		end)*/
	end

end

function PANEL:PerformLayout(w, h)
	local slot_size_w, slot_size_h = self:GetSlotSize()
	local slot_padding = self:GetSlotPadding()
	local width = (slot_size_w + slot_padding) * self:GetInventoryWidth() - slot_padding
	local height = (slot_size_h + slot_padding) * self:GetInventoryHeight() - slot_padding

	if height > h then
		width = width + math.scale_x(16) + slot_padding
	end

	self.scroll:SetWide(self.max_width)
	self.horizontal_scroll:SetSize(w, h)
end

function PANEL:Paint(w, h)

end

do
	surface.CreateFont('inventory.title', {
		font = 'Blender Pro Bold',
		extended = true,
		size = ix.UI.Scale(13),
		weight = 500,
		antialias = true,
	})
end

local clrTitle = Color(0, 210 * 0.35, 255 * 0.35, 225)
local function PaintTitle(self, w, h)
	surface.SetFont('inventory.title')
	local textW, textH = surface.GetTextSize(self.title)

	surface.SetDrawColor(clrTitle)
	surface.DrawRect(0, 0, self.size, h)

	surface.SetTextColor(0, 210* 0.8, 255 * 0.8, 255)
	surface.SetTextPos(textH / 2, h / 2 - textH / 2)
	surface.DrawText(self.title)
end

function PANEL:SizeToContents()
	self:SetSize(self.max_width + 10, self.max_height + 5)
end

function PANEL:StartDragging(dropped)
	if IsValid(dropped.scroll) then
		return dropped.scroll:StartDragging(dropped)
	end
	
	local w, h = dropped:GetItemSize()
	local x, y = dropped:GetItemPos()
	local slot_size_w, slot_size_h = self:GetSlotSize()
	local slot_padding = self:GetSlotPadding()
	local drag_inventory_id = dropped:GetInventoryID()
	local panel = self

	if drag_inventory_id != self:GetInventoryID() then
		panel = ix.Inventory:Get(drag_inventory_id).panel
	end

	dropped:SetVisible(false)
	dropped.title = nil

	for i = y, y + h - 1 do
		if i == y then

			LocalPlayer():ChatPrint(tostring(dropped.container))
			
			local slot = vgui.Create('ui.inv.item', dropped.container)
			slot:SetSize(slot_size_w, slot_size_h)
			slot:SetPos(0, 0)
			slot.container = dropped.container
			slot.slot_x = 1
			slot.slot_y = i
			slot.slot_size = {slot_size_w, slot_size_h}
			slot.slot_padding = slot_padding
			slot.inventory_id = panel:GetInventoryID()
			slot.multislot = panel:IsMultislot()

			local icon = panel:GetIcon()

			if icon then
				slot.icon = icon
			end

			if panel:IsDisabled() then
				slot.disabled = true
			end
		end
	end
end

function PANEL:OnDrop(dropped)
	RememberCursorPosition()
	
	local drop_slot = ix.inventory_drop_slot

	if drop_slot.out_of_bounds then
		self:Rebuild()

		local drag_slot = ix.inventory_drag_slot

		if IsValid(drag_slot) then
			local drag_inventory_id = drag_slot:GetInventoryID()

			if drag_inventory_id != self:GetInventoryID() then
				local panel = ix.Inventory:Get(drag_inventory_id).panel

				if IsValid(panel) then
					panel:Rebuild()
				end
			end
		end

		return
	end

	ix.inventory_drag_slot = nil
	ix.inventory_drop_slot = nil

	drop_slot.is_hovered = false

	local split = false
	local split_count = 0

	if dropped.item_count > 1 then
		if input.IsKeyDown(KEY_LCONTROL) then
			split = true
		elseif input.IsKeyDown(KEY_LSHIFT) then
			split = true
			split_count = 1
		end
	end

	local dropped_item = dropped.instance_ids[1]
	local item = ix.Item.instances[dropped_item]

	if !item then
		return
	end

	if drop_slot.item_data then
		if ix.Item:OpenItemMenuCombine(item, drop_slot.item_data, split, split_count) then
			local panel = ix.Inventory:Get(item.inventory_id).panel

			if IsValid(panel) then
				panel:Rebuild()
			end
			
			return
		end
	end
	
	net.Start('inventory.move')
		net.WriteUInt(item.inventory_id, 32)
		net.WriteUInt(self:GetInventoryID(), 32)
		net.WriteUInt(item.x, 8)
		net.WriteUInt(item.y, 8)
		net.WriteBool(split)
		net.WriteUInt(split_count, 16)
		net.WriteUInt(drop_slot.slot_x, 8)
		net.WriteUInt(drop_slot.slot_y, 8)
		net.WriteBool(dropped:WasRotated())
	net.SendToServer()
end

function PANEL:SetInventoryID(inventory_id)
	self.inventory_id = inventory_id

	self:Rebuild()
end

function PANEL:Rebuild()
	dragndrop.Clear()
	self.scroll:Clear()

	for i = 1, self:GetInventoryHeight() do
		self.slot_panels[i] = {}
	end

	local slot_size_w, slot_size_h = self:GetSlotSize()
	local slot_padding = self:GetSlotPadding()
	local width, height = self:GetInventorySize()

	self.max_width = 0
	self.max_height = 0

	for i = 1, height do
		local label = vgui.Create('EditablePanel', self.scroll)
		label:Dock(TOP)
		label.title = L(slotTitles[i]):utf8upper()
		label.size = slot_size_w
		label.Paint = PaintTitle
		label:SetSize(slot_size_w, 16)

		self.scroll:AddItem(label)

		local container = vgui.Create('EditablePanel', self.scroll)
		container:Dock(TOP)
		container:DockMargin(0, 0, 0, 16)
		container.container = true
		container:Receiver('ix.item', function(receiver, dropped, is_dropped, menu_index, mouse_x, mouse_y)
			dropped = dropped[1]

			if dropped:IsVisible() then
				self:StartDragging(dropped)
			end

			if is_dropped then
				self:OnDrop(dropped)
			else
				local drop_slot = ix.inventory_drop_slot
				local slot = receiver:GetClosestChild(mouse_x, mouse_y)

				slot.is_hovered = true

				if IsValid(drop_slot) then
					if slot != drop_slot then
						drop_slot.is_hovered = false
					else
						return
					end
				end

				ix.inventory_drop_slot = slot
			end
		end)

		local slot = vgui.Create('ui.inv.item', container)
		slot:SetSize(slot_size_w, slot_size_h)
		slot:SetPos(0, 0)
		slot.container = container
		slot.slot_x = 1
		slot.slot_y = i
		slot.slot_size = {slot_size_w, slot_size_h}
		slot.slot_padding = slot_padding
		slot.inventory_id = self:GetInventoryID()
		slot.multislot = self:IsMultislot()

		local icon = self:GetIcon()

		if icon then
			slot.icon = icon
		end

		if self:IsDisabled() then
			slot.disabled = true
		end

		if self.slot_panels[i][1] == false then
			slot:SetVisible(false)
		else
			local instance_ids = self:GetSlot(1, i)

			if instance_ids and #instance_ids > 0 then
				local item = ix.Item.instances[instance_ids[1]]

				if #instance_ids == 1 then
					slot:SetItem(instance_ids[1])
				else
					slot:SetItemMulti(instance_ids)
				end

				if item and item.inventory_data then
					local inventory
					for k, v in pairs(ix.Inventory:All()) do
						if v.instance_id == item.id then
							inventory = v
							break
						end
					end

					print("AYYY!", inventory, item.id)
					if inventory then
						local panel = vgui.Create('ui.inv', container)
						panel:SetSlotSize(slot_size_w * 0.5, slot_size_h * 0.5)
						panel:SetInventoryID(inventory.id)
						panel:Rebuild()
						panel:SizeToContents()
						panel:MoveRightOf(slot, 5)

						inventory.panel = panel
					end
				end
			end
		end

		if i == 3 then
			local panel = vgui.Create('ui.inv', container)
			panel:SetSlotSize(slot_size_w * 0.5, slot_size_h * 0.5)
			panel:SetInventoryID(LocalPlayer():GetInventory('main').id)
			panel.OnRebuild = function(self)
				ix.util.TabFocus(self, self.isTabFrame)
			end
			panel:Rebuild()
			panel:SizeToContents()
			panel:MoveRightOf(slot, 5)
			panel.isTabFrame = self.isTabFrame

			LocalPlayer():GetInventory('main').panel = panel
		end

		self.slot_panels[i][1] = slot

		container:InvalidateLayout(true)
		container:SizeToChildren(true, true)

		self.scroll:AddItem(container)
		self.max_width = math.max(self.max_width, container:GetWide())
		self.max_height = self.max_height + container:GetTall() + label:GetTall() + (i != height and 16 or 0)
	end
	
	if self.OnRebuild then
		self:OnRebuild()
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

function PANEL:SetSlotPadding(padding)
	self.slot_padding = padding
end

function PANEL:SetIcon(icon)
	self.icon = icon
end

function PANEL:GetInventory()
	return ix.Inventory:Get(self:GetInventoryID())
end

function PANEL:GetInventoryID()
	return self.inventory_id
end

function PANEL:GetInventoryWidth()
	return self:GetInventory():GetWidth()
end

function PANEL:GetInventoryHeight()
	return self:GetInventory():GetHeight()
end

function PANEL:GetInventorySize()
	return self:GetInventory():GetSize()
end

function PANEL:GetInventoryType()
	return self:GetInventory():GetType()
end

function PANEL:GetSlots()
	return self:GetInventory():GetSlots()
end

function PANEL:GetSlot(x, y)
	return self:GetInventory():GetSlot(x, y)
end

function PANEL:GetOwner()
	return self:GetInventory():GetOwner()
end

function PANEL:GetSlotSize()
	return self.slot_size_w, self.slot_size_h
end

function PANEL:GetSlotPadding()
	return self.slot_padding
end

function PANEL:IsMultislot()
	return self:GetInventory():IsMultislot()
end

function PANEL:IsDisabled()
	return self:GetInventory():IsDisabled()
end

function PANEL:DrawInventorySlots(bool)
	self.draw_inventory_slots = bool
end

function PANEL:GetIcon()
	return self.icon
end

function PANEL:SetTitle(title)
	self.title = title
end

vgui.Register('ui.player.inventory', PANEL, 'EditablePanel')
local size = math.scale(64)
local REGION_GAP = math.scale(4)

local function GetClosestVisibleSlot(parent, x, y)
	local best, best_dist = nil, math.huge

	for _, child in ipairs(parent:GetChildren()) do
		if child:IsVisible() and child.slot_x then
			local cx, cy = child:GetPos()
			local cw, ch = child:GetSize()
			local dx = math.max(cx - x, 0, x - cx - cw)
			local dy = math.max(cy - y, 0, y - cy - ch)
			local dist = dx * dx + dy * dy

			if dist < best_dist then
				best_dist = dist
				best = child
			end
		end
	end

	return best
end

local PANEL = {}
PANEL.title = ''
PANEL.slot_size_w = size
PANEL.slot_size_h = size
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
	self.scroll:GetCanvas():Receiver('ix.item', function(receiver, dropped, is_dropped, menu_index, mouse_x, mouse_y)
		dropped = dropped[1]

		if dropped:IsVisible() then
			self:StartDragging(dropped)
		end

		if is_dropped then
			if dropped.OnLootDrop then
				dropped:OnLootDrop(self)
			else
				self:OnDrop(dropped)
			end
		else
			local slot_w, slot_h = dropped:GetItemSize()
			local drop_slot = ix.inventory_drop_slot
			local is_multislot = self:IsMultislot()
			local slot_size_w, slot_size_h = self:GetSlotSize()
			local w, h = 0, 0

			if is_multislot and (slot_w > 1 or slot_h > 1) then
				w, h = (slot_w - 1) * 0.5 * slot_size_w, (slot_h - 1) * 0.5 * slot_size_h
			end

			local slot = GetClosestVisibleSlot(receiver, mouse_x - w, mouse_y - h)

			if !slot then return end
			
			slot.is_hovered = true

			if IsValid(drop_slot) then
				if slot != drop_slot then
					drop_slot.is_hovered = false
				else
					return
				end
			end

			local slot_x, slot_y = slot:GetItemPos()

			if is_multislot then
				local inv = self:GetInventory()

				if !inv:IsRectInRegion(slot_x, slot_y, slot_w, slot_h) then
					slot.out_of_bounds = true
				else
					slot.out_of_bounds = false
				end
			end

			ix.inventory_drop_slot = slot
		end
	end)

	self.horizontal_scroll:AddPanel(self.scroll)

	local parent = self:GetParent()

	if IsValid(parent) and !parent.container then
		parent:Receiver('ix.item', function(receiver, dropped, is_dropped, menu_index, mouse_x, mouse_y)
			local dropped = dropped[1]

			if is_dropped then
				self:Rebuild()
			else
				local drop_slot = ix.inventory_drop_slot

				if IsValid(drop_slot) then
					drop_slot.is_hovered = false
					ix.inventory_drop_slot = nil
				end
			end
		end)
	end
end

function PANEL:OnKeyCodePressed(key)
	local droppable = dragndrop.GetDroppable('ix.item')

	if droppable then
		droppable = droppable[1]

		if key == KEY_R and IsValid(droppable) then
			droppable:Turn()

			local drop_slot = ix.inventory_drop_slot

			if IsValid(drop_slot) then
				drop_slot.is_hovered = false
				ix.inventory_drop_slot = nil
			end
		end
	end
end

function PANEL:GetContentSize()
	if self._contentWidth and self._contentHeight then
		return self._contentWidth, self._contentHeight
	end

	local slot_size_w, slot_size_h = self:GetSlotSize()
	local slot_padding = self:GetSlotPadding()

	return (slot_size_w + slot_padding) * self:GetInventoryWidth() - slot_padding,
		(slot_size_h + slot_padding) * self:GetInventoryHeight() - slot_padding
end

function PANEL:PerformLayout(w, h)
	local width, height = self:GetContentSize()

	if height > h then
		width = width + math.scale_x(16) + self:GetSlotPadding()
	end

	self.scroll:SetWide(width)
	self.horizontal_scroll:SetSize(math.min(w, width), math.min(h, height))
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
function PANEL:PaintOver(w, h)
	if self.title and self.title != '' then
		DisableClipping(true)
			surface.SetFont('inventory.title')
			local textW, textH = surface.GetTextSize(self.title)

			surface.SetDrawColor(clrTitle)
			surface.DrawRect(0, 0, w, -textH - 2)

			surface.SetTextColor(0, 210* 0.8, 255 * 0.8, 255)
			surface.SetTextPos(2, -textH - 1)
			surface.DrawText(self.title)
		DisableClipping(false)
	end
end

function PANEL:SizeToContents()
	self:SetSize(self:GetContentSize())
end

function PANEL:StartDragging(dropped)
	if dropped.isLoot then
		return
	end

	if dropped.pendingTransfer then
		return
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

	for i = y, y + h - 1 do
		for k = x, x + w - 1 do
			if i == y and k == x then
				local px, py = panel:GetCellPixelPos(k, i)
				local slot = vgui.Create('ui.inv.item', panel.scroll:GetCanvas())
				slot:SetSize(slot_size_w, slot_size_h)
				slot:SetPos(px, py)
				slot.slot_x = k
				slot.slot_y = i
				slot.slot_size = {slot_size_w, slot_size_h}
				slot.slot_padding = slot_padding
				slot.inventory_id = panel:GetInventoryID()
				slot.multislot = panel:IsMultislot()
				slot.scroll = panel

				local icon = panel:GetIcon()

				if icon then
					slot.icon = icon
				end

				if panel:IsDisabled() then
					slot.disabled = true
				end

				if panel.draw_inventory_slots == true then
					slot.slot_number = k + (i - 1) * panel:GetInventoryWidth()
				end
			elseif panel:IsMultislot() then
				if k > panel:GetInventoryWidth() or i > panel:GetInventoryHeight() then
					continue
				end

				local row = panel.slot_panels[i]
				local slot = row and row[k]

				if IsValid(slot) then
					slot:Reset()
					slot:SetVisible(true)
				end
			end
		end
	end
end

function PANEL:OnDrop(dropped)
	RememberCursorPosition()

	local drop_slot = ix.inventory_drop_slot

	if !dropped then
		self:Rebuild()
		return
	else
		dropped.procceed = true
	end

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

	if item.stackable_legacy and item:GetValue() > 1 then
		if input.IsKeyDown(KEY_LCONTROL) then
			split = true
		elseif input.IsKeyDown(KEY_LSHIFT) then
			split = true
			split_count = 1
		end
	end

	if drop_slot.item_data then
		if ix.Item:OpenItemMenuCombine(item, drop_slot.item_data, split, split_count) then
			local panel = ix.Inventory:Get(item.inventory_id).panel

			if IsValid(panel) then
				panel:Rebuild()
			end
			
			return
		end
	else
		if split and item.stackable_legacy then
			local panel = ix.Inventory:Get(item.inventory_id).panel

			if IsValid(panel) then
				panel:Rebuild()
			end

			net.Start('item.legacy.stack.create')
				net.WriteUInt(item.inventory_id, 32)
				net.WriteUInt(self:GetInventoryID(), 32)
				net.WriteUInt(item.x, 8)
				net.WriteUInt(item.y, 8)
				net.WriteUInt(drop_slot.slot_x, 8)
				net.WriteUInt(drop_slot.slot_y, 8)
				net.WriteBool(split)
				net.WriteUInt(split_count, 32)
				net.WriteBool(dropped:WasRotated())
			net.SendToServer()
			return
		end
	end

	local oldInventoryID = item.inventory_id
	local targetInventoryID = self:GetInventoryID()
	local oldX, oldY = item.x, item.y
	local target_x, target_y, was_rotated = drop_slot.slot_x, drop_slot.slot_y, dropped:WasRotated()

	local old_inventory = ix.Inventory:Get(oldInventoryID)
	local inventory = ix.Inventory:Get(targetInventoryID)

	local slot = old_inventory:GetSlot(item.x, item.y)
	local items = table.Copy(slot)

	if split then
		items = {}

		for i = 1, (split_count != 0 and split_count or (#slot * 0.5)) do
			table.insert(items, slot[i])
		end
	end

	local did_optimistic = false

	if ix.gui.can_drop then
		did_optimistic = true

		if oldInventoryID == targetInventoryID then
			old_inventory:MoveStack(items, target_x, target_y, was_rotated)
		end

		ix.gui.can_drop = false
	end

	if !did_optimistic and oldInventoryID == targetInventoryID then
		if IsValid(old_inventory.panel) then
			old_inventory.panel:Rebuild()
		end

		return
	end
	
	net.Start('inventory.move')
		net.WriteUInt(oldInventoryID, 32)
		net.WriteUInt(targetInventoryID, 32)
		net.WriteUInt(oldX, 8)
		net.WriteUInt(oldY, 8)
		net.WriteBool(split)
		net.WriteUInt(split_count, 16)
		net.WriteUInt(target_x, 8)
		net.WriteUInt(target_y, 8)
		net.WriteBool(was_rotated)
	net.SendToServer()

	if IsValid(old_inventory.panel) then
		old_inventory.panel:Rebuild()
	end

	if oldInventoryID != targetInventoryID and IsValid(inventory.panel) then
		inventory.panel:Rebuild()
	end
end

function PANEL:SetInventoryID(inventory_id)
	self.inventory_id = inventory_id

	self:Rebuild()
end

function PANEL:ShouldBeRebuild()
    local width, height = self:GetInventorySize()
    
    local meta_items = {}
    local meta_occupied = {}
    
    for i = 1, height do
        for k = 1, width do
            local slot_items = self:GetSlot(k, i) or {}
            
            for _, item_id in ipairs(slot_items) do
                local instance = ix.Item.instances[item_id]
                if instance and not meta_items[item_id] then
                    if instance.x == k and instance.y == i then
                        meta_items[item_id] = {
                            x = k, 
                            y = i,
                            width = instance.width or 1,
                            height = instance.height or 1
                        }
                        
                        for y = i, i + (instance.height or 1) - 1 do
                            for x = k, k + (instance.width or 1) - 1 do
                                meta_occupied[x .. "_" .. y] = item_id
                            end
                        end
                    end
                end
            end
        end
    end
    
    local slot_items = {}
    local slot_occupied = {}
    
    for i = 1, height do
        for k = 1, width do
            local slot = self.slot_panels[i] and self.slot_panels[i][k]
            
            if IsValid(slot) and slot.instance_ids and #slot.instance_ids > 0 then
                local item_id = slot.instance_ids[1]
                local instance = ix.Item.instances[item_id]
                
                if instance and not slot_items[item_id] then
                    if instance.x == k and instance.y == i then
                        slot_items[item_id] = {
                            x = k, 
                            y = i,
                            width = instance.width or 1,
                            height = instance.height or 1
                        }
                        
                        for y = i, i + (instance.height or 1) - 1 do
                            for x = k, k + (instance.width or 1) - 1 do
                                slot_occupied[x .. "_" .. y] = item_id
                            end
                        end
                    end
                end
            end
        end
    end
    
    local meta_count = 0
    for _ in pairs(meta_items) do meta_count = meta_count + 1 end
    
    local slot_count = 0
    for _ in pairs(slot_items) do slot_count = slot_count + 1 end
    
    if meta_count != slot_count then
        return true
    end
    
    for item_id, meta_data in pairs(meta_items) do
        local slot_data = slot_items[item_id]
        
        if not slot_data then
            return true
        end
        
        if meta_data.x != slot_data.x or 
           meta_data.y != slot_data.y or
           meta_data.width != slot_data.width or
           meta_data.height != slot_data.height then
            return true
        end
    end
    
    for item_id, slot_data in pairs(slot_items) do
        local meta_data = meta_items[item_id]
        
        if not meta_data then
            return true
        end
    end
    
    for i = 1, height do
        for k = 1, width do
            local key = k .. "_" .. i
            local meta_item = meta_occupied[key]
            local slot_item = slot_occupied[key]
            
            if (meta_item and not slot_item) or (not meta_item and slot_item) then
                return true
            end
            if meta_item and slot_item and meta_item != slot_item then
                return true
            end
        end
    end
    return false
end

function PANEL:ComputeRegionLayout()
	local inventory = self:GetInventory()
	local regions = inventory:GetRegions()

	self._regionRects = nil
	self._regionOffsets = nil
	self._contentWidth = nil
	self._contentHeight = nil

	if !regions then return end

	local slot_size_w, slot_size_h = self:GetSlotSize()
	local slot_padding = self:GetSlotPadding()
	local gap = REGION_GAP

	local offsets = {}

	for idx, r in ipairs(regions) do
		local gx, gy = 0, 0

		for idx2, r2 in ipairs(regions) do
			if idx2 >= idx then break end

			if r2.x + r2.w == r.x then
				local y_overlap = math.max(r.y, r2.y) <= math.min(r.y + r.h - 1, r2.y + r2.h - 1)

				if y_overlap then
					gx = math.max(gx, offsets[idx2].x + gap)
				end
			end

			if r2.y + r2.h == r.y then
				local x_overlap = math.max(r.x, r2.x) <= math.min(r.x + r.w - 1, r2.x + r2.w - 1)

				if x_overlap then
					gy = math.max(gy, offsets[idx2].y + gap)
				end
			end
		end

		offsets[idx] = {x = gx, y = gy}
	end

	self._regionOffsets = offsets

	local regionRects = {}
	local max_w, max_h = 0, 0

	for idx, r in ipairs(regions) do
		local off = offsets[idx]
		local px = (r.x - 1) * (slot_size_w + slot_padding) + off.x
		local py = (r.y - 1) * (slot_size_h + slot_padding) + off.y
		local pw = r.w * (slot_size_w + slot_padding) - slot_padding
		local ph = r.h * (slot_size_h + slot_padding) - slot_padding

		regionRects[idx] = {x = px, y = py, w = pw, h = ph}
		max_w = math.max(max_w, px + pw)
		max_h = math.max(max_h, py + ph)
	end

	self._regionRects = regionRects
	self._contentWidth = max_w
	self._contentHeight = max_h
end

function PANEL:GetCellPixelPos(x, y)
	local slot_size_w, slot_size_h = self:GetSlotSize()
	local slot_padding = self:GetSlotPadding()
	local base_x = (x - 1) * (slot_size_w + slot_padding)
	local base_y = (y - 1) * (slot_size_h + slot_padding)

	local inventory = self:GetInventory()

	if !inventory._regionMap or !self._regionOffsets then
		return base_x, base_y
	end

	local regionIdx = inventory._regionMap[y] and inventory._regionMap[y][x]

	if regionIdx and self._regionOffsets[regionIdx] then
		local off = self._regionOffsets[regionIdx]
		return base_x + off.x, base_y + off.y
	end

	return base_x, base_y
end

function PANEL:Rebuild()
	dragndrop.Clear()
	self.scroll:Clear()

	local slot_size_w, slot_size_h = self:GetSlotSize()
	local slot_padding = self:GetSlotPadding()
	local width, height = self:GetInventorySize()
	local inventory = self:GetInventory()
	local regions = inventory:GetRegions()

	self.slot_panels = {}
	self.slot_parents = {}

	self:ComputeRegionLayout()

	local regionRects = self._regionRects
	self.scroll:GetCanvas().Paint = function(pnl, cw, ch)
		if regionRects then
			surface.SetDrawColor(0, 73, 88, 100)

			for _, rect in ipairs(regionRects) do
				surface.DrawOutlinedRect(rect.x, rect.y, rect.w, rect.h)
			end
		end
	end

	local function CreateSlotAt(k, i)
		self.slot_panels[i] = self.slot_panels[i] or {}

		local px, py = self:GetCellPixelPos(k, i)
		local slot = vgui.Create('ui.inv.item', self.scroll)
		slot:SetSize(slot_size_w, slot_size_h)
		slot:SetPos(px, py)
		slot.slot_x = k
		slot.slot_y = i
		slot.slot_size = {slot_size_w, slot_size_h}
		slot.slot_padding = slot_padding
		slot.inventory_id = self:GetInventoryID()
		slot.multislot = self:IsMultislot()
		slot.scroll = self

		if self.draw_inventory_slots == true then
			slot.slot_number = k + (i - 1) * width
		end

		local icon = self:GetIcon()

		if icon then
			slot.icon = icon
		end

		if self:IsDisabled() then
			slot.disabled = true
		end

		return slot
	end

	local function PopulateSlot(slot, k, i)
		if istable(self.slot_panels[i][k]) then
			local data = self.slot_panels[i][k]
			slot:SetVisible(false)
			slot.parent = function(this)
				if !IsValid(this.parentX) then
					this.parentX = self.slot_panels[data[1]][data[2]]
				end

				return this.parentX
			end
		else
			local instance_ids = self:GetSlot(k, i)

			if instance_ids and #instance_ids > 0 then
				if #instance_ids == 1 then
					slot:SetItem(instance_ids[1])
				else
					slot:SetItemMulti(instance_ids)
				end
			end

			if self:IsMultislot() and slot:IsVisible() then
				local w, h = slot:GetItemSize()

				if w > 1 or h > 1 then
					for m = 1, h do
						for n = 1, w do
							local slot_pos_y, slot_pos_x = (i + m - 1), (k + n - 1)

							if slot_pos_y > height or slot_pos_x > width then
								continue
							end

							self.slot_panels[slot_pos_y] = self.slot_panels[slot_pos_y] or {}
							self.slot_panels[slot_pos_y][slot_pos_x] = {i, k}
						end
					end

					slot:SetSize((slot_size_w + slot_padding) * w - slot_padding, (slot_size_h + slot_padding) * h - slot_padding)
					slot:Rebuild()
				end
			end
		end
	end

	if regions then
		for _, r in ipairs(regions) do
			for iy = r.y, r.y + r.h - 1 do
				for ix = r.x, r.x + r.w - 1 do
					local slot = CreateSlotAt(ix, iy)

					PopulateSlot(slot, ix, iy)

					self.slot_panels[iy][ix] = slot
					self.scroll:AddItem(slot)
				end
			end
		end
	else
		for i = 1, height do
			self.slot_panels[i] = self.slot_panels[i] or {}

			for k = 1, width do
				local slot = CreateSlotAt(k, i)

				PopulateSlot(slot, k, i)

				self.slot_panels[i][k] = slot
				self.scroll:AddItem(slot)
			end
		end
	end

	if ix.inventory and ix.inventory.RestoreAllPendingFlags then
		ix.inventory.RestoreAllPendingFlags()
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

vgui.Register('ui.inv', PANEL, 'Panel')


PANEL = {}
DEFINE_BASECLASS("DFrame")

function PANEL:Init()
	self:ShowCloseButton(true)
	self:SetDraggable(true)
	self:SetSizable(true)
	self:SetTitle(L"inv")

	self.btnMinim:SetVisible(false)
	self.btnMinim:SetMouseInputEnabled(false)
	self.btnMaxim:SetVisible(false)
	self.btnMaxim:SetMouseInputEnabled(false)

	self.panel = self:Add('ui.inv')
	self.panel:Dock(TOP)
end

function PANEL:SetInventory(inventory)
	self.panel:SetInventoryID(inventory.id)

	inventory.panel = self.panel
end

function PANEL:Rebuild()
	self.panel:Rebuild()
	self.panel:SizeToContents()
end

function PANEL:PerformLayout(width, height)
	BaseClass.PerformLayout(self, width, height)

	self.panel:SizeToContents()
end


vgui.Register('ui.inv.wrapper', PANEL, 'DFrame')
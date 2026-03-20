local Inventory = class 'Inventory'

-- Initializes the new inventory class
-- and loads it to the server cache.
-- ```
-- -- Creating new inventory
-- local inventory = Inventory.new()
-- inventory.title = 'Test inventory'
-- inventory:set_size(4, 4)
-- inventory.type = 'testing_inventory'
-- inventory.multislot = false
-- ```
-- @param id [Number]
function Inventory:Init(id)
	self.title = 'Undefined'
	self.type = 'default'
	self.width = 1
	self.height = 1
	self.slots = {}
	self.multislot = true
	self.disabled = false
	self.regions = nil
	self._regionMap = nil

	if SERVER then
		self.infinite_width = false
		self.infinite_height = false
		self.default = false
		self.receivers = {}

		id = table.insert(ix.Inventory.stored, self)
	else
		ix.Inventory.stored[id] = self
	end

	self.id = id
end

function Inventory:__tostring() return 'inventory[' .. (self.id or 0) .. ']' end

function Inventory:GetWidth() return self.width end
function Inventory:GetHeight() return self.height end
function Inventory:GetSize() return self.width, self.height end
function Inventory:GetType() return self.type end
function Inventory:GetSlots() return self.slots end
function Inventory:GetOwner() return self.owner end

function Inventory:IsMultislot() return self.multislot end
function Inventory:IsDisabled() return self.disabled end
function Inventory:IsWidthInfinite() return self.infinite_width end
function Inventory:IsHeightInfinite() return self.infinite_height end
function Inventory:IsDefault() return self.default end

function Inventory:GetRegions() return self.regions end

function Inventory:SetRegions(regions)
	self.regions = regions

	if regions then
		self._regionMap = {}

		local max_w, max_h = 0, 0

		for idx, r in ipairs(regions) do
			max_w = math.max(max_w, r.x + r.w - 1)
			max_h = math.max(max_h, r.y + r.h - 1)

			for iy = r.y, r.y + r.h - 1 do
				self._regionMap[iy] = self._regionMap[iy] or {}

				for ix = r.x, r.x + r.w - 1 do
					self._regionMap[iy][ix] = idx
				end
			end
		end

		self:SetSize(max_w, max_h)
	else
		self._regionMap = nil
	end
end

function Inventory:IsInRegion(x, y)
	if !self._regionMap then return true end

	return self._regionMap[y] and self._regionMap[y][x] and true or false
end

function Inventory:IsRectInRegion(x, y, w, h)
	if !self.regions then return true end

	for _, r in ipairs(self.regions) do
		if r.x <= x and x + w - 1 <= r.x + r.w - 1
		and r.y <= y and y + h - 1 <= r.y + r.h - 1 then
			return true
		end
	end

	return false
end

--- Sets the width of the inventory and rebuilds its slots.
function Inventory:SetWidth(width)
	self.width = width

	self:Rebuild()
end

--- Sets the height of the inventory and rebuilds its slots.
function Inventory:SetHeight(height)
	self.height = height

	self:Rebuild()
end

--- Sets the width and height of the inventory and rebuilds its slots.
function Inventory:SetSize(width, height)
	self.width = width
	self.height = height

	self:Rebuild()
end

function Inventory:Rebuild()
	for i = 1, self.height do
		self.slots[i] = self.slots[i] or {}

		for k = 1, self.width do
			self.slots[i][k] = self.slots[i][k] or {}
		end
	end
end

function Inventory:GetItems()
	local items = {}

	for k, v in ipairs(self:GetItemsID()) do
		local item = ix.Item.instances[v]

		if item then
			table.insert(items, item)

			local inventory = item.inventory

			if inventory then
				table.Add(items, inventory:GetItems())
			end
		end
	end

	return items
end

function Inventory:GetItemsID()
	local items = {}

	for i = 1, self.height do
		for k = 1, self.width do
			local stack = self.slots[i][k]

			if istable(stack) and !table.IsEmpty(stack) then
				for _, v in pairs(stack) do
					items[v] = true
				end
			end
		end
	end

	return table.GetKeys(items)
end

function Inventory:GetSlot(x, y)
	if x <= self.width and y <= self.height then
		return self.slots[y][x]
	end
end

function Inventory:GetFirstAtSlot(x, y)
	local slot = self:GetSlot(x, y)

	if istable(slot) and !table.IsEmpty(slot) then
		return slot[1]
	end
end

function Inventory:GetItemsCount(id)
	return table.Count(self:FindItems(id))
end

function Inventory:IsEmpty()
	return table.IsEmpty(self:GetItemsID())
end

function Inventory:FindItem(id)
	for k, v in ipairs(self:GetItems()) do
		if v.uniqueID == id then
			return v
		end
	end
end

function Inventory:FindItems(id)
	local items = {}

	for k, v in ipairs(self:GetItems()) do
		if v.uniqueID == id then
			table.insert(items, v)
		end
	end

	return items
end

function Inventory:HasItem(id)
	local item = self:FindItem(id)

	if item then
		return true, item
	end
end

function Inventory:HasItems(id, amount)
	amount = amount or 1

	local items = self:FindItems(id)

	if table.Count(items) >= amount then
		return true, items
	end

	return false, items
end

function Inventory:HasItemByID(instance_id)
	if table.HasValue(self:GetItemsID(), instance_id) then
		return true, ix.Item.instances[instance_id]
	end

	return false
end

function Inventory:FindPosition(item, w, h)
	local x, y, need_rotation

	if item.stackable then
		x, y, need_rotation = self:FindStack(item, w, h)

		if x and y then
			need_rotation = need_rotation != item.rotated
		end
	end

	if !x or !y then
		x, y = self:FindEmptySlot(w, h)

		if !x or !y then
			x, y = self:FindEmptySlot(h, w)

			need_rotation = true
		end
	end

	return x, y, need_rotation
end

function Inventory:FindStack(item, w, h)
	for k, v in pairs(self:FindItems(item.uniqueID)) do
		if self:CanStack(item, v) then
			return v.x, v.y, v.rotated
		end
	end
end

function Inventory:CanStack(item, stack_item)
	local slot = self:GetSlot(stack_item.x, stack_item.y)

	if stack_item and stack_item.uniqueID == item.uniqueID and item.stackable and #slot < item.max_stack then
		return true
	end

	return false
end

function Inventory:FindEmptySlot(w, h)
	if !self.regions then
		for i = 1, self:GetHeight() - h + 1 do
			for k = 1, self:GetWidth() - w + 1 do
				if self:IsSlotsEmpty(k, i, w, h) then
					return k, i
				end
			end
		end

		return
	end

	for _, r in ipairs(self.regions) do
		if r.w >= w and r.h >= h then
			for iy = r.y, r.y + r.h - h do
				for ix = r.x, r.x + r.w - w do
					if self:IsSlotsEmpty(ix, iy, w, h) then
						return ix, iy
					end
				end
			end
		end
	end
end

function Inventory:IsSlotsEmpty(x, y, w, h)
	for i = y, y + h - 1 do
		for k = x, x + w - 1 do
			if !table.IsEmpty(self.slots[i][k]) then
				return false
			end

			if self.reservedSlots and self.reservedSlots[i] and self.reservedSlots[i][k] then
				return false
			end
		end
	end

	return true
end

function Inventory:OverlapsStack(item, x, y, w, h)
	for i = y, y + h - 1 do
		for k = x, x + w - 1 do
			local slot = self:GetSlot(k, i)
			local stack_item = ix.Item.instances[slot[1]]

			if stack_item and self:CanStack(item, stack_item) and !table.HasValue(slot, item.id) then
				return true, stack_item.x, stack_item.y, stack_item.rotated != item.rotated
			end
		end
	end
end

function Inventory:OverlapsItself(instance_id, x, y, w, h)
	for i = y, y + h - 1 do
		for k = x, x + w - 1 do
			local slot = self.slots[i][k]

			if table.HasValue(slot, instance_id) then
				return true
			end
		end
	end

	return false
end

function Inventory:OverlapsOnlyItself(instance_id, x, y, w, h, rotation)
	local oldW, oldH = w, h

	if rotation then
		h = oldW
		w = oldH
	end
	
	for i = y, y + h - 1 do
		for k = x, x + w - 1 do
			local slot = self.slots[i][k]

			if !table.HasValue(slot, instance_id) and !table.IsEmpty(slot) then
				return false
			end
		end
	end

	return true
end

function Inventory:GetItemSize(item)
	if !self:IsMultislot() then
		return 1, 1
	end

	local item_w, item_h = item.width, item.height

	if item.rotated then
		return item_h, item_w
	else
		return item_w, item_h
	end
end

if SERVER then
	util.AddNetworkString('ixInvSync')
	util.AddNetworkString('inventory.move')
	util.AddNetworkString('inventory.move.ack')
	util.AddNetworkString('inventory.move.reject')
	util.AddNetworkString('inventory.move.delayed')
	util.AddNetworkString('inventory.move.delayed.complete')
	util.AddNetworkString('inventory.move.delayed.cancel')
	util.AddNetworkString('inventory.delta.moved')
	util.AddNetworkString('inventory.delta.added')
	util.AddNetworkString('inventory.delta.removed')
	util.AddNetworkString('inventory.delta.transferred')

	ix.inventory = ix.inventory or {}
	ix.inventory.pendingTransfers = {}
	ix.inventory.nextTransferId = 0

	local TRANSFER_DELAY = 2.5

	function ix.inventory.CancelTransfer(transferId)
		local pending = ix.inventory.pendingTransfers[transferId]

		if !pending then return end

		timer.Remove('ixPendingTransfer_' .. transferId)

		local targetInv = ix.Inventory:Get(pending.to_id)

		if targetInv then
			targetInv:UnreserveSlots(transferId)
		end

		for _, instanceId in ipairs(pending.items) do
			if ix.inventory.pendingTransfers['item_' .. instanceId] == transferId then
				ix.inventory.pendingTransfers['item_' .. instanceId] = nil
			end
		end

		if IsValid(pending.client) then
			net.Start('inventory.move.delayed.cancel')
				net.WriteUInt(transferId, 32)
			net.Send(pending.client)
		end

		ix.inventory.pendingTransfers[transferId] = nil
	end

	function ix.inventory.CancelPlayerTransfers(client)
		for transferId, pending in pairs(ix.inventory.pendingTransfers) do
			if isnumber(transferId) and istable(pending) and pending.client == client then
				ix.inventory.CancelTransfer(transferId)
			end
		end
	end

	function Inventory:ReserveSlots(x, y, w, h, transferId)
		self.reservedSlots = self.reservedSlots or {}

		for i = y, y + h - 1 do
			self.reservedSlots[i] = self.reservedSlots[i] or {}

			for k = x, x + w - 1 do
				self.reservedSlots[i][k] = transferId
			end
		end
	end

	function Inventory:UnreserveSlots(transferId)
		if !self.reservedSlots then return end

		for i, row in pairs(self.reservedSlots) do
			for k, tid in pairs(row) do
				if tid == transferId then
					row[k] = nil
				end
			end

			if table.IsEmpty(row) then
				self.reservedSlots[i] = nil
			end
		end

		if table.IsEmpty(self.reservedSlots) then
			self.reservedSlots = nil
		end
	end

	function Inventory:AreSlotsReserved(x, y, w, h, excludeTransferId)
		if !self.reservedSlots then return false end

		for i = y, y + h - 1 do
			if self.reservedSlots[i] then
				for k = x, x + w - 1 do
					local tid = self.reservedSlots[i][k]

					if tid and tid != excludeTransferId then
						return true
					end
				end
			end
		end

		return false
	end

	function Inventory:AddItem(item, x, y, raw, noLog)
		if !item then 
			return false, 'invalidItem'
		end

		local need_rotation = false
		local w, h = self:GetItemSize(item)

		if raw != true then
			if !x or !y or x < 1 or y < 1 or x + w - 1 > self:GetWidth() or y + h - 1 > self:GetHeight() then
				x, y, need_rotation = self:FindPosition(item, w, h)
			end
		end

		if x and y then
			if raw != true then
				local final_w, final_h = need_rotation and h or w, need_rotation and w or h

				if self.regions and !self:IsRectInRegion(x, y, final_w, final_h) then
					return false, 'noFit'
				end

				if !item.stackable and !self:OverlapsOnlyItself(item.id, x, y, w, h, need_rotation) then
					return false, 'noFit'
				end
			end
			
			item.inventory_id = self.id
			item.inventory_type = self.type
			item.x = x
			item.y = y
			item.mark_as_save = true

			if need_rotation then
				w, h = h, w

				item.rotated = !item.rotated
			end

			for i = y, y + h - 1 do
				for k = x, x + w - 1 do
					table.insert(self.slots[i][k], item.id)
				end
			end

			self:CheckSize()

			if !noLog then
				hook.Run('InventoryItemAdded', nil, self, item)
			end
		else
			return false, 'noFit'
		end

		return true
	end

	function Inventory:AddItemByID(instance_id, x, y)
		return self:AddItem(ix.Item.instances[instance_id], x, y)
	end

	function Inventory:GiveItem(id, amount, data)
		amount = amount or 1

		for i = 1, amount do
			local item = ix.Item:Instance(id, data)
			local success, error_text = self:AddItem(item)

			if !success then
				return success, error_text
			end
		end

		return true
	end

	function Inventory:TakeItemTable(item)
		if !item then 
			return false, 'invalidItem'
		end

		if item.inventory_id != self.id then
			return false, 'invalidItem'
		end

		local x, y = item.x, item.y
		local w, h = self:GetItemSize(item)

		item.inventory_id = nil
		item.inventory_type = nil
		item.x = nil
		item.y = nil
		item.rotated = false
		item.mark_as_save = true

		for i = y, y + h - 1 do
			for k = x, x + w - 1 do
				table.RemoveByValue(self.slots[i][k], item.id)
			end
		end

		self:CheckSize()

		hook.Run('InventoryItemRemoved', self, item)

		return true
	end

	function Inventory:TakeItem(uniqueID)
		local item = self:FindItem(uniqueID)

		if item then
			return self:TakeItemByID(item.id)
		end

		return false, 'invalidItem'
	end

	function Inventory:TakeItems(id, amount)
		if self:GetItemsCount(id) < amount then
			return false, 'notEnoughItems'
		end

		for i = 1, amount do
			self:TakeItem(id)
		end

		return true
	end

	function Inventory:TakeItemByID(instance_id)
		return self:TakeItemTable(ix.Item.instances[instance_id])
	end

	function Inventory:MoveItem(instance_id, x, y, was_rotated)
		local item = ix.Item.instances[instance_id]

		if !item then 
			return false, 'invalidItem' 
		end

		local success, error = hook.Run('CanMoveItem', item, self, x, y)

		if success == false then
			return false, error
		end

		local need_rotation = false
		local old_x, old_y = item.x, item.y
		local w, h = self:GetItemSize(item)
		local old_w, old_h = w, h

		if was_rotated then
			w, h = h, w
		end

		if !x or !y or x < 1 or y < 1 or x + w - 1 > self:GetWidth() or y + h - 1 > self:GetHeight() then
			x, y, need_rotation = self:FindPosition(item, w, h)

			if !x or !y then
				return false, 'noFit'
			end
		elseif !self:IsSlotsEmpty(x, y, w, h) then
			local overlap, new_x, new_y, new_rotation = self:OverlapsStack(item, x, y, w, h)

			if overlap then
				x, y = new_x, new_y

				if new_rotation != was_rotated then
					need_rotation = true
				end
			elseif !self:OverlapsOnlyItself(instance_id, x, y, w, h, need_rotation) then
				return false, 'noFit'
			end
		end

		if self.regions then
			local final_w, final_h = need_rotation and h or w, need_rotation and w or h

			if !self:IsRectInRegion(x, y, final_w, final_h) then
				return false, 'noFit'
			end
		end

		item.x = x
		item.y = y
		item.mark_as_save = true

		if need_rotation then
			w, h = h, w
		end

		if was_rotated != need_rotation then
			item.rotated = !item.rotated
		end

		for i = old_y, old_y + old_h - 1 do
			for k = old_x, old_x + old_w - 1 do
				table.RemoveByValue(self.slots[i][k], instance_id)
			end
		end

		for i = y, y + h - 1 do
			for k = x, x + w - 1 do
				table.insert(self.slots[i][k], instance_id)
			end
		end

		self:CheckSize()

		return true
	end

	function Inventory:Transfer(instance_id, inventory, x, y, was_rotated)
		local item = ix.Item.instances[instance_id]

		if !item then 
			return false, 'invalidItem'
		end

		local success, error = hook.Run('CanTransferItem', item, inventory, x, y, self)

		if success == false then
			return false, error
		end

		if item.CanTransfer then
			local canTransfer, transferReason = item:CanTransfer(self, inventory, x, y)

			if canTransfer == false then
				return false, transferReason or 'notAllowed'
			end
		end

		local need_rotation = false
		local old_x, old_y = item.x, item.y
		local w, h = inventory:GetItemSize(item)
		local old_w, old_h = self:GetItemSize(item)

		if was_rotated then
			w, h = h, w
		end

		if !x or !y or x < 1 or y < 1 or x + w - 1 > inventory:GetWidth() or y + h - 1 > inventory:GetHeight() then
			x, y, need_rotation = inventory:FindPosition(item, w, h)

			if !x or !y then
				return false, 'noFit'
			end
		elseif !inventory:IsSlotsEmpty(x, y, w, h) then
			local overlap, new_x, new_y, new_rotation = inventory:OverlapsStack(item, x, y, w, h)

			if overlap then
				x, y = new_x, new_y

				if new_rotation != was_rotated then
					need_rotation = true
				end
			else
				return false, 'noFit'
			end
		end

		if inventory.regions then
			local final_w, final_h = need_rotation and h or w, need_rotation and w or h

			if !inventory:IsRectInRegion(x, y, final_w, final_h) then
				return false, 'noFit'
			end
		end

		item.inventory_id = inventory.id
		item.inventory_type = inventory.type
		item.x = x
		item.y = y
		item.mark_as_save = true

		if need_rotation then
			w, h = h, w
		end

		if was_rotated != need_rotation then
			item.rotated = !item.rotated
		end

		for i = old_y, old_y + old_h - 1 do
			for k = old_x, old_x + old_w - 1 do
				table.RemoveByValue(self.slots[i][k], instance_id)
			end
		end

		hook.Run('InventoryItemRemoved', self, item, inventory)

		for i = y, y + h - 1 do
			for k = x, x + w - 1 do
				table.insert(inventory.slots[i][k], instance_id)
			end
		end

		hook.Run('InventoryItemAdded', self, inventory, item)

		self:CheckSize()
		inventory:CheckSize()

		return true
	end

	function Inventory:MoveStack(instance_ids, x, y, was_rotated)
		local instance_id = instance_ids[1]
		local item = ix.Item.instances[instance_id]
		local old_x, old_y = item.x, item.y
		local slot = self:GetSlot(old_x, old_y)
		local w, h = self:GetItemSize(item)

		if !table.equal(instance_ids, slot) and self:OverlapsItself(instance_id, x, y, w, h) then
			return true
		end

		for k, v in ipairs(instance_ids) do
			local success, error = self:MoveItem(v, x, y, was_rotated)

			if !success then
				return success, error
			end
		end

		return true
	end

	function Inventory:TransferStack(instance_ids, inventory, x, y, was_rotated)
		for k, v in ipairs(instance_ids) do
			local success, error_text = self:Transfer(v, inventory, x, y, was_rotated)

			if !success then
				return success, error_text
			end
		end

		return true
	end

	function Inventory:GetReceivers()
		return table.GetKeys(self.receivers)
	end

	function Inventory:AddReceiver(client)
		self.receivers[client] = true
	end

	function Inventory:RemoveReceiver(client)
		self.receivers[client] = nil
	end

	function Inventory:OnCheckAccess(client)
		local bAccess = false

		for _, v in pairs(self:GetReceivers()) do
			if v == client then
				bAccess = true
				break
			end
		end

		return bAccess
	end

	function Inventory:WriteNetData()
		net.WriteUInt(self.id, 32)
		net.WriteString(self.type)
		net.WriteUInt(self.width, 6)
		net.WriteUInt(self.height, 6)
		net.WriteUInt(IsValid(self.owner) and self.owner:EntIndex() or 0, 8)
		net.WriteBool(self.multislot)
		net.WriteBool(self.disabled)

		local hasRegions = self.regions != nil
		net.WriteBool(hasRegions)

		if hasRegions then
			net.WriteUInt(#self.regions, 4)

			for _, r in ipairs(self.regions) do
				net.WriteUInt(r.x, 6)
				net.WriteUInt(r.y, 6)
				net.WriteUInt(r.w, 6)
				net.WriteUInt(r.h, 6)
			end
		end

		net.WriteUInt(self.instance_id and self.instance_id or 0, 32)

		local ids = self:GetItemsID()
		net.WriteUInt(#ids, 16)

		for _, id in ipairs(ids) do
			net.WriteUInt(id, 32)
		end
	end

	function Inventory:Sync()
		for k, v in ipairs(self:GetReceivers()) do
			if !IsValid(v) then 
				self:RemoveReceiver(v)
				continue 
			end
			
			self:SyncItemsBatch(v)
			
			net.Start('ixInvSync')
				self:WriteNetData()
			net.Send(v)
		end
	end

	function Inventory:SyncExcept(except)
		for k, v in ipairs(self:GetReceivers()) do
			if !IsValid(v) then 
				self:RemoveReceiver(v)
				continue 
			end

			if v == except then continue end
			
			self:SyncItemsBatch(v)
			
			net.Start('ixInvSync')
				self:WriteNetData()
			net.Send(v)
		end
	end

	function Inventory:SyncTo(client)
		if !IsValid(client) then return end

		self:SyncItemsBatch(client)

		net.Start('ixInvSync')
			self:WriteNetData()
		net.Send(client)
	end

	function Inventory:CheckSize()
		if self.instance_id then
			local item = ix.Item.instances[self.instance_id]

			if item then
				item.mark_as_save = true
			end
		end

		if !self:IsHeightInfinite() and !self:IsWidthInfinite() then return end

		local max_x, max_y = 0, 0

		for i = 1, self:GetHeight() do
			for k = 1, self:GetWidth() do
				if !table.IsEmpty(self:GetSlot(k, i)) then
					max_x, max_y = k, i
				end
			end
		end

		if self:IsHeightInfinite() then
			self.height = max_y + 1
		end

		if self:IsWidthInfinite() then
			self.width = max_x + 1
		end

		self:Rebuild()
		self:Sync()
	end

	function Inventory:SetDisabled(disabled)
		self.disabled = disabled

		self:Sync()
	end

	function Inventory:SendDeltaMove(instance_id, old_x, old_y, new_x, new_y, rotated, except)
		local item = ix.Item.instances[instance_id]

		if !item then return end

		local w, h = self:GetItemSize(item)

		for k, v in ipairs(self:GetReceivers()) do
			if !IsValid(v) or v == except then continue end

			item:Sync(v)

			net.Start('inventory.delta.moved')
				net.WriteUInt(self.id, 32)
				net.WriteUInt(instance_id, 32)
				net.WriteUInt(old_x, 8)
				net.WriteUInt(old_y, 8)
				net.WriteUInt(new_x, 8)
				net.WriteUInt(new_y, 8)
				net.WriteUInt(w, 8)
				net.WriteUInt(h, 8)
				net.WriteBool(rotated or false)
			net.Send(v)
		end
	end

	function Inventory:SendDeltaAdd(instance_id, x, y, except)
		local item = ix.Item.instances[instance_id]

		if !item then return end

		local w, h = self:GetItemSize(item)

		for k, v in ipairs(self:GetReceivers()) do
			if !IsValid(v) or v == except then continue end

			item:Sync(v)

			net.Start('inventory.delta.added')
				net.WriteUInt(self.id, 32)
				net.WriteUInt(instance_id, 32)
				net.WriteUInt(x, 8)
				net.WriteUInt(y, 8)
				net.WriteUInt(w, 8)
				net.WriteUInt(h, 8)
			net.Send(v)
		end
	end

	function Inventory:SendDeltaRemove(instance_id, old_x, old_y, except)
		local item = ix.Item.instances[instance_id]
		local w, h = 1, 1

		if item then
			w, h = self:GetItemSize(item)
		end

		for k, v in ipairs(self:GetReceivers()) do
			if !IsValid(v) or v == except then continue end

			net.Start('inventory.delta.removed')
				net.WriteUInt(self.id, 32)
				net.WriteUInt(instance_id, 32)
				net.WriteUInt(old_x, 8)
				net.WriteUInt(old_y, 8)
				net.WriteUInt(w, 8)
				net.WriteUInt(h, 8)
			net.Send(v)
		end
	end

	function Inventory:SendDeltaTransfer(instance_id, from_inv, old_x, old_y, new_x, new_y, except)
		local item = ix.Item.instances[instance_id]

		if !item then return end

		local old_w, old_h = from_inv:GetItemSize(item)
		local new_w, new_h = self:GetItemSize(item)

		local targets = {}
		local seen = {}

		for k, v in ipairs(from_inv:GetReceivers()) do
			if IsValid(v) and v != except and !seen[v] then
				seen[v] = true
				table.insert(targets, v)
			end
		end

		for k, v in ipairs(self:GetReceivers()) do
			if IsValid(v) and v != except and !seen[v] then
				seen[v] = true
				table.insert(targets, v)
			end
		end

		for _, v in ipairs(targets) do
			item:Sync(v)

			net.Start('inventory.delta.transferred')
				net.WriteUInt(from_inv.id, 32)
				net.WriteUInt(self.id, 32)
				net.WriteUInt(instance_id, 32)
				net.WriteUInt(old_x, 8)
				net.WriteUInt(old_y, 8)
				net.WriteUInt(old_w, 8)
				net.WriteUInt(old_h, 8)
				net.WriteUInt(new_x, 8)
				net.WriteUInt(new_y, 8)
				net.WriteUInt(new_w, 8)
				net.WriteUInt(new_h, 8)
			net.Send(v)
		end
	end

	local BATCH_MAX_SIZE = 60000

	function Inventory:SyncItemsBatch(client)
		local itemsData = {}
		local directItems = self:GetItemsID()

		for _, itemID in ipairs(directItems) do
			local item = ix.Item.instances[itemID]

			if !item then continue end

			local syncData = item:CollectSyncData(client)
			table.insert(itemsData, syncData)
		end

		if #itemsData == 0 then return end

		local function SendBatch(batch)
			local encoded = pon.encode(batch)
			local compressed = util.Compress(encoded)

			if #compressed > BATCH_MAX_SIZE and #batch > 1 then
				local mid = math.floor(#batch / 2)
				local first, second = {}, {}

				for i = 1, mid do first[i] = batch[i] end
				for i = mid + 1, #batch do table.insert(second, batch[i]) end

				SendBatch(first)
				SendBatch(second)

				return
			end

			local length = #compressed

			net.Start('item.sync.batch')
				net.WriteUInt(length, 32)
				net.WriteData(compressed, length)
			net.Send(client)
		end

		SendBatch(itemsData)

		for _, itemID in ipairs(directItems) do
			local item = ix.Item.instances[itemID]

			if item and item.OnSync then
				item:OnSync(client)
			end
		end
	end

	function ix.inventory.ValidateCrossTransfer(old_inventory, inventory, instance_id, target_x, target_y, was_rotated)
		local item = ix.Item.instances[instance_id]

		if !item then
			return false, 'invalidItem'
		end

		local success, err = hook.Run('CanTransferItem', item, inventory, target_x, target_y, old_inventory)

		if success == false then
			return false, err
		end

		if item.CanTransfer then
			local canTransfer, transferReason = item:CanTransfer(old_inventory, inventory, target_x, target_y)

			if canTransfer == false then
				return false, transferReason or 'notAllowed'
			end
		end

		local need_rotation = false
		local w, h = inventory:GetItemSize(item)

		if was_rotated then
			w, h = h, w
		end

		local x, y = target_x, target_y

		if !x or !y or x < 1 or y < 1 or x + w - 1 > inventory:GetWidth() or y + h - 1 > inventory:GetHeight() then
			x, y, need_rotation = inventory:FindPosition(item, w, h)

			if !x or !y then
				return false, 'noFit'
			end
		elseif !inventory:IsSlotsEmpty(x, y, w, h) then
			local overlap, new_x, new_y, new_rotation = inventory:OverlapsStack(item, x, y, w, h)

			if overlap then
				x, y = new_x, new_y

				if new_rotation != was_rotated then
					need_rotation = true
				end
			else
				return false, 'noFit'
			end
		end

		if inventory.regions then
			local final_w, final_h = need_rotation and h or w, need_rotation and w or h

			if !inventory:IsRectInRegion(x, y, final_w, final_h) then
				return false, 'noFit'
			end
		end

		local final_w = need_rotation and h or w
		local final_h = need_rotation and w or h

		return true, nil, x, y, final_w, final_h, need_rotation
	end

	net.Receive('inventory.move', function(_, client)
		local from_id = net.ReadUInt(32)
		local to_id = net.ReadUInt(32)
		local x = net.ReadUInt(8)
		local y = net.ReadUInt(8)
		local split = net.ReadBool()
		local split_count = net.ReadUInt(16)
		local target_x = net.ReadUInt(8)
		local target_y = net.ReadUInt(8)
		local was_rotated = net.ReadBool()
		local old_inventory = ix.Inventory:Get(from_id)
		local inventory = ix.Inventory:Get(to_id)

		if !old_inventory or !inventory then
			net.Start('inventory.move.reject')
				net.WriteString('invalidInventory')
			net.Send(client)

			if old_inventory then old_inventory:SyncTo(client) end
			if inventory then inventory:SyncTo(client) end

			return
		end

		if !inventory:OnCheckAccess(client) or !old_inventory:OnCheckAccess(client) then
			net.Start('inventory.move.reject')
				net.WriteString('noAccess')
			net.Send(client)

			old_inventory:SyncTo(client)

			if to_id != from_id then
				inventory:SyncTo(client)
			end

			return
		end
		
		local slot = old_inventory:GetSlot(x, y)

		if !istable(slot) or table.IsEmpty(slot) then
			net.Start('inventory.move.reject')
				net.WriteString('')
			net.Send(client)

			old_inventory:SyncTo(client)

			if to_id != from_id then
				inventory:SyncTo(client)
			end

			return
		end
		
		local item = ix.Item.instances[slot[1]]

		--if hook.run('PlayerCanMoveItem', player, item_obj, instance_ids, inventory_id, x, y) == false then
		--	return
		--end

		local items = table.Copy(slot)

		if split then
			items = {}

			for i = 1, (split_count != 0 and split_count or (#slot * 0.5)) do
				table.insert(items, slot[i])
			end
		end

		for _, instanceId in ipairs(items) do
			if ix.inventory.pendingTransfers['item_' .. instanceId] then
				net.Start('inventory.move.reject')
					net.WriteString('itemLocked')
				net.Send(client)

				old_inventory:SyncTo(client)

				if to_id != from_id then
					inventory:SyncTo(client)
				end

				return
			end
		end

		if to_id == from_id then
			local move_item = ix.Item.instances[items[1]]
			local old_move_x, old_move_y = move_item and move_item.x, move_item and move_item.y

			local success, error = inventory:MoveStack(items, target_x, target_y, was_rotated)

			if success == false or error then
				net.Start('inventory.move.reject')
					net.WriteString(error or '')
				net.Send(client)

				inventory:SyncTo(client)
			else
				net.Start('inventory.move.ack')
				net.Send(client)

				if move_item then
					inventory:SendDeltaMove(items[1], old_move_x, old_move_y, move_item.x, move_item.y, move_item.rotated, client)
				end
			end
		else
			local success, err, final_x, final_y, final_w, final_h, need_rotation =
				ix.inventory.ValidateCrossTransfer(old_inventory, inventory, items[1], target_x, target_y, was_rotated)

			if !success then
				net.Start('inventory.move.reject')
					net.WriteString(err or '')
				net.Send(client)

				inventory:SyncTo(client)
				old_inventory:SyncTo(client)

				return
			end

			ix.inventory.nextTransferId = ix.inventory.nextTransferId + 1
			local transferId = ix.inventory.nextTransferId

			inventory:ReserveSlots(final_x, final_y, final_w, final_h, transferId)

			for _, instanceId in ipairs(items) do
				ix.inventory.pendingTransfers['item_' .. instanceId] = transferId
			end

			local source_item = ix.Item.instances[items[1]]
			local source_w, source_h = old_inventory:GetItemSize(source_item)

			if source_item.rotated then
				source_w, source_h = source_h, source_w
			end

			ix.inventory.pendingTransfers[transferId] = {
				client = client,
				from_id = from_id,
				to_id = to_id,
				items = items,
				source_x = x,
				source_y = y,
				target_x = final_x,
				target_y = final_y,
				was_rotated = was_rotated,
				need_rotation = need_rotation,
				final_w = final_w,
				final_h = final_h,
			}

			net.Start('inventory.move.delayed')
				net.WriteUInt(transferId, 32)
				net.WriteUInt(from_id, 32)
				net.WriteUInt(x, 8)
				net.WriteUInt(y, 8)
				net.WriteUInt(source_w, 8)
				net.WriteUInt(source_h, 8)
				net.WriteUInt(to_id, 32)
				net.WriteUInt(final_x, 8)
				net.WriteUInt(final_y, 8)
				net.WriteUInt(final_w, 8)
				net.WriteUInt(final_h, 8)
				net.WriteUInt(items[1], 32)
			net.Send(client)

			timer.Create('ixPendingTransfer_' .. transferId, TRANSFER_DELAY, 1, function()
				local pending = ix.inventory.pendingTransfers[transferId]

				if !pending then return end

				local targetInv = ix.Inventory:Get(pending.to_id)
				local sourceInv = ix.Inventory:Get(pending.from_id)

				if targetInv then
					targetInv:UnreserveSlots(transferId)
				end

				for _, instanceId in ipairs(pending.items) do
					ix.inventory.pendingTransfers['item_' .. instanceId] = nil
				end

				ix.inventory.pendingTransfers[transferId] = nil

				if !sourceInv or !targetInv then return end

				local transferSuccess, transferError

				if #pending.items == 1 then
					transferSuccess, transferError = sourceInv:Transfer(pending.items[1], targetInv, pending.target_x, pending.target_y, pending.was_rotated)
				else
					transferSuccess, transferError = sourceInv:TransferStack(pending.items, targetInv, pending.target_x, pending.target_y, pending.was_rotated)
				end

				if transferSuccess == false or transferError then
					if IsValid(pending.client) then
						net.Start('inventory.move.delayed.cancel')
							net.WriteUInt(transferId, 32)
						net.Send(pending.client)

						sourceInv:SyncTo(pending.client)
						targetInv:SyncTo(pending.client)
					end
				else
					local transferred_item = ix.Item.instances[pending.items[1]]

					if IsValid(pending.client) then
						net.Start('inventory.move.delayed.complete')
							net.WriteUInt(transferId, 32)
						net.Send(pending.client)

						sourceInv:SyncTo(pending.client)
						targetInv:SyncTo(pending.client)
					end

					if transferred_item then
						targetInv:SendDeltaTransfer(pending.items[1], sourceInv, pending.source_x, pending.source_y, transferred_item.x, transferred_item.y, pending.client)
					end
				end
			end)
		end
	end)

	hook.Add('PlayerDisconnected', 'ix.inventory.CancelPending', function(client)
		ix.inventory.CancelPlayerTransfers(client)
	end)
else
	function Inventory:MoveStack(instance_ids, x, y, was_rotated)
		local instance_id = instance_ids[1]
		local item = ix.Item.instances[instance_id]
		local old_x, old_y = item.x, item.y
		local slot = self:GetSlot(old_x, old_y)
		local w, h = self:GetItemSize(item)

		if !table.equal(instance_ids, slot) and self:OverlapsItself(instance_id, x, y, w, h) then
			return true
		end

		for k, v in ipairs(instance_ids) do
			local success = self:MoveItem(v, x, y, was_rotated)

			if !success then
				return success
			end
		end

		return true
	end

	function Inventory:MoveItem(instance_id, x, y, was_rotated)
		local item = ix.Item.instances[instance_id]

		if !item then 
			return
		end

		local need_rotation = false
		local old_x, old_y = item.x, item.y
		local w, h = self:GetItemSize(item)
		local old_w, old_h = w, h

		if was_rotated then
			w, h = h, w
		end

		if !x or !y or x < 1 or y < 1 or x + w - 1 > self:GetWidth() or y + h - 1 > self:GetHeight() then
			x, y, need_rotation = self:FindPosition(item, w, h)

			if !x or !y then
				return false
			end
		elseif !self:IsSlotsEmpty(x, y, w, h) then
			local overlap, new_x, new_y, new_rotation = self:OverlapsStack(item, x, y, w, h)

			if overlap then
				x, y = new_x, new_y

				if new_rotation != was_rotated then
					need_rotation = true
				end
			elseif !self:OverlapsOnlyItself(instance_id, x, y, w, h, need_rotation) then
				return false
			end
		end

		if self.regions then
			local final_w, final_h = need_rotation and h or w, need_rotation and w or h

			if !self:IsRectInRegion(x, y, final_w, final_h) then
				return false
			end
		end

		item.x = x
		item.y = y

		if need_rotation then
			w, h = h, w
		end

		if was_rotated != need_rotation then
			item.rotated = !item.rotated
		end

		for i = old_y, old_y + old_h - 1 do
			for k = old_x, old_x + old_w - 1 do
				table.RemoveByValue(self.slots[i][k], instance_id)
			end
		end

		for i = y, y + h - 1 do
			for k = x, x + w - 1 do
				table.insert(self.slots[i][k], instance_id)
			end
		end

		return true
	end

	function Inventory:Transfer(instance_id, inventory, x, y, was_rotated)
		local item = ix.Item.instances[instance_id]

		if !item then 
			return
		end

		local need_rotation = false
		local old_x, old_y = item.x, item.y
		local w, h = inventory:GetItemSize(item)
		local old_w, old_h = self:GetItemSize(item)

		if was_rotated then
			w, h = h, w
		end

		if !x or !y or x < 1 or y < 1 or x + w - 1 > inventory:GetWidth() or y + h - 1 > inventory:GetHeight() then
			x, y, need_rotation = inventory:FindPosition(item, w, h)

			if !x or !y then
				return false
			end
		elseif !inventory:IsSlotsEmpty(x, y, w, h) then
			local overlap, new_x, new_y, new_rotation = inventory:OverlapsStack(item, x, y, w, h)

			if overlap then
				x, y = new_x, new_y

				if new_rotation != was_rotated then
					need_rotation = true
				end
			else
				return false
			end
		end

		if inventory.regions then
			local final_w, final_h = need_rotation and h or w, need_rotation and w or h

			if !inventory:IsRectInRegion(x, y, final_w, final_h) then
				return false
			end
		end

		item.inventory_id = inventory.id
		item.inventory_type = inventory.type
		item.x = x
		item.y = y

		if need_rotation then
			w, h = h, w
		end

		if was_rotated != need_rotation then
			item.rotated = !item.rotated
		end

		for i = old_y, old_y + old_h - 1 do
			for k = old_x, old_x + old_w - 1 do
				table.RemoveByValue(self.slots[i][k], instance_id)
			end
		end

		for i = y, y + h - 1 do
			for k = x, x + w - 1 do
				table.insert(inventory.slots[i][k], instance_id)
			end
		end

		return true
	end

	function Inventory:TransferStack(instance_ids, inventory, x, y, was_rotated)
		for k, v in ipairs(instance_ids) do
			local success = self:Transfer(v, inventory, x, y, was_rotated)

			if !success then
				return success
			end
		end

		return true
	end

	function Inventory:CreatePanel(parent)
		local panel = vgui.Create('ui.inv', parent)
		panel:SetTitle(L(self.title or self.type))
		panel:SetIcon(self.icon)
		panel:SetInventoryID(self.id)
		panel:Rebuild()

		self.panel = panel

		return panel
	end

	local EquipmentTypes = {
		["head"] = true,
		["mask"] = true,
		["torso"] = true,
		["legs"] = true,
		["hands"] = true,
		["radio"] = true,
		["cid"] = true,
		["ears"] = true,
		["arm"] = true,
		["backpack"] = true,
	}

	ix.inventory = ix.inventory or {}
	ix.inventory.clientPendingTransfers = {}

	function ix.inventory.ApplyPendingFlags(transferId)
		local pending = ix.inventory.clientPendingTransfers[transferId]

		if !pending then return end

		local srcInv = ix.Inventory:Get(pending.fromInvId)

		if srcInv and IsValid(srcInv.panel) then
			local sp = srcInv.panel.slot_panels
			local slotPanel = sp and sp[pending.sourceY] and sp[pending.sourceY][pending.sourceX]

			if IsValid(slotPanel) and !istable(slotPanel) then
				slotPanel.pendingTransfer = transferId
			end
		end

	end

	function ix.inventory.RestoreAllPendingFlags()
		for transferId, _ in pairs(ix.inventory.clientPendingTransfers) do
			ix.inventory.ApplyPendingFlags(transferId)
		end
	end

	function ix.inventory.ClearPendingFlags(transferId)
		local pending = ix.inventory.clientPendingTransfers[transferId]

		if !pending then return end

		local srcInv = ix.Inventory:Get(pending.fromInvId)

		if srcInv and IsValid(srcInv.panel) then
			local sp = srcInv.panel.slot_panels
			local slotPanel = sp and sp[pending.sourceY] and sp[pending.sourceY][pending.sourceX]

			if IsValid(slotPanel) and !istable(slotPanel) then
				slotPanel.pendingTransfer = nil
			end
		end

	end

	net.Receive('inventory.move.ack', function() end)

	net.Receive('inventory.move.reject', function()
		local error = net.ReadString()

		if error and error != '' then
			LocalPlayer():NotifyLocalized(error)
		end
	end)

	net.Receive('inventory.move.delayed', function()
		local transferId = net.ReadUInt(32)
		local fromInvId = net.ReadUInt(32)
		local sourceX = net.ReadUInt(8)
		local sourceY = net.ReadUInt(8)
		local sourceW = net.ReadUInt(8)
		local sourceH = net.ReadUInt(8)
		local toInvId = net.ReadUInt(32)
		local targetX = net.ReadUInt(8)
		local targetY = net.ReadUInt(8)
		local targetW = net.ReadUInt(8)
		local targetH = net.ReadUInt(8)
		local instanceId = net.ReadUInt(32)

		ix.inventory.clientPendingTransfers[transferId] = {
			fromInvId = fromInvId,
			sourceX = sourceX,
			sourceY = sourceY,
			sourceW = sourceW,
			sourceH = sourceH,
			toInvId = toInvId,
			targetX = targetX,
			targetY = targetY,
			targetW = targetW,
			targetH = targetH,
			instanceId = instanceId,
		}

		ix.inventory.ApplyPendingFlags(transferId)
	end)

	net.Receive('inventory.move.delayed.complete', function()
		local transferId = net.ReadUInt(32)

		ix.inventory.ClearPendingFlags(transferId)
		ix.inventory.clientPendingTransfers[transferId] = nil
	end)

	net.Receive('inventory.move.delayed.cancel', function()
		local transferId = net.ReadUInt(32)

		ix.inventory.ClearPendingFlags(transferId)
		ix.inventory.clientPendingTransfers[transferId] = nil
	end)

	net.Receive('ixInvSync', function(len)
		local id = net.ReadUInt(32)
		local inv_type = net.ReadString()
		local w, h = net.ReadUInt(6), net.ReadUInt(6)
		local owner = Entity(net.ReadUInt(8))
		local multislot, disabled = net.ReadBool(), net.ReadBool()

		local hasRegions = net.ReadBool()
		local regions

		if hasRegions then
			local count = net.ReadUInt(4)
			regions = {}

			for i = 1, count do
				regions[i] = {
					x = net.ReadUInt(6),
					y = net.ReadUInt(6),
					w = net.ReadUInt(6),
					h = net.ReadUInt(6)
				}
			end
		end

		local instance_id = net.ReadUInt(32)

		local item_count = net.ReadUInt(16)
		local items = {}

		for i = 1, item_count do
			items[i] = net.ReadUInt(32)
		end

		local inventory = ix.Inventory:Get(id) or ix.meta.Inventory:New(id)
		inventory:SetSize(w, h)
		inventory.type = inv_type

		if regions then
			inventory:SetRegions(regions)
		else
			inventory:SetRegions(nil)
		end

		if EquipmentTypes[inv_type] then
			inventory.isEquipment = true
		end
		
		inventory.multislot = multislot
		inventory.disabled = disabled
		inventory.owner = IsValid(owner) and owner
		inventory.slots = {}

		if instance_id != 0 then
			inventory.instance_id = instance_id

			if ix.Item.instances[instance_id] then
				ix.Item.instances[instance_id].inventory = inventory
			end
		end

		inventory:Rebuild()

		local client = LocalPlayer()

		if owner and owner == client then
			client.inventories = client.inventories or {}
			client.inventories[inv_type] = inventory

			ix.gui.can_craft = nil

			timer.Simple(0, function()
				if ix.gui.setup_backpack then
					ix.gui.setup_backpack()
				end
			end)
		end
		
		for k, itemID in ipairs(items) do
			local instance = ix.Item:Instances()[itemID]

			if !instance then continue end

			instance.inventory_type = inv_type
			
			local w, h = inventory:GetItemSize(instance)
			local x, y = instance.x, instance.y
			
			for i = y, y + h - 1 do
				for k = x, x + w - 1 do
					if inventory.slots[i] and inventory.slots[i][k] then
						table.insert(inventory.slots[i][k], itemID)
					end
				end
			end
		end

		if IsValid(inventory.panel) then
			inventory.panel:Rebuild()
		end
	end)

	net.Receive('inventory.delta.moved', function()
		local inv_id = net.ReadUInt(32)
		local instance_id = net.ReadUInt(32)
		local old_x = net.ReadUInt(8)
		local old_y = net.ReadUInt(8)
		local new_x = net.ReadUInt(8)
		local new_y = net.ReadUInt(8)
		local w = net.ReadUInt(8)
		local h = net.ReadUInt(8)
		local rotated = net.ReadBool()

		local inventory = ix.Inventory:Get(inv_id)
		local item = ix.Item.instances[instance_id]

		if !inventory or !item then return end

		local old_w, old_h = inventory:GetItemSize(item)

		for i = old_y, old_y + old_h - 1 do
			for k = old_x, old_x + old_w - 1 do
				if inventory.slots[i] and inventory.slots[i][k] then
					table.RemoveByValue(inventory.slots[i][k], instance_id)
				end
			end
		end

		item.x = new_x
		item.y = new_y
		item.rotated = rotated

		for i = new_y, new_y + h - 1 do
			for k = new_x, new_x + w - 1 do
				if inventory.slots[i] and inventory.slots[i][k] then
					table.insert(inventory.slots[i][k], instance_id)
				end
			end
		end

		if IsValid(inventory.panel) then
			inventory.panel:Rebuild()
		end
	end)

	net.Receive('inventory.delta.added', function()
		local inv_id = net.ReadUInt(32)
		local instance_id = net.ReadUInt(32)
		local x = net.ReadUInt(8)
		local y = net.ReadUInt(8)
		local w = net.ReadUInt(8)
		local h = net.ReadUInt(8)

		local inventory = ix.Inventory:Get(inv_id)
		local item = ix.Item.instances[instance_id]

		if !inventory or !item then return end

		item.x = x
		item.y = y
		item.inventory_id = inv_id
		item.inventory_type = inventory.type

		for i = y, y + h - 1 do
			for k = x, x + w - 1 do
				if inventory.slots[i] and inventory.slots[i][k] then
					table.insert(inventory.slots[i][k], instance_id)
				end
			end
		end

		if IsValid(inventory.panel) then
			inventory.panel:Rebuild()
		end
	end)

	net.Receive('inventory.delta.removed', function()
		local inv_id = net.ReadUInt(32)
		local instance_id = net.ReadUInt(32)
		local old_x = net.ReadUInt(8)
		local old_y = net.ReadUInt(8)
		local w = net.ReadUInt(8)
		local h = net.ReadUInt(8)

		local inventory = ix.Inventory:Get(inv_id)

		if !inventory then return end

		for i = old_y, old_y + h - 1 do
			for k = old_x, old_x + w - 1 do
				if inventory.slots[i] and inventory.slots[i][k] then
					table.RemoveByValue(inventory.slots[i][k], instance_id)
				end
			end
		end

		if IsValid(inventory.panel) then
			inventory.panel:Rebuild()
		end
	end)

	net.Receive('inventory.delta.transferred', function()
		local from_inv_id = net.ReadUInt(32)
		local to_inv_id = net.ReadUInt(32)
		local instance_id = net.ReadUInt(32)
		local old_x = net.ReadUInt(8)
		local old_y = net.ReadUInt(8)
		local old_w = net.ReadUInt(8)
		local old_h = net.ReadUInt(8)
		local new_x = net.ReadUInt(8)
		local new_y = net.ReadUInt(8)
		local new_w = net.ReadUInt(8)
		local new_h = net.ReadUInt(8)

		local from_inv = ix.Inventory:Get(from_inv_id)
		local to_inv = ix.Inventory:Get(to_inv_id)
		local item = ix.Item.instances[instance_id]

		if !item then return end

		if from_inv then
			for i = old_y, old_y + old_h - 1 do
				for k = old_x, old_x + old_w - 1 do
					if from_inv.slots[i] and from_inv.slots[i][k] then
						table.RemoveByValue(from_inv.slots[i][k], instance_id)
					end
				end
			end

			if IsValid(from_inv.panel) then
				from_inv.panel:Rebuild()
			end
		end

		item.x = new_x
		item.y = new_y
		item.inventory_id = to_inv_id

		if to_inv then
			item.inventory_type = to_inv.type

			for i = new_y, new_y + new_h - 1 do
				for k = new_x, new_x + new_w - 1 do
					if to_inv.slots[i] and to_inv.slots[i][k] then
						table.insert(to_inv.slots[i][k], instance_id)
					end
				end
			end

			if IsValid(to_inv.panel) then
				to_inv.panel:Rebuild()
			end
		end
	end)
end
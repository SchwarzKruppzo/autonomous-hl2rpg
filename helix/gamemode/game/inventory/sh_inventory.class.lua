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
	for i = 1, self:GetHeight() - h + 1 do
		for k = 1, self:GetWidth() - w + 1 do
			if self:IsSlotsEmpty(k, i, w, h) then
				return k, i
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

	function Inventory:Sync()
		for k, v in ipairs(self:GetReceivers()) do
			if !IsValid(v) then 
				self:RemoveReceiver(v)
				continue 
			end
			
			for _, item in ipairs(self:GetItems()) do
				item:Sync(v)
			end
			
			net.Start('ixInvSync')
				net.WriteUInt(self.id, 32)
				net.WriteString(self.type)
				net.WriteUInt(self.width, 6)
				net.WriteUInt(self.height, 6)
				net.WriteUInt(IsValid(self.owner) and self.owner:EntIndex() or 0, 8)
				net.WriteBool(self.multislot)
				net.WriteBool(self.disabled)
				net.WriteUInt(self.instance_id and self.instance_id or 0, 32)
				net.WriteTable(self:GetItemsID())
			net.Send(v)
		end
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
			return
		end

		if !inventory:OnCheckAccess(client) or !old_inventory:OnCheckAccess(client) then
			return
		end
		
		local slot = old_inventory:GetSlot(x, y)

		if !istable(slot) or table.IsEmpty(slot) then
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

		local success, error
		if to_id == from_id then
			inventory:MoveStack(items, target_x, target_y, was_rotated)
		else
			if #items == 1 then
				success, error = old_inventory:Transfer(items[1], inventory, target_x, target_y, was_rotated)
			else
				success, error = old_inventory:TransferStack(items, inventory, target_x, target_y, was_rotated)
			end

			old_inventory:Sync()
		end

		inventory:Sync()

		if error then
			client:NotifyLocalized(error)
		end
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

	net.Receive('ixInvSync', function(len)
		local id = net.ReadUInt(32)
		local inv_type = net.ReadString()
		local w, h = net.ReadUInt(6), net.ReadUInt(6)
		local owner = Entity(net.ReadUInt(8))
		local multislot, disabled = net.ReadBool(), net.ReadBool()
		local instance_id = net.ReadUInt(32)
		local items = net.ReadTable() // workaround

		local inventory = ix.Inventory:Get(id) or ix.meta.Inventory:New(id)
		inventory:SetSize(w, h)
		inventory.type = inv_type

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
			instance.inventory_type = inv_type
			
			local w2, h2, x, y = instance.width, instance.height, instance.x, instance.y
			local w, h = w2, h2

			if instance.rotated then
				w = h2
				h = w2
			end
			
			for i = y, y + h - 1 do
				for k = x, x + w - 1 do
					if inventory.slots[i] and inventory.slots[i][k] then
						table.insert(inventory.slots[i][k], itemID)
					end
				end
			end
		end

		if IsValid(inventory.panel) && inventory.panel:ShouldBeRebuild() then
			inventory.panel:Rebuild()
		end
	end)
end
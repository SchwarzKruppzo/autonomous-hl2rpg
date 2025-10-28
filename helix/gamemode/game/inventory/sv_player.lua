do
	local PLAYER = FindMetaTable("Player")

	function PLAYER:CreateInventories()
		local inventories = {}

		hook.Run("CreatePlayerInventories", self, inventories)

		for k, v in pairs(inventories) do
			if !self.default_inventory and v:IsDefault() then
				self.default_inventory = v.type
			end

			v:AddReceiver(self)
			v.owner = self
		end

		self.inventories = inventories
		self:SyncInventories()
		
		self:LoadInventories(function()
			self:SyncInventories()
		end)
	end

	function PLAYER:LoadInventories(callback)
		local item_ids = self:GetCharacter():GetSavedItems()

		ix.Item:LoadInstanceByID(item_ids, function(item)
			if item.inventory_type then
				local x, y = item.x, item.y
				local inventory_type = item.inventory_type
				local inventory = self:GetInventory(inventory_type)

				if !inventory then
					return
				end
				
				if inventory:IsWidthInfinite() and x > inventory:GetWidth() then
					inventory:SetWidth(x + 1)
				end

				if inventory:IsHeightInfinite() and y > inventory:GetHeight() then
					inventory:SetHeight(y + 1)
				end

				inventory:AddItem(item, x, y, nil, true)
			end
		end, callback)
	end

	function PLAYER:DeleteInventories()
		for k, v in pairs(self:GetInventories()) do
			if v.owner == self then
				ix.Inventory.stored[v.id] = nil
			end
		end
	end

	function PLAYER:SyncInventories()
		for k, v in pairs(self:GetInventories()) do
			v:Sync()
		end
	end

	function PLAYER:SyncInventory(inv_type)
		self:GetInventory(inv_type):Sync()
	end

	function PLAYER:AddItem(item, inv_type)
		local inventory = self:GetInventory(inv_type or self.default_inventory or "main")
		local success, error = inventory:AddItem(item)

		if !success then
			local backpack = self:GetBackpack()

			if backpack then
				inventory = backpack:GetInventory()
				
				success, error = inventory:AddItem(item)
			end
		end

		inventory:Sync()

		return success, error
	end

	function PLAYER:AddItemByID(instance_id, inv_type)
		return self:AddItem(ix.Item.instances[instance_id], inv_type)
	end

	function PLAYER:GiveItem(id, amount, data, inv_type)
		local inventory = self:GetInventory(inv_type or self.default_inventory or "main")
		local success, error = inventory:GiveItem(id, amount, data)

		inventory:Sync()

		return success, error
	end

	function PLAYER:TakeItem(id, inv_type)
		if inv_type then
			local inventory = self:GetInventory(inv_type)
			local success, error = inventory:TakeItem(id)

			inventory:Sync()

			return success, error
		else
			for k, v in pairs(self:GetInventories()) do
				local found, item = v:HasItem(id)

				if found then
					local inv = ix.Inventory:Get(item.inventory_id)

					if inv then
						local success, error = inv:TakeItem(id)
						inv:Sync()

						return success, error
					end
				end
			end

			return false, 'invalidItem'
		end
	end

	function PLAYER:TakeItems(id, amount, inv_type)
		if inv_type then
			local inventory = self:GetInventory(inv_type)
			local success, error = inventory:TakeItems(id, amount)

			inventory:Sync()

			return success, error
		else
			if self:GetItemsCount(id) < amount then
				return false, 'notEnoughItems'
			else
				for k, v in pairs(self:GetInventories()) do
					local found, item = v:HasItem(id)

					if amount > 0 and found then
						local inv = ix.Inventory:Get(item.inventory_id)

						if inv then
							inv:TakeItem(id)
							inv:Sync()

							amount = amount - 1
						end
					end
				end

				return true
			end
		end
	end

	function PLAYER:TakeItemByID(instance_id, inv_type)
		if inv_type then
			local inventory = self:GetInventory(inv_type)
			local success, error = inventory:TakeItemByID(instance_id)

			inventory:Sync()

			return success, error
		else
			local has, item = self:HasItemByID(instance_id)

			if has then
				local inventory = self:GetInventory(item.inventory_type)
				local success, error = inventory:TakeItemTable(item)

				inventory:Sync()

				return success, error
			else
				return false, 'invalidItem'
			end
		end
	end

	function PLAYER:TransferItem(item, inv_type)
		local old_inventory = self:GetInventory(item.inventory_type)
		local new_inventory = self:GetInventory(inv_type)

		if item.inventory_type != inv_type then
			local success, error = old_inventory:Transfer(item, new_inventory)

			if success then
				//old_inventory:Sync()
				//new_inventory:Sync()
				// already synced in Transfer

				return true
			else
				return false, error
			end
		end
	end

	function PLAYER:OpenInventory(inventory)
		inventory:AddReceiver(self)
		inventory:Sync()
	end

	function PLAYER:OpenPlayerInventory(target)
		local inventory_ids = {}

		for k, v in pairs(target:GetInventories()) do
			v:AddReceiver(self)
			v:Sync()

			table.insert(inventory_ids, v.id)
		end
	end
end

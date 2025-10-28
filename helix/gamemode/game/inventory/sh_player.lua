do
	local PLAYER = FindMetaTable("Player")

	function PLAYER:GetInventory(inv_type)
		return self.inventories[inv_type]
	end

	function PLAYER:GetInventories()
		return self.inventories or {}
	end

	function PLAYER:GetItems(inv_type)
		if inv_type then
			return self:GetInventory(inv_type):GetItems()
		else
			local items = {}

			for k, v in pairs(self:GetInventories()) do
				table.Add(items, v:GetItems())
			end

			return items
		end
	end

	function PLAYER:GetItemsID(inv_type)
		if inv_type then
			return self:GetInventory(inv_type)
		else
			local items = {}

			for k, v in pairs(self:GetInventories()) do
				table.Add(items, v:GetItemsID())
			end

			return items
		end
	end

	function PLAYER:GetSlot(x, y, inv_type)
		return self:GetInventory(inv_type):GetSlot(x, y)
	end

	function PLAYER:GetFirstAtSlot(x, y, inv_type)
		return self:GetInventory(inv_type):GetFirstAtSlot(x, y)
	end

	function PLAYER:GetItemsCount(id, inv_type)
		if inv_type then
			return self:GetInventory(inv_type):GetItemsCount(id)
		else
			local count = 0

			for k, v in pairs(self:GetInventories()) do
				count = count + v:GetItemsCount(id)
			end

			return count
		end
	end

	function PLAYER:FindItem(id, inv_type)
		if inv_type then
			return self:GetInventory(inv_type):FindItem(id)
		else
			for k, v in pairs(self:GetInventories()) do
				local item = v:FindItem(id)

				if item then
					return item
				end
			end
		end
	end

	function PLAYER:FindItems(id, inv_type)
		if inv_type then
			return self:GetInventory(inv_type):FindItems(id)
		else
			local items = {}

			for k, v in pairs(self:GetInventories()) do
				table.Add(items, v:FindItems(id))
			end

			return items
		end
	end

	function PLAYER:HasItem(id, inv_type)
		if inv_type then
			return self:GetInventory(inv_type):HasItem(id)
		else
			for k, v in pairs(self:GetInventories()) do
				local found, item = v:HasItem(id)
				
				if found then
					return true, item
				end
			end

			return false
		end
	end

	function PLAYER:HasItemByID(instance_id, inv_type)
		if inv_type then
			return self:GetInventory(inv_type):HasItemByID(instance_id)
		else
			for k, v in pairs(self:GetInventories()) do
				local found, item = v:HasItemByID(instance_id)

				if found then
					return true, item
				end
			end

			return false
		end
	end

	function PLAYER:HasItemEquipped(id)
		local item = self:FindItem(id)

		if item and item:IsEquipped() then
			return true, item
		end

		return false
	end

	function PLAYER:GetItemFromWeapon(weapon_class)
		for k, v in pairs(self:GetItems()) do
			if v.IsEquipped and v:IsEquipped() and v.weapon_class == weapon_class then
				return v
			end
		end
	end

	function PLAYER:GetActiveWeaponItem()
		local weapon = self:GetActiveWeapon()

		if IsValid(weapon) then
			return self:GetItemFromWeapon(weapon:GetClass())
		end
	end

	function PLAYER:GetBackpack()
		local backpackID = self:GetFirstAtSlot(1, 1, 'backpack')
		local backpack = backpackID and ix.Item.instances[backpackID]
		
		return backpack
	end
end

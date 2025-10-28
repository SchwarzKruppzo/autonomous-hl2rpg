local ItemEquipable = class("ItemEquipable"):implements("Item")

ItemEquipable.category = 'Equipment'
ItemEquipable.stackable = false
ItemEquipable.equip_slot = 'hotbar'
ItemEquipable.equip_inv = nil

local EQUIPMENT_SLOTS = {
	['torso'] = 1,
	['legs'] = 2,
	['backpack'] = 3
}

function ItemEquipable:GetEquipmentSlot(slot)
	if isstring(slot) then
		return EQUIPMENT_SLOTS[slot]
	else
		for slotName, slotID in pairs(EQUIPMENT_SLOTS) do
			if slotID == slot then
				return slotName
			end
		end
	end
end

function ItemEquipable:Init()
	self.functions.equip = {
		tip = "equipTip",
		icon = "icon16/box.png",
		OnRun = function(item)
			local inventory = item.player:GetInventory(self.equip_inv)

			local x, y

			if self.equip_slot then
				x = 1
				y = self:GetEquipmentSlot(self.equip_slot)
			end

			if IsValid(item.entity) then
				local bSuccess, error = inventory:AddItem(item, x, y)

				if bSuccess then
					item.entity:Delete()

					inventory:Sync()

					item:Equip(item.player, bSuccess)
				else
					item.player:NotifyLocalized(error or 'unknownError')
				end

				return bSuccess
			else
				if !self:IsEquipped() then
					local old_inventory = ix.Inventory:Get(item.inventory_id)

					old_inventory:Transfer(item.id, inventory, x, y, false)

					old_inventory:Sync()
					inventory:Sync()
				end
			end
		end,
		OnCanRun = function(item)
			local client = item.player

			return IsValid(client) and !item:IsEquipped() and item:CanEquip(client)
		end
	}

	self.functions.unequip = {
		tip = "unequipTip",
		icon = "icon16/box.png",
		OnRun = function(item)
			local old_inventory = ix.Inventory:Get(item.inventory_id)
			local inventory = item.player:GetInventory('main')

			old_inventory:Transfer(item.id, inventory)

			old_inventory:Sync()
			inventory:Sync()
		end,
		OnCanRun = function(item)
			local client = item.player

			return IsValid(client) and item:IsEquipped() and item:CanUnequip(client)
		end
	}
end

function ItemEquipable:IsEquipped()
	return self.inventory_type == self.equip_inv and (self.equip_slot and (self.y == EQUIPMENT_SLOTS[self.equip_slot]) or true)
end

function ItemEquipable:CanTransfer(oldInventory, inventory, x, y)
	local player = self:GetOwner()
	local inv_type = inventory.type

	if inv_type == self.equip_inv then
		if self.equip_slot and (y != EQUIPMENT_SLOTS[self.equip_slot]) then
			return false
		end
		
		if self:CanEquip(player) == false then
			return false
		end

		for k, v in pairs(inventory:GetItems()) do
			if v.equip_inv and v:IsEquipped() and v.id != self.id then
				if self.equip_slot and (v.equip_slot == self.equip_slot) and (v.equip_inv == self.equip_inv) then
					return false
				else
					if v.equip_inv == self.equip_inv then
						return false
					end
				end
			end
		end
	elseif inv_type != self.equip_inv then
		if inventory.isEquipment then
			return false
		else
			if self:CanUnequip(player) == false then
				return false
			end
		end
	end
end

function ItemEquipable:OnDrop(owner)
	if self:IsEquipped() then
		self:OnUnequipped(owner)
	end
end

function ItemEquipable:CanEquip(player)
	if self.gender then
		if player:GetCharacter():GetGender() != self.gender then
			return false
		end
	end
	
	return true
end

function ItemEquipable:CanUnequip(player)
	return true
end

function ItemEquipable:OnEquipped(player)
end

function ItemEquipable:OnUnequipped(player)
end

function ItemEquipable:Equip(player, should_equip, noPlaySound)
	if !noPlaySound and self.action_sounds then
		player:EmitSound(self.action_sounds[should_equip and 'equip' or 'unequip'])
	end

	if should_equip then
		self:OnEquipped(player)

		hook.Run('OnItemEquipped', player, self)
	else
		self:OnUnequipped(player)

		hook.Run('OnItemUnequipped', player, self)
	end
end

function ItemEquipable:OnTransfer(newInventory, oldInventory)
	if newInventory and newInventory.type == self.equip_inv then
		self:Equip(newInventory.owner, true)
	elseif oldInventory and oldInventory.type == self.equip_inv then
		self:Equip(oldInventory.owner, false)
	end
end
/*
function ItemEquipable:OnLoadout(player)
	if self:IsEquipped() then
		self:Equip(player, true, true)
	end
end
*/
if CLIENT then
	function ItemEquipable:PaintOver(w, h)
		if self:IsEquipped() then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 20, 8, 8)
		end
	end
end

return ItemEquipable
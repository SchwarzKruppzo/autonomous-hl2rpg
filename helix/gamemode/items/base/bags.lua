if !ix.meta.ItemEquipable then
	ix.util.Include("equipable.lua", "shared")
end

ix.outfits = {}

local Item = class("ItemBag")
implements("ItemEquipable", "ItemBag")

Item = ix.meta.ItemBag

Item.category = 'Storage'
Item.stackable = false
Item.isBag = true
Item.default_inventory = {}
Item.inventory_data = {
	width = 4,
	height = 4,
	type = 'item_container',
	multislot = true
}

function Item:GetInventory()
	if SERVER then
		return self.inventory
	else
		if !self.inventory then
			for k, v in pairs(ix.Inventory:All()) do
				if v.instance_id == self.id then
					self.inventory = v
					break
				end
			end
		end

		return self.inventory
	end
end

function Item:Init()
	ix.meta.ItemEquipable.Init(self)

	self.equip_inv = 'backpack'
	self.equip_slot = nil
	self.category = 'Storage'

	self.functions.view = {
		tip = "viewTip",
		icon = "icon16/box.png",
		OnClick = function(item)
			local parent = IsValid(ix.gui.menuInventoryContainer) and ix.gui.menuInventoryContainer or ix.gui.openedStorage

			local inventory = item:GetInventory()

			if inventory then
				if IsValid(inventory.panel) then
					if inventory.panel.test then
						inventory.panel.test:Remove()
					else
						inventory.panel:Remove()
					end
				end

				local panel = vgui.Create('ui.inv.wrapper', IsValid(parent) and parent or nil)
				panel.panel:SetSlotSize(64, 64)
				panel:SetInventory(inventory)
				inventory.panel.test = panel
				panel:Rebuild()
				panel:InvalidateLayout(true)
				panel:SizeToChildren(true, true)

				if (parent != ix.gui.menuInventoryContainer) then
					panel:Center()
					
					if (parent == ix.gui.openedStorage) then
						panel:MoveToFront()
						//panel:MakePopup()
					end
				else
					panel:MoveToFront()
				end
			end
		end,
		OnRun = function()
		end,
		OnCanRun = function(item)
			local client = item.player

			if CLIENT then
				if IsValid(ix.gui.menu) and item:IsEquipped() then
					return false
				end
			end

			return IsValid(client) and !IsValid(item.entity)
		end
	}
end

function Item:GetInventoryData()
	return self.inventory_data
end

function Item:CreateInventory()
	local data = self:GetInventoryData()
	local inventory = ix.meta.Inventory:New()
		inventory.title = self:GetName()
		inventory:SetSize(data.width or 1, data.height or 1)
		inventory.type = data.type or 'item_container'
		inventory.multislot = data.multislot != nil and data.multislot or true
		inventory.infinite_width = data.infinite_width != nil and data.infinite_width or false
		inventory.infinite_height = data.infinite_height != nil and data.infinite_height or false
		inventory.instance_id = self.id

	self.inventory = inventory
end

function Item:CanTransfer(oldInventory, newInventory, x, y)
	if newInventory and newInventory == self.inventory then
		return false
	end

	if newInventory.type == 'main' then
		local hasBag = false

		for k, v in pairs(newInventory:GetItems()) do
			if v.isBag then
				hasBag = true
				break
			end
		end

		local itemID = newInventory.owner:GetFirstAtSlot(1, 1, 'backpack')

		return !hasBag and (!itemID or itemID == self.id), 'hasBag'
	end

	if newInventory.type == 'container' or newInventory.type == 'item_container' then
		local hasItem

		for k, v in ipairs(self:GetInventory():GetItemsID()) do
			hasItem = true
			break
		end

		return !hasItem, 'equippedBag'
	end

	return ix.meta.ItemEquipable.CanTransfer(self, oldInventory, newInventory, x, y)
end

function Item:CanTake(client)
	if SERVER then
		local hasBag

		for k, v in pairs(client:GetInventory("main"):GetItems()) do
			if v.isBag then
				hasBag = true
				break
			end
		end

		local itemID = client:GetFirstAtSlot(1, 1, 'backpack')

		if itemID or hasBag then
			client:NotifyLocalized('hasBag')
			return false
		end
	end
end

function Item:OnEquipped(client)
	if self.GetOutfitData then
		client.char_outfit:AddItem(self, false, {})
		client.char_outfit:Update()
	end
end

function Item:OnUnequipped(client)
	if self.GetOutfitData then
		client.char_outfit:RemoveItem(self)
		client.char_outfit:Update()
	end
end

function Item:OnRegistered()
	if isfunction(self.GetOutfitData) then
		local id = #ix.outfits + 1

		ix.outfits[id] = self:GetOutfitData()

		self.outfit_id = id
	end
end

if SERVER then
	function Item:OnInstanced(isCreated)
		if !self.inventory then
			self:CreateInventory()

			if self.items then
				ix.Item:LoadInstanceByID(self.items, function(item)
					self.inventory:AddItem(item, item.x, item.y)
				end)

				self.items = nil
			end
		end

		if isCreated and self.inventory then
		end
	end

	function Item:OnSync(receiver, transmit)
		if self.inventory_id and self.inventory then
			local hasReceiver

			for _, v in ipairs(self.inventory.receivers) do
				if v == receiver then
					hasReceiver = true
				end
			end

			if !hasReceiver then
				self.inventory:AddReceiver(receiver)
			end
			
			self.inventory:Sync()
		end
	end

	function Item:OnSave()
		self.items = self.inventory and self.inventory:GetItemsID()
	end
end

return Item
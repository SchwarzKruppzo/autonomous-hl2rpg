local Item = class("ItemFilter"):implements("Item")

Item.stackable = false
Item.isFilter = true

function Item:IsEquipped()
	return self.inventory_type == 'main' and (self:GetData('equip') == true)
end

local function Write_Equip(item, value)
	net.WriteBool(value)
end

local function Read_Equip(item)
	return net.ReadBool(value)
end

local function Write_Durability(item, value)
	net.WriteFloat(value)
end

local function Read_Durability(item)
	return net.ReadFloat()
end

function Item:GetDescription()
	return L("filterDesc", L(self.description), math.Round(100 * (self:GetFilterQuality() / self.filterQuality)))
end

function Item:GetFilterQuality()
	return self:GetData("filterQuality", self.filterQuality)
end

function Item:SetFilterQuality(amount)
	self:SetData("filterQuality", amount)
end

function Item:Init()
	self.category = 'Фильтры'

	self.filterQuality = self.filterQuality or 100

	self.functions.equip = {
		tip = "equipTip",
		icon = "icon16/box.png",
		OnRun = function(item)
			item:Equip(item.player)
		end,
		OnCanRun = function(item)
			local client = item.player

			return !item:GetEntity() and IsValid(client) and !item:IsEquipped()
		end
	}

	self.functions.unequip = {
		tip = "unequipTip",
		icon = "icon16/box.png",
		OnRun = function(item)
			item:Unequip()
		end,
		OnCanRun = function(item)
			local client = item.player

			return !item:GetEntity() and IsValid(client) and item:IsEquipped()
		end
	}

	self:AddData("equip", {
		Transmit = ix.transmit.owner,
		Write = Write_Equip,
		Read = Read_Equip
	})

	self:AddData("filterQuality", {
		Transmit = ix.transmit.owner,
		Write = Write_Durability,
		Read = Read_Durability
	})
end

function Item:OnInstanced(isCreated)
	if isCreated then
		self:SetData("filterQuality", self.filterQuality)
	end
end

function Item:Equip(client)
	local items = client:GetItems()

	for _, v in pairs(items) do
		if v.id != self.id then
			if !v.isFilter then continue end
			
			local itemTable = ix.Item.instances[v.id]

			if itemTable:IsEquipped() then
				return false
			end
		end
	end

	local itemID = client:GetFirstAtSlot(1, 1, 'mask')
	local mask = itemID and ix.Item.instances[itemID]

	if !mask or !mask.isGasmask then
		return
	end

	mask:SetData("filter", self.id)

	self:SetData("equip", true)
end

function Item:Unequip(inventory)
	local owner
	local inventory = inventory or (self.inventory_id and ix.Inventory:Get(self.inventory_id))

	if inventory and (IsValid(inventory.owner) and inventory.owner:IsPlayer()) then
		owner = inventory.owner
	end
	
	self:SetData("equip", false)
end

function Item:OnTransfer(newInventory, oldInventory)
	self:Unequip(oldInventory)
end

function Item:OnDrop(client, inventory)
	if self:GetData("equip") then
		self:Unequip(inventory)
	end
end

if CLIENT then
	function Item:PaintOver(w, h)
		if self:GetData("equip") then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end
end

return Item
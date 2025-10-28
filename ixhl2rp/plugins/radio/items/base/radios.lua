local Item = class("ItemRadio")
implements("ItemEquipable", "ItemRadio")

Item = ix.meta.ItemRadio

function Item:Init()
	ix.meta.ItemEquipable.Init(self)

	self.equip_inv = 'radio'
	self.equip_slot = nil

	self.model = self.model or "models/cellar/items/handheld_radio.mdl"

	self.frequency = self.frequency or "main"
	self.frequencyID = self.frequencyID or "freq_main"

	self.category = 'Коммуникация'

	self.functions.toggle = {
		name = "Переключить",
		OnRun = function(item)
			item:SetData("on", !item:GetData("on", false))

			ix.radio:SetPlayerChannels(item.player)
		end,
		OnCanRun = function(item)
			return item:IsEquipped() and (IsValid(item.player) and !IsValid(item.entity) and !item.player:IsRestricted() and 
			(!item.factionLock or item.factionLock[item.player:Team()]) == true)
		end
	}

	self:AddData("on", {
		Transmit = ix.transmit.owner,
	})
end

function Item:IsOn()
	return self:GetData("on", false) == true
end

function Item:GetFrequency()
	return self.frequency
end

function Item:GetFrequencyID()
	return self.frequencyID
end

function Item:OnDrop(owner)
	ix.meta.ItemEquipable.OnDrop(self, owner)
	
	self:SetData("on", false)

	ix.radio:SetPlayerChannels(owner)
end

function Item:OnTransfer(newInventory, oldInventory)
	ix.meta.ItemEquipable.OnTransfer(self, newInventory, oldInventory)
	
	self:SetData("on", false)

	local owner
	local inventory = oldInventory or (self.inventory_id and ix.Inventory:Get(self.inventory_id))

	if inventory and (IsValid(inventory.owner) and inventory.owner:IsPlayer()) then
		owner = inventory.owner
	end

	if IsValid(owner) then
		ix.radio:SetPlayerChannels(owner)
	end
end

if SERVER then
	function Item:OnInstanced(isCreated)
		if isCreated then
			self:SetData("on", false)
		end
	end
end

if CLIENT then
	function Item:PaintOver(width, height)
		if self:IsOn() then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(width - 14, height - 14, 8, 8)
		end
	end

	function Item:PopulateTooltip(tooltip)
		local panel = tooltip:AddRowAfter("rarity", "frequency")
		panel:SetBackgroundColor(derma.GetColor(self:GetData("on", false) and "Success" or "Error", tooltip))
		panel:SetText("Частота: " .. self:GetFrequency())
		panel:SizeToContents()
	end
end

return Item
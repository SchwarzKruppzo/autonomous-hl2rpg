if !ix.meta.ItemDrink then
	ix.util.Include("drinks.lua", "shared")
end

local ItemCustomize = class("ItemCustomizeConsumable")
implements("ItemDrink", "ItemCustomizeConsumable")

ItemCustomize = ix.meta.ItemCustomizeConsumable
ItemCustomize.isCustomBase = true

function ItemCustomize:Init()
	ix.meta.ItemDrink.Init(self)

	self.category = "Кастом"

	self:AddData("checksum", {
		Transmit = ix.transmit.all,
	})

	self:AddDataCallback("checksum", function(item, value)
		if !ix.CustomItem.loaded then
			ix.CustomItem:Load()
		end
		
		local saved = ix.CustomItem.stored[value]

		if saved then
			ix.CustomItem:Deploy(item.id, saved)
		else
			ix.CustomItem.queue[value] = ix.CustomItem.queue[value] or {}
			ix.CustomItem.queue[value][item:GetID()] = true

			net.Start("item.custom.sync")
				net.WriteType(value)
			net.SendToServer()
		end
	end)
end

function ItemCustomize:GetMaterial()
	return self.material
end

function ItemCustomize:PostCustomDeploy()
	self.stats.uses = self.uses
	self.stats.thirst = self.thirst
	self.stats.hunger = self.hunger
	self.stats.stamina = self.stamina
end

function ItemCustomize:OnInstanced(isCreated)
	local saved = ix.CustomItem.stored[self:GetData("checksum")]

	if saved then
		for k, v in pairs(saved) do
			if !isfunction(self[k]) then
				self[k] = v
			end
		end

		self.stats.uses = self.uses
		self.stats.thirst = self.thirst
		self.stats.hunger = self.hunger
		self.stats.stamina = self.stamina
	end

	ix.meta.ItemDrink.OnInstanced(self, isCreated)
end

return ItemCustomize
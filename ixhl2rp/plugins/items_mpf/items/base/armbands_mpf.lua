local ItemArmbandMPF = class("ItemArmbandMPF"):implements("Item")

ItemArmbandMPF = ix.meta.ItemArmbandMPF
ItemArmbandMPF.model = "models/props_junk/cardboard_box004a.mdl"
ItemArmbandMPF.description = ""
ItemArmbandMPF.isArmband = true

function ItemArmbandMPF:Init()
	self.armband = self.armband or 0
	self.category = 'Повязки (MPF)'

	self.combine = self.combine or {}
	self.combine.armband = {
		name = "Надеть повязку",
		OnRun = function(item, targetItem, items)
			targetItem:SetData("armband", item.armband)

			if targetItem:IsEquipped() then
				local owner
				local inventory = inventory or (targetItem.inventory_id and ix.Inventory:Get(targetItem.inventory_id))

				if inventory and (IsValid(inventory.owner) and inventory.owner:IsPlayer()) then
					owner = inventory.owner
				end

				owner:SetNWInt("sg_armband", item.armband)

				targetItem:UpdateMPF(owner, item.armband)
			end
			
			item:Remove()

			return
		end,
		OnCanRun = function(item, targetItem)
			return targetItem.isMPF
		end
	}
end

return ItemArmbandMPF
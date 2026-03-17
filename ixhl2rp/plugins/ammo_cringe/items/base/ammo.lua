local ItemAmmo = class("ItemAmmo")
implements("ItemStackable", "ItemAmmo")

ItemAmmo = ix.meta.ItemAmmo
ItemAmmo.contraband = true

function ItemAmmo:Init()
	ix.meta.ItemStackable.Init(self)

	self.category = "item.category.ammo"
end

return ItemAmmo
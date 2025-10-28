local Inventory = ix.util.Lib("Inventory", {
	stored = {}
})

ix.util.Include("ui/cl_inventory_item.lua")
ix.util.Include("ui/cl_inventory.lua")
ix.util.Include("ui/cl_inventory.player.lua")
ix.util.Include("ui/cl_containerview.lua")
ix.util.Include("ui/cl_equipment.lua")
ix.util.Include("sh_inventory.class.lua")

function Inventory:All() return self.stored end
function Inventory:Get(id) return self.stored[id] end

ix.util.Include("sh_storage.lua")
ix.util.Include("sh_player.lua")
ix.util.Include("sv_player.lua")

function GM:CanPlayerEquipItem(client, item)
	return item.invID == client:GetCharacter():GetInventory():GetID()
end

function GM:CanPlayerUnequipItem(client, item)
	return item.invID == client:GetCharacter():GetInventory():GetID()
end

if SERVER then
	function GM:OnItemTransferred(item, curInv, inventory)
		local bagInventory = item.GetInventory and item:GetInventory()

		if (!bagInventory) then
			return
		end

		-- we need to retain the receiver if the owner changed while viewing as storage
		if (inventory.storageInfo and isfunction(curInv.GetOwner)) then
			bagInventory:AddReceiver(curInv:GetOwner())
		end
	end

	function GM:InventoryItemRemoved(oldInventory, item, newInventory)
		if item.OnTransfer then
			item:OnTransfer(newInventory, oldInventory)
		end
	end

	function GM:CanTransferItem(item, newInventory, x, y, oldInventory)
		if !item.equip_inv and newInventory.isEquipment then
			return false, 'test'
		end
	end

	function GM:CanPlayerTakeItem(client, item)
		return item.CanTake and item:CanTake(client)
	end

	function GM:CanPlayerDropItem(client, item)
		return item.CanDrop and item:CanDrop(client)
	end
else
	hook.Add("CreateMenuButtons", "ixInventory", function(tabs)
		if (hook.Run("CanPlayerViewInventory") == false) then
			return
		end

		tabs["inv"] = {
			bDefault = true,
			Create = function(info, container)
				local x = container:Add("ui.equipment")
				x:Setup()
			end
		}
	end)

	hook.Add("PostRenderVGUI", "ixInvHelper", function()
		local pnl = ix.gui.inv1

		hook.Run("PostDrawInventory", pnl)
	end)
end
local Inventory = ix.util.Lib("Inventory", {
	stored = {},

	transferDelay = 2.5,
	transferDelayMin = 0.25,
	transferDelayMax = 15,

	pendingTransfers = {},
	nextTransferId = 0,

	_deferredRebuilds = {},
	_reservedTargets = {},
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
	function Inventory:ComputeTransferDelay(client, items, sourceItem)
		local delay = self.transferDelay

		if sourceItem then
			if sourceItem.transferDelay != nil then
				delay = tonumber(sourceItem.transferDelay) or delay
			else
				local sc = tonumber(sourceItem.transferDelayScale)

				if sc then
					delay = delay * sc
				end
			end
		end

		local hookDelay = hook.Run("СomputeItemTransferDelay", client, items, sourceItem, delay)

		if hookDelay != nil then
			delay = hookDelay or delay
		end

		return math.Clamp(delay, self.transferDelayMin, self.transferDelayMax)
	end

	function Inventory:CancelTransfer(transferId)
		local pending = self.pendingTransfers[transferId]

		if !pending then return end

		timer.Remove('ixPendingTransfer_' .. transferId)

		local targetInv = self:Get(pending.to_id)

		if targetInv then
			targetInv:UnreserveSlots(transferId)
		end

		for _, instanceId in ipairs(pending.items) do
			if self.pendingTransfers['item_' .. instanceId] == transferId then
				self.pendingTransfers['item_' .. instanceId] = nil
			end
		end

		if IsValid(pending.client) then
			net.Start('inventory.move.delayed.cancel')
				net.WriteUInt(transferId, 32)
			net.Send(pending.client)
		end

		self.pendingTransfers[transferId] = nil
	end

	function Inventory:CancelPlayerTransfers(client)
		for transferId, pending in pairs(self.pendingTransfers) do
			if transferId and istable(pending) and pending.client == client then
				self:CancelTransfer(transferId)
			end
		end
	end

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
	function Inventory:SafeRebuildPanel(panel)
		if !IsValid(panel) then return end

		if dragndrop.IsDragging() then
			self._deferredRebuilds = self._deferredRebuilds or {}
			self._deferredRebuilds[panel] = true

			if !self._deferredRebuildHooked then
				self._deferredRebuildHooked = true

				hook.Add("Think", "ixInvDeferredRebuild", function()
					if dragndrop.IsDragging() then return end

					local panels = self._deferredRebuilds or {}

					self._deferredRebuilds = nil
					self._deferredRebuildHooked = nil

					hook.Remove("Think", "ixInvDeferredRebuild")

					for pnl, _ in pairs(panels) do
						if IsValid(pnl) then
							pnl:Rebuild()
						end
					end
				end)
			end
		else
			panel:Rebuild()
		end
	end

	function Inventory:DebouncedRebuild(panel)
		if !IsValid(panel) then return end

		self._debouncedPanels = self._debouncedPanels or {}
		self._debouncedPanels[panel] = true

		if self._debounceRebuildScheduled then return end

		self._debounceRebuildScheduled = true

		timer.Simple(0, function()
			self._debounceRebuildScheduled = nil

			local panels = self._debouncedPanels or {}

			self._debouncedPanels = nil

			for pnl, _ in pairs(panels) do
				self:SafeRebuildPanel(pnl)
			end
		end)
	end

	function Inventory:ApplyReservedTargetHighlight(transferId, toInvId, tx, ty, tw, th)
		self._reservedTargets[transferId] = {inv = toInvId, x = tx, y = ty, w = tw, h = th}

		local inv = self:Get(toInvId)
		local pnl = inv and inv.panel

		if !IsValid(pnl) then return end

		for iy = ty, ty + th - 1 do
			for ix = tx, tx + tw - 1 do
				local sp = pnl.slot_panels[iy] and pnl.slot_panels[iy][ix]

				if IsValid(sp) then
					sp.reservedTransferTarget = true
					sp.reservedTransferId = transferId
				end
			end
		end
	end

	function Inventory:RemoveReservedTargetHighlight(transferId)
		local data = self._reservedTargets[transferId]

		if data then
			local inv = self:Get(data.inv)
			local pnl = inv and inv.panel

			if IsValid(pnl) then
				for iy = data.y, data.y + data.h - 1 do
					for ix = data.x, data.x + data.w - 1 do
						local sp = pnl.slot_panels[iy] and pnl.slot_panels[iy][ix]

						if IsValid(sp) then
							sp.reservedTransferTarget = nil
							sp.reservedTransferId = nil
						end
					end
				end
			end
		end

		self._reservedTargets[transferId] = nil
	end

	function Inventory:RestoreReservedTargetHighlights(panel)
		local inv = panel:GetInventory()

		if !inv then return end

		for tid, data in pairs(self._reservedTargets or {}) do
			if data.inv == inv.id then
				for iy = data.y, data.y + data.h - 1 do
					for ix = data.x, data.x + data.w - 1 do
						local sp = panel.slot_panels[iy] and panel.slot_panels[iy][ix]

						if IsValid(sp) then
							sp.reservedTransferTarget = true
							sp.reservedTransferId = tid
						end
					end
				end
			end
		end
	end

	function Inventory:ClientCanOptimisticMoveStack(inventory, items, target_x, target_y, was_rotated)
		if !inventory or !items or #items < 1 then return false end

		local first = ix.Item.instances[items[1]]

		if !first or first.inventory_id != inventory.id then return false end

		local w, h = inventory:GetItemSize(first)

		if was_rotated then
			w, h = h, w
		end

		if inventory.regions and !inventory:IsRectInRegion(target_x, target_y, w, h) then return false end

		if target_x < 1 or target_y < 1 or target_x + w - 1 > inventory:GetWidth() or target_y + h - 1 > inventory:GetHeight() then
			return false
		end

		return true
	end

	function Inventory:SetPendingFlags(transferId, state)
		if !state then
			self:RemoveReservedTargetHighlight(transferId)
		end
		
		local pending = self.pendingTransfers[transferId]

		if !pending then return end

		local srcInv = self:Get(pending.fromInvId)

		if srcInv and IsValid(srcInv.panel) then
			local sp = srcInv.panel.slot_panels
			local slotPanel = sp and sp[pending.sourceY] and sp[pending.sourceY][pending.sourceX]

			if IsValid(slotPanel) then
				slotPanel.pendingTransfer = state and transferId or nil
			end
		end
	end

	function Inventory:RestoreAllPendingFlags()
		for transferId, _ in pairs(self.pendingTransfers) do
			self:SetPendingFlags(transferId, true)
		end
	end

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
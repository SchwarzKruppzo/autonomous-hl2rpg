ix.dynloot = ix.dynloot or {}
ix.dynloot.context = ix.dynloot.context or {}

if (SERVER) then
	util.AddNetworkString("dynamic.loot.close")
	util.AddNetworkString("dynamic.loot.take")
	

	function ix.dynloot.InUse(inventoryID)
		local info = ix.dynloot.context[inventoryID]
		if info then
			for v, _ in pairs(info.receivers) do
				if IsValid(v) and v:IsPlayer() and v != info.entity then
					return true
				end
			end
		end

		return false
	end

	function ix.dynloot.InUseBy(inventoryID, client)
		local info = ix.dynloot.context[inventoryID]

		if info then
			for v, _ in pairs(info.receivers) do
				if IsValid(v) and v:IsPlayer() and v == client then
					return true
				end
			end
		end

		return false
	end

	function ix.dynloot.CreateContext(inventoryID, info)
		info = info or {}

		info.id = inventoryID
		info.name = info.name or "Storage"
		info.entity = assert(IsValid(info.entity), "expected valid entity in info table") and info.entity
		info.bMultipleUsers = info.bMultipleUsers == nil and false or info.bMultipleUsers
		info.searchTime = tonumber(info.searchTime) or 0
		info.searchText = info.searchText or "@storageSearching"
		info.data = info.data or {}
		info.Inventory = info.Inventory or function() return {} end
		info.receivers = info.receivers or {}

		ix.dynloot.context[inventoryID] = info
	end

	function ix.dynloot.RemoveContext(inventoryID)
		ix.dynloot.context[inventoryID] = nil
	end

	function ix.dynloot.Sync(client, inventoryID)
		local info = ix.dynloot.context[inventoryID]

		netstream.Start(client, "dynamic.loot.open", inventoryID, info.entity, info.name, info:Inventory())
	end

	function ix.dynloot.AddReceiver(client, inventoryID, bDontSync)
		local info = ix.dynloot.context[inventoryID]

		if info then
			info.receivers[client] = true

			client.ixOpenLoot = inventoryID

			if isfunction(info.OnPlayerOpen) then
				info.OnPlayerOpen(client)
			end

			if !bDontSync then
				ix.dynloot.Sync(client, inventoryID)
			end

			return true
		end

		return false
	end

	function ix.dynloot.RemoveReceiver(client, inventoryID, bDontRemove)
		local info = ix.dynloot.context[inventoryID]

		if info then
			info.receivers[client] = nil

			if isfunction(info.OnPlayerClose) then
				info.OnPlayerClose(client)
			end

			if !bDontRemove and !ix.dynloot.InUse(inventoryID) then
				ix.dynloot.RemoveContext(inventoryID)
			end

			client.ixOpenLoot = nil
			return true
		end

		return false
	end

	function ix.dynloot.Open(client, inventoryID, data)
		assert(IsValid(client) and client:IsPlayer(), "expected valid player")

		local info = ix.dynloot.context[inventoryID]

		if !info then
			data = data or {}
			ix.dynloot.CreateContext(inventoryID, data)
		end

		info = ix.dynloot.context[inventoryID]

		if info.bMultipleUsers or !ix.dynloot.InUse(inventoryID) then
			ix.dynloot.AddReceiver(client, inventoryID, true)
		else
			client:NotifyLocalized("storageInUse")
			return
		end

		if info.searchTime > 0 then
			client:SetAction(info.searchText, info.searchTime)
			client:DoStaredAction(info.entity, function()
				if IsValid(client) and IsValid(info.entity) and info then
					if isfunction(info.OnPlayerSync) then
						info.OnPlayerSync(client)
					end

					ix.dynloot.Sync(client, inventoryID)
				end
			end, info.searchTime, function()
				if IsValid(client) then
					ix.dynloot.RemoveReceiver(client, inventoryID)
					client:SetAction()
				end
			end)
		else
			ix.dynloot.Sync(client, inventory)
		end
	end

	function ix.dynloot.Close(inventoryID)
		local info = ix.dynloot.context[inventoryID]

		if info then
			local receivers = table.GetKeys(info.receivers)

			if #receivers > 0 then
				net.Start("dynamic.loot.close")
					net.WriteString(inventoryID)
				net.Send(receivers)
			end

			ix.dynloot.RemoveContext(inventory)
		end
	end

	net.Receive("dynamic.loot.close", function(length, client)
		local info = ix.dynloot.context[client.ixOpenLoot]

		if info then
			ix.dynloot.RemoveReceiver(client, client.ixOpenLoot)
		end
	end)

	net.Receive("dynamic.loot.take", function(length, client)
		local id = net.ReadUInt(32)
		local invID = net.ReadUInt(32)
		local x = net.ReadUInt(8)
		local y = net.ReadUInt(8)
		local rotated = net.ReadBool()

		local info = ix.dynloot.context[client.ixOpenLoot]

		if info then
			local uniqueID = info.entity.inventory[id]

			if uniqueID then
				local inventory = ix.Inventory:Get(invID)

				if inventory then
					local item = ix.Item:Instance(uniqueID)
					item.rotated = rotated

					local success = inventory:AddItem(item, x, y)

					if !success then
						success = inventory:AddItem(item)
					end

					if success then
						info.entity.inventory[id] = nil
						
						inventory:Sync()
					end
				end

				local receivers = table.GetKeys(info.receivers)
				if #receivers > 0 then
					netstream.Start(receivers, "dynamic.loot.sync", client.ixOpenLoot, info:Inventory())
				end
			end
		end
	end)
else
	net.Receive("dynamic.loot.close", function()
		if IsValid(ix.gui.openedLoot) then
			ix.gui.openedLoot:Remove()
		end
	end)

	netstream.Hook("dynamic.loot.open", function(inventoryID, entity, name, inventory)
		local x = vgui.Create("ui.dynamic.loot")
		x:Rebuild(inventory, name)
	end)

	netstream.Hook("dynamic.loot.sync", function(inventoryID, inventory)
		if IsValid(ix.gui.lootStorage) then
			ix.gui.lootStorage:Rebuild(inventory)
		end
	end)
end
local PLUGIN = PLUGIN

util.AddNetworkString("rp.search.request")
util.AddNetworkString("emote.container")

function PLUGIN:SendSearchPlayerRequest(player, target)
	if IsValid(target.WantToSearch) and (target.WantToSearchTime or 0) <= CurTime() then
		player:NotifyLocalized("psearchAlready")
		return
	end

	if !player.SearchCoolDown or !player.SearchCoolDown[target] or CurTime() > player.SearchCoolDown[target] then
		local ct = CurTime()

		player:NotifyLocalized("psearchPending")

		player.SearchCoolDown = player.SearchCoolDown or {}
		player.SearchCoolDown[target] = ct + 15

		target.WantToSearch = player
		target.WantToSearchTime = ct + 15

		net.Start("rp.search.request")
			net.WriteEntity(player)
		net.Send(target)
		return
	end

	player:NotifyLocalized("psearchWait")
end

function PLUGIN:InventoryItemRemoved(oldInventory, item, newInventory)
	if IsValid(oldInventory.owner) and oldInventory.owner:IsPlayer() and newInventory then
		if newInventory.instance_id then
			local item = ix.Item.instances[newInventory.instance_id]
			if item and item.inventory_id then
				newInventory = ix.Inventory:Get(item.inventory_id)
			end
		end
		
		local owner = newInventory.owner
		if IsValid(owner) and owner:IsPlayer() and owner.ixOpenStorage and owner != oldInventory.owner then
			net.Start("emote.container")
				net.WriteEntity(owner)
				net.WriteString(item.uniqueID)
			net.SendChatType(owner, "me")
		end
	end
end

net.Receive("rp.search.request", function(len, client)
	if client.WantToSearchTime and CurTime() >= client.WantToSearchTime then
		client.WantToSearchTime = nil
		client.WantToSearch = nil
		return
	end

	local state = net.ReadBool()
	
	if IsValid(client.WantToSearch) then
		if !state then
			client:NotifyLocalized("psearchDecline")
			client.WantToSearch:NotifyLocalized("psearchDecline2")
		else
			client:NotifyLocalized("psearchAccept")
			Schema:SearchPlayer(client.WantToSearch, client)
		end

		client.WantToSearchTime = nil
		client.WantToSearch = nil
	end
end)
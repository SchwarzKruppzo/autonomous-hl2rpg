util.AddNetworkString("MenuItemSpawn")
util.AddNetworkString("MenuItemGive")

net.Receive("MenuItemSpawn", function(len, player)
	local hasCustomAccess = CAMI.PlayerHasAccess(player, "Helix - Create Custom Items", nil)
	local hasFlag = player:GetCharacter():HasFlags("G")

	if !hasCustomAccess and !hasFlag then
		return
	end

	local data = net.ReadString()
	local isCustom = net.ReadBool()

	if #data <= 0 then return end

	local uniqueID = data:lower()
	local canSpawn = true
	if !isCustom then
		if !ix.Item:Get(uniqueID) then
			for k, v in SortedPairs(ix.Item:All()) do
				if ix.util.StringMatches(v.name, uniqueID) then
					uniqueID = k
					canSpawn = v.NoSpawn and false or true
					break
				end
			end
		end
	end

	local vStart = player:GetShootPos()
	local vForward = player:GetAimVector()
	local trace = {}
	trace.start = vStart
	trace.endpos = vStart + (vForward * 2048)
	trace.filter = player

	local tr = util.TraceLine(trace)
	local ang = player:EyeAngles()
	ang.yaw = ang.yaw + 180
	ang.roll = 0
	ang.pitch = 0

	local entity
	if !isCustom then
		if !hasFlag then
			return
		end

		if !canSpawn then
			return
		end
		
		local new_item = ix.Item:Instance(uniqueID)
		entity = ix.Item:Spawn(tr.HitPos, ang, new_item)

		ix.log.AddRaw(string.format("%s has [G] spawned item %s (#%s).", player:Name(), new_item:GetName(), new_item.id))
	else
		if !hasCustomAccess then
			return
		end

		local info = ix.CustomItem.stored[uniqueID]

		info.custom = info.custom or "customize_base"
		if info.custom then
			local new_item = ix.Item:Instance(info.custom, {checksum = uniqueID})
			new_item:SetData("checksum", uniqueID)

			entity = ix.Item:Spawn(tr.HitPos, ang, new_item)
		end
	end

	if IsValid(entity) then
		player:NotifyLocalized("itemCreated")
	end
end)

net.Receive("MenuItemGive", function(len, player)
	local hasCustomAccess = CAMI.PlayerHasAccess(player, "Helix - Create Custom Items", nil)
	local hasFlag = player:GetCharacter():HasFlags("G")

	if !hasCustomAccess and !hasFlag then
		return
	end

	local data = net.ReadString()
	local isCustom = net.ReadBool()

	if #data <= 0 then return end

	local uniqueID = data:lower()
	local canSpawn = true
	if !isCustom then
		if !ix.Item:Get(uniqueID) then
			for k, v in SortedPairs(ix.Item:All()) do
				if ix.util.StringMatches(v.name, uniqueID) then
					uniqueID = k
					canSpawn = v.NoSpawn and false or true

					break
				end
			end
		end
	end

	local bSuccess, error

	if !isCustom then
		if !hasFlag then
			return
		end

		if !canSpawn then
			return
		end

		local new_item = ix.Item:Instance(uniqueID)
		bSuccess, error = player:AddItem(new_item)

		ix.log.AddRaw(string.format("%s has [G] spawned item %s (#%s).", player:Name(), new_item:GetName(), new_item.id))
	else
		if !hasCustomAccess then
			return
		end

		local info = ix.CustomItem.stored[uniqueID]

		info.custom = info.custom or "customize_base"

		if info.custom then
			local new_item = ix.Item:Instance(info.custom, {checksum = uniqueID})
			new_item:SetData("checksum", uniqueID)

			bSuccesss, error = player:AddItem(new_item)
		end
	end

	if (bSuccess) then
		player:NotifyLocalized("itemCreated")
	else
		player:NotifyLocalized(tostring(error))
	end
end)
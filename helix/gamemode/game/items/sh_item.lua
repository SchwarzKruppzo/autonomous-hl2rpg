local Item = ix.util.Lib("Item", {
	stored = {},
	base = {},
	instances = {},
	entities = {},
	instance_count = 0,
	var_max = 0,
	var_max_bits = 1
})

Item.vars = {}
Item.vars_id = {}
Item.items_to_save = {}
Item.items_to_savedata = {}

ix.util.Include("sh_item.class.lua")
ix.util.Include("sh_preview.lua")
ix.util.Include("cl_spawn.items.lua")
ix.util.Include("sv_spawn.items.lua")

ix.flag.Add("G", "Access to item spawn.")

function Item:All() return self.stored end
function Item:Instances() return self.instances end
function Item:InstanceCount() return self.instance_count end
function Item:Ents() return self.entities end
function Item:Get(uniqueID) return self.stored[uniqueID] end

function Item:Register(uniqueID, item)
	if !item then return end
	
	if !uniqueID then
		ErrorNoHalt("[Helix] Attempt to register an item without a valid ID!\n")
		return
	end

	local max = table.Count(item.functions)

	item.functions_id = {}
	item.functions_bits = net.ChooseOptimalBits(max)

	local i = 0
	for key, action in pairs(item.functions) do
		i = i + 1

		action.index = i
		item.functions_id[i] = key
	end

	if istable(item.combine) then
		local max = table.Count(item.combine)

		item.combine_id = {}
		item.combine_bits = net.ChooseOptimalBits(max)

		local i = 0
		for key, action in pairs(item.combine) do
			i = i + 1

			action.index = i
			item.combine_id[i] = key
		end
	end

	self.stored[uniqueID] = item
end

function Item:Load(path, uniqueID, baseID)
	local prefix = uniqueID:sub(1, 3)

	if prefix == "sh_" then
		uniqueID = uniqueID:sub(4)
	end
	
	if uniqueID:sub(1, 1) == "!" then
		ix.util.Include(path, "shared")
		return
	end
	
	uniqueID = uniqueID:sub(1, #uniqueID - 4)

	ITEM = ix.meta.Item:New(uniqueID)

	if baseID then
		ITEM:Base(baseID)
	end

	ix.util.Include(path, "shared")

	ITEM:Register()
	ITEM = nil
end

function Item:LoadBase(path, uniqueID)
	uniqueID = uniqueID:sub(1, #uniqueID - 4)

	local ITEM = ix.util.Include(path, "shared")
	ITEM.uniqueID = uniqueID

	if !ITEM then
		ErrorNoHalt("[Helix] Attempt to register an invalid base! (" .. (uniqueID or "nil") .. ")\n")
		return
	end

	self.base[uniqueID] = ITEM
end

function Item:LoadFromDir(directory)
	local files, folders = file.Find(directory.."/base/*", "LUA")

	for _, v in ipairs(files) do
		self:LoadBase(directory.."/base/"..v, v)
	end

	files, folders = file.Find(directory.."/*", "LUA")

	for _, v in ipairs(folders) do
		if v == "base" then
			continue
		end

		for _, v2 in ipairs(file.Find(directory.."/"..v.."/*.lua", "LUA")) do
			self:Load(directory.."/"..v .. "/".. v2, v2, v)
		end
	end

	for _, v in ipairs(files) do
		self:Load(directory.."/"..v, v)
	end
end

function Item:New(uniqueID, forcedID)
	if self.instances[forcedID] and self.instances[forcedID].uniqueID == uniqueID then
		return self.instances[forcedID]
	end

	local stockItem = self.stored[uniqueID]

	if stockItem then
		//local item = table.Copy(stockItem)
		//item.id = forcedID
		local item = setmetatable({id = forcedID, data = {}, items = {}}, {
			__index = stockItem,
			__eq = stockItem.__eq,
			__tostring = stockItem.__tostring
		})

		self.instances[forcedID] = item

		return item
	else
		ErrorNoHalt("[Helix] Attempt to index unknown item '"..uniqueID.."'\n")
	end
end

if SERVER then
	util.AddNetworkString("item.sync")
	util.AddNetworkString("item.data")
	util.AddNetworkString("item.action")
	util.AddNetworkString("item.entity.action")
	util.AddNetworkString('item.combine')
	util.AddNetworkString('item.drop')
	util.AddNetworkString('item.legacy.stack.combine')
	util.AddNetworkString('item.legacy.stack.create')


	function Item:SaveAll()
		local count = 0
		for itemID, _ in pairs(self.items_to_save) do
			if self.instances[itemID] then
				self.instances[itemID]:Save()
			end
			
			count = count + 1
		end

		self.items_to_save = {}

		print("[Helix] Saved "..count.." items!")
	end

	function Item:SaveData()
		local count = 0
		for itemID, _ in pairs(self.items_to_savedata) do
			if self.instances[itemID] then
				self.instances[itemID]:SaveData()
			end
			
			count = count + 1
		end

		self.items_to_savedata = {}
	end

	local function threadsave()
		ix.Item:SaveData()
	end

	function Item:Async_SaveData()
		local handle = coroutine.create(threadsave)
    	coroutine.resume(handle)
	end
	
	function Item:SyncAll(client)
		for itemID, entity in pairs(self.entities) do
			if !IsValid(entity) then continue end
			
			self.instances[itemID]:Sync(client)
		end
	end

	function Item:GenerateID()
		self.instance_count = self.instance_count + 1

		return self.instance_count
	end

	function Item:LoadInstanceByID(id, itemCallback, callback)
		if !isnumber(id) and !istable(id) then
			return
		end

		if istable(id) then
			if table.IsEmpty(id) then
				return
			end
		end
		
		local query = mysql:Select("ix_items")
			query:Select("item_id")
			query:Select("unique_id")
			query:Select("data")
			query:Select("character_id")
			query:Select("player_id")
			query:Select("x")
			query:Select("y")
			query:Select("rotated")
			query:Select("inventory_type")
			query:Select("items")
			query:WhereIn("item_id", id)
			query:Callback(function(result)
				if istable(result) and #result > 0 then
					for _, item in ipairs(result) do
						if !ix.Item:Get(item.unique_id) then
							continue
						end

						local x, y = tonumber(item.x), tonumber(item.y)
						local itemID = tonumber(item.item_id)
						local data = util.JSONToTable(item.data or "[]")
						local characterID, playerID = tonumber(item.character_id), tostring(item.player_id)

						local item2 = self:New(item.unique_id, itemID)//, characterID, (playerID == "" or playerID == "NULL") and nil or playerID)

						if item2 then
							if item.items then
								item2.items = util.JSONToTable(item.items or "[]")
							end

							if item.inventory_type then
								item2.inventory_type = item.inventory_type
							end

							if characterID then
								item2.character_id = characterID
							end

							item2.data = istable(data) and table.Copy(data) or {}
							item2.x = x
							item2.y = y
							item2.rotated = tobool(item.rotated)

							if item2.OnInstanced then
								item2:OnInstanced()
							end

							if itemCallback then
								itemCallback(item2)
							end

							item2.mark_as_save = false
						end
					end
				end

				if callback then
					callback()
				end
			end)
		query:Execute()
	end

	function Item:LoadToInventory(id, inventory, itemCallback, callback)
		if !id then
			return
		end
		
		self:LoadInstanceByID(id, function(item)
			if item.inventory_id then
				return
			end

			if !item.inventory_type or (inventory.type != item.inventory_type) then
				return
			end

			if itemCallback then
				itemCallback(item, inventory)
			end
			
			inventory:AddItem(item, item.x, item.y, nil, true)
		end, callback)
	end

	function Item:LoadInstanceCount()
		local query = mysql:Select("ix_items")
			query:Select("item_id")
			query:Callback(function(result)
				if istable(result) and #result > 0 then
					local count = 0

					for k, v in ipairs(result) do
						count = math.max(count, v.item_id)
					end

					self.instance_count = count
				end
			end)
		query:Execute()
	end

	function Item:Instance(uniqueID, itemData, forcedID, characterID, playerID)
		if !uniqueID or self.stored[uniqueID] then
			local itemID = forcedID or self:GenerateID()
			local item = self:New(uniqueID, itemID)

			if item then
				item.data = istable(itemData) and table.Copy(itemData) or {}
				item.characterID = characterID or 0
				item.playerID = playerID or 0
				item.mark_as_save = true
				
				if item.OnInstanced then
					item:OnInstanced(true)
				end

				local query = mysql:InsertReplace("ix_items")
					query:Insert("item_id", item.id)
					query:Insert("unique_id", item.uniqueID)
					query:Insert("data", util.TableToJSON(item.data))
					query:Insert("rotated", item.rotated)
					query:Insert("x", tonumber(item.x))
					query:Insert("y", tonumber(item.y))
					query:Insert("character_id", tonumber(item.characterID))
					query:Insert("player_id", tonumber(item.playerID))
				query:Execute()

				return item
			end
		else
			ErrorNoHalt("[Helix] Attempt to instance an invalid item! (" .. (uniqueID or "nil") .. ")\n")
		end
	end

	function Item:Spawn(position, angles, item)
		if item and item.id > 0 then
			local client

			local entity = ents.Create("ix_item")
			entity:SetAngles(angles or Angle(0, 0, 0))
			entity:SetItem(item.id)

			if type(position) == "Player" then
				client = position
				position = position:GetItemDropPos(entity)
			end

			entity:SetPos(position)
			entity:Spawn()

			item:SetEntity(entity)
			item:Sync()

			if IsValid(client) then
				entity.ixSteamID = client:SteamID()
				entity.ixCharID = client:GetCharacter():GetID()
				entity:SetNetVar("owner", entity.ixCharID)
			end

			self.entities[item.id] = entity

			hook.Run("OnItemSpawned", entity)
			return entity, item
		end
	end

	function Item:DropItem(client, instance_ids, pos, ang)
		if isnumber(instance_ids) then
			instance_ids = { instance_ids }
		end

		local first_item = self.instances[instance_ids[1]]
		local inventory = ix.Inventory:Get(first_item.inventory_id)

		for k, v in ipairs(instance_ids) do
			local item = self.instances[v]

			if hook.Run('CanPlayerDropItem', client, item) == false then return end

			inventory:TakeItemTable(item)

			local result
			if item.OnDrop then
				result = item:OnDrop(client, inventory)
			end
			
			if result != true then
				self:Spawn(pos and pos or client, ang, item)
			end
		end

		inventory:Sync()

		//Item.async_save_entities()

		return true
	end

	function Item:PerformInventoryAction(client, item, inventory_id, action_id, data, item_count)
		local character = client:GetCharacter()

		if !character then
			return
		end

		local inventory = ix.Inventory:Get(inventory_id)

		if !inventory then
			return
		end
		
		//if hook.Run("CanPlayerInteractItem", client, action, item, data) == false then
		//	return
		//end

		if !inventory:OnCheckAccess(client) then
			return
		end

		item.player = client

		if item.inventory_id != inventory_id then
			return
		end

		local action_key = isnumber(action_id) and item.functions_id[action_id] or action_id
		local action = item.functions[action_key]

		/*
		if (!item.bAllowMultiCharacterInteraction and IsValid(client) and client:GetCharacter()) then
			local itemPlayerID = item:GetPlayerID()
			local itemCharacterID = item:GetCharacterID()
			local playerID = client:SteamID64()
			local characterID = client:GetCharacter():GetID()

			if (itemPlayerID and itemCharacterID and itemPlayerID == playerID and itemCharacterID != characterID) then
				client:NotifyLocalized("itemOwned")

				item.player = nil
				item.entity = nil
				return
			end
		end*/

		if action then
			local items = {item.id}

			if item_count > 1 then
				local slot = inventory:GetSlot(item.x, item.y)

				items = {}

				for i = 1, item_count do
					table.insert(items, slot[i])
				end
			end

			if action.OnCanRun and action.OnCanRun(item, items, data) == false then
				item.player = nil

				return
			end

			hook.Run("PlayerInteractItem", client, action.name or action_key, item)

			local result = action.OnRun(item, items, data)

			if action.Sound then
				item.player:EmitSound(action.Sound, 65, 100, 1)
			end

			item.player = nil

			return result
		end
	end

	function Item:PerformItemEntityAction(client, item, entity, action_id)
		print("Item::EntityAction", client, item, entity, action_id)

		local character = client:GetCharacter()

		if !character then
			return
		end

		if item.entity != entity then
			return
		end

		//if hook.Run("CanPlayerInteractItem", client, action, item, data) == false then
		//	return
		//end

		item.player = client

		if entity:GetPos():Distance(client:GetPos()) > 96 then
			return
		end

		local action_key = isnumber(action_id) and item.functions_id[action_id] or action_id
		local action = item.functions[action_key]

		/*
		if (!item.bAllowMultiCharacterInteraction and IsValid(client) and client:GetCharacter()) then
			local itemPlayerID = item:GetPlayerID()
			local itemCharacterID = item:GetCharacterID()
			local playerID = client:SteamID64()
			local characterID = client:GetCharacter():GetID()

			if (itemPlayerID and itemCharacterID and itemPlayerID == playerID and itemCharacterID != characterID) then
				client:NotifyLocalized("itemOwned")

				item.player = nil
				item.entity = nil
				return
			end
		end*/

		if action then
			if action.OnCanRun and action.OnCanRun(item, data) == false then
				item.player = nil

				return
			end

			hook.Run("PlayerInteractItem", client, action.name or action_key, entity)

			local result = action.OnRun(item, data)

			if action.Sound then
				entity:EmitSound(action.Sound, 65, 100, 1)
			end

			item.player = nil

			return result
		end
	end

	function Item:PerformInventoryCombineAction(client, item, targetItem, action_id, data, item_count)
		print("Item::CombineAction", client, item, targetItem, action_id)

		local character = client:GetCharacter()

		if !character then
			return
		end

		if item.uniqueID == targetItem.uniqueID and item.stackable then
			return
		end
		
		if !item.inventory_id or !targetItem.inventory_id then
			return
		end
		
		local inventory = ix.Inventory:Get(item.inventory_id)
		local targetInventory = ix.Inventory:Get(targetItem.inventory_id)

		//if hook.Run("CanPlayerInteractItem", client, action, item, data) == false then
		//	return
		//end

		if !inventory:OnCheckAccess(client) then
			return
		end

		item.player = client
		targetItem.player = client

		local action_key = isnumber(action_id) and item.combine_id[action_id] or action_id
		local action = item.combine[action_key]

		/*
		if (!item.bAllowMultiCharacterInteraction and IsValid(client) and client:GetCharacter()) then
			local itemPlayerID = item:GetPlayerID()
			local itemCharacterID = item:GetCharacterID()
			local playerID = client:SteamID64()
			local characterID = client:GetCharacter():GetID()

			if (itemPlayerID and itemCharacterID and itemPlayerID == playerID and itemCharacterID != characterID) then
				client:NotifyLocalized("itemOwned")

				item.player = nil
				item.entity = nil
				return
			end
		end*/

		if action then
			local items = {item.id}

			if item_count > 1 then
				local slot = inventory:GetSlot(item.x, item.y)

				items = {}

				for i = 1, item_count do
					table.insert(items, slot[i])
				end
			end

			if action.OnCanRun and action.OnCanRun(item, targetItem, items, data) == false then
				item.player = nil
				targetItem.player = nil

				return
			end

			hook.Run("PlayerInteractItem", client, action.name or action_key, item)

			local result = action.OnRun(item, targetItem, items, data)

			if action.Sound then
				item.player:EmitSound(action.Sound, 65, 100, 1)
			end

			item.player = nil
			targetItem.player = nil

			return result
		end
	end

	net.Receive('item.action', function(len, client)
		local item = Item.instances[net.ReadUInt(32)]

		if item then
			ix.Item:PerformInventoryAction(client, item, net.ReadUInt(32), net.ReadUInt(item.functions_bits), net.ReadTable(), (net.ReadBool() == true) and net.ReadUInt(32) or 0)
		end
	end)

	net.Receive('item.combine', function(len, client)
		local item = Item.instances[net.ReadUInt(32)]
		local targetItem = Item.instances[net.ReadUInt(32)]

		if item and targetItem then
			ix.Item:PerformInventoryCombineAction(client, item, targetItem, net.ReadUInt(item.combine_bits), net.ReadTable(), (net.ReadBool() == true) and net.ReadUInt(32) or 0)
		end
	end)

	net.Receive('item.drop', function(len, client)
		local item = ix.Item.instances[net.ReadUInt(32)]
		local normal = net.ReadVector()
		local ang = net.ReadAngle()

		local character = client:GetCharacter()

		if !character then
			return
		end

		local inventory = ix.Inventory:Get(item.inventory_id)

		if !inventory or !inventory:OnCheckAccess(client) then
			return
		end

		item.player = client

		local data = {}
		data.start = client:GetShootPos()
		data.endpos = data.start + normal * 86
		data.filter = client

		local trace = util.TraceLine(data)

		ix.Item:DropItem(client, item.id, trace.HitPos, ang)
		
		timer.Simple(0, function()
			local vFlushPoint = item.entity:NearestPoint(trace.HitPos - (trace.HitNormal * 512))
			vFlushPoint = item.entity:GetPos() - vFlushPoint
			vFlushPoint = trace.HitPos + vFlushPoint

			item.entity:SetPos(vFlushPoint)
		end)

		item.player = nil
	end)

	net.Receive('item.legacy.stack.combine', function(len, client)
		local item = Item.instances[net.ReadUInt(32)]
		local targetItem = Item.instances[net.ReadUInt(32)]

		if !item or !targetItem then
			return
		end
		
		local isSplit = net.ReadBool()
		local splitCount = 0
		local sentStacks = 0

		local max = targetItem.max_stack
		local value = item:GetValue()
		local targetValue = targetItem:GetValue()

		if isSplit then
			splitCount = net.ReadUInt(32)

			splitCount = math.Clamp(splitCount, 0, max)

			if splitCount == 0 then
				splitCount = value * 0.5
			end

			for i = 1, splitCount do
				if (value - i) < 0 then break end
				if (targetValue + i) > max then break end
				
				sentStacks = sentStacks + 1
			end

			sentStacks = math.max(math.min(sentStacks, value), 1)
		else
			sentStacks = value
		end

		if (targetValue + sentStacks) > max then
			sentStacks = max - targetValue
		end

		targetItem:SetData("stack", targetItem:GetValue() + sentStacks)
		item:SetData("stack", item:GetValue() - sentStacks)
		
		if item:GetValue() <= 0 then
			item:Remove()
		end
	end)

	net.Receive('item.legacy.stack.create', function(len, client)
		local from_id = net.ReadUInt(32)
		local to_id = net.ReadUInt(32)
		local x = net.ReadUInt(8)
		local y = net.ReadUInt(8)
		local target_x = net.ReadUInt(8)
		local target_y = net.ReadUInt(8)
		local isSplit = net.ReadBool()
		local splitCount = net.ReadUInt(32)
		local was_rotated = net.ReadBool()

		local old_inventory = ix.Inventory:Get(from_id)
		local inventory = ix.Inventory:Get(to_id)

		if !old_inventory or !inventory then
			return
		end

		if !inventory:OnCheckAccess(client) or !old_inventory:OnCheckAccess(client) then
			return
		end

		local slot = old_inventory:GetSlot(x, y)

		if !istable(slot) or table.IsEmpty(slot) then
			return
		end

		local item = ix.Item.instances[slot[1]]

		local newItem = ix.Item:Instance(item.uniqueID)
		local success, error_text

		if to_id == from_id then
			success, error_text = inventory:AddItem(newItem, target_x, target_y)
			inventory:Sync()
		else
			success, error_text = old_inventory:AddItem(newItem, target_x, target_y)
			old_inventory:Sync()
		end

		if success then
			local sentStacks = 0

			local max = item.max_stack
			local value = item:GetValue()

			if isSplit then
				splitCount = math.Clamp(splitCount, 0, max)

				if splitCount == 0 then
					splitCount = value * 0.5
				end
				
				for i = 1, splitCount do
					if (value - i) < 0 then break end
					
					sentStacks = sentStacks + 1
				end

				sentStacks = math.max(math.min(sentStacks, value), 1)
			end

			item:SetData("stack", item:GetValue() - sentStacks)
			newItem:SetData("stack", sentStacks)

			if item:GetValue() <= 0 then
				item:Remove()
			end
		end
	end)
else
	local function InventoryAction(item, inventory_id, action_index, items, data)
		net.Start('item.action')
			net.WriteUInt(item.id, 32)
			net.WriteUInt(inventory_id, 32)
			net.WriteUInt(action_index, item.functions_bits)
			net.WriteTable(data or {})

			local split = #items > 1

			net.WriteBool(split)

			if split then
				net.WriteUInt(#items, 32)
			end
		net.SendToServer()
	end

	local function InventoryCombineAction(item, targetItem, action_index, items, data)
		net.Start('item.combine')
			net.WriteUInt(item.id, 32)
			net.WriteUInt(targetItem.id, 32)
			net.WriteUInt(action_index, item.combine_bits)
			net.WriteTable(data or {})

			local split = #items > 1

			net.WriteBool(split)

			if split then
				net.WriteUInt(#items, 32)
			end
		net.SendToServer()
	end

	function Item:OpenItemMenu(items, inventory_id, isSplit, splitCount)
		local new_items = table.Copy(items)
		local item = self.instances[items[#items]]

		if input.IsKeyDown(KEY_LCONTROL) then
			new_items = {}

			for i = 1, #items * 0.5 do
				table.insert(new_items, items[i])
			end
		elseif input.IsKeyDown(KEY_LSHIFT) then
			new_items = {items[#items]}
		end
		
		if !item then
			return
		end

		item.player = LocalPlayer()

		if hook.Run('CanItemMenuOpen', item) == false then return end

		local menu = ix.SimpleMenu()

		for k, v in SortedPairs(item.functions) do
			if k == 'drop' or (v.OnCanRun and v.OnCanRun(item, new_items) == false) then
				continue
			end

			-- is Multi-Option Function
			if v.isMulti then
				local subMenu, subMenuOption = menu:AddSubMenu(L(v.name or k), function()
					item.player = LocalPlayer()
						local send = true

						if v.OnClick then
							send = v.OnClick(item, new_items)
						end

						if v.sound then
							surface.PlaySound(v.sound)
						end

						if send != false then
							InventoryAction(item, inventory_id, v.index, new_items)
						end
					item.player = nil
				end)
				subMenuOption:SetImage(v.icon or "icon16/brick.png")

				if v.multiOptions then
					local options = isfunction(v.multiOptions) and v.multiOptions(item, new_items, LocalPlayer()) or v.multiOptions

					for _, sub in pairs(options) do
						subMenu:AddOption(L(sub.name or "subOption"), function()
							item.player = LocalPlayer()
								local send = true

								if sub.OnClick then
									send = sub.OnClick(item, new_items)
								end

								if sub.sound then
									surface.PlaySound(sub.sound)
								end

								if send != false then
									InventoryAction(item, inventory_id, v.index, new_items, sub.data)
								end
							item.player = nil
						end)
					end
				end
			else
				menu:AddOption(L(v.name or k), function()
					item.player = LocalPlayer()
						local send = true

						if v.OnClick then
							send = v.OnClick(item, new_items)
						end

						if v.sound then
							surface.PlaySound(v.sound)
						end

						if send != false then
							InventoryAction(item, inventory_id, v.index, new_items)
						end
					item.player = nil
				end):SetImage(v.icon or "icon16/brick.png")
			end
		end

		-- we want drop to show up as the last option
		local info = item.functions.drop

		if info and info.OnCanRun and info.OnCanRun(item, new_items) != false then
			menu:AddOption(L(info.name or "drop"), function()
				item.player = LocalPlayer()
					local send = true

					if info.OnClick then
						send = info.OnClick(item, new_items)
					end

					if info.sound then
						surface.PlaySound(info.sound)
					end

					if send != false then
						InventoryAction(item, inventory_id, info.index, new_items)
					end
				item.player = nil
			end):SetImage(info.icon or "icon16/brick.png")
		end

		item.player = nil

		menu:Open()
	end

	function Item:OpenItemMenuCombine(item, targetItem, isSplit, splitCount)
		if !targetItem then
			return
		end

		if item.uniqueID == targetItem.uniqueID then
			if item.stackable then
				return
			elseif item.stackable_legacy then
				net.Start('item.legacy.stack.combine')
					net.WriteUInt(item.id, 32)
					net.WriteUInt(targetItem.id, 32)
					net.WriteBool(isSplit)
					if isSplit then
						net.WriteUInt(splitCount, 32)
					end
				net.SendToServer()
				return true
			end
		end

		if !istable(item.combine) then
			return
		end
		
		targetItem.player = LocalPlayer()
		item.player = LocalPlayer()

		local items = {item.id}

		if isSplit then
			local inventory = ix.Inventory:Get(item.inventory_id)

			if inventory then
				local slot = inventory:GetSlot(item.x, item.y)

				items = {}

				for i = 1, (splitCount != 0 and splitCount or (#slot * 0.5)) do
					table.insert(items, slot[i])
				end
			end
		end

		local menu = ix.SimpleMenu()

		for k, v in SortedPairs(item.combine) do
			if v.OnCanRun and v.OnCanRun(item, targetItem, items) == false then
				continue
			end

			-- is Multi-Option Function
			if v.isMulti then
				local subMenu, subMenuOption = menu:AddSubMenu(L(v.name or k), function()
					targetItem.player = LocalPlayer()
					item.player = LocalPlayer()
						local send = true

						if v.OnClick then
							send = v.OnClick(item, targetItem, items)
						end

						if v.sound then
							surface.PlaySound(v.sound)
						end

						if send != false then
							InventoryCombineAction(item, targetItem, v.index, items)
						end
					targetItem.player = nil
					item.player = nil
				end)
				subMenuOption:SetImage(v.icon or "icon16/brick.png")

				if v.multiOptions then
					local options = isfunction(v.multiOptions) and v.multiOptions(item, targetItem, items, LocalPlayer()) or v.multiOptions

					for _, sub in pairs(options) do
						subMenu:AddOption(L(sub.name or "subOption"), function()
							itemTable.player = LocalPlayer()
							item.player = LocalPlayer()
								local send = true

								if v.OnClick then
									send = v.OnClick(item, targetItem, items)
								end

								if v.sound then
									surface.PlaySound(v.sound)
								end

								if send != false then
									InventoryCombineAction(item, targetItem, v.index, items, sub.data)
								end
							itemTable.player = nil
							item.player = nil
						end)
					end
				end
			else
				menu:AddOption(L(v.name or k), function()
					targetItem.player = LocalPlayer()
					item.player = LocalPlayer()
						local send = true

						if v.OnClick then
							send = v.OnClick(item, targetItem, items)
						end

						if v.sound then
							surface.PlaySound(v.sound)
						end

						if send != false then
							InventoryCombineAction(item, targetItem, v.index, items)
						end
					targetItem.player = nil
					item.player = nil
				end):SetImage(v.icon or "icon16/brick.png")
			end
		end

		menu:Open()

		targetItem.player = nil
		item.player = nil

		return true
	end
end
		
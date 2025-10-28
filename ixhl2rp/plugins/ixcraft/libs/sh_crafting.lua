local Craft = ix.util.Lib("Craft", {
	recipes = {},
	stations = {},
})

local function ValidateItem(recipe, entry)
	if isstring(entry) then
		if !ix.Item.stored[entry] then
			ErrorNoHalt("[ixcraft] Attempt to index unknown item '"..entry.."' in recipe '"..recipe.."'\n")
		end
	elseif istable(entry) then
		for key, _ in pairs(entry) do
			ValidateItem(recipe, key)
		end
	end
end

function Craft:ValidateRecipe(recipe, data)
	if data.requirements then
		ValidateItem(recipe, data.requirements)
	end

	if data.results then
		ValidateItem(recipe, data.results)
	end

	if data.any then
		ValidateItem(recipe, data.any)
	end

	if data.tools then
		for _, key in pairs(data.tools) do
			ValidateItem(recipe, key)
		end
	end
end

function Craft:LoadFromDir(directory, pathType, category)
	for _, v in ipairs(file.Find(directory.."/*.lua", "LUA")) do
		local uniqueID = v:sub(1, #v - 4)

		if pathType == "recipe" then
			RECIPE = ix.meta.CraftRecipe:New(uniqueID)
				RECIPE.mainCategory = category

				ix.util.Include(directory.."/"..v, "shared")

				if !RECIPE.disabled then
					--self:ValidateRecipe(uniqueID, RECIPE)

					self.recipes[uniqueID] = RECIPE
				end
			RECIPE = nil
		elseif pathType == "station" then
			STATION = ix.meta.CraftStation:New(uniqueID)

				ix.util.Include(directory.."/"..v, "shared")

				//if (!scripted_ents.Get("ix_station_"..niceName)) then
					local STATION_ENT = scripted_ents.Get("ix_station")
					STATION_ENT.PrintName = STATION.name
					STATION_ENT.uniqueID = uniqueID
					STATION_ENT.Spawnable = true
					STATION_ENT.AdminOnly = true
					STATION_ENT.Tags = STATION_ENT.tags
					scripted_ents.Register(STATION_ENT, "ix_station_"..uniqueID)
				//end

				self.stations[uniqueID] = STATION
			STATION = nil
		end
	end
end

if SERVER then
	util.AddNetworkString("ixCraftRecipe")

	function Craft:AttemptCraft(recipe, client)
		local character = client:GetCharacter()

		if !character then
			return false
		end
		
		if recipe.skill and istable(recipe.skill) then
			local skill = recipe.skill[1]
			local skillTable = ix.skills.list[skill]

			if skillTable then
				local needed = tonumber(recipe.skill[2])
				local ourSkill = character:GetSkillModified(skill)

				if ourSkill < needed then
					return false, string.format("Необходим навык %s %s!",  L(skillTable.name, client), needed)
				end
			end
		end

		if recipe.station then
			local hasStation

			if istable(recipe.station) then
				for k, v in ipairs(recipe.station) do
					if IsValid(client.ixStation) and client.ixStation:GetStationTable().uniqueID == v then
						hasStation = true
						break
					end
				end

				if !hasStation then
					return false, "Необходимо использовать рабочее место!"
				end
			else
				local stationInfo = self.stations[recipe.station]
				
				if IsValid(client.ixStation) and client.ixStation:GetStationTable().uniqueID == recipe.station then
					hasStation = true
				end

				if !hasStation then
					return false, "Необходимо использовать "..stationInfo.name.."!"
				end
			end
		end

		local hasItems = true
		local hasTools = true

		if recipe.tools then
			for _, uniqueID in pairs(recipe.tools or {}) do
				if !client:HasItem(uniqueID) then
					hasTools = false
					break
				end
			end
		end

		if !hasTools then
			return false, "У вас нет необходимых инструментов!"
		end

		if recipe.isBreakdown then
			local hasInCraft

			if IsValid(client.ixStation) then
				hasInCraft = client.ixStation.inventory:HasItem(recipe.requirements)
			end

			if !client:HasItem(recipe.requirements, "main") and !hasInCraft then
				hasItems = false
			end
		else
			for uniqueID, amount in pairs(recipe.requirements or {}) do
				local count = 0
				local stored = ix.Item:Get(uniqueID)

				if stored.stackable_legacy then
					for k, v in ipairs(client:GetInventory("main"):GetItems()) do
						if v.uniqueID == uniqueID then
							count = count + v:GetValue()
						end
					end

					if IsValid(client.ixStation) then
						for k, v in ipairs(client.ixStation.inventory:GetItems()) do
							if v.uniqueID == uniqueID then
								count = count + v:GetValue()
							end
						end
					end

					if count < amount then
						hasItems = false
						break
					end
				else
					count = count + client:GetInventory("main"):GetItemsCount(uniqueID)

					if IsValid(client.ixStation) then
						count = count + client.ixStation.inventory:GetItemsCount(uniqueID)
					end

					if recipe.any and recipe.any[uniqueID] then
						for k, v in pairs(recipe.any[uniqueID]) do
							count = count + client:GetInventory("main"):GetItemsCount(k)

							if IsValid(client.ixStation) then
								count = count + client.ixStation.inventory:GetItemsCount(k)
							end
						end
					end

					if count < amount then
						hasItems = false
						break
					end
				end
			end
		end
		
		if !hasItems then
			return false, "У вас нет необходимых предметов!"
		end

		return true
	end

	function Craft:GetSkillScale(client, skill, level)
		local character = client:GetCharacter()
		local currentLevel = character:GetSkillModified(skill)

		return math.Clamp(math.Remap(level, currentLevel - 4, currentLevel, 0, 1), 0, 1)
	end

	function Craft:OnCraft(recipe, client)
		local character = client:GetCharacter()

		local xp = recipe.xp or 0

		if recipe.skill then
			local skill = recipe.skill[1]
			local level = recipe.skill[2]
			
			xp = xp * self:GetSkillScale(client, skill, level)

			character:DoAction("craft_"..skill, xp)
		end

		local inventory = client:GetInventory("main")

		local resync = {}

		if recipe.isBreakdown then
			local hasItem

			for k, v in ipairs(inventory:GetItems()) do
				if v.uniqueID == recipe.requirements then
					local inv = v.inventory_id
					hasItem = true
					v:Remove(nil, true)

					resync[inv] = true
					break
				end
			end

			if IsValid(client.ixStation) and !hasItem then
				for k, v in ipairs(client.ixStation.inventory:GetItems()) do
					if v.uniqueID == recipe.requirements then
						local inv = v.inventory_id
						hasItem = true
						v:Remove(nil, true)

						resync[inv] = true
						break
					end
				end
			end
		else
			local function isAccept(recipe, uniqueID, targetUniqueID)
				if uniqueID == targetUniqueID then
					return true
				end

				if recipe.any and recipe.any[targetUniqueID] and recipe.any[targetUniqueID][uniqueID] then
					return true
				end
				
				return false
			end
			
			for uniqueID, amount in pairs(recipe.requirements or {}) do
				local countRemoved = 0
				local stored = ix.Item:Get(uniqueID)

				if stored.stackable_legacy then
					for k, v in ipairs(inventory:FindItems(uniqueID)) do
						if countRemoved >= amount then break end

						countRemoved = countRemoved + v:TakeValue(amount - countRemoved)
					end

					if countRemoved < amount and IsValid(client.ixStation) then
						for k, v in ipairs(client.ixStation.inventory:FindItems(uniqueID)) do
							if countRemoved >= amount then 
								break
							end

							countRemoved = countRemoved + v:TakeValue(amount - countRemoved)
						end
					end
				else
					for k, v in ipairs(inventory:GetItems()) do
						if isAccept(recipe, v.uniqueID, uniqueID) then
							if (countRemoved + 1) > amount then continue end

							countRemoved = countRemoved + 1
							local inv = v.inventory_id
							v:Remove(nil, true)
							resync[inv] = true
						end
					end

					if countRemoved == amount then
						continue
					end
					
					if IsValid(client.ixStation) then
						for k, v in ipairs(client.ixStation.inventory:GetItems()) do
							if isAccept(recipe, v.uniqueID, uniqueID) then
								if (countRemoved + 1) > amount then continue end

								countRemoved = countRemoved + 1
								local inv = v.inventory_id
								v:Remove(nil, true)
								resync[inv] = true
							end
						end
					end
				end
			end
		end

		if recipe.tools then
			local found = {}

			for _, uniqueID in pairs(recipe.tools or {}) do
				if found[uniqueID] then continue end

				local sorted = {}

				for k, v in ipairs(client:FindItems(uniqueID)) do
					sorted[#sorted + 1] = {value = (v:GetData("durability") or v.durability), item = v}
				end

				if #sorted > 0 then
					table.SortByMember(sorted, "value", true)

					found[uniqueID] = sorted[1].item
				end
			end

			for _, item in pairs(found) do
				if item.TakeDurability then
					local default_durability = item.DurabilityCraft or 100

					if recipe.isBreakdown then
						default_durability = item.DurabilityBreakdown or 10
					end

					item:TakeDurability(recipe.tool_durability and recipe.tool_durability[item.uniqueID] or default_durability, client)
				end
			end
		end

		for uniqueID, amount in pairs(recipe.results or {}) do
			if istable(amount) then
				amount = math.random(amount[1], amount[2])
			end

			local stored = ix.Item:Get(uniqueID)

			if stored.stackable_legacy then
				local countAdded = 0

				for k, v in ipairs(inventory:FindItems(uniqueID)) do
					if countAdded >= amount then break end

					countAdded = countAdded + v:AddValue(amount - countAdded)
				end

				if countAdded < amount and IsValid(client.ixStation) then
					for k, v in ipairs(client.ixStation.inventory:FindItems(uniqueID)) do
						if countAdded >= amount then break end

						countAdded = countAdded + v:AddValue(amount - countAdded)
					end
				end

				local remain = (amount - countAdded)

				remain = math.abs(remain)
				
				if remain > 0 then
					local max = stored.max_stack
					for i = 1, math.ceil(remain / max) do
						remain = remain - max
						local value = max + math.min(remain, 0)
						
						local inventory = client:GetInventory("main")
						local item = ix.Item:Instance(uniqueID)
						item:SetData("stack", value)
						local x, y, need_rotation = inventory:FindPosition(item, item.width, item.height)

						if IsValid(client.ixStation) then
							if !x or !y then
								inventory = client.ixStation.inventory

								x, y, need_rotation = inventory:FindPosition(item, item.width, item.height)
							end
						end

						if !x or !y then
							inventory = nil
						end
						
						if inventory then
							item.rotated = need_rotation

							inventory:AddItem(item, x, y)

							resync[inventory.id] = true
						else
							ix.Item:Spawn(client, nil, item)
						end
					end
				end
			else
				for i = 1, amount do
					local inventory = client:GetInventory("main")
					local item = ix.Item:Instance(uniqueID)
					local x, y, need_rotation = inventory:FindPosition(item, item.width, item.height)

					if IsValid(client.ixStation) then
						if !x or !y then
							inventory = client.ixStation.inventory

							x, y, need_rotation = inventory:FindPosition(item, item.width, item.height)
						end
					end

					if !x or !y then
						inventory = nil
					end
					
					if inventory then
						item.rotated = need_rotation

						inventory:AddItem(item, x, y)

						resync[inventory.id] = true
					else
						ix.Item:Spawn(client, nil, item)
					end
				end
			end
		end

		for k, v in pairs(resync) do
			local inventory = ix.Inventory.stored[k]

			if inventory then
				inventory:Sync()
			end
		end

		if recipe.skill then
			client:Notify(string.format("Вы получили %s опыта за %s!", xp, recipe.isBreakdown and "разбор" or "создание"))
		end
		
		return true
	end

	function Craft:CraftRecipe(client, uniqueID)
		local recipeTable = self.recipes[uniqueID]

		if recipeTable then
			local bCanCraft, reason = self:AttemptCraft(recipeTable, client)

			if !bCanCraft then
				client:Notify(reason)
				return false
			end

			local success = self:OnCraft(recipeTable, client)

			return success
		end
	end

	net.Receive("ixCraftRecipe", function(length, client)
		ix.Craft:CraftRecipe(client, net.ReadString())
	end)
end

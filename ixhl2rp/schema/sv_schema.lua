function Schema:AddCombineDisplayMessage(text, color, exclude, ...)
	color = color or color_white

	local arguments = {...}
	local receivers = {}

	-- we assume that exclude will be part of the argument list if we're using
	-- a phrase and exclude is a non-player argument
	if (type(exclude) != "Player") then
		table.insert(arguments, 1, exclude)
	end

	for _, v in ipairs(player.GetAll()) do
		if (v:IsCombine() and v != exclude) then
			receivers[#receivers + 1] = v
		end
	end

	netstream.Start(receivers, "CombineDisplayMessage", text, color, arguments)
end

local cached_id = {}
function Schema:GetDatafile(cid, regid)
	local datafile = ix.plugin.list["datafile"]
	local data
	local datafileID

	if cached_id[cid] and cached_id[cid][regid] then
		datafileID = cached_id[cid][regid]
		data = datafile.stored[datafileID]
	else
		for id, v in pairs(datafile.stored) do
			if v[2] == cid and v[3] == regid then
				cached_id[cid] = cached_id[cid] or {}
				cached_id[cid][regid] = id

				datafileID = id
				data = v
				break
			end
		end
	end

	if data then
		return datafileID, data[5], data[4]
	end
end

local loyalTable = {
	["Anti-Citizen"] = -1,
	["Citizen"] = 0,
	["Black"] = 1,
	["Brown"] = 2,
	["Orange"] = 3,
	["Red"] = 4,
	["Blue"] = 5,
	["Green"] = 6,
	["Gold"] = 7,
	["Platinum"] = 8,
}

function Schema:GetCitizenRationTypes(character)
	local item = character:GetPlayer():GetIDCard()

	if item then
		local dID, datafile, genericdata = Schema:GetDatafile(item:GetData("cid") or "", item:GetData("number") or "")
		local level = loyalTable[genericdata.status] or 0

		if level >= 5 then
			return "ration_tier_4"
		elseif level >= 3 then
			return "ration_tier_1"
		end
	end

	return "ration_tier_0"
end

-- data saving
function Schema:SaveRationDispensers()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_rationdispenser")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetEnabled()}
	end

	ix.data.Set("rationDispensers", data)
end

function Schema:SaveVendingMachines()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_vendingmachine")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetAllStock()}
	end

	ix.data.Set("vendingMachines", data)
end

function Schema:SaveCombineMonitors()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_combineaccessmonitor")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetDTString(0), v:GetDTString(1), v:GetDTString(2), v:GetDTString(3), v:GetDTInt(0)}
	end

	ix.data.Set("combineAccMonitors", data)
end

function Schema:SaveCombineFields()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ent_cmb_forcefield")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles()}
	end

	ix.data.Set("forceFields2", data)
end

function Schema:SaveSinkTriggers()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_sink_trigger")) do
		data[#data + 1] = {v:GetClass(), v:GetPos(), v:GetAngles()}
	end

	for _, v in ipairs(ents.FindByClass("ix_toilet_trigger")) do
		data[#data + 1] = {v:GetClass(), v:GetPos(), v:GetAngles()}
	end

	ix.data.Set("sinkTriggers", data)
end

-- data loading
function Schema:LoadRationDispensers()
	for _, v in ipairs(ix.data.Get("rationDispensers") or {}) do
		local dispenser = ents.Create("ix_rationdispenser")

		dispenser:SetPos(v[1])
		dispenser:SetAngles(v[2])
		dispenser:Spawn()
		dispenser:SetEnabled(v[3])
	end
end

function Schema:LoadVendingMachines()
	for _, v in ipairs(ix.data.Get("vendingMachines") or {}) do
		local vendor = ents.Create("ix_vendingmachine")

		vendor:SetPos(v[1])
		vendor:SetAngles(v[2])
		vendor:Spawn()
		vendor:SetStock(v[3])
	end
end

function Schema:LoadCombineMonitors()
	for _, v in ipairs(ix.data.Get("combineAccMonitors") or {}) do
		local mon = ents.Create("ix_combineaccessmonitor")

		mon:SetPos(v[1])
		mon:SetAngles(v[2])
		mon:Spawn()
		mon:SetDTString(0,v[3])
		mon:SetDTString(1,v[4])
		mon:SetDTString(2,v[5])
		mon:SetDTString(3,v[6])
		mon:SetDTInt(0,v[7])
	end
end

function Schema:LoadCombineFields()
	for _, v in ipairs(ix.data.Get("forceFields2") or {}) do
		local field = ents.Create("ent_cmb_forcefield")

		field:SetPos(v[1])
		field:SetAngles(v[2])
		field:Spawn()
	end
end

function Schema:LoadSinkTriggers()
	for _, v in ipairs(ix.data.Get("sinkTriggers") or {}) do
		local trigger = ents.Create(v[1])

		trigger:SetPos(v[2])
		trigger:SetAngles(v[3])
		trigger:Spawn()
	end
end

function Schema:SearchPlayer(client, target)
	if !target:GetCharacter() then
		return false
	end

	local name = hook.Run("GetDisplayedName", target) or target:Name()
	local inventory = target:GetInventory("main")

	ix.storage.Open(client, inventory, {
		entity = target,
		name = name,
		OnPlayerOpen = function(client)
			for k, v in pairs(target:GetInventories()) do
				if v.type == "main" then continue end
				
				v:AddReceiver(client)
			end
		end,
		OnPlayerClose = function(client)
			for k, v in pairs(target:GetInventories()) do
				if v.type == "main" then continue end

				v:RemoveReceiver(client)
			end
		end,
		OnSync = function(client)
			for k, v in pairs(target:GetInventories()) do
				if v.type == "main" then continue end
				
				v:Sync(client)
			end
		end,
	})

	return true
end

/*
concommand.Add("unlock_ration", function(client)
	if IsValid(client) then
		return
	end
	
	net.Start("ration.notify")
	net.Broadcast()

	timer.Simple(4, function()
		for k, v in pairs(ents.FindByClass("ix_rationdispenser")) do
			v:SetEnabled(true)
		end
	end)
end)

concommand.Add("lock_ration", function(client)
	if IsValid(client) then
		return
	end

	for k, v in pairs(ents.FindByClass("ix_rationdispenser")) do
		v:SetEnabled(false)
	end
end)
*/
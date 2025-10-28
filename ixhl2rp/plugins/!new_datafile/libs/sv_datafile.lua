local Datafile = ix.util.Lib("Datafile", {
	cached = {}
})

local prime = 99787 // prime % 4 = 3, don't change
local offset = 318 // > sqrt(prime), don't change
local block = 1000
function Datafile:GenerateCitizenID(characterID)
	characterID = (characterID + offset) % prime

	local cid = 0

	for _ = 1, math.floor(characterID/block) do
		cid = (cid + (characterID * block) % prime) % prime
	end

	cid = (cid + (characterID * (characterID % block) % prime)) % prime

	if (2 * characterID < prime) then
		return Schema:ZeroNumber(cid, 5)
	else
		return Schema:ZeroNumber(prime - cid, 5)
	end
end

function Datafile:OnCardEquipped(client, item, isEquip)
	print("Datafile:OnCardEquipped", client, item, isEquip)
end

function Datafile:Preload(info)
	info.character_id = tonumber(info.character_id)

	local datafile = self.cached[info.character_id]

	if datafile then
		return datafile
	else
		self.cached[info.character_id] = ix.meta.Datafile:New(info)

		return self.cached[info.character_id]
	end
end

function Datafile:CreateRaw(info, callback)
	if !info.character_id then return end
	
	local time = os.time()

	info.character_name = info.character_name or ""
	info.citizen_id = info.citizen_id or self:GenerateCitizenID(tonumber(info.character_id))
	info.dna = info.dna or ""
	info.job = info.job or ""
	info.house = info.house or ""
	info.points = info.points or 0
	info.money = info.money or 0
	
	info.civil_status = info.civil_status or ix.Loyalty.CITIZEN
	info.create_time = info.create_time or time
	info.last_seen = info.last_seen or time
	
	info.data = info.data or {}

	local query = mysql:Insert("datafiles")
		query:Insert("character_id", info.character_id)
		query:Insert("character_name", info.character_name)
		query:Insert("citizen_id", info.citizen_id)
		query:Insert("dna", info.dna)
		query:Insert("job", info.job)
		query:Insert("house", info.house)
		query:Insert("civil_status", info.civil_status)
		query:Insert("points", info.points)
		query:Insert("money", info.money)
		query:Insert("create_time", info.create_time)
		query:Insert("last_seen", info.last_seen)
		query:Insert("data", util.TableToJSON(info.data))
		query:Callback(function(result, status, lastID)
			local datafile = self:Preload(info)

			if callback then
				callback(datafile)
			end
		end)
	query:Execute()
end

function Datafile:Create(character, info, callback)
	info = info or {}

	info.character_id = character:GetID()
	info.character_name = character:GetName()

	hook.Run("CreateInitialDatafile", character, info)

	self:CreateRaw(info, callback)
end

function Datafile:Get(charID)
	return self.cached[charID]
end

function Datafile:Setup(client, character)
	local id = character:GetID()

	character.noDatafile = !self.cached[id] and true or false
	character.datafile = self.cached[id] or nil
end

function Datafile:FetchTransactions(client, key, value, limit, page, callback)
	local query = mysql:Select("datafiles_transactions")
		if limit and page then
			query:Limit(limit)
			query:Offset((page - 1) * limit)
		end
		
		if key == "char" then
			query.whereList[#query.whereList + 1] = "(`receiver_id` = '"..query:Escape(value).."' OR `sender_id` = '"..query:Escape(value).."')"
		else
			query:Where(key, value)
		end

		query:Select("id")
		query:Select("timestamp")
		query:Select("receiver_id")
		query:Select("sender_id")
		query:Select("receiver_name")
		query:Select("sender_name")
		query:Select("amount")
		query:Select("reason")
		query:Callback(function(result)
			if !IsValid(client) then return end

			if callback and istable(result) then
				callback(result)
			end
		end)
		query:OrderByDesc("timestamp")
	query:Execute()
end

function TestAddTransaction(client)
	local id = math.random(1000,2000)
	local name = "Random"..id

	if IsValid(client) then
		id = client:GetCharacter():GetID()
		name = client:GetCharacter():GetName()
	end


	local query = mysql:Insert("datafiles_transactions")
		query:Insert("receiver_id", id)
		query:Insert("sender_id", 888)
		query:Insert("receiver_name", name)
		query:Insert("sender_name", "K West")
		query:Insert("reason", "Debug")
		query:Insert("amount", math.random(1, 9999))
		query:Insert("timestamp", os.time())
		query:Callback(function(result, status, lastID)
			print("transaction created", lastID)
		end)
	query:Execute()
end

function Datafile:FetchMessages(client, key, value, limit, page, callback)
	local query = mysql:Select("datafiles_messages")
		if limit and page then
			query:Limit(limit)
			query:Offset((page - 1) * limit)
		end
		
		if key == "char" then
			query.whereList[#query.whereList + 1] = "(`receiver_id` = '"..query:Escape(value).."' OR `sender_id` = '"..query:Escape(value).."' OR `receiver_id` = '0')"
		else
			query:Where(key, value)
		end

		query:Select("id")
		query:Select("timestamp")
		query:Select("receiver_id")
		query:Select("sender_id")
		query:Select("sender_name")
		query:Select("text")
		query:Select("title")
		query:Callback(function(result)
			if !IsValid(client) then return end

			if callback and istable(result) then
				callback(result)
			end
		end)
		query:OrderByDesc("timestamp")
	query:Execute()
end


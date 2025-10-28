local PLUGIN = PLUGIN

ix.poi = ix.poi or {}

function PLUGIN:OnPlayerEnterBusiness(client, propertyID, zone)
	local poi = ix.poi[propertyID]

	if poi and poi.active then
		if !IsValid(poi.active) then
			poi.active = false
			return
		end

		local steamID = client:SteamID()

		if !poi.visitors[steamID] and client != poi.active then
			poi.cash = poi.cash + 5

			if poi.log then
				poi.log.visitors = poi.log.visitors + 1
			end

			poi.visitors[steamID] = true
		end
	end
end

function PLUGIN:PlayerLoadedCharacter(client, character, oldCharacter)
	if client.activePoi then
		local poi = ix.poi[client.activePoi]

		if poi then
			poi.active = false
		end

		client.activePoi = nil
	end
end

local function CreatePropertyZone(id, startPos, endPos, cash)
	if !ix.poi[id] then
		cash = cash or 0

		local zone = ents.Create("ix_property_zone")
		zone:Spawn()
		zone:SetupProperty(id, startPos, endPos)

		ix.poi[id] = {
			zone = zone,
			active = false,
			cash = cash,
			visitors = {}
		}
	end

	return zone
end

function PLUGIN:AreaEditAdd(id, type, startPosition, endPosition)
	if type == "property" then
		CreatePropertyZone(id, startPosition, endPosition)

		return true
	end
end

function PLUGIN:SaveData()
	local data = {}

	local registers = {}
	local savedRegisters = {}
	for _, v in ipairs(ents.FindByClass("ix_property_cash")) do
		registers[v.propertyID] = v
	end

	for _, v in ipairs(ents.FindByClass("ix_property_zone")) do
		local zoneID = v.propertyID
		local poi = ix.poi[zoneID]

		if poi then
			local register = registers[zoneID]
			local regPos, regAng, regAccess

			if IsValid(register) and !savedRegisters[v.propertyID] then
				regPos = register:GetPos()
				regAng = register:GetAngles()
				regAccess = register.access

				savedRegisters[v.propertyID] = true
			end

			data[#data + 1] = {zoneID, v.worldPos1, v.worldPos2, poi.cash, regPos, regAng, regAccess}
		end
	end

	self:SetData(data)
end

function PLUGIN:LoadData()
	local data = self:GetData()

	for _, v in ipairs(data) do
		CreatePropertyZone(v[1], v[2], v[3], v[4])

		if v[5] then
			local entity = ents.Create("ix_property_cash")
			entity:SetPos(v[5])
			entity:SetAngles(v[6])
			entity:Spawn()
			entity.propertyID = v[1]
			entity.access = v[7]

			local physObject = entity:GetPhysicsObject()

			if IsValid(physObject) then
				physObject:EnableMotion(false)
			end
		end
	end
end
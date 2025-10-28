local PLUGIN = PLUGIN

function PLUGIN:PlayerLoadedCharacter(client, character, lastCharacter)
	local steamID = client:SteamID64()

	timer.Create("ixRad" .. steamID, 1, 0, function()
		if IsValid(client) and character then
			self:RadTick(client, character)
		else
			timer.Remove("ixRad" .. steamID)
		end
	end)
end

function PLUGIN:PlayerDeath(client)
	client.lastRadNotify = nil
	client.lastRadLevel = nil
end

function PLUGIN:OnPlayerRadLevelChanged(client, newRad)
	if newRad > 899 then
		client:RadNotify(5)
	elseif newRad > 599 then
		client:RadNotify(4)
	elseif newRad > 449 then
		client:RadNotify(3)
	elseif newRad > 299 then
		client:RadNotify(2)
	elseif newRad > 149 then
		client:RadNotify(1)
	else
		client.lastRadNotify = nil
	end
end

function PLUGIN:RadTick(client, character)
	local radiation_dmg = client:GetNetVar("radDmg") or 0

	if !client:IsInArea() and (radiation_dmg > 0) then
		client:SetNetVar("radDmg", nil)
		return
	elseif client:IsInArea() and radiation_dmg <= 0 then
		local area = ix.area.stored[client:GetArea()]
	
		if area and area.type == "rad" then
			radiation_dmg = area.properties.radDamage or 0

			client:SetNetVar("radDmg", radiation_dmg)
			return
		end
	end

	if !client:Alive() or client:GetMoveType() == MOVETYPE_NOCLIP then
		return
	end

	if radiation_dmg <= 0 then
		return
	end

	local health = character:Health()

	if !health.radiation then
		health:AddHediff("radiation", 0)
		health.radiation = true
	end
end

function PLUGIN:OnPlayerAreaChanged(client, oldID, newID)
	local area = ix.area.stored[newID]

	if area and area.type == "rad" then
		client:SetNetVar("radDmg", area.properties.radDamage or 0)
	else
		client:SetNetVar("radDmg", nil)
	end
end

local client = player.GetAll()[1]
local steamID = client:SteamID64()
local character = client:GetCharacter()

timer.Create("ixRad" .. steamID, 1, 0, function()
	if IsValid(client) and character then
		PLUGIN:RadTick(client, character)
	else
		timer.Remove("ixRad" .. steamID)
	end
end)
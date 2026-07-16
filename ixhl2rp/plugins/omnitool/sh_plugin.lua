local PLUGIN = PLUGIN

PLUGIN.name = "Omni Tool"
PLUGIN.author = "Kushida"
PLUGIN.description = "Provides direct access to Combine devices and protected equipment."

function PLUGIN:IsOmniTool(item)
	return istable(item) and item.uniqueID == "omnitool"
end

function PLUGIN:IsCitizenID(item)
	return istable(item) and isfunction(item.Is) and item:Is("cidcard")
end

function PLUGIN:GetLookedEntity(client)
	if (!IsValid(client)) then
		return
	end

	local trace = client:GetEyeTraceNoCursor()

	return trace and trace.Entity
end

function PLUGIN:IsLookedAt(client, entity, distance)
	return IsValid(entity) and self:GetLookedEntity(client) == entity
		and client:GetPos():DistToSqr(entity:GetPos()) <= distance * distance
end

function PLUGIN:CanUseItem(client, item)
	if (!IsValid(client) or !client:GetCharacter() or !item or !item.inventory_id) then
		return false
	end

	local inventory = ix.Inventory:Get(item.inventory_id)

	if (!inventory) then
		return false
	end

	if (SERVER) then
		return isfunction(inventory.OnCheckAccess) and inventory:OnCheckAccess(client)
	end

	return true
end

function PLUGIN:CanConnectToScanner(client, scanner)
	local scanners = ix.plugin.list and ix.plugin.list["combinescanners"]

	if (!IsValid(client) or !client:GetCharacter() or !scanners or !IsValid(scanner)
		or scanner:GetClass() != "ix_scanner" or !self:IsLookedAt(client, scanner, 400)) then
		return false
	end

	if (IsValid(client:GetNWEntity("OmniManhack"))) then
		return false
	end

	local activeScanner = isfunction(client.GetPilotingScanner) and client:GetPilotingScanner()

	if (IsValid(activeScanner)) then
		return false
	end

	local sameFaction = scanner:GetIsCombine() == client:IsCombine()

	return sameFaction and scanners:CanEnterToScanner(client, scanner)
end

function PLUGIN:CanConnectToManhack(client, manhack)
	if (!IsValid(client) or !client:GetCharacter() or !IsValid(manhack)
		or manhack:GetClass() != "npc_manhack" or !client:IsCombine()
		or client:IsRestricted() or !self:IsLookedAt(client, manhack, 400)
		or IsValid(client:GetNWEntity("OmniManhack"))) then
		return false
	end

	local scanner = isfunction(client.GetPilotingScanner) and client:GetPilotingScanner()

	if (IsValid(scanner)) then
		return false
	end

	local owner = manhack:GetNetVar("owner")
	local pilot = manhack:GetNWEntity("OmniPilot")

	if (IsValid(pilot) and pilot != client) then
		return false
	end

	if (CLIENT) then
		return true
	end

	return tonumber(owner) == client:GetCharacter():GetID()
end

function PLUGIN:CanConnectToRemote(client, entity)
	return self:CanConnectToScanner(client, entity) or self:CanConnectToManhack(client, entity)
end

ix.util.Include("cl_manhack.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_manhack.lua")

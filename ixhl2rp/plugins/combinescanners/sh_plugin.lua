local PLUGIN = PLUGIN

PLUGIN.name = "Combine Scanners"
PLUGIN.author = "Schwarz Kruppzo, Alan Wake"
PLUGIN.description = "Adds a controllable combine scanners."

PLUGIN.Picture = {
	w = 580,
	h = 420,
	w2 = 580 * 0.5,
	h2 = 420 * 0.5,
	delay = 15
}

function PLUGIN:StartCommand(player, cmd)
	if (IsValid(player:GetPilotingScanner())) then
		cmd:RemoveKey(bit.bor(IN_ATTACK, IN_ATTACK2))
		cmd:ClearMovement()
	end
end

function PLUGIN:SetupMove(player, mvd, cmd)
	if (player:IsPilotScanner()) then
		if mvd:KeyDown(IN_JUMP) then
			local newbuttons = bit.band(mvd:GetButtons(), bit.bnot(IN_JUMP))
			mvd:SetButtons(newbuttons)
		end
	end
end

do
	local PLAYER = FindMetaTable("Player")

	function PLAYER:IsPilotScanner()
		return IsValid(self:GetPilotingScanner())
	end

	function PLAYER:GetPilotingScanner()
		return self:GetNWEntity("Scanner")
	end
end

function PLUGIN:GetActiveScanners(forceRebellion) // by default returns combine scanners
	local tbl = {}
	for k,v in ipairs(ents.FindByClass("ix_scanner"))do
		if (forceRebellion && !v:GetIsCombine()) then
			tbl[#tbl + 1] = v
			continue
		end

		tbl[#tbl + 1] = v
	end

	return tbl
end

function PLUGIN:CanEnterToScanner(client, scanner, terminal)
	if (client:IsRestricted() or IsValid(scanner:GetPilot()) or (!IsValid(terminal) || client:GetPos():Distance(terminal:GetPos()) > 400)) then
		return false
	end

	return true
end

function PLUGIN:CanFoldScanner(client, scanner)
	if (client:IsRestricted() or IsValid(scanner:GetPilot()) or client:GetPos():Distance(scanner:GetPos()) > 400) then
		return false
	end

	return true
end

function PLUGIN:GetMaxID(forCombine)
	local tblActive = self:GetActiveScanners(!forCombine)

	local maxId = 0
	for k,v in ipairs(tblActive)do
		local currentId = v:GetID()
		if currentId > maxId then
			maxId = currentId
		end
	end

	return maxId
end

function PLUGIN:GenerateScannerName(isCombine)
	local newScannerId = self:GetMaxID(isCombine) + 1

	if (isCombine) then
		return Format("AE:c24.SCN-%d", newScannerId), newScannerId
	end

	return Format("AE:???-%d", newScannerId), newScannerId
end

ix.util.Include("sh_commands.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_plugin.lua")
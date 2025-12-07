local PLUGIN = PLUGIN

util.AddNetworkString("ScannerPhoto")
util.AddNetworkString("ScannerData")
util.AddNetworkString("ScannerEnter")
util.AddNetworkString("ScannerExit")
util.AddNetworkString("ScannerTerminalAccess")
util.AddNetworkString("ScannerTerminalDeploy")
util.AddNetworkString("ScannerTerminalDeploy2")
util.AddNetworkString("ScannerFlash")
util.AddNetworkString("ScannerFold")

local sndSpotlight = Sound("npc/turret_floor/click1.wav")

concommand.Add("scanner_spotlight", function(player)
	local scanner = player:GetPilotingScanner()

	if !IsValid(scanner) then return end

	if (scanner.nextLightToggle or 0) >= CurTime() then return end
	scanner.nextLightToggle = CurTime() + 0.5

	local spot = scanner:IsSpotlightOn()
	scanner:Spotlight(!spot)

	scanner:EmitSound(sndSpotlight, 50, spot and 240 or 250)
end)

concommand.Add("scanner_photo", function(player)
	local scanner = player:GetPilotingScanner()

	if !IsValid(scanner) then return end

	if ((scanner.nextPicture2 or 0) >= CurTime()) then return end
	scanner.nextPicture2 = CurTime() + (PLUGIN.Picture.delay - 1)

	if !scanner.Rebel then
		net.Start("ScannerPhoto")
		net.Send(player)
	end

	scanner:Flash()
end)

function PLUGIN:CanPlayerReceiveScan(client, photographer)
	return client:IsCombine()
end

function PLUGIN:LoadScannerTerminals()
	for _, v in ipairs(ix.data.Get("cmbScannerTerminals") or {}) do
		local rs = ents.Create("ix_scannerterminal")

		rs:SetPos(v[1])
		rs:SetAngles(v[2])
		rs:Spawn()

		local phys = rs:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
end

function PLUGIN:SaveScannerTerminals()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_scannerterminal")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles()}
	end

	ix.data.Set("cmbScannerTerminals", data)
end

function PLUGIN:ConnectScannerToPlayer(client, scanner, terminal)
	if (self:CanEnterToScanner(client, scanner, terminal)) then
		scanner:Transmit(client)
		client:SetNWEntity("Scanner", scanner)

		return true
	end
end

function PLUGIN:SpawnScanner(isCombine, pos)
	if (!pos) then
		local spawnPoints = (ix.plugin.list["spawns"].spawns["metropolice"] or {})["scanner"]

		if (!spawnPoints or #spawnPoints <= 0) then return end

		pos = spawnPoints[math.random(1, #spawnPoints)]
	end

	local scanner = ents.Create("ix_scanner")
	scanner:SetPos(pos)
	scanner:Spawn()

	scanner:SetIsCombine(isCombine)

	local generatedName, scannerId = self:GenerateScannerName(isCombine)
	scanner:SetScannerName(generatedName)
	scanner:SetID(scannerId)

	return scanner
end

function PLUGIN:ActivateScannerAsItem(item)
	local itemEnt = item.entity
	if (IsValid(itemEnt) && item.uniqueID == "combine_scanner") then
		local pos, angles = itemEnt:GetPos(), itemEnt:GetAngles()
		local entity = self:SpawnScanner(true, pos)

		entity:SetAngles(angles)
		itemEnt:Remove()

		return true, entity
	end

	return false
end

function PLUGIN:DeployScanner(client, terminal, isPortable)
	if client:IsPilotScanner() or client:IsRagdoll() or !client:Alive() or !client:GetCharacter() then
		return
	end

	local item = client:FindItem("combine_scanner")

	if (!item) then
		return false, "Необходим сканнер для размещения!"
	end

	local scanner = self:SpawnScanner(true)

	if (!IsValid(scanner)) then
		return false, "Невозможно определить точку спавна сканнера!"
	end

	local res = self:ConnectScannerToPlayer(client, scanner, terminal)

	if (!res) then
		SafeRemoveEntity(scanner)
		return false, "Не удалось подключиться к сканнеру!"
	end

	item:Remove()

	return true, nil, scanner
end

net.Receive("ScannerData", function(len, client)
	local scanner = client:GetPilotingScanner()

	if client:IsPilotScanner() and (scanner.nextPicture or 0) < CurTime() and !scanner.Rebel then
		scanner.nextPicture = CurTime() + (PLUGIN.Picture.delay - 1)

		local length = net.ReadUInt(16)
		local data = net.ReadData(length)
		
		if length != #data then
			return
		end

		local receivers = {}

		for _, v in ipairs(player.GetAll()) do
			if PLUGIN:CanPlayerReceiveScan(v, client) then
				receivers[#receivers + 1] = v
			end
		end

		if #receivers > 0 then
			net.Start("ScannerData")
				net.WriteUInt(#data, 16)
				net.WriteData(data, #data)
			net.Send(receivers)
		end
	end
end)

PLUGIN.activeID = PLUGIN.activeID or 0

net.Receive("ScannerTerminalDeploy", function(len, player)
	local terminal = net.ReadEntity()

	if !IsValid(terminal) or !terminal.IsScannerTerminal then
		return
	end
	if player:GetPos():Distance(terminal:GetPos()) > 400 then
		return
	end

	local result, err, scanner = PLUGIN:DeployScanner(player, terminal)
	if (!result) then
		return player:Notify(err)
	end

	player:Notify(Format("Присвоено название: %s", scanner:GetScannerName()))
end)

net.Receive("ScannerFold", function(len, player)
	local scanner = net.ReadEntity()
	if (IsValid(scanner) && scanner:GetClass() == "ix_scanner") && PLUGIN:CanFoldScanner(player, scanner) then
		local pos, angles = scanner:GetPos(), scanner:GetAngles()
		SafeRemoveEntity(scanner)

		local instance = ix.Item:Instance("combine_scanner")
		ix.Item:Spawn(pos, angles, instance)
	end
end)

net.Receive("ScannerEnter", function(len, player)
	local scanner = net.ReadEntity()
	local terminal = net.ReadEntity()
	if (IsValid(terminal) && terminal:GetClass() == "ix_scannerterminal") then
		local result = PLUGIN:ConnectScannerToPlayer(player, scanner, terminal)
		if (!result) then
			player:Notify("Не удалось подключиться к сканнеру!")
		end
	end
	// TODO: Available to enter scanner from portable device
end)
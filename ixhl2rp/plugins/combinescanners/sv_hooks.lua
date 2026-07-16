local PLUGIN = PLUGIN

function PLUGIN:RemoveScanner(player)
	if player:IsPilotScanner() then
		SafeRemoveEntity(player:GetPilotingScanner())
	end

	local activeid = self:GetActiveScanners()[player]
	if IsValid(activeid) then
		SafeRemoveEntity(activeid)
		self:GetActiveScanners()[player] = nil
	end
end

function PLUGIN:PlayerSwitchFlashlight(player)
	if player:IsPilotScanner() then
		return false;
	end
end

function PLUGIN:PlayerNoClip(player)
	if player:IsPilotScanner() then
		return false
	end
end

function PLUGIN:PlayerUse(player)
	if player:IsPilotScanner() then
		return false
	end
end

function PLUGIN:DoPlayerDeath(player)
	self:RemoveScanner(player)
end

function PLUGIN:CharacterLoaded(character)
	local client = character:GetPlayer()
	
	self:RemoveScanner(client)
end

--function PLUGIN:CanEnterObserverMode(player)
	--local scanner = player:IsPilotScanner() and player:GetPilotingScanner() or false

	--return scanner
--end

local SCANNER_SOUNDS2 = {
	Sound("npc/scanner/scanner_talk1.wav"),
	Sound("npc/scanner/scanner_talk2.wav")
}

function PLUGIN:KeyPress(player, key)
	if (!player:IsPilotScanner()) then
		return
	end

	if (key == IN_USE) then
		player:GetPilotingScanner():Eject()

		return true
	end

	if ((player.scnNextSound or 0) < CurTime()) then
		local source

		if key == IN_RELOAD then
			source = table.Random(SCANNER_SOUNDS2)
			player.scnNextSound = CurTime() + 10
		end

		if source then
			player:GetPilotingScanner():EmitSound(source)
		end
	end
end

function PLUGIN:LoadData()
    self:LoadScannerTerminals()
end

function PLUGIN:SaveData()
	self:SaveScannerTerminals()
end

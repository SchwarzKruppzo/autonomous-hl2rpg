local PLUGIN = PLUGIN

PLUGIN.name = "Door Commands"
PLUGIN.author = "Schwarz Kruppzo"

ix.lang.AddTable("ru", {
	cmdDoorLockDesc = "Закрыть дверь",
	cmdDoorUnlockDesc = "Открыть дверь",
	cmdDoorSetAccessDesc = "Назначить игроку доступ (owner, tenant, guest) к двери на которую вы смотрите.",
	cmdDoorRemoveAccessDesc = "Забрать у игрока доступ к двери на которую вы смотрите.",
	cmdDoorResetAccessDesc = "Сбросить весь доступ дверям.",
	dDoorLocked = "Вы успешно закрыли эту дверь.",
	dDoorUnlocked = "Вы успешно открыли эту дверь.",
	dAccessSet = "Вы успешно изменили доступ.",
	dAccessRemoved = "Вы успешно забрали доступ.",
	dAccessReset = "Вы успешно сбросили доступ.",
})
ix.lang.AddTable("en", {
	cmdDoorLockDesc = "Lock the door.",
	cmdDoorUnlockDesc = "Unlock the door.",
	cmdDoorSetAccessDesc = "Set a player's access (owner, tenant, guest) to the door you're looking at.",
	cmdDoorRemoveAccessDesc = "Remove a player's access to the door you're looking at.",
	cmdDoorResetAccessDesc = "Reset all door access.",
	dDoorLocked = "You have successfully locked this door.",
	dDoorUnlocked = "You have successfully unlocked this door.",
	dAccessSet = "You have successfully changed access.",
	dAccessRemoved = "You have successfully removed access.",
	dAccessReset = "You have successfully reset access.",
})
ix.lang.AddTable("fr", {
	cmdDoorLockDesc = "Fermer la porte.",
	cmdDoorUnlockDesc = "Ouvrir la porte.",
	cmdDoorSetAccessDesc = "Définir l'accès d'un joueur (owner, tenant, guest) à la porte que vous regardez.",
	cmdDoorRemoveAccessDesc = "Retirer l'accès d'un joueur à la porte que vous regardez.",
	cmdDoorResetAccessDesc = "Réinitialiser tout accès aux portes.",
	dDoorLocked = "Vous avez fermé cette porte.",
	dDoorUnlocked = "Vous avez ouvert cette porte.",
	dAccessSet = "Vous avez modifié l'accès.",
	dAccessRemoved = "Vous avez retiré l'accès.",
	dAccessReset = "Vous avez réinitialisé l'accès.",
})
ix.lang.AddTable("es-es", {
	cmdDoorLockDesc = "Cerrar la puerta.",
	cmdDoorUnlockDesc = "Abrir la puerta.",
	cmdDoorSetAccessDesc = "Asignar acceso (owner, tenant, guest) al jugador para la puerta que miras.",
	cmdDoorRemoveAccessDesc = "Quitar el acceso del jugador a la puerta que miras.",
	cmdDoorResetAccessDesc = "Restablecer todo el acceso de las puertas.",
	dDoorLocked = "Has cerrado esta puerta correctamente.",
	dDoorUnlocked = "Has abierto esta puerta correctamente.",
	dAccessSet = "Has cambiado el acceso correctamente.",
	dAccessRemoved = "Has quitado el acceso correctamente.",
	dAccessReset = "Has restablecido el acceso correctamente.",
})

do
	ix.command.Add("DoorLock", {
		description = "@cmdDoorLockDesc",
		privilege = "Manage Doors",
		adminOnly = true,
		OnRun = function(self, client)
			local entity = client:GetEyeTrace().Entity

			if IsValid(entity) and entity:IsDoor() then
				local partner = entity:GetDoorPartner()

				if IsValid(partner) then
					partner:Fire("lock")
				end

				entity:Fire("lock")

				return "@dDoorLocked"
			else
				return "@dNotValid"
			end
		end
	})

	ix.command.Add("DoorUnlock", {
		description = "@cmdDoorUnlockDesc",
		privilege = "Manage Doors",
		adminOnly = true,
		OnRun = function(self, client)
			local entity = client:GetEyeTrace().Entity

			if IsValid(entity) and entity:IsDoor() then
				local partner = entity:GetDoorPartner()

				if IsValid(partner) then
					partner:Fire("unlock")
				end

				entity:Fire("unlock")

				return "@dDoorUnlocked"
			else
				return "@dNotValid"
			end
		end
	})

	local access = {
		["owner"] = DOOR_OWNER,
		["tenant"] = DOOR_TENANT,
		["guest"] = DOOR_GUEST,
	}
	ix.command.Add("DoorSetAccess", {
		description = "@cmdDoorSetAccessDesc",
		privilege = "Manage Doors",
		adminOnly = true,
		arguments = {ix.type.character, bit.bor(ix.type.string, ix.type.optional)},
		OnRun = function(self, client, target, acc)
			local entity = client:GetEyeTrace().Entity

			if IsValid(entity) and entity:IsDoor() then
				local a = access[acc] or DOOR_OWNER

				PLUGIN:DoorSetAccess(target:GetPlayer(), entity, a)

				return "@dAccessSet"
			else
				return "@dNotValid"
			end
		end
	})

	ix.command.Add("DoorRemoveAccess", {
		description = "@cmdDoorRemoveAccessDesc",
		privilege = "Manage Doors",
		adminOnly = true,
		arguments = {ix.type.character},
		OnRun = function(self, client, target, acc)
			local entity = client:GetEyeTrace().Entity

			if IsValid(entity) and entity:IsDoor() then
				PLUGIN:DoorRemoveAccess(target:GetPlayer(), entity)

				return "@dAccessRemoved"
			else
				return "@dNotValid"
			end
		end
	})

	ix.command.Add("DoorResetAccess", {
		description = "@cmdDoorResetAccessDesc",
		privilege = "Manage Doors",
		adminOnly = true,
		OnRun = function(self, client, target, acc)
			local entity = client:GetEyeTrace().Entity

			if IsValid(entity) and entity:IsDoor() then
				PLUGIN:DoorResetAccess(entity)

				return "@dAccessReset"
			else
				return "@dNotValid"
			end
		end
	})
end

if SERVER then
	PLUGIN.doors = PLUGIN.doors or {}
	PLUGIN.doorUsers = PLUGIN.doorUsers or {}

	function PLUGIN:SaveData()
		self:SetData(self.doors)
	end

	function PLUGIN:LoadData()
		self.doors = {}
		self.doorUsers = {}

		local data = self:GetData()

		for doorID, info in pairs(data) do
			self.doors[doorID] = info

			for charID, access in pairs(info) do
				self.doorUsers[charID] = self.doorUsers[charID] or {}
				self.doorUsers[charID][doorID] = true
			end
		end
	end

	function PLUGIN:DoorSetAccess(client, door, access, notBuy)
		if door.ixParent then
			self:DoorSetAccess(client, door, access, notBuy)

			return
		end

		local char = client:GetCharacter()
		local doorID = door:MapCreationID()

		if char and doorID then
			local id = char:GetID()

			self.doors[doorID] = self.doors[doorID] or {}
			self.doorUsers[id] = self.doorUsers[id] or {}

			self.doors[doorID][id] = access or DOOR_GUEST
			self.doorUsers[id][doorID] = true

			door.ixAccess = door.ixAccess or {}
			door.ixAccess[client] = access or DOOR_GUEST
		end
	end

	function PLUGIN:DoorRemoveAccess(client, door)
		if door.ixParent then
			self:DoorRemoveAccess(client, door)

			return
		end

		local char = client:GetCharacter()
		local doorID = door:MapCreationID()

		if char and doorID then
			local id = char:GetID()

			self.doors[doorID] = self.doors[doorID] or {}
			self.doorUsers[id] = self.doorUsers[id] or {}

			self.doors[doorID][id] = nil
			self.doorUsers[id][doorID] = nil

			door.ixAccess = door.ixAccess or {}
			door.ixAccess[client] = nil
		end
	end

	function PLUGIN:DoorResetAccess(door)
		if door.ixParent then
			self:DoorResetAccess(door)

			return
		end

		local doorID = door:MapCreationID()

		if doorID then
			self.doors[doorID] = nil

			for charID, doors in pairs(self.doorUsers) do
				if doors[doorID] then
					self.doorUsers[charID][doorID] = nil
				end
			end

			door.ixAccess = {}
		end
	end

	function PLUGIN:PrePlayerLoadedCharacter(client, character, oldcharacter)
		if oldcharacter then
			for doorID, _ in pairs(self.doorUsers[oldcharacter:GetID()] or {}) do
				local door = ents.GetMapCreatedEntity(doorID)

				if IsValid(door) then
					door.ixAccess = door.ixAccess or {}
					door.ixAccess[client] = nil
				end
			end
		end

		local charID = character:GetID()

		for doorID, _ in pairs(self.doorUsers[charID] or {}) do
			local door = ents.GetMapCreatedEntity(doorID)

			if IsValid(door) then
				door.ixAccess = door.ixAccess or {}
				door.ixAccess[client] = (self.doors[doorID] or {})[charID] or nil
			end
		end
	end

	function PLUGIN:PlayerDisconnected(client)
		local character = client:GetCharacter()

		if character then
			for doorID, _ in pairs(self.doorUsers[character:GetID()] or {}) do
				local door = ents.GetMapCreatedEntity(doorID)

				if IsValid(door) then
					door.ixAccess = door.ixAccess or {}
					door.ixAccess[client] = nil
				end
			end
		end
	end

	function PLUGIN:OnDoorAccessChanged(door, target, access, client)
		local doorID = door:MapCreationID()

		if doorID then
			if access and access > 0 then
				self:DoorSetAccess(target, door, access)
			else
				self:DoorRemoveAccess(target, door)
			end
		end
	end

	net.Receive("ixDoorPermission", function(length, client)
		local door = net.ReadEntity()
		local target = net.ReadEntity()
		local access = net.ReadUInt(4)

		if (IsValid(target) and target:GetCharacter() and door.ixAccess and (door:GetDTEntity(0) == client or door:CheckDoorAccess(client, DOOR_OWNER)) and target != client) then
			access = math.Clamp(access or 0, DOOR_NONE, DOOR_TENANT)

			if (access == door.ixAccess[target]) then
				return
			end

			door.ixAccess[target] = access

			hook.Run("OnDoorAccessChanged", door, target, access, client)

			local recipient = {}

			for k, v in pairs(door.ixAccess) do
				if (v > DOOR_GUEST) then
					recipient[#recipient + 1] = k
				end
			end

			if (#recipient > 0) then
				net.Start("ixDoorPermission")
					net.WriteEntity(door)
					net.WriteEntity(target)
					net.WriteUInt(access, 4)
				net.Send(recipient)
			end
		end
	end)
end


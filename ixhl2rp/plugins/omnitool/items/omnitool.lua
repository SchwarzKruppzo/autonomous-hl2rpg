local PLUGIN = PLUGIN

ITEM.name = "omnitool.name"
ITEM.model = "models/alyx_emptool_prop.mdl"
ITEM.description = "omnitool.description"
ITEM.category = "omnitool.category"
ITEM.rarity = 3
ITEM.width = 1
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(7.9705405235291, 1.3049583435059, 131.99598693848),
	ang = Angle(86.487617492676, 186.46231079102, 0),
	fov = 1.7994338862117,
}
ITEM.contraband = true

function ITEM:GetName()
	return CLIENT and L(self.name) or (isfunction(l) and l(self.name) or self.name)
end

ITEM.functions.editCombineLock = {
	name = "omnitool.editCombineLock",
	OnClick = function(item)
		local lookedUpEntity = PLUGIN:GetLookedEntity(item.player)
		if (!IsValid(lookedUpEntity) or lookedUpEntity:GetClass() != "ix_combinelock") then
			return false
		end

		local access = lookedUpEntity:GetAccess()
		Derma_StringRequest(L("omnitool.lockAccessTitle"), L("omnitool.lockAccessPrompt", access), access, function(newAccess)
			netstream.Start("ixOmniEditCombineLock", item:GetID(), lookedUpEntity, newAccess)
		end)

		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		local lookedUpEntity = PLUGIN:GetLookedEntity(client)

		return PLUGIN:CanUseItem(client, item) and PLUGIN:IsLookedAt(client, lookedUpEntity, 360)
			and lookedUpEntity:GetClass() == "ix_combinelock"
			and client:HasIDAccess(lookedUpEntity:GetAccess())
	end
}

ITEM.functions.connectToScanner = {
	name = "omnitool.connect",
	OnRun = function(item)
		local client = item.player
		local lookedUpEntity = PLUGIN:GetLookedEntity(client)
		local scanners = ix.plugin.list and ix.plugin.list["combinescanners"]

		if (scanners and IsValid(lookedUpEntity) and lookedUpEntity:GetClass() == "ix_scanner"
			and PLUGIN:CanConnectToScanner(client, lookedUpEntity)
			and scanners:ConnectScannerToPlayer(client, lookedUpEntity)) then
			return false
		end

		if (IsValid(lookedUpEntity) and lookedUpEntity:GetClass() == "npc_manhack"
			and PLUGIN:CanConnectToManhack(client, lookedUpEntity)
			and PLUGIN:ConnectManhackToPlayer(client, lookedUpEntity)) then
			return false
		end

		client:NotifyLocalized("omnitool.connectionFailed")

		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		local lookedUpEntity = PLUGIN:GetLookedEntity(client)

		return PLUGIN:CanUseItem(client, item) and PLUGIN:CanConnectToRemote(client, lookedUpEntity)
	end
}


ITEM.combine = ITEM.combine or {}

ITEM.combine.editCitizenID = {
	name = "omnitool.editCitizenID",
	icon = "icon16/vcard_edit.png",
	OnRun = function(item, targetItem)
		if (!PLUGIN:CanUseItem(item.player, item) or !PLUGIN:CanUseItem(item.player, targetItem)
			or !PLUGIN:IsCitizenID(targetItem)) then
			return false
		end

		PLUGIN:OpenCitizenIDEditor(item.player, item, targetItem)

		return false
	end,
	OnCanRun = function(item, targetItem)
		return item != targetItem and PLUGIN:CanUseItem(item.player, item)
			and PLUGIN:CanUseItem(item.player, targetItem) and PLUGIN:IsCitizenID(targetItem)
	end
}

ITEM.combine.dropBioLock = {
	name = "omnitool.dropBioLock",
	icon = "icon16/disconnect.png",
	OnRun = function(item, targetItem)
		local client = item.player

		if (!targetItem.isWeapon or !targetItem.hasLock or !targetItem:GetData("locked")) then
			client:NotifyLocalized("omnitool.weaponNoBiolock")

			return false
		end

		targetItem:SetData("locked", nil)

		if (!client:IsCombine()) then
			local character = client:GetCharacter()
			local luck = tonumber(character and character:GetSpecial("lk")) or 0

			if (math.random(100) + luck - 1 < 95) then
				item:Remove()

				local position = client:GetPos() + Vector(0, 0, 30)
				local effect = EffectData()
					effect:SetStart(position)
					effect:SetOrigin(position)
					effect:SetMagnitude(0)
					effect:SetScale(0.5)
					effect:SetColor(25)
					effect:SetEntity(client)
				util.Effect("Explosion", effect, true, true)
				util.BlastDamage(client, client, position, 280, 20)
				client:NotifyLocalized("omnitool.biolockFailure")

				return false
			end
		end

		client:NotifyLocalized("omnitool.biolockSuccess")

		return false
	end,
	OnCanRun = function(item, targetItem)
		if (item == targetItem or !PLUGIN:CanUseItem(item.player, item)
			or !PLUGIN:CanUseItem(item.player, targetItem) or !targetItem.isWeapon
			or !targetItem.hasLock) then
			return false
		end

		return CLIENT or targetItem:GetData("locked") != nil
	end
}

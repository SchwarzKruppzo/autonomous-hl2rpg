local PLUGIN = PLUGIN

local MAX_ACCESS_COUNT = 64
local MAX_ACCESS_LENGTH = 64
local ACCESS_PATTERN = "^[%w_%-]+%*?$"
local REQUEST_COOLDOWN = 0.5

local function takeCooldown(client, key)
	local cooldowns = client.ixOmniCooldowns or {}
	local currentTime = CurTime()

	client.ixOmniCooldowns = cooldowns

	if ((cooldowns[key] or 0) > currentTime) then
		return false
	end

	cooldowns[key] = currentTime + REQUEST_COOLDOWN

	return true
end

local function normalizeAccess(value)
	if (!isstring(value)) then
		return
	end

	value = string.Trim(value)

	if (#value == 0 or #value > MAX_ACCESS_LENGTH or !value:match(ACCESS_PATTERN)) then
		return
	end

	return value
end

local function normalizeAccessList(client, values)
	if (!istable(values)) then
		return
	end

	local access = {}
	local count = 0

	for _, value in ipairs(values) do
		count = count + 1

		if (count > MAX_ACCESS_COUNT) then
			return
		end

		value = normalizeAccess(value)

		if (!value or access[value] or !PLUGIN:CanGrantCitizenIDAccess(client, value)) then
			return
		end

		access[value] = true
	end

	return access
end

local function cardHasAccess(item, value)
	local storedAccess = item:GetData("access", {})

	if (!istable(storedAccess)) then
		return false
	end

	if (storedAccess[value]) then
		return true
	end

	for storedValue in pairs(storedAccess) do
		storedValue = normalizeAccess(storedValue)

		if (storedValue and storedValue:sub(-1) == "*") then
			local prefix = storedValue:sub(1, -2)

			if (value:sub(1, #prefix) == prefix) then
				return true
			end
		end
	end

	return false
end

local function getItem(itemID)
	return ix.Item.instances[tonumber(itemID or 0)]
end

function PLUGIN:GetOwnedOmniTool(client, itemID)
	local item = getItem(itemID)

	if (!self:IsOmniTool(item) or !self:CanUseItem(client, item)) then
		return
	end

	return item
end

function PLUGIN:CanGrantCitizenIDAccess(client, value)
	if (!IsValid(client) or !client:GetCharacter()) then
		return false
	end

	if (client:HasIDAccess(value)) then
		return true
	end

	for _, item in ipairs(client:GetItems()) do
		if (self:IsCitizenID(item) and self:CanUseItem(client, item) and cardHasAccess(item, value)) then
			return true
		end
	end

	return false
end

local function collectAccess(item)
	local access = {}
	local storedAccess = item:GetData("access", {})

	if (!istable(storedAccess)) then
		return access
	end

	for key in pairs(storedAccess) do
		key = normalizeAccess(key)

		if (key) then
			access[#access + 1] = key
		end
	end

	table.sort(access)

	return access
end

function PLUGIN:OpenCitizenIDEditor(client, tool, targetItem)
	if (!IsValid(client) or !self:IsOmniTool(tool) or !self:GetOwnedOmniTool(client, tool:GetID())
		or !self:IsCitizenID(targetItem) or !self:CanUseItem(client, targetItem)) then
		return false
	end

	if (!takeCooldown(client, "openCardEditor")) then
		return false
	end

	local cards = {}

	for _, item in ipairs(client:GetItems()) do
		if (item != targetItem and self:IsCitizenID(item) and self:CanUseItem(client, item)) then
			cards[#cards + 1] = {
				id = item:GetID(),
				name = item:GetData("name", "nobody"),
				number = item:GetData("number", ""),
				access = collectAccess(item)
			}
		end
	end

	table.sort(cards, function(left, right)
		return (left.name or "") < (right.name or "")
	end)

	netstream.Start(client, "ixOmniCitizenIDEdit", tool:GetID(), targetItem:GetID(), {
		name = targetItem:GetData("name", "nobody"),
		number = targetItem:GetData("number", ""),
		access = collectAccess(targetItem)
	}, cards)

	return true
end

netstream.Hook("ixOmniEditCombineLock", function(client, toolID, combineLock, newAccess)
	local tool = PLUGIN:GetOwnedOmniTool(client, toolID)

	if (!tool or !IsValid(combineLock) or combineLock:GetClass() != "ix_combinelock"
		or PLUGIN:GetLookedEntity(client) != combineLock
		or client:GetPos():DistToSqr(combineLock:GetPos()) > 360 * 360) then
		return
	end

	if (!takeCooldown(client, "editLock")) then
		return
	end

	if (!client:HasIDAccess(combineLock:GetAccess())) then
		combineLock:DisplayError()
		client:NotifyLocalized("omnitool.lockAccessDenied")

		return
	end

	newAccess = normalizeAccess(newAccess)

	if (!newAccess or !client:HasIDAccess(newAccess)) then
		combineLock:DisplayError()
		client:NotifyLocalized("omnitool.lockAccessUnavailable")

		return
	end

	combineLock:SetAccess(newAccess)
	combineLock:EmitSound("buttons/combine_button7.wav")
	client:NotifyLocalized("omnitool.lockAccessChanged", newAccess)
end)

netstream.Hook("ixOmniCitizenIDEdit", function(client, toolID, itemID, newData)
	local tool = PLUGIN:GetOwnedOmniTool(client, toolID)
	local item = getItem(itemID)

	if (!tool or !PLUGIN:IsCitizenID(item) or !PLUGIN:CanUseItem(client, item) or !istable(newData)) then
		return
	end

	if (!takeCooldown(client, "editCard")) then
		return
	end

	local access = normalizeAccessList(client, newData.access)

	if (!access) then
		client:NotifyLocalized("omnitool.invalidAccessList")

		return
	end

	item:SetData("access", access)
	hook.Run("OnIDCardUpdated", item)
	client:NotifyLocalized("omnitool.cardAccessChanged")
end)

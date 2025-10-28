local lib = ix.util.Lib("EntityDraw", {})

lib.DrawHookCallbacks = {}
lib.EnterRangeCallback = {}
lib.EntitiesInRange = {} -- Entities in range with callbacks registered

local DEFAULT_ENT_MAX_DISTANCE = 90000
local RENDER_DISTANCE_CLIENT_SETTING = 1

function lib:AddCachedDrawCallback(sHookName, sEntClassName, nMaxDistance, fCallback)
	if !isstring(sEntClassName) then
		error("ERROR: Attempted to add entity ui class subscription but passed invalid ent class. String expected got: " .. type(sEntClassName))
		return
	end

	-- Make max distance an optional param
	if fCallback == nil and isfunction(nMaxDistance) then
		fCallback = nMaxDistance
		nMaxDistance = DEFAULT_ENT_MAX_DISTANCE
	end

	self.DrawHookCallbacks[sEntClassName] = self.DrawHookCallbacks[sEntClassName] or {}
	self.DrawHookCallbacks[sEntClassName][sHookName] = self.DrawHookCallbacks[sEntClassName][sHookName] or {}

	table.insert(self.DrawHookCallbacks[sEntClassName][sHookName], {maxDistance = nMaxDistance, callback = fCallback})
end

--[[
	Registers a callback to be called when an entity enters the range of the entity range cache
	sCallbackUID - A unique string id for this callback
	sEntClassName - The class of the entity to subscribe to
--]]
function lib:AddEnterRangeCallback(sCallbackUID, sEntClassName, fCallback)
	if !isstring(sEntClassName) then
		error("ERROR: Attempted to add entity enter range subscription but passed invalid ent class. String expected got: " .. type(sEntClassName))
		return
	end

	self.EnterRangeCallback[sEntClassName] = self.EnterRangeCallback[sEntClassName] or {}
	self.EnterRangeCallback[sEntClassName][sCallbackUID] = fCallback
end

local ENTITY_DISCOVERY_DISTANCE = 512 -- How large of a radius to look for entites around the player
local ENTITY_DISCOVERY_INTERVAL = 2 -- How often to search for entites in range of the player
local ENTITY_DISTANCE_REFRESH_INTERVAL = 0.4 -- How often to update the distance a player is from an entity

local AllEntitiesInRange = {} -- Cache of entities found near the player even ones that don't have draw callbacks, this is indexed by the entities for quick lookup

-- Checks whether the passed entity is within the players render range
function lib:IsInRange(eEnt)
	return AllEntitiesInRange[eEnt]
end

local flLastRefresh = CurTime()
local flLastDistanceRefresh = CurTime() 
-- Searches for entities nearby and updates the cache
local function updateEntityRangeCache()
	if (flLastRefresh or 0) + ENTITY_DISCOVERY_INTERVAL > CurTime() then return end
	lib.EntitiesInRange = {} -- dump the old table
	local tCurrentEntitiesInRange = {}


	local eLocalPlayer = LocalPlayer()
	local vPlayerPosition = eLocalPlayer:GetPos()
	local tEntsInRange = ents.FindInSphere(vPlayerPosition, ENTITY_DISCOVERY_DISTANCE * RENDER_DISTANCE_CLIENT_SETTING)

	for index = 1, #tEntsInRange do
		local ent = tEntsInRange[index]
		if not IsValid(ent) then continue end

		local sEntClass = ent:GetClass()

		tCurrentEntitiesInRange[ent] = true
		-- Check if the entity was in range before. If not call the enter range callback if one exists
		local tCallbacks = lib.EnterRangeCallback[sEntClass]
		if not AllEntitiesInRange[ent] and tCallbacks then
			-- Run any callbacks subscribed to this entity coming into range
			for sCallbackUID, fCallback in pairs(tCallbacks) do
				if fCallback then fCallback(ent) end
			end
		end

		local sEntClass = ent:GetClass()
		if not lib.DrawHookCallbacks[sEntClass] then continue end

		nEntDistance = vPlayerPosition:DistToSqr(ent:GetPos())
		table.insert(lib.EntitiesInRange, {ent_class = sEntClass, ent_distance = nEntDistance, ent = ent})
	end

	AllEntitiesInRange = tCurrentEntitiesInRange

	local flCurTime = CurTime()
	flLastRefresh = flCurTime
	flLastDistanceRefresh = flCurTime
end

-- Updates the distances of all entities in the cache
local function updateEntityDistances()
	if (flLastDistanceRefresh or 0) + ENTITY_DISTANCE_REFRESH_INTERVAL > CurTime() then return end

	local vPlayerPosition = LocalPlayer():GetPos()

	for index = 1, #lib.EntitiesInRange do
		local tEntData = lib.EntitiesInRange[index]
		if IsValid(tEntData.ent) then
			tEntData.ent_distance = vPlayerPosition:DistToSqr(tEntData.ent:GetPos())
		end
	end

	flLastDistanceRefresh = CurTime()
end


local function runHooks(sHookName, tEntData)
	local tHooks = lib.DrawHookCallbacks[tEntData.ent_class][sHookName]
	if not tHooks then return end
	for j=1, #tHooks do
		local tEntry = tHooks[ j ]
		if tEntData.ent_distance <= tEntry.maxDistance * RENDER_DISTANCE_CLIENT_SETTING then
			tEntry.callback(tEntData.ent)
		end
	end
end

hook.Add("PostDrawTranslucentRenderables", "ix.CachedPostDrawTrans", function()
	-- Call the DrawEntityUI hook on all valid ents in the cache.
	for index = 1, #lib.EntitiesInRange do
		local tEntData = lib.EntitiesInRange[index]
		if tEntData and IsValid(tEntData.ent) then
			runHooks("PostDrawTranslucentRenderables", tEntData) -- Runs any callbacks subscribed to this ent type on this hook, if any exist
		end
	end
end)

hook.Add("PostPlayerDraw", "ix.CachedPostPlayerDraw", function()
	-- Call the DrawEntityUI hook on all valid ents in the cache.
	for index = 1, #lib.EntitiesInRange do
		local tEntData = lib.EntitiesInRange[index]
		if tEntData and IsValid(tEntData.ent) then
			runHooks("PostPlayerDraw", tEntData) -- Runs any callbacks subscribed to this ent type on this hook, if any exist
		end
	end
end)

hook.Add("PostDrawOpaqueRenderables", "ix.CachedPostDrawOpaqueRenderables", function()
	-- Call the DrawEntityUI hook on all valid ents in the cache.
	for index = 1, #lib.EntitiesInRange do
		local tEntData = lib.EntitiesInRange[index]
		if tEntData and IsValid( tEntData.ent ) then
			runHooks( "PostDrawOpaqueRenderables", tEntData ) -- Runs any callbacks subscribed to this ent type on this hook, if any exist
		end
	end
end)

hook.Add("SlowThink", "lib.CachedSlowThink", function()
	updateEntityRangeCache()
	updateEntityDistances()

	-- Call the DrawEntityUI hook on all valid ents in the cache.
	for index = 1, #lib.EntitiesInRange do
		local tEntData = lib.EntitiesInRange[index]
		if tEntData and IsValid(tEntData.ent) then
			runHooks("SlowThink", tEntData) -- Runs any callbacks subscribed to this ent type on this hook, if any exist
		end
	end
end)
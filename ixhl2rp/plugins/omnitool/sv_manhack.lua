local PLUGIN = PLUGIN

local CONTROLLER_CLASS = "ix_manhack_controller"
local CONTROLLER_MINS = Vector(-8, -8, -4)
local CONTROLLER_MAXS = Vector(8, 8, 4)
local MANHACK_SOUNDS = {
	"NPC_Manhack.EngineSound1",
	"NPC_Manhack.BladeSound",
	"NPC_Manhack.Grind",
	"NPC_Manhack.Slice"
}

local function StopControllerMovement(controller)
	if (!IsValid(controller)) then
		return
	end

	local physicsObject = controller:GetPhysicsObject()

	if (IsValid(physicsObject)) then
		physicsObject:SetVelocity(vector_origin)
		physicsObject:SetAngleVelocity(vector_origin)
	end
end

local function CopyBodygroups(entity)
	local bodygroups = {}

	for _, bodygroup in ipairs(entity:GetBodyGroups()) do
		bodygroups[bodygroup.id] = entity:GetBodygroup(bodygroup.id)
	end

	return bodygroups
end

local function ApplyBodygroups(entity, bodygroups)
	for id, value in pairs(bodygroups or {}) do
		entity:SetBodygroup(id, value)
	end
end

local function CaptureManhack(manhack)
	local health = math.max(manhack:Health(), 1)

	return {
		owner = manhack:GetNetVar("owner"),
		health = health,
		maxHealth = math.max(manhack:GetMaxHealth(), health),
		spawnFlags = manhack:GetSpawnFlags(),
		position = manhack:GetPos(),
		angles = manhack:GetAngles(),
		name = manhack:GetName(),
		skin = manhack:GetSkin(),
		color = manhack:GetColor(),
		renderMode = manhack:GetRenderMode(),
		material = manhack:GetMaterial(),
		bodygroups = CopyBodygroups(manhack),
		constructionSaved = manhack.constructionSaved == true
	}
end

local function StopNativeManhack(manhack)
	if (!IsValid(manhack)) then
		return
	end

	for _, soundName in ipairs(MANHACK_SOUNDS) do
		manhack:StopSound(soundName)
	end

	if (isfunction(manhack.SetMoveVelocity)) then
		manhack:SetMoveVelocity(vector_origin)
	end

	manhack:SetAbsVelocity(vector_origin)
	manhack:SetMoveType(MOVETYPE_NONE)

	if (isfunction(manhack.SetNPCState)) then
		manhack:SetNPCState(NPC_STATE_SCRIPT)
	end

	if (isfunction(manhack.SetSchedule)) then
		manhack:SetSchedule(SCHED_NPC_FREEZE)
	end
end

local function FindRestorePosition(snapshot, position, filter)
	local candidates = {}

	if (isvector(position)) then
		candidates[#candidates + 1] = position
		candidates[#candidates + 1] = position + Vector(0, 0, 8)
	end

	if (snapshot and isvector(snapshot.position)) then
		candidates[#candidates + 1] = snapshot.position
	end

	for _, candidate in ipairs(candidates) do
		if (!isvector(candidate) or !util.IsInWorld(candidate)) then
			continue
		end

		local trace = util.TraceHull({
			start = candidate,
			endpos = candidate,
			mins = CONTROLLER_MINS,
			maxs = CONTROLLER_MAXS,
			filter = filter,
			mask = MASK_SOLID
		})

		if (!trace.StartSolid) then
			return candidate
		end
	end

	return snapshot and snapshot.position or position
end

local function RestoreNativeManhack(snapshot, position, angles, health)
	if (!istable(snapshot)) then
		return
	end

	local manhack = ents.Create("npc_manhack")

	if (!IsValid(manhack)) then
		return
	end

	position = FindRestorePosition(snapshot, position)
	angles = isangle(angles) and Angle(0, angles.y, 0) or Angle(0, snapshot.angles.y, 0)

	manhack:SetPos(position)
	manhack:SetAngles(angles)

	if (isnumber(snapshot.spawnFlags) and snapshot.spawnFlags != 0) then
		manhack:SetKeyValue("spawnflags", tostring(snapshot.spawnFlags))
	end

	if (isstring(snapshot.name) and snapshot.name != "") then
		manhack:SetName(snapshot.name)
	end

	manhack:Spawn()
	manhack:Activate()
	manhack:SetSkin(snapshot.skin or 0)
	manhack:SetColor(snapshot.color or color_white)
	manhack:SetRenderMode(snapshot.renderMode or RENDERMODE_NORMAL)
	manhack:SetMaterial(snapshot.material or "")
	ApplyBodygroups(manhack, snapshot.bodygroups)

	local maxHealth = math.max(tonumber(snapshot.maxHealth) or 1, 1)
	manhack:SetMaxHealth(maxHealth)
	manhack:SetHealth(math.Clamp(tonumber(health) or snapshot.health or maxHealth, 1, maxHealth))
	manhack:SetNWEntity("OmniPilot", NULL)
	manhack:SetNetVar("owner", snapshot.owner)

	if (snapshot.constructionSaved) then
		local construction = ix.plugin.Get("construction")

		if (construction and isfunction(construction.AddConstructionToSave)) then
			construction:AddConstructionToSave(manhack)
		end
	end

	StopNativeManhack(manhack)

	return manhack
end

local function CreateController(client, manhack)
	local position = manhack:GetPos()
	local trace = util.TraceHull({
		start = position,
		endpos = position,
		mins = CONTROLLER_MINS,
		maxs = CONTROLLER_MAXS,
		filter = {client, manhack},
		mask = MASK_SOLID
	})

	if (trace.StartSolid or !util.IsInWorld(position)) then
		return
	end

	local snapshot = CaptureManhack(manhack)
	local controller = ents.Create(CONTROLLER_CLASS)

	if (!IsValid(controller)) then
		return
	end

	controller:SetPos(position)
	controller:SetAngles(Angle(0, manhack:GetAngles().y, 0))
	controller:SetPilot(client)
	controller:SetYawOffset(math.AngleDifference(manhack:GetAngles().y, client:EyeAngles().y))
	controller:Spawn()

	local physicsObject = controller:GetPhysicsObject()

	if (controller:IsMarkedForDeletion() or !IsValid(physicsObject)) then
		controller:Remove()
		return
	end

	controller:SetSkin(snapshot.skin)
	controller:SetColor(snapshot.color)
	controller:SetRenderMode(snapshot.renderMode)
	controller:SetMaterial(snapshot.material)
	ApplyBodygroups(controller, snapshot.bodygroups)
	controller:SetMaxHealth(snapshot.maxHealth)
	controller:SetHealth(snapshot.health)
	controller:SetNetVar("owner", snapshot.owner)
	controller.ixOmniManhackSnapshot = snapshot

	StopControllerMovement(controller)
	physicsObject:Wake()

	manhack:SetNWEntity("OmniPilot", NULL)
	manhack.ixOmniReplacing = true
	StopNativeManhack(manhack)
	manhack:Remove()

	return controller, snapshot
end

local function RestorePlayerControl(client)
	if (!IsValid(client)) then
		return
	end

	local wasFrozen = client.ixOmniManhackWasFrozen
	local oldEyeAngles = client.ixOmniManhackEyeAngles

	client:SetNWEntity("OmniManhack", NULL)
	client:SetNWEntity("OmniManhackController", NULL)
	client:SetViewEntity(client)

	if (wasFrozen != nil) then
		client:Freeze(wasFrozen == true)
	end

	if (isangle(oldEyeAngles)) then
		client:SetEyeAngles(oldEyeAngles)
	end

	client.ixOmniManhackWasFrozen = nil
	client.ixOmniManhackEyeAngles = nil
	client.ixOmniManhackEntity = nil
	client.ixOmniManhackSnapshot = nil
end

function PLUGIN:GetPilotingManhackController(client)
	if (!IsValid(client)) then
		return NULL
	end

	return client:GetNWEntity("OmniManhackController")
end

function PLUGIN:GetPilotingManhack(client)
	if (!IsValid(client)) then
		return NULL
	end

	local controller = self:GetPilotingManhackController(client)

	if (IsValid(controller)) then
		return controller
	end

	return client:GetNWEntity("OmniManhack")
end

function PLUGIN:IsPilotManhack(client)
	local controller = self:GetPilotingManhackController(client)

	return IsValid(controller) and controller:GetClass() == CONTROLLER_CLASS
		and controller:GetPilot() == client
end

function PLUGIN:EjectManhack(client, restoreManhack)
	if (!IsValid(client)) then
		return false
	end

	local controller = self:GetPilotingManhackController(client)
	local hasControlState = IsValid(controller) or client.ixOmniManhackWasFrozen != nil
		or client.ixOmniManhackEntity != nil

	if (!hasControlState) then
		return false
	end

	restoreManhack = restoreManhack != false

	local snapshot = IsValid(controller) and controller.ixOmniManhackSnapshot
		or client.ixOmniManhackSnapshot
	local position = IsValid(controller) and controller:GetPos()
		or snapshot and snapshot.position
	local angles = IsValid(controller) and controller:GetAngles()
		or snapshot and snapshot.angles
	local health = IsValid(controller) and controller:Health()
		or snapshot and snapshot.health

	if (IsValid(controller)) then
		position = FindRestorePosition(snapshot, position, controller)
		controller:SetPilot(NULL)
		controller.ixOmniRemoving = true
		controller:SetSolid(SOLID_NONE)
		controller:SetMoveType(MOVETYPE_NONE)
		StopControllerMovement(controller)
	end

	RestorePlayerControl(client)

	if (IsValid(controller)) then
		controller:Remove()
	end

	local manhack

	if (restoreManhack) then
		manhack = RestoreNativeManhack(snapshot, position, angles, health)
	end

	return true, manhack
end

function PLUGIN:DestroyControlledManhack(controller)
	if (!IsValid(controller) or controller:GetClass() != CONTROLLER_CLASS) then
		return false
	end

	local client = controller:GetPilot()

	if (IsValid(client) and self:GetPilotingManhackController(client) == controller) then
		return self:EjectManhack(client, false)
	end

	controller.ixOmniRemoving = true
	controller:Remove()

	return true
end

function PLUGIN:ConnectManhackToPlayer(client, manhack)
	if (IsValid(client) and (client.ixOmniManhackWasFrozen != nil
		or IsValid(self:GetPilotingManhackController(client)))) then
		self:EjectManhack(client)
	end

	if (!self:CanConnectToManhack(client, manhack)) then
		return false
	end

	local oldEyeAngles = client:EyeAngles()
	local controller, snapshot = CreateController(client, manhack)

	if (!IsValid(controller)) then
		return false
	end

	client.ixOmniManhackWasFrozen = client:IsFrozen()
	client.ixOmniManhackEyeAngles = oldEyeAngles
	client.ixOmniManhackEntity = controller
	client.ixOmniManhackSnapshot = snapshot
	client:SetNWEntity("OmniManhack", controller)
	client:SetNWEntity("OmniManhackController", controller)
	client:SetViewEntity(controller)

	client:NotifyLocalized("omnitool.manhackConnected")

	return true
end

function PLUGIN:StartCommand(client, command)
	local controller = self:GetPilotingManhackController(client)

	if (!IsValid(controller) or controller:GetClass() != CONTROLLER_CLASS
		or controller:GetPilot() != client or client.ixOmniManhackEntity != controller) then
		return
	end

	if (command:KeyDown(IN_USE)) then
		if ((controller.ixOmniNextEject or 0) <= CurTime()) then
			controller.ixOmniNextEject = CurTime() + 0.5
			self:EjectManhack(client)
		end

		command:RemoveKey(IN_USE)
		return
	end

	local physicsObject = controller:GetPhysicsObject()

	if (!IsValid(physicsObject)) then
		self:EjectManhack(client)
		return
	end

	command:ClearMovement()
	command:RemoveKey(bit.bor(IN_ATTACK, IN_ATTACK2, IN_RELOAD, IN_USE))
end

function PLUGIN:KeyPress(client, key)
	if (key != IN_USE or !self:IsPilotManhack(client)) then
		return
	end

	local controller = self:GetPilotingManhackController(client)

	if ((controller.ixOmniNextEject or 0) <= CurTime()) then
		controller.ixOmniNextEject = CurTime() + 0.5
		self:EjectManhack(client)
	end

	return true
end

function PLUGIN:PlayerUse(client)
	if (self:IsPilotManhack(client)) then
		return false
	end
end

function PLUGIN:PlayerNoClip(client)
	if (self:IsPilotManhack(client)) then
		return false
	end
end

function PLUGIN:DoPlayerDeath(client)
	self:EjectManhack(client)
end

function PLUGIN:CharacterLoaded(character)
	self:EjectManhack(character:GetPlayer())
end

function PLUGIN:PlayerDisconnected(client)
	self:EjectManhack(client)
end

function PLUGIN:PreCleanupMap()
	self.ixOmniCleaning = true

	for _, client in ipairs(player.GetAll()) do
		self:EjectManhack(client, false)
	end
end

function PLUGIN:PostCleanupMap()
	self.ixOmniCleaning = nil
end

function PLUGIN:EntityRemoved(entity)
	if (entity:GetClass() != CONTROLLER_CLASS or entity.ixOmniRemoving) then
		return
	end

	for _, client in ipairs(player.GetAll()) do
		if (client.ixOmniManhackEntity == entity) then
			RestorePlayerControl(client)
		end
	end
end

timer.Create("ixOmniManhackCleanup", 0.5, 0, function()
	for _, client in ipairs(player.GetAll()) do
		local controller = PLUGIN:GetPilotingManhackController(client)

		if (IsValid(controller)) then
			local character = client:GetCharacter()
			local physicsObject = controller:GetPhysicsObject()
			local ownsManhack = character
				and tonumber(controller:GetNetVar("owner")) == character:GetID()

			if (controller:GetClass() != CONTROLLER_CLASS or controller:GetPilot() != client
				or client.ixOmniManhackEntity != controller or !IsValid(physicsObject)
				or !client:Alive() or !client:IsCombine() or client:IsRestricted()
				or !ownsManhack) then
				PLUGIN:EjectManhack(client)
			end
		elseif (client.ixOmniManhackWasFrozen != nil or client.ixOmniManhackEntity != nil) then
			RestorePlayerControl(client)
		end
	end
end)

local COMMAND = {}
COMMAND.description = "omnitool.manhackEjectDesc"

function COMMAND:OnRun(client)
	if (PLUGIN:IsPilotManhack(client)) then
		PLUGIN:EjectManhack(client)
	end
end

ix.command.Add("ManhackEject", COMMAND)

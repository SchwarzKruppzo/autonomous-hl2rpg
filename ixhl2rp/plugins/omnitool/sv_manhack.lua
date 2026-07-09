local PLUGIN = PLUGIN

local CONTROLLER_CLASS = "ix_manhack_controller"
local CONTROLLER_MINS = Vector(-8, -8, -4)
local CONTROLLER_MAXS = Vector(8, 8, 4)
local MANHACK_SPEED = 350
local MANHACK_ACCELERATION = 1400
local MANHACK_DECELERATION = 2000

local function StopManhackMovement(manhack)
	if (!IsValid(manhack)) then
		return
	end

	if (isfunction(manhack.SetMoveVelocity)) then
		manhack:SetMoveVelocity(vector_origin)
	end

	manhack:SetAbsVelocity(vector_origin)

	local physicsObject = manhack:GetPhysicsObject()

	if (IsValid(physicsObject)) then
		physicsObject:SetVelocity(vector_origin)
		physicsObject:SetAngleVelocity(vector_origin)
	end
end

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

local function RestoreManhackState(manhack, position, angles)
	if (!IsValid(manhack)) then
		return
	end

	local moveType = manhack.ixOmniManhackMoveType
	local solid = manhack.ixOmniManhackSolid
	local collisionGroup = manhack.ixOmniManhackCollisionGroup
	local noDraw = manhack.ixOmniManhackNoDraw

	if (isvector(position) and util.IsInWorld(position)) then
		manhack:SetPos(position)
	end

	if (isangle(angles)) then
		manhack:SetAngles(angles)
	end

	if (isnumber(solid)) then
		manhack:SetSolid(solid)
	end

	if (isnumber(collisionGroup)) then
		manhack:SetCollisionGroup(collisionGroup)
	end

	if (isnumber(moveType)) then
		manhack:SetMoveType(moveType)
	end

	if (noDraw != nil) then
		manhack:SetNoDraw(noDraw == true)
	end

	manhack.ixOmniManhackMoveType = nil
	manhack.ixOmniManhackSolid = nil
	manhack.ixOmniManhackCollisionGroup = nil
	manhack.ixOmniManhackNoDraw = nil

	StopManhackMovement(manhack)
end

local function StopManhackControl(manhack, fallbackController)
	if (!IsValid(manhack)) then
		if (IsValid(fallbackController)) then
			StopControllerMovement(fallbackController)
			fallbackController:Remove()
		end

		return
	end

	local controller = manhack.ixOmniManhackController

	if (!IsValid(controller)) then
		controller = fallbackController
	end

	local position = IsValid(controller) and controller:GetPos() or manhack:GetPos()
	local angles = IsValid(controller) and controller:GetAngles() or manhack:GetAngles()

	manhack.ixOmniManhackController = nil

	if (IsValid(controller)) then
		StopControllerMovement(controller)

		if (isfunction(controller.SetControlledManhack)) then
			controller:SetControlledManhack(NULL)
		end

		controller:Remove()
	end

	RestoreManhackState(manhack, position, angles)
end

local function StartManhackControl(manhack)
	if (!IsValid(manhack)) then
		return
	end

	local position = manhack:GetPos()
	local trace = util.TraceHull({
		start = position,
		endpos = position,
		mins = CONTROLLER_MINS,
		maxs = CONTROLLER_MAXS,
		filter = manhack,
		mask = MASK_SOLID
	})

	if (trace.StartSolid or !util.IsInWorld(position)) then
		return
	end

	manhack.ixOmniManhackMoveType = manhack:GetMoveType()
	manhack.ixOmniManhackSolid = manhack:GetSolid()
	manhack.ixOmniManhackCollisionGroup = manhack:GetCollisionGroup()
	manhack.ixOmniManhackNoDraw = manhack:GetNoDraw()

	StopManhackMovement(manhack)
	manhack:SetMoveType(MOVETYPE_NONE)
	manhack:SetSolid(SOLID_NONE)
	manhack:SetNoDraw(true)

	local controller = ents.Create(CONTROLLER_CLASS)

	if (!IsValid(controller)) then
		RestoreManhackState(manhack)
		return
	end

	controller:SetPos(position)
	controller:SetAngles(Angle(0, manhack:GetAngles().y, 0))
	controller:Spawn()

	local physicsObject = controller:GetPhysicsObject()

	if (controller:IsMarkedForDeletion() or !IsValid(physicsObject)) then
		controller:Remove()
		RestoreManhackState(manhack)
		return
	end

	controller:SetControlledManhack(manhack)
	controller:SetSkin(manhack:GetSkin())
	controller:SetColor(manhack:GetColor())
	controller:SetRenderMode(manhack:GetRenderMode())
	controller:SetMaterial(manhack:GetMaterial())

	for _, bodygroup in ipairs(manhack:GetBodyGroups()) do
		controller:SetBodygroup(bodygroup.id, manhack:GetBodygroup(bodygroup.id))
	end

	StopControllerMovement(controller)
	physicsObject:Wake()

	manhack.ixOmniManhackController = controller
	manhack:DeleteOnRemove(controller)

	return controller
end

local function ApproachVelocity(currentVelocity, targetVelocity, maximumChange)
	local difference = targetVelocity - currentVelocity
	local differenceLength = difference:Length()

	if (differenceLength <= maximumChange or differenceLength == 0) then
		return targetVelocity
	end

	difference:Mul(maximumChange / differenceLength)
	currentVelocity:Add(difference)

	return currentVelocity
end

function PLUGIN:GetPilotingManhack(client)
	if (!IsValid(client)) then
		return NULL
	end

	return client:GetNWEntity("OmniManhack")
end

function PLUGIN:GetPilotingManhackController(client)
	if (!IsValid(client)) then
		return NULL
	end

	return client:GetNWEntity("OmniManhackController")
end

function PLUGIN:IsPilotManhack(client)
	return IsValid(self:GetPilotingManhack(client)) and IsValid(self:GetPilotingManhackController(client))
end

function PLUGIN:EjectManhack(client)
	if (!IsValid(client)) then
		return false
	end

	local manhack = self:GetPilotingManhack(client)
	local controller = self:GetPilotingManhackController(client)
	local wasFrozen = client.ixOmniManhackWasFrozen

	if (!IsValid(manhack) and !IsValid(controller) and wasFrozen == nil) then
		return false
	end

	if (IsValid(manhack)) then
		local pilot = manhack:GetNWEntity("OmniPilot")

		if (pilot == client) then
			manhack:SetNWEntity("OmniPilot", NULL)
			StopManhackControl(manhack, controller)
		elseif (!IsValid(pilot)) then
			StopManhackControl(manhack, controller)
		end
	elseif (IsValid(controller)) then
		StopControllerMovement(controller)
		controller:Remove()
	end

	client:SetNWEntity("OmniManhack", NULL)
	client:SetNWEntity("OmniManhackController", NULL)
	client:SetViewEntity(client)

	client:Freeze(wasFrozen == true)
	client.ixOmniManhackWasFrozen = nil

	return true
end

function PLUGIN:ConnectManhackToPlayer(client, manhack)
	if (IsValid(client) and client.ixOmniManhackWasFrozen != nil
		and !IsValid(self:GetPilotingManhack(client))) then
		self:EjectManhack(client)
	end

	if (!self:CanConnectToManhack(client, manhack)) then
		return false
	end

	local controller = StartManhackControl(manhack)

	if (!IsValid(controller)) then
		return false
	end

	client.ixOmniManhackWasFrozen = client:IsFrozen()
	manhack:SetNWEntity("OmniPilot", client)
	client:SetNWEntity("OmniManhack", manhack)
	client:SetNWEntity("OmniManhackController", controller)
	client:SetViewEntity(controller)

	client:NotifyLocalized("omnitool.manhackConnected")

	return true
end

function PLUGIN:StartCommand(client, command)
	local manhack = self:GetPilotingManhack(client)
	local controller = self:GetPilotingManhackController(client)

	if (!IsValid(manhack) or !IsValid(controller) or manhack:GetNWEntity("OmniPilot") != client
		or manhack.ixOmniManhackController != controller) then
		return
	end

	if (command:KeyDown(IN_USE)) then
		if ((manhack.ixOmniNextEject or 0) <= CurTime()) then
			manhack.ixOmniNextEject = CurTime() + 0.5
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

	local viewAngles = command:GetViewAngles()
	local forward = (command:KeyDown(IN_FORWARD) and 1 or 0) - (command:KeyDown(IN_BACK) and 1 or 0)
	local side = (command:KeyDown(IN_MOVERIGHT) and 1 or 0) - (command:KeyDown(IN_MOVELEFT) and 1 or 0)
	local direction = viewAngles:Forward() * forward + viewAngles:Right() * side

	if (command:KeyDown(IN_JUMP)) then
		direction = direction + vector_up
	elseif (command:KeyDown(IN_DUCK)) then
		direction = direction - vector_up
	end

	if (direction:LengthSqr() > 1) then
		direction:Normalize()
	end

	local targetVelocity = direction * MANHACK_SPEED
	local acceleration = direction:LengthSqr() > 0 and MANHACK_ACCELERATION or MANHACK_DECELERATION
	local velocity = ApproachVelocity(physicsObject:GetVelocity(), targetVelocity,
		acceleration * engine.TickInterval())

	physicsObject:SetVelocity(velocity)
	physicsObject:SetAngleVelocity(vector_origin)
	physicsObject:SetAngles(Angle(0, viewAngles.y, 0))
	physicsObject:Wake()

	command:ClearMovement()
	command:RemoveKey(bit.bor(IN_ATTACK, IN_ATTACK2, IN_RELOAD, IN_USE))
end

function PLUGIN:KeyPress(client, key)
	if (key != IN_USE or !self:IsPilotManhack(client)) then
		return
	end

	local manhack = self:GetPilotingManhack(client)

	if ((manhack.ixOmniNextEject or 0) <= CurTime()) then
		manhack.ixOmniNextEject = CurTime() + 0.5
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

function PLUGIN:EntityRemoved(entity)
	local class = entity:GetClass()

	if (class != "npc_manhack" and class != CONTROLLER_CLASS) then
		return
	end

	for _, client in ipairs(player.GetAll()) do
		if (self:GetPilotingManhack(client) == entity or self:GetPilotingManhackController(client) == entity) then
			self:EjectManhack(client)
		end
	end
end

timer.Create("ixOmniManhackCleanup", 0.5, 0, function()
	for _, client in ipairs(player.GetAll()) do
		local manhack = PLUGIN:GetPilotingManhack(client)
		local controller = PLUGIN:GetPilotingManhackController(client)
		local character = client:GetCharacter()
		local ownsManhack = character and IsValid(manhack)
			and tonumber(manhack:GetNetVar("owner")) == character:GetID()
		local controllerMatches = IsValid(controller) and isfunction(controller.GetControlledManhack)
			and controller:GetControlledManhack() == manhack

		if (IsValid(manhack) and (!IsValid(controller) or !controllerMatches
			or manhack:GetNWEntity("OmniPilot") != client or !client:Alive()
			or !client:IsCombine() or client:IsRestricted() or !ownsManhack)) then
			PLUGIN:EjectManhack(client)
		elseif (!IsValid(manhack) and (IsValid(controller) or client.ixOmniManhackWasFrozen != nil)) then
			PLUGIN:EjectManhack(client)
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

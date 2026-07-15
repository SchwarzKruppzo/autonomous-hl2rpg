AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local MOVE_FORCE = 15
local FAST_MOVE_FORCE = 30
local BRAKE_FORCE = 0.1
local ANGLE_PITCH_LIMIT = 40
local COLLISION_DAMAGE_MIN = 3
local COLLISION_DAMAGE_MAX = 5
local COLLISION_DAMAGE_COOLDOWN = 0.25
local COLLISION_FORCE_MIN = 800
local COLLISION_FORCE_MAX = 1200
local COLLISION_RECOIL_FORCE = 500
local BLADE_SWEEP_MINS = Vector(-18, -18, -18)
local BLADE_SWEEP_MAXS = Vector(18, 18, 18)
local BLADE_SWEEP_MAX_DISTANCE_SQR = 128 * 128
local BLADE_BLOCK_DISTANCE = 34
local BLADE_RECOIL_MIN_SPEED = 40
local BLADE_RECOIL_MAX_SPEED = 120
local BLADE_PLAYER_PUSH_SPEED = 80
local BLADE_PILOT_ARM_DELAY = 0.75
local BLADE_PILOT_ARM_DISTANCE_SQR = 96 * 96
local ENGINE_SOUND = Sound("NPC_Manhack.EngineSound1")
local BLADE_SOUND = Sound("NPC_Manhack.BladeSound")

local function IsBladeTarget(controller, target)
	local pilot = controller:GetPilot()

	return IsValid(pilot) and IsValid(target) and target:Health() > 0
		and (target:IsPlayer() or target:IsNPC() or target:IsNextBot())
		and (!target:IsPlayer() or target:Alive())
		and (target != pilot or controller.ixOmniPilotBladeArmed == true)
end

function ENT:Initialize()
	self:SetModel("models/manhack.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetTrigger(true)

	local sequence = self:LookupSequence("fly")

	if (sequence >= 0) then
		self:ResetSequence(sequence)
		self:SetPlaybackRate(1)
	end

	local physicsObject = self:GetPhysicsObject()

	if (!IsValid(physicsObject)) then
		self:Remove()
		return
	end

	physicsObject:EnableMotion(true)
	physicsObject:EnableGravity(false)
	physicsObject:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
	physicsObject:AddGameFlag(FVPHYSICS_NO_PLAYER_PICKUP)
	physicsObject:SetVelocity(vector_origin)
	physicsObject:SetAngleVelocity(vector_origin)
	physicsObject:Wake()

	self.shadowControl = {
		pos = self:GetPos(),
		angle = self:GetAngles(),
		secondstoarrive = 0.1,
		maxangular = 1000000,
		maxangulardamp = 1000000,
		maxspeed = 0,
		maxspeeddamp = 0,
		dampfactor = 1,
		teleportdistance = 0
	}

	self:SetMaxHealth(25)
	self:SetHealth(25)
	self.ixOmniLastBladePosition = self:WorldSpaceCenter()
	self.ixOmniPilotBladeArmTime = CurTime() + BLADE_PILOT_ARM_DELAY
	self.ixOmniPilotBladeArmed = false
	self:StartMotionController()

	self.engineSound = CreateSound(self, ENGINE_SOUND)
	self.bladeSound = CreateSound(self, BLADE_SOUND)
	self.engineSound:PlayEx(1, 100)
	self.bladeSound:PlayEx(0.5, 100)
end

function ENT:Think()
	if (self.engineSound) then
		self.engineSound:ChangePitch(100 + math.min(self:GetVelocity():Length() * 0.2, 50))
	end

	self:CheckBladeContacts()

	self:NextThink(CurTime())

	return true
end

function ENT:PhysicsUpdate(physicsObject)
	local pilot = self:GetPilot()
	local direction = vector_origin
	local hasVerticalInput = false

	if (IsValid(pilot)) then
		local angles = pilot:EyeAngles()
		angles.y = angles.y + self:GetYawOffset()
		angles.r = 0

		local forward = (pilot:KeyDown(IN_FORWARD) and 1 or 0) - (pilot:KeyDown(IN_BACK) and 1 or 0)
		local side = (pilot:KeyDown(IN_MOVERIGHT) and 1 or 0) - (pilot:KeyDown(IN_MOVELEFT) and 1 or 0)
		local movingUp = pilot:KeyDown(IN_JUMP)
		local movingDown = pilot:KeyDown(IN_DUCK)

		direction = angles:Forward() * forward + angles:Right() * side
		hasVerticalInput = forward != 0 or movingUp or movingDown

		if (movingUp) then
			direction = direction + vector_up
		elseif (movingDown) then
			direction = direction - vector_up
		end

		if (direction:LengthSqr() > 1) then
			direction:Normalize()
		end

		local force = pilot:KeyDown(IN_SPEED) and FAST_MOVE_FORCE or MOVE_FORCE
		physicsObject:ApplyForceCenter(direction * force)
	end

	physicsObject:ApplyForceCenter(-physicsObject:GetVelocity() * BRAKE_FORCE)

	if (!hasVerticalInput) then
		local velocity = physicsObject:GetVelocity()
		velocity.z = 0
		physicsObject:SetVelocity(velocity)
	end

	physicsObject:Wake()
end

function ENT:PhysicsSimulate(physicsObject, deltaTime)
	local angles = self:GetAngles()
	local pilot = self:GetPilot()

	if (IsValid(pilot)) then
		angles = pilot:EyeAngles()
		angles.y = angles.y + self:GetYawOffset()
		angles.p = math.Clamp(angles.p, -ANGLE_PITCH_LIMIT, ANGLE_PITCH_LIMIT)
		angles.r = 0
	end

	self.shadowControl.pos = self:GetPos()
	self.shadowControl.angle = angles
	self.shadowControl.delta = deltaTime

	physicsObject:Wake()
	physicsObject:ComputeShadowControl(self.shadowControl)
end

function ENT:FindBladeContact(startPosition, endPosition)
	local travel = endPosition - startPosition
	local travelLengthSqr = travel:LengthSqr()
	local pilot = self:GetPilot()
	local closestTarget
	local closestPosition
	local closestFraction

	for _, target in ipairs(ents.FindAlongRay(startPosition, endPosition,
		BLADE_SWEEP_MINS, BLADE_SWEEP_MAXS)) do
		if (!IsBladeTarget(self, target)) then
			continue
		end

		local targetPosition = target:WorldSpaceCenter()
		local fraction = 0

		if (travelLengthSqr > 0) then
			fraction = math.Clamp((targetPosition - startPosition):Dot(travel) / travelLengthSqr, 0, 1)
		end

		local contactPosition = startPosition + travel * fraction
		local obstruction = util.TraceLine({
			start = startPosition,
			endpos = targetPosition,
			filter = {self, pilot, target},
			mask = MASK_SOLID
		})

		if (obstruction.Hit or (closestFraction and fraction >= closestFraction)) then
			continue
		end

		closestTarget = target
		closestPosition = contactPosition
		closestFraction = fraction
	end

	return closestTarget, closestPosition, travel
end

function ENT:BlockBladeContact(target, contactPosition, startPosition, travel, velocity, physicsObject)
	if (!IsValid(physicsObject) or !isvector(contactPosition) or !isvector(startPosition)
		or !isvector(travel)) then
		return
	end

	local travelDirection = travel:GetNormalized()
	local targetIsAhead = travel:LengthSqr() > 0
		and (target:WorldSpaceCenter() - startPosition):Dot(travel) > 0

	if (targetIsAhead) then
		local blockedCenter = contactPosition - travelDirection * BLADE_BLOCK_DISTANCE
		local placement = util.TraceHull({
			start = blockedCenter,
			endpos = blockedCenter,
			mins = BLADE_SWEEP_MINS,
			maxs = BLADE_SWEEP_MAXS,
			filter = {self, self:GetPilot(), target},
			mask = MASK_SOLID
		})

		if (!placement.StartSolid and util.IsInWorld(blockedCenter)) then
			local centerOffset = self:WorldSpaceCenter() - self:GetPos()
			self:SetPos(blockedCenter - centerOffset)
		end
	end

	local away = self:WorldSpaceCenter() - target:WorldSpaceCenter()

	if (away:LengthSqr() == 0) then
		away = travel:LengthSqr() > 0 and -travel or -self:GetForward()
	end

	away:Normalize()

	if (targetIsAhead or velocity:Dot(away) < 0) then
		local recoilSpeed = math.Clamp(velocity:Length() * 0.35,
			BLADE_RECOIL_MIN_SPEED, BLADE_RECOIL_MAX_SPEED)
		physicsObject:SetVelocity(away * recoilSpeed)
	else
		physicsObject:ApplyForceCenter(away * COLLISION_RECOIL_FORCE)
	end
end

function ENT:CheckBladeContacts()
	local pilot = self:GetPilot()
	local physicsObject = self:GetPhysicsObject()

	if (!IsValid(pilot) or !IsValid(physicsObject)) then
		return
	end

	local currentPosition = self:WorldSpaceCenter()
	local startPosition = self.ixOmniLastBladePosition or currentPosition

	if (!self.ixOmniPilotBladeArmed and CurTime() >= (self.ixOmniPilotBladeArmTime or 0)
		and currentPosition:DistToSqr(pilot:WorldSpaceCenter()) >= BLADE_PILOT_ARM_DISTANCE_SQR) then
		self.ixOmniPilotBladeArmed = true
	end

	if (startPosition:DistToSqr(currentPosition) > BLADE_SWEEP_MAX_DISTANCE_SQR) then
		startPosition = currentPosition
	end

	local velocity = physicsObject:GetVelocity()
	local endPosition = currentPosition + velocity * engine.TickInterval()
	self.ixOmniLastBladePosition = currentPosition

	local target, contactPosition, travel = self:FindBladeContact(startPosition, endPosition)

	if (!IsValid(target)) then
		return
	end

	self:DealBladeDamage(target, target:WorldSpaceCenter(), velocity)
	self:BlockBladeContact(target, contactPosition, startPosition, travel, velocity, physicsObject)
	self.ixOmniLastBladePosition = self:WorldSpaceCenter()
end

function ENT:DealBladeDamage(target, hitPosition, velocity)
	if (!IsBladeTarget(self, target)) then
		return
	end

	self.ixOmniCollisionDamageCooldowns = self.ixOmniCollisionDamageCooldowns or {}

	if ((self.ixOmniCollisionDamageCooldowns[target] or 0) > CurTime()) then
		return
	end

	self.ixOmniCollisionDamageCooldowns[target] = CurTime() + COLLISION_DAMAGE_COOLDOWN

	local forceDirection = self:GetForward()

	if (isvector(velocity) and velocity:LengthSqr() > 0) then
		forceDirection = velocity:GetNormalized()
	end

	local force = forceDirection * math.random(COLLISION_FORCE_MIN, COLLISION_FORCE_MAX)
	hitPosition = isvector(hitPosition) and hitPosition or target:WorldSpaceCenter()
	local damageInfo = DamageInfo()

	damageInfo:SetDamage(math.random(COLLISION_DAMAGE_MIN, COLLISION_DAMAGE_MAX))
	damageInfo:SetDamageType(DMG_SLASH)
	damageInfo:SetAttacker(self)
	damageInfo:SetInflictor(self)
	damageInfo:SetDamageForce(force)
	damageInfo:SetDamagePosition(hitPosition)
	damageInfo:SetReportedPosition(hitPosition)
	target:TakeDamageInfo(damageInfo)

	local targetPhysics = target:GetPhysicsObject()

	if (target:IsPlayer()) then
		target:SetVelocity(forceDirection * BLADE_PLAYER_PUSH_SPEED)
	elseif (IsValid(targetPhysics)) then
		targetPhysics:ApplyForceOffset(force, hitPosition)
	end

	self:EmitSound("NPC_Manhack.Slice", 70, 100, 0.7)

	return true
end

function ENT:PhysicsCollide(collisionData, physicsObject)
	local hitNormal = collisionData.HitNormal

	if (self:DealBladeDamage(collisionData.HitEntity, collisionData.HitPos,
		collisionData.OurOldVelocity) and IsValid(physicsObject) and isvector(hitNormal)) then
		physicsObject:ApplyForceCenter(-hitNormal * COLLISION_RECOIL_FORCE)
	end
end

function ENT:StartTouch(target)
	if (IsValid(target)) then
		self:DealBladeDamage(target, target:WorldSpaceCenter(), self:GetVelocity())
	end
end

function ENT:Touch(target)
	if (IsValid(target)) then
		self:DealBladeDamage(target, target:WorldSpaceCenter(), self:GetVelocity())
	end
end

function ENT:OnTakeDamage(damageInfo)
	if (self:Health() <= 0) then
		return
	end

	self:SetHealth(self:Health() - damageInfo:GetDamage())

	if (self:Health() > 0) then
		return
	end

	self:EmitSound("NPC_Manhack.Die")

	local plugin = ix.plugin.Get("omnitool")

	if (plugin and isfunction(plugin.DestroyControlledManhack)) then
		plugin:DestroyControlledManhack(self)
	else
		self:Remove()
	end
end

function ENT:OnRemove()
	self:StopMotionController()

	if (self.engineSound) then
		self.engineSound:Stop()
	end

	if (self.bladeSound) then
		self.bladeSound:Stop()
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

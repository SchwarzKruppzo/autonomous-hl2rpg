AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local CONTROLLER_MINS = Vector(-8, -8, -4)
local CONTROLLER_MAXS = Vector(8, 8, 4)

function ENT:Initialize()
	self:SetModel("models/manhack.mdl")
	self:PhysicsInitBox(CONTROLLER_MINS, CONTROLLER_MAXS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionBounds(CONTROLLER_MINS, CONTROLLER_MAXS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

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
	physicsObject:EnableDrag(false)
	physicsObject:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
	physicsObject:AddGameFlag(FVPHYSICS_NO_PLAYER_PICKUP)
	physicsObject:SetVelocity(vector_origin)
	physicsObject:SetAngleVelocity(vector_origin)
	physicsObject:Wake()
end

function ENT:OnTakeDamage(damageInfo)
	local manhack = self:GetControlledManhack()

	if (IsValid(manhack)) then
		manhack:TakeDamageInfo(damageInfo)
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

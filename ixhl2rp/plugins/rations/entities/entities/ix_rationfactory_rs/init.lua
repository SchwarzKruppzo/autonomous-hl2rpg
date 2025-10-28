include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local SPAWN_ITEM = "ration_tier_1v"

function ENT:Initialize()
	self:SetModel("models/props_combine/combine_smallmonitor001.mdl")
	
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetSolid(SOLID_VPHYSICS)
	self.nextUse = 0
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

function ENT:PhysicsUpdate(physicsObject)
	if !self:IsPlayerHolding() and !self:IsConstrained() then
		physicsObject:SetVelocity(Vector(0, 0, 0))
		physicsObject:Sleep()
	end
end

function ENT:Touch(ent)
	if self.nextUse > CurTime() then
		return
	end

	self.nextUse = CurTime() + 1

	if !ent.GetItem then
		return
	end

	local item = ent:GetItem()

	if !item or item.uniqueID != "filled_ration" then
		return
	end
	
	local workers = item.workers or {}
	local held = ent.ixHeldOwner
	local pos, angles = ent:GetPos(), ent:GetAngles()
	ent:Remove()

	timer.Simple(0, function()
		local instance = ix.Item:Instance(SPAWN_ITEM)
		instance.workers = table.Copy(workers)
		if IsValid(held) then
			instance.workers[held:GetCharacter():GetID()] = true
		end
		
		ix.Item:Spawn(pos, ang, instance)
	end)

	self:EmitSound("buttons/button4.wav")
end
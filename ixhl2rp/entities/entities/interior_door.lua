AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)

	if SERVER then
		self:SetUseType(SIMPLE_USE)

		local obj = self:GetPhysicsObject()

		if IsValid(obj) then
			obj:EnableMotion(false)
		end
	end
end

function ENT:Use(activator) end

function ENT:KeyValue(key, value)
	if key == "model" then
		self:SetModel(value)
	end
end
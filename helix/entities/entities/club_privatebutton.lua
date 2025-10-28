AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.AutomaticFrameAdvance = true

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

function ENT:Use(activator)
	if activator:IsPlayer() then 
		if self.nextUse and self.nextUse >= CurTime() then
			return
		end
		
		if !self.door then
			for k, v in ipairs(ents.FindByClass("func_door")) do
				if v:GetName() == self.target then
					self.door = v
				end
			end
		end
		
		self.door:Fire("toggle")

		self:ResetSequence("press")
		self:EmitSound("buttons/combine_button1.wav")
		
		self.nextUse = CurTime() + 2
	end
end

function ENT:KeyValue(key, value)
	if key == "model" then
		self:SetModel(value)
	end

	if key == "target" then
		self.target = value
	end
end
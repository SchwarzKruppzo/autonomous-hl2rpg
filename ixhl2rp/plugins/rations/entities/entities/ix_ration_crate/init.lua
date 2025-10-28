include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local RATION_TO_FILL = "ration_tier_1"

function ENT:Initialize()
	self:SetModel("models/Items/item_item_crate.mdl")
	
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetHealth(50)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetCount(0)

	local physicsObject = self:GetPhysicsObject()
	
	if IsValid(physicsObject) then
		physicsObject:Wake()
		physicsObject:EnableMotion(true)
	end
end

function ENT:Explode()
	local effectData = EffectData()
	effectData:SetStart(self:GetPos())
	effectData:SetOrigin(self:GetPos())
	effectData:SetScale(8)
	
	util.Effect("GlassImpact", effectData, true, true)
	
	self:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav")
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

function ENT:OnTakeDamage(damageInfo)
	self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))
	
	if self:Health() <= 0 then
		self:Explode();
		self:Remove()
	end
end

local model = "models/items/item_item_crate.mdl"
function ENT:Touch(ent)
	if self.stop then
		return
	end

	if self.nextUse and self.nextUse > CurTime() then
		return
	end

	self.nextUse = CurTime() + 1

	if !ent.GetItem then
		return
	end

	local item = ent:GetItem()

	if !item or item.uniqueID != RATION_TO_FILL then
		return
	end
	
	ent:Remove()

	self.workers = self.workers or {}

	for charID, _ in pairs(item.workers or {}) do
		self.workers[#self.workers + 1] = charID
	end
	
	local held = ent.ixHeldOwner

	if IsValid(held) then
		self.workers[#self.workers + 1] = held:GetCharacter():GetID()
	end

	local newCount = self:GetCount() + 1

	if newCount == 10 then
		self.stop = true
	end
	
	self:SetCount(newCount)

	self:EmitSound("items/medshot4.wav")
end

function ENT:Use(activator)
	if self.nextUse and self.nextUse > CurTime() then
		return
	end

	self.nextUse = CurTime() + 1

	
	if self:GetCount() != 10 then
		return
	end

	if IsValid(activator.crateTake) then
		return
	end
	
	activator.crateTake = self

	net.Start("crate.take")
		net.WriteEntity(self)
	net.Send(activator)
end
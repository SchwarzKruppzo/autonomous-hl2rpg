AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "NPC Apartaments"
ENT.Category = "Fun + Games"

ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end

	local ent = ents.Create(ClassName)
	ent:SetPos(tr.HitPos + tr.HitNormal)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/Humans/Group02/male_08.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_BBOX)
		self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 72))
		self:ResetSequence(self:LookupSequence("lineidle02"))
		self:SetUseType(SIMPLE_USE)
		self:SetBloodColor(BLOOD_COLOR_RED)
	else
		self:SetIK(false)
	end
end

function ENT:Use(activator)
	if activator:IsPlayer() then 
		hook.Run("PlayerRoomBuyMenu", activator)
	end
end

function ENT:Think()
	self:NextThink(CurTime())
	return true
end


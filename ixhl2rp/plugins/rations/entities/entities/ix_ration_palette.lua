AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.Type = "anim"
ENT.PrintName = "Crate Palette"
ENT.Category = "HL2 RP Ration Factory"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.bNoPersist = true
ENT.isPalette = true

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/props_junk/wood_pallet001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		
		local physObj = self:GetPhysicsObject()

		if IsValid(physObj) then
			physObj:EnableMotion(true)
			physObj:Wake()
		end

		self.crates = {}
	end
end

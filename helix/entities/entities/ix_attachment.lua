AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Attachment"
ENT.Category = "Autonomous"

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.AutomaticFrameAdvance = false

function ENT:Initialize()

end

function ENT:Draw()
	self:DrawModel()
end
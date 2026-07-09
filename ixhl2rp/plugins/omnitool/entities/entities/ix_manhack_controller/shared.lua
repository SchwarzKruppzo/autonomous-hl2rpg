ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Omnitool Manhack Controller"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "ControlledManhack")
end

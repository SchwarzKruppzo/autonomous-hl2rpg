include("shared.lua")

function ENT:Draw()
	if (self:GetPilot() == LocalPlayer()) then
		return
	end

	self:DrawModel()
end

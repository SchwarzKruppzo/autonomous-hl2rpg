ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()  
    self:SetSolid(SOLID_BBOX)
    self:SetTrigger(true)
end

function ENT:SetupProperty(id, pos1, pos2)
	self.propertyID = id
	self.worldPos1 = pos1
	self.worldPos2 = pos2

	self:SetPos(pos1 + (pos1 - pos2)/2)
	self:SetCollisionBoundsWS(pos1, pos2)
end

function ENT:StartTouch(activator)
	if IsValid(activator) then
		if activator:IsPlayer() and activator:Alive() and activator:GetMoveType() != 8 then
			if activator.inPropertyZone != self then
				activator.inPropertyZone = self

				hook.Run("OnPlayerEnterBusiness", activator, self.propertyID, self)
			else
				activator.inPropertyZone = nil
			end
		end
	end
end

function ENT:EndTouch(activator)
end

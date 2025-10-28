ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:StartTouch(activator)
	if IsValid(activator) and activator:IsPlayer() then
		print(self.interior)
		hook.Run("PlayerEnteredRoom", activator, self.interior)
	end
end

function ENT:EndTouch(activator)
	if IsValid(activator) and activator:IsPlayer() then
		hook.Run("PlayerExitedRoom", activator, self.interior)
	end
end

function ENT:KeyValue(key, value)
	if key == "interior" then
		self.interior = value
	end
end

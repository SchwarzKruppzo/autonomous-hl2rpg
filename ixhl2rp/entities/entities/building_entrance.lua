ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:StartTouch(activator)
	if IsValid(activator) and activator:IsPlayer() then
		hook.Run("PlayerEnteredEntrance", activator, self.building)
	end
end

function ENT:EndTouch(activator)
	if IsValid(activator) and activator:IsPlayer() then
		hook.Run("PlayerExitedEntrance", activator, self.building)
	end
end

function ENT:KeyValue(key, value)
	if key == "entrance" then
		self.building = value
	end
end

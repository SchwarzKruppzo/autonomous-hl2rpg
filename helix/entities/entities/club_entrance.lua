ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:StartTouch(activator)
	if IsValid(activator) and activator:IsPlayer() then

	end
end

function ENT:EndTouch(activator)
	if IsValid(activator) and activator:IsPlayer() then
		
	end
end

function ENT:KeyValue(key, value)

end

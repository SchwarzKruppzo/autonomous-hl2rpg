local PLUGIN = PLUGIN

PLUGIN.name = "Door Lock Save"
PLUGIN.author = "Schwarz Kruppzo"

if SERVER then
	function PLUGIN:SaveData()
		local doors = {}

		for k, v in ipairs(ents.FindByClass("prop_door_rotating")) do
			if !v:CreatedByMap() then continue end
			
			doors[#doors + 1] = {v:MapCreationID(), v:IsLocked()}
		end

		self:SetData(doors)
	end

	function PLUGIN:InitPostEntity()
		local doors = self:GetData()

		for k, v in ipairs(doors or {}) do
			local door = ents.GetMapCreatedEntity(v[1])
			local locked = tobool(v[2])

			if IsValid(door) and door:IsDoor() then
				if locked then
					door:Fire('lock')
				end
			end
		end
	end
end


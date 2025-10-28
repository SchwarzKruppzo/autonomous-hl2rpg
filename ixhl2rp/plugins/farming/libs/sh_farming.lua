FARMING_TICK = 4

local Farming = ix.util.Lib("Farming", {
	plants = {},
	stored = {}
})

function Farming:RegisterPlant(id, info)
	info.Name = info.Name or "Unknown"
	info.Description = info.Description or ""
	info.Model = info.Model or "models/hunter/blocks/cube025x025x025.mdl"

	self.stored[id] = info
end

function Farming:GetPlant(id)
	return self.stored[id]
end

if SERVER then
	function Farming:AddPlant(entity)
		if IsValid(entity) and entity.IsPlant then
			table.insert(self.plants, entity)
		end
	end

	function Farming:RemovePlant(entity)
		for k, v in ipairs(self.plants) do
			if IsValid(v) and v == entity then
				table.remove(self.plants, k)
				continue
			end
		end
	end

	function Farming:Tick()
		for k, v in ipairs(self.plants) do
			if IsValid(v) then
				local succ, err = pcall(v.OnTick, v)
			end
		end
	end

	timer.Create("farming.tick", FARMING_TICK, 0, function()
		ix.Farming:Tick()
	end)
end
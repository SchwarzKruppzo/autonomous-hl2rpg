local PLUGIN = PLUGIN

function PLUGIN:SaveData()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_plant")) do
		data[#data + 1] = {
			v:GetPos(),
			v:GetAngles(),
			v:GetPlant(),
			v:GetWater(),
			v:GetIsGrow(),
			v.value or 0,
			v.stage or 1,
			v.wasHarvested or false,
			v.character or 0
		}
	end

	self:SetData(data)
end

function PLUGIN:LoadData()
	local data = self:GetData()

	if data then
		for _, v in ipairs(data) do
			local entity = ents.Create("ix_plant")
			entity:SetPos(v[1])
			entity:SetAngles(v[2])
			entity:Spawn()
			entity:SetupPlant(v[3])
			entity:SetWater(v[4])
			entity:SetStage(v[7])
			entity:SetIsGrow(v[5])

			entity.value = tonumber(v[6])
			entity.wasHarvested = tobool(v[8])
			entity.character = tonumber(v[9])

			entity:SetNetVar("owner", entity.character)
		end
	end
end
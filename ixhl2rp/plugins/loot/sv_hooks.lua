function PLUGIN:SaveData()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_loot")) do
		data[#data + 1] = {
			v:GetPos(),
			v:GetAngles(),
			v:GetContainer()
		}
	end

	self:SetData(data)
end

function PLUGIN:LoadData()
	local data = self:GetData()

	if data then
		for _, v in ipairs(data) do
			local entity = ents.Create("ix_loot")
			entity:SetPos(v[1])
			entity:SetAngles(v[2])
			entity:Spawn()
			entity:SetupContainer(v[3])

			local physObject = entity:GetPhysicsObject()

			if IsValid(physObject) then
				physObject:EnableMotion(false)
			end
		end
	end
end
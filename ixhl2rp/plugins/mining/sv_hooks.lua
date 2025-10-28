local PLUGIN = PLUGIN

function PLUGIN:SaveData()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_vein_*")) do
		data[#data + 1] = {
			v:GetClass(),
			v:GetPos(),
			v:GetAngles()
		}
	end

	for _, v in ipairs(ents.FindByClass("ix_tree")) do
		data[#data + 1] = {
			v:GetClass(),
			v:GetPos(),
			v:GetAngles()
		}
	end

	self:SetData(data)
end

function PLUGIN:LoadData()
	local data = self:GetData()

	if data then
		for _, v in ipairs(data) do
			local entity = ents.Create(v[1])

			if IsValid(entity) then
				entity:SetPos(v[2])
				entity:SetAngles(v[3])
				entity:Spawn()
				
				local physObject = entity:GetPhysicsObject()

				if IsValid(physObject) then
					physObject:EnableMotion(false)
				end
			end
		end
	end
end

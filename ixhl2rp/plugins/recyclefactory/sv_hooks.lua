function PLUGIN:SaveData()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_factory_recycler")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles()}
	end

	ix.data.Set("recycleFactory", data)
end

function PLUGIN:LoadData()
	for _, v in ipairs(ix.data.Get("recycleFactory") or {}) do
		local factory = ents.Create("ix_factory_recycler")

		factory:SetPos(v[1])
		factory:SetAngles(v[2])
		factory:Spawn()

		local phys = factory:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
end
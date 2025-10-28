function PLUGIN:CanPlayerHoldObject(client, entity)
	if entity.isRationCrate then
		return true
	end
end

function PLUGIN:SaveData()
	local data = {}
	for _, v in ipairs(ents.FindByClass("ix_ration_crate")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetCount()}
	end
	ix.data.Set("rationCrates", data)


	data = {}
	for _, v in ipairs(ents.FindByClass("ix_rationfactory_cd")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetLocked()}
	end
	ix.data.Set("rationFactoryCD", data)


	data = {}
	for _, v in ipairs(ents.FindByClass("ix_rationfactory_erd")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetLocked()}
	end
	ix.data.Set("rationFactoryERD", data)


	data = {}
	for _, v in ipairs(ents.FindByClass("ix_rationfactory_rs")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles()}
	end
	ix.data.Set("rationFactoryRS", data)


	data = {}
	for _, v in ipairs(ents.FindByClass("ix_rationfactory_sd")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetLocked()}
	end
	ix.data.Set("rationFactorySD", data)


	data = {}
	for _, v in ipairs(ents.FindByClass("ix_rationfactory_wd")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetLocked()}
	end
	ix.data.Set("rationFactoryWD", data)


	data = {}
	for _, v in ipairs(ents.FindByClass("ix_ration_palette")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles()}
	end
	ix.data.Set("cratePalette", data)
end

function PLUGIN:LoadData()
	for _, v in ipairs(ix.data.Get("rationCrates") or {}) do
		local crate = ents.Create("ix_ration_crate")

		crate:SetPos(v[1])
		crate:SetAngles(v[2])
		crate:Spawn()
		crate:SetCount(v[3])

		local phys = crate:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end

	for _, v in ipairs(ix.data.Get("rationFactoryCD") or {}) do
		local cd = ents.Create("ix_rationfactory_cd")

		cd:SetPos(v[1])
		cd:SetAngles(v[2])
		cd:Spawn()
		cd:SetLocked(v[3])

		local phys = cd:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end

	for _, v in ipairs(ix.data.Get("rationFactoryERD") or {}) do
		local erd = ents.Create("ix_rationfactory_erd")

		erd:SetPos(v[1])
		erd:SetAngles(v[2])
		erd:Spawn()
		erd:SetLocked(v[3])

		local phys = erd:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end

	for _, v in ipairs(ix.data.Get("rationFactoryRS") or {}) do
		local rs = ents.Create("ix_rationfactory_rs")

		rs:SetPos(v[1])
		rs:SetAngles(v[2])
		rs:Spawn()

		local phys = rs:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end

	for _, v in ipairs(ix.data.Get("rationFactorySD") or {}) do
		local sd = ents.Create("ix_rationfactory_sd")

		sd:SetPos(v[1])
		sd:SetAngles(v[2])
		sd:Spawn()
		sd:SetLocked(v[3])

		local phys = sd:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end

	for _, v in ipairs(ix.data.Get("rationFactoryWD") or {}) do
		local wd = ents.Create("ix_rationfactory_wd")

		wd:SetPos(v[1])
		wd:SetAngles(v[2])
		wd:Spawn()
		wd:SetLocked(v[3])

		local phys = wd:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end

	for _, v in ipairs(ix.data.Get("cratePalette") or {}) do
		local wd = ents.Create("ix_ration_palette")

		wd:SetPos(v[1])
		wd:SetAngles(v[2])
		wd:Spawn()

		local phys = wd:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
end

util.AddNetworkString("crate.take")
util.AddNetworkString("crate.stop")

net.Receive("crate.stop", function(len, client)
	client.crateTake = nil
end)

net.Receive("crate.take", function(len, client)
	local crate = client.crateTake

	local angle = net.ReadAngle()

	local trace = client:GetEyeTraceNoCursor()
	local mins, maxs = crate:GetModelBounds() 
	local data = {}
	data.mins = mins
	data.maxs = maxs
	data.start = trace.StartPos
	data.endpos = trace.StartPos + trace.Normal * 86
	data.filter = client
	trace = util.TraceLine(data)

	local palette
	local ent = trace.Entity

	if IsValid(ent) then
		if ent.isPalette then
			palette = ent
		elseif ent.isRationCrate then
			palette = ent.palette
		end
	end
	

	if !palette then
		client.crateTake = nil
		return
	end

	local sitTrace = util.TraceHull({
		start = trace.HitPos + Vector(0, 0, 3),
		endpos = trace.HitPos,
		mins = mins,
		maxs = maxs
	})

	if sitTrace.AllSolid then
		client.crateTake = nil
		return
	end

	crate:SetPos(trace.HitPos)
	crate:SetAngles(angle)
	crate:PhysicsDestroy()
	crate:PhysicsInit(SOLID_BBOX)
	crate:SetMoveType(MOVETYPE_NONE)
	//crate:SetParent(ent)
	crate.palette = palette

	palette.crates[#palette.crates + 1] = crate

	client.crateTake = nil
end)
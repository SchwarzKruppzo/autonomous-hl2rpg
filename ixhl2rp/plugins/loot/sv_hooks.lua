util.AddNetworkString("loot.spawnpoint")

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

net.Receive("loot.spawnpoint", function(len, client)
	if !client:IsSuperAdmin() then return end

	local id = net.ReadString()

	local vStart = client:GetShootPos()
	local vForward = client:GetAimVector()
	local trace = {}
	trace.start = vStart
	trace.endpos = vStart + (vForward * 2048)
	trace.filter = client

	local tr = util.TraceLine(trace)
	local ang = client:EyeAngles()
	ang.yaw = ang.yaw + 180
	ang.roll = 0
	ang.pitch = 0

	local loot = ents.Create("ix_loot")
	loot:SetPos(tr.HitPos)
	loot:SetAngles(ang)
	loot:Spawn()
	loot:Activate()
	loot:SetupContainer(id)
end)
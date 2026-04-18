local PLUGIN = PLUGIN

util.AddNetworkString("animhelper.select")

net.Receive("animhelper.select", function(_, client)
	local pos = net.ReadVector()
	local ang = net.ReadAngle()
	local option = net.ReadString()
	local offsetZ = math.Clamp(net.ReadFloat(), -2, 4)
	local curTime = CurTime()

	local character = client:GetCharacter()

	if !character or client.ixUntimedSequence then
		return
	end

	if client:IsPilotScanner() then
		return
	end

	if !PLUGIN:CanSit(client, pos, option) then
		return
	end

	if !client.nextAnimSelect or curTime >= client.nextAnimSelect then
		if client:IsProne() then
			prone.Exit(client)
		end

		client.nextAnimSelect = curTime + 2

		local sitOffset = vector_origin
		local animGroup = client.ixAnimModelClass
		local info = ix.AnimHelper.anims[option]

		if info then
			local offset = info.offset[animGroup] or info.offset[1]

			if offset then
				sitOffset = offset or vector_origin
			end
		end

		local finalPos = pos + ang:Forward() * sitOffset.x + Vector(0, 0, sitOffset.z + offsetZ)
		
		client.latestSitPos = client:GetPos()
		client.latestSitAng = client:GetAngles()
		client.latestCharKey = character:GetID()

		client:SetPos(finalPos)

		local angles = client:GetAngles()
		angles.y = ang.y

		client:SetAngles(angles)
		client:SetLocalVelocity(vector_origin)
		client:SetVelocity(vector_origin)

		client:SetNetVar("sitHelperPos", client:GetPos())
		client:SetNetVar("actEnterAngle", client:GetAngles())

		client.ixUntimedSequence = true
		client:SetCollisionGroup(COLLISION_GROUP_WORLD)
		client:ForceSequence(option, nil, 0, nil)

		net.Start("ixActEnter")
			net.WriteBool(true)
		net.Send(client)
	end
end)

function PLUGIN:PlayerLeaveSequence(client)
	if client:GetNetVar("sitHelperPos") then
		client.ixUntimedSequence = nil

		client:SetNetVar("sitHelperPos", nil)
		client:SetNetVar("actEnterAngle", nil)

		if client.latestCharKey == client:GetCharacter():GetID() then
			client:SetPos(client.latestSitPos)
			client:SetAngles(client.latestSitAng)
		end

		client.latestSitPos = nil
		client.latestSitAng = nil
		client.latestCharKey = nil
		
		client:SetLocalVelocity(vector_origin)
		client:SetVelocity(vector_origin)
		client:SetCollisionGroup(COLLISION_GROUP_PLAYER)

		net.Start("ixActLeave")
		net.Send(client)
	end
end

PLUGIN["prone.CanEnter"] = function(self, client)
	if client:GetNetVar("sitHelperPos") then
		return false
	end
end

local PLUGIN = PLUGIN

function PLUGIN:InitPostEntity()
	net.Start("clientprop.sync")
	net.SendToServer()
end

local updateInterval = 6
function PLUGIN:Think()
	self.coroutine = self.coroutine and coroutine.status(self.coroutine) != "dead" and self.coroutine or coroutine.create(function()
		while true do
			local maxProcessed = ix.option.Get("csRenderSpeed", 50)
			local processed = 0

			for _, info in ipairs(self.clientProps) do
				self:HandleClientsideProp(info)
				processed = processed + 1

				if processed >= maxProcessed then
					processed = 0

					coroutine.yield()
				end
			end

			coroutine.yield()
		end
	end)

	if FrameNumber() % updateInterval != 0 then 
		return 
	end

	local resumeSuccess, err = coroutine.resume(self.coroutine)

	if !resumeSuccess then
		ErrorNoHalt(err)
	end
end

function PLUGIN:KeyPress(client, key)
	if !IsFirstTimePredicted() or key != IN_ATTACK then return end
	
	local weapon = client:GetActiveWeapon()

	if !IsValid(weapon) or weapon:GetClass() != "weapon_physgun" then return end
	if !CAMI.PlayerHasAccess(client, "Helix - Manage Clientside Props") then return end

	local searchDist = 0
	local selectedProp
	local shootPos = client:GetShootPos()
	local forwardVec = client:GetAimVector()
	local trace = {
		start = shootPos,
		endpos = shootPos,
		filter = client
	}

	while searchDist < 256 do
		if IsValid(selectedProp) then break end

		trace.endpos = trace.start + forwardVec * searchDist

		for _, prop in ipairs(self.activeClientProps) do
			if prop:GetPos():DistToSqr(trace.endpos) > 65536 then continue end

			local boundsMin, boundsMax = prop:GetRenderBounds()
			local relPos = prop:WorldToLocal(trace.endpos)

			if !relPos:WithinAABox(boundsMin, boundsMax) then continue end

			selectedProp = prop
				
			break
		end

		searchDist = searchDist + 1
	end

	if !IsValid(selectedProp) then return end

	net.Start("clientprop.recreate")
		net.WriteVector(selectedProp:GetPos())
	net.SendToServer()
end

express.Receive("clientprop.sync", function(props)
	PLUGIN.clientProps = props
end)

net.Receive("clientprop.prop", function()
	local info = net.ReadTable()

	PLUGIN.clientProps[#PLUGIN.clientProps + 1] = info
end)

net.Receive("clientprop.recreate", function()
	local pos = net.ReadVector()

	for k, data in ipairs(PLUGIN.clientProps) do
		if !data.position:IsEqualTol(pos, 0.1) then continue end

		table.remove(PLUGIN.clientProps, k)

		break
	end

	for _, prop in ipairs(PLUGIN.activeClientProps) do
		if !prop:GetPos():IsEqualTol(pos, 0.1) then continue end

		prop:Remove()
		table.remove(PLUGIN.activeClientProps, k)

		break
	end
end)

net.Receive("clientprop.clear", function()
	local pos = net.ReadVector()
	local radius = net.ReadUInt(16)

	local new = {}
	for _, info in ipairs(PLUGIN.clientProps) do
		if info.position:Distance(pos) <= radius then continue end

		new[#new + 1] = info
	end

	local newActive = {}
	for _, prop in ipairs(PLUGIN.activeClientProps) do
		if prop:GetPos():Distance(pos) <= radius then
			prop:Remove()
		else
			newActive[#newActive + 1] = prop
		end
	end

	PLUGIN.clientProps = new
	PLUGIN.activeClientProps = newActive
end)




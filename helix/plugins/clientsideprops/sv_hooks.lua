local PLUGIN = PLUGIN

function PLUGIN:SaveData()
	self:SetData(self.clientProps)
end

function PLUGIN:LoadData()
	self.clientProps = self:GetData() or {}
end

net.Receive("clientprop.recreate", function(_, client)
	if !CAMI.PlayerHasAccess(client, "Helix - Manage Clientside Props") then return end
	if client.nextPropRecreate and client.nextPropRecreate >= CurTime() then return end

	local weapon = client:GetActiveWeapon()
	if !IsValid(weapon) or weapon:GetClass() != "weapon_physgun" then return end

	client.nextPropRecreate = CurTime() + 1

	local pos = net.ReadVector()
	local info

	for k, prop in ipairs(PLUGIN.clientProps) do
		if prop.position:IsEqualTol(pos, 0.1) then 
			table.remove(PLUGIN.clientProps, k)

			info = prop

			break
		end
	end

	if info then
		local ent = ents.Create("prop_physics")
		ent:SetModel(info.model)
		ent:SetPos(info.position)
		ent:SetAngles(info.angles)
		ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
		ent:SetSkin(info.skin)
		ent:SetColor(info.color)
		ent:SetMaterial(info.material)
		ent:Spawn()

		local phys = ent:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end

		net.Start("clientprop.recreate")
			net.WriteVector(pos)
		net.Broadcast()
	end
end)

net.Receive("clientprop.sync", function(_, client)
	if #PLUGIN.clientProps <= 0 then
		return
	end
	
	if !client.firstClientsidePropSync then
		express.Broadcast("clientprop.sync", PLUGIN.clientProps, function()
			client.firstClientsidePropSync = true
		end)
	end
end)
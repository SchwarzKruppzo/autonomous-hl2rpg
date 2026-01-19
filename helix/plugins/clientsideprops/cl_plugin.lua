local PLUGIN = PLUGIN

PLUGIN.activeClientProps = PLUGIN.activeClientProps or {}

function PLUGIN:HandleClientsideProp(info)
	local PVS = NikNaks.CurrentMap:PVSForOrigin(LocalPlayer():EyePos())

	if PVS and PVS:TestPosition(info.position) then
		for _, prop in ipairs(self.activeClientProps) do
			if info.position:IsEqualTol(prop:GetPos(), 0.1) then 
				return
			end
		end

		local ent = ClientsideModel(info.model)
		ent:SetPos(info.position)
		ent:SetAngles(info.angles)
		ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
		ent:SetSkin(info.skin)
		ent:SetColor(info.color)
		ent:SetMaterial(info.material)
		ent:Spawn()

		self.activeClientProps[#self.activeClientProps + 1] = ent
	else
		for k, prop in ipairs(self.activeClientProps) do
			if !info.position:IsEqualTol(prop:GetPos(), 0.1) then continue end

			prop:Remove()

			table.remove(self.activeClientProps, k)

			return
		end
	end
end

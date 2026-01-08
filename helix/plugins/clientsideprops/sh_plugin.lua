local PLUGIN = PLUGIN
local Persistence = ix.plugin.Get("persistence")

PLUGIN.name = "Clientside Props"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = "Convert serverside props to clientside props for performance."

PLUGIN.clientProps = PLUGIN.clientProps or {}

ix.util.Include("cl_hooks.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_plugin.lua")

CAMI.RegisterPrivilege({
	Name = "Helix - Manage Clientside Props",
	MinAccess = "admin"
})

ix.option.Add("csRenderSpeed", ix.type.number, 50, {
	category = "option.category.performance",
	min = 1,
	max = 512
})

ix.command.Add("RemoveClientProps", {
	description = "@cmd.clientprops.remove",
	adminOnly = true,
	arguments = {
		ix.type.number
	},
	OnRun = function(self, client, radius)
		if radius < 0 then
			client:NotifyLocalized("clientprops.invalidRadius")

			return
		end

		local new = {}
		for _, info in ipairs(PLUGIN.clientProps) do
			if info.position:Distance(client:GetPos()) <= radius then continue end
			
			new[#new + 1] = info
		end

		PLUGIN.clientProps = new

		net.Start("clientprop.clear")
			net.WriteVector(client:GetPos())
			net.WriteUInt(radius, 16)
		net.Broadcast()

		client:NotifyLocalized("clientprops.removed", radius)
	end
})



properties.Add("clientprop", {
	MenuLabel = "Make Clientside",
	Order = 400,
	MenuIcon = "icon16/contrast_low.png",

	Filter = function(self, entity, client)
		return entity:GetClass() == "prop_physics" and CAMI.PlayerHasAccess(client, "Helix - Manage Clientside Props")
	end,

	Action = function(self, entity)
		self:MsgStart()
			net.WriteEntity(entity)
		self:MsgEnd()
	end,

	Receive = function(self, length, client)
		local entity = net.ReadEntity()

		if !IsValid(entity) then return end
		if !self:Filter(entity, client) then return end
		
		if !entity:TestPVS(client) then
			client:NotifyLocalized("clientprops.outOfBound")

			return
		end

		if entity.PermaID then
			client:NotifyLocalized("clientprops.permaall")

			return
		end

		if Persistence then
			for k, v in ipairs(Persistence.stored) do
				if v == entity then
					table.remove(Persistence.stored, k)

					break
				end
			end

			entity:SetNetVar("Persistent", false)
		end

		local info = {
			position = entity:GetPos(),
			angles = entity:GetAngles(),
			model = entity:GetModel(),
			skin = entity:GetSkin(),
			color = entity:GetColor(),
			material = entity:GetMaterial()
		}

		entity:Remove()

		PLUGIN:BroadcastProp(info)
		PLUGIN.clientProps[#PLUGIN.clientProps + 1] = info
	end
})


local PLUGIN = PLUGIN or {}

PLUGIN.name = "Context Inventory Menu"
PLUGIN.author = "Dysp"
PLUGIN.description = "Allows to check characters inventory"

CAMI.RegisterPrivilege({
	Name = "Helix - Admin Context Inventory",
	MinAccess = "admin"
})

properties.Add("ixViewPlayerInventory", {
	MenuLabel = "#View Inventory",
	Order = 1,
	MenuIcon = "icon16/eye.png",


	Filter = function(self, entity, client)
		return CAMI.PlayerHasAccess(client, "Helix - Admin Context Inventory", nil) and entity:IsPlayer()
	end,

	Action = function(self, entity)
		self:MsgStart()
			net.WriteEntity(entity)
		self:MsgEnd()
	end,

	Receive = function(self, length, client)
		if (CAMI.PlayerHasAccess(client, "Helix - Admin Context Inventory", nil)) then
			local entity = net.ReadEntity()


			local name = entity:GetCharacter():GetName()
			local inventory = entity:GetInventory("main")

			ix.storage.Open(client, inventory, {
				entity = entity,
				name = name,
				OnPlayerOpen = function(client)
					for k, v in pairs(entity:GetInventories()) do
						if v.type == "main" then continue end
						
						v:AddReceiver(client)
					end
				end,
				OnPlayerClose = function(client)
					for k, v in pairs(entity:GetInventories()) do
						if v.type == "main" then continue end

						v:RemoveReceiver(client)
					end
				end,
				OnSync = function(client)
					for k, v in pairs(entity:GetInventories()) do
						if v.type == "main" then continue end
						
						v:Sync(client)
					end
				end,
			})
		end
	end
})
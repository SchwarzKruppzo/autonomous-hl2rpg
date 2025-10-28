local PLUGIN = PLUGIN or {}

PLUGIN.name = "Ragdoll Looting"
PLUGIN.author = ""
PLUGIN.description = ""


if SERVER then
	util.AddNetworkString("rp.search.ragdoll")
	util.AddNetworkString("rp.ragdoll.menu")
	
	net.Receive("rp.search.ragdoll", function(len, ply)
		local doll = net.ReadEntity()

		local data = {}
			data.start = ply:GetShootPos()
			data.endpos = data.start + ply:GetAimVector() * 96
			data.filter = ply
		local target = util.TraceLine(data).Entity

		local clientTarget = IsValid(target.ixPlayer) and target.ixPlayer or target

		if IsValid(target.ixPlayer) then
			if doll != target then return end

			if !target.inventory then
				target.inventory = clientTarget:GetInventory('main')
			end

			ix.storage.Open(ply, target.inventory, {
				entity = clientTarget,
				name = "Инвентарь лежачего",
				searchTime = 0,
				OnPlayerOpen = function(client)
					for k, v in pairs(clientTarget:GetInventories()) do
						if v.type == "main" then continue end
						
						v:AddReceiver(client)
					end
				end,
				OnPlayerClose = function(client)
					for k, v in pairs(clientTarget:GetInventories()) do
						if v.type == "main" then continue end

						v:RemoveReceiver(client)
					end
				end,
				OnSync = function(client)
					for k, v in pairs(clientTarget:GetInventories()) do
						if v.type == "main" then continue end
						
						v:Sync(client)
					end
				end
			})
		end
	end)
else
	net.Receive("rp.ragdoll.menu", function(len, player)
		local doll = net.ReadEntity()

		if IsValid(doll) then
			function doll:GetEntityMenu()
				local options = {
					["Обыскать"] = function()
						net.Start("rp.search.ragdoll")
							net.WriteEntity(self)
						net.SendToServer()
						return false
					end
				}
				return options
			end
		end
	end)
end

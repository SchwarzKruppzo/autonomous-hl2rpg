ENT.Type = "anim"
ENT.PrintName = "Station"
ENT.Category = "Helix"
ENT.Spawnable = false
ENT.inv_width = 7
ENT.inv_height = 12

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "StationID")

	if SERVER then
		self:NetworkVarNotify("StationID", self.OnVarChanged)
	end
end

if SERVER then
	util.AddNetworkString("ixOpenStationCraft")

	function ENT:Initialize()
		if !self.uniqueID then
			self:Remove()

			return
		end

		self:SetStationID(self.uniqueID)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:PhysicsInit(SOLID_VPHYSICS)

		local physObj = self:GetPhysicsObject()

		if IsValid(physObj) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end

		local inventory = ix.meta.Inventory:New()
		inventory:SetSize(self.inv_width, self.inv_height)
		inventory.title = self.PrintName
		inventory.type = "container"
		inventory.owner = self

		self.inventory = inventory
	end

	function ENT:OnVarChanged(name, oldID, newID)
		local stationTable = ix.Craft.stations[newID]

		if stationTable then
			self:SetModel(stationTable:GetModel())
		end
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_PVS
	end

	function ENT:Use(client)
		local ct = CurTime()

		if (client.nextStationUse and ct < client.nextStationUse) or client:IsRestricted() then
			return
		end

		self.inventory:AddReceiver(client)
		self.inventory:Sync()

		local pingtime = client:Ping() * 0.001

		timer.Simple(pingtime, function()
			if !IsValid(client) then
				return
			end
			
			net.Start("ixOpenStationCraft")
				net.WriteEntity(self)
				net.WriteUInt(self.inventory.id, 32)
			net.Send(client)

			client.ixStation = self
		end)

		client.nextStationUse = ct + 0.5
	end

	net.Receive("ixOpenStationCraft", function(len, client)
		client.ixStation = nil
	end)
else
	ENT.PopulateEntityInfo = true

	function ENT:OnPopulateEntityInfo(tooltip)
		local station = self:GetStationTable()

		if station then
			local name = tooltip:AddRow("name")
			name:SetImportant()
			name:SetText(station.GetName and station:GetName() or L(station.name))
			name:SetMaxWidth(math.max(name:GetMaxWidth(), ScrW() * 0.5))
			name:SizeToContents()

			local description = tooltip:AddRow("description")
			description:SetText(station.GetDescription and station:GetDescription() or L(station.description))
			description:SizeToContents()

			if station.PopulateTooltip then
				station:PopulateTooltip(tooltip)
			end
		end
	end

	function ENT:Draw()
		self:DrawModel()
	end

	net.Receive("ixOpenStationCraft", function(len)
		local station = net.ReadEntity()
		local stationTable = station:GetStationTable()
		local id = net.ReadUInt(32)
		local inventory = ix.Inventory:Get(id)

		LocalPlayer().ixStation = station

		if IsValid(ix.gui.stationCraft) then
			ix.gui.stationCraft:Remove()
			ix.gui.stationCraft = nil
		end

		if IsValid(station) and inventory then
			local panel = vgui.Create("ui.craft")
			panel.station = stationTable
			panel.inventoryID = id
			panel.isMini = false
			panel:Setup()
			panel.OnClose = function()
				LocalPlayer().ixStation = nil
				net.Start("ixOpenStationCraft")
				net.SendToServer()
			end

			ix.gui.stationCraft = panel
			ix.gui.can_craft = nil
		else
			LocalPlayer().ixStation = nil

			net.Start("ixOpenStationCraft")
			net.SendToServer()
		end
	end)
end

function ENT:GetStationTable()
	return ix.Craft.stations[self:GetStationID()]
end

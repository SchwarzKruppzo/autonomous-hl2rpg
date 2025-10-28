AddCSLuaFile()
DEFINE_BASECLASS("base_anim")

ENT.Type = "anim"
ENT.Author = "Schwarz Kruppzo"
ENT.PrintName = "Loot Point"
ENT.Category = "HL2RP Loot"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Container")
	self:NetworkVar("Bool", 0, "Locked")
end

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end

		self.info = {}
		self.respawn = nil
	end

	function ENT:SetupContainer(containerID)
		local info = ix.LootContainer:Get(containerID)

		if !info then
			return
		end
		
		self.info = info

		self:SetModel(istable(info.Model) and table.Random(info.Model) or info.Model)
		self:SetMoveType(MOVETYPE_NONE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetSolid(SOLID_VPHYSICS)

		if info.Skin then
			self:SetSkin(info.Skin)
		end
		
		if info.BodyGroups then
			self:SetBodyGroups(info.BodyGroups)
		end

		if info.NotSolid then
			self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		end

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end

		self:SetContainer(containerID)

		self.respawn = nil
		self:GenerateLoot()
	end

	function ENT:GenerateLoot()
		local info = self.info
		local loot = info.Process(info, self)

		self.inventory = {}

		for k, item in ipairs(loot) do
			self.inventory[#self.inventory + 1] = item
		end

		self:SetLocked(info.Locked or false)
	end

	function ENT:UpdateTransmitState()
		if self.info and self.info.Hide then
			if self.respawn and self.respawn > CurTime() then
				return TRANSMIT_NEVER
			end
		end

		return TRANSMIT_PVS
	end

	function ENT:Think()
		if self.respawn and self.respawn < CurTime() then
			self.respawn = nil

			self:GenerateLoot()

			if istable(self.info.Model) then
				self:SetModel(table.Random(self.info.Model))
			end

			if self.info.Hide then
				self:SetSolid(SOLID_VPHYSICS)
				self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
			end
		end

		self:NextThink(CurTime() + 1)
	end

	function ENT:Use(client)
		if client:IsRestricted() then
			return
		end

		if self.inventory and (client.nextOpenLoot or 0) < CurTime() then
			local character = client:GetCharacter()

			if character then
				local hasTool, item
				if self.info.Tool and self:GetLocked() then
					for k, v in ipairs(client:FindItems(self.info.Tool)) do
						if v:HasDurability() then
							hasTool = true
							item = v
							break
						end
					end
					
					if !hasTool then
						client.nextOpenLoot = CurTime() + 5
						local x_item = ix.Item:Get(self.info.Tool)
						client:Notify(string.format("Вам нужна %s чтобы вскрыть этот контейнер!", x_item:GetName()))
						return
					end

					item.tool_using = true
				end
				
				ix.dynloot.Open(client, "loot"..self:EntIndex(), {
					name = self.info.Name,
					searchText = self.info.SearchText or "@storageSearching",
					entity = self,
					searchTime = (self.info.SearchTime or 5),
					bMultipleUsers = true,
					OnPlayerSync = function()
						if item then
							item.tool_using = nil
						end

						local locked = self:GetLocked()
						
						if locked then
							item:TakeDurability(self.info.ToolDamage or 100, client)

							if self.info.CrackSound then
								client:EmitSound(self.info.CrackSound)
							end

							self:SetLocked(false)
						else
							if self.info.OpenSound then
								client:EmitSound(self.info.OpenSound)
							end
						end
					end,
					OnPlayerClose = function()
						if !self.respawn and self.inventory then
							local hasItems = false

							for k, v in ipairs(self.inventory) do
								if v then
									hasItems = true
									break
								end
							end

							if !hasItems then
								if self.info.OnSuccess then
									self.info.OnSuccess(client)
								end
						
								self.respawn = CurTime() + (self.info.Respawn or 1)

								if self.info.Hide then
									self:SetSolid(SOLID_NONE)
									self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
								end
							end
						end
		
						if item then
							item.tool_using = nil
						end
						
						if self.info.CloseSound then
							client:EmitSound(self.info.CloseSound)
						end
					end,
					Inventory = function() return self.inventory end
				})
			end

			client.nextOpenLoot = CurTime() + 2
		end
	end
else
	function ENT:Draw()
		self:DrawModel()
	end

	ENT.PopulateEntityInfo = true

	function ENT:OnPopulateEntityInfo(tooltip)
		local containerID = self:GetContainer()
		local info = ix.LootContainer:Get(containerID)

		if info then
			local title = tooltip:AddRow("name")
			title:SetImportant()
			title:SetText(info.Name)
			title:SizeToContents()
		end
	end
end

properties.Add("ix_lootbox", {
	MenuLabel = "Set Loot Container",
	Order = 400,
	MenuIcon = "icon16/tag_blue_edit.png",

	Filter = function(self, entity, client)
		if (entity:GetClass() != "ix_loot") then return false end
		if (!gamemode.Call("CanProperty", client, "ix_lootbox", entity)) then return false end

		return true
	end,

	Action = function(self, entity)
		Derma_StringRequest("Specify Container ID", "", "", function(text)
			self:MsgStart()
				net.WriteEntity(entity)
				net.WriteString(text)
			self:MsgEnd()
		end)
	end,

	Receive = function(self, length, client)
		local entity = net.ReadEntity()

		if (!IsValid(entity)) then return end
		if (!self:Filter(entity, client)) then return end

		local text = net.ReadString()

		entity:SetupContainer(text)
	end
})
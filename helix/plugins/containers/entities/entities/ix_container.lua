
ENT.Type = "anim"
ENT.PrintName = "Container"
ENT.Category = "Helix"
ENT.Spawnable = false
ENT.bNoPersist = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "ID")
	self:NetworkVar("Bool", 0, "Locked")
	self:NetworkVar("String", 0, "DisplayName")
end

if (SERVER) then
	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self.receivers = {}

		local definition = ix.container.stored[self:GetModel():lower()]

		if (definition) then
			self:SetDisplayName(definition.name)
		end

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(true)
			physObj:Wake()
		end
	end

	function ENT:CreateInventory(data)
		local model = self:GetModel():lower()
		data = data or ix.container.stored[model]

		local inventory = ix.meta.Inventory:New()
		inventory:SetSize(data.width, data.height)
		inventory.title = data.name
		inventory.type = "container"
		inventory.owner = self

		self:SetInventory(inventory)
	end

	function ENT:LoadItems(items)
		if istable(items) then
			ix.Item:LoadInstanceByID(items, function(item)
				local inventory = ix.Inventory:Get(self:GetID())

				inventory:AddItem(item, item.x, item.y)
			end)
		end
	end

	function ENT:GetItems()
		local index = self:GetID()

		if index then
			local inventory = ix.Inventory:Get(index)

			return inventory:GetItemsID()
		end
		
		return {}
	end
	
	function ENT:SetInventory(inventory)
		if (inventory) then
			self:SetID(inventory.id)
		end
	end

	function ENT:SetMoney(amount)
		self.money = math.max(0, math.Round(tonumber(amount) or 0))
	end

	function ENT:GetMoney()
		return self.money or 0
	end

	function ENT:OnRemove()
		local index = self:GetID()

		if (!ix.shuttingDown and !self.ixIsSafe and ix.entityDataLoaded and index) then
			local inventory = ix.Inventory:Get(index)

			if (inventory) then
				hook.Run("ContainerRemoved", self, inventory)
			end
		end
	end

	function ENT:OpenInventory(activator)
		local inventory = self:GetInventory()

		if (inventory) then
			local name = self:GetDisplayName()
			local definition = ix.container.stored[self:GetModel():lower()]

			ix.storage.Open(activator, inventory, {
				name = name,
				entity = self,
				searchTime = ix.config.Get("containerOpenTime", 0.7),
				data = {money = self:GetMoney()},
				OnPlayerOpen = function()
					if (definition.OnOpen) then
					    definition.OnOpen(self, activator)
					end
				end,
				OnPlayerClose = function()
					if (definition.OnClose) then
						definition.OnClose(self, activator)
					end

					ix.log.Add(activator, "closeContainer", name, inventory.id)
				end
			})

			if (self:GetLocked()) then
				self.Sessions[activator:GetCharacter():GetID()] = true
			end

			ix.log.Add(activator, "openContainer", name, inventory.id)
		end
	end

	function ENT:Use(activator)
		local inventory = self:GetInventory()

		if (inventory and (activator.ixNextOpen or 0) < CurTime()) then
			local character = activator:GetCharacter()

			if (character) then
				local definition = ix.container.stored[self:GetModel():lower()]

				if (self:GetLocked() and !self.Sessions[character:GetID()]) then
					self:EmitSound(definition.locksound or "doors/default_locked.wav")

					if (!self.keypad) then
						net.Start("ixContainerPassword")
							net.WriteEntity(self)
						net.Send(activator)
					end
				else
					self:OpenInventory(activator)
				end
			end

			activator.ixNextOpen = CurTime() + 1
		end
	end
else
	ENT.PopulateEntityInfo = true

	local COLOR_LOCKED = Color(200, 38, 19, 200)
	local COLOR_UNLOCKED = Color(135, 211, 124, 200)

	function ENT:OnPopulateEntityInfo(tooltip)
		local definition = ix.container.stored[self:GetModel():lower()]
		local bLocked = self:GetLocked()

		surface.SetFont("ixIconsSmall")

		local iconText = bLocked and "P" or "Q"
		local iconWidth, iconHeight = surface.GetTextSize(iconText)

		-- minimal tooltips have centered text so we'll draw the icon above the name instead
		if (tooltip:IsMinimal()) then
			local icon = tooltip:AddRow("icon")
			icon:SetFont("ixIconsSmall")
			icon:SetTextColor(bLocked and COLOR_LOCKED or COLOR_UNLOCKED)
			icon:SetText(iconText)
			icon:SizeToContents()
		end

		local title = tooltip:AddRow("name")
		title:SetImportant()
		title:SetText(self:GetDisplayName())
		title:SetBackgroundColor(ix.config.Get("color"))
		title:SetTextInset(iconWidth + 8, 0)
		title:SizeToContents()

		if (!tooltip:IsMinimal()) then
			title.Paint = function(panel, width, height)
				panel:PaintBackground(width, height)

				surface.SetFont("ixIconsSmall")
				surface.SetTextColor(bLocked and COLOR_LOCKED or COLOR_UNLOCKED)
				surface.SetTextPos(4, height * 0.5 - iconHeight * 0.5)
				surface.DrawText(iconText)
			end
		end

		local description = tooltip:AddRow("description")
		description:SetText(definition.description)
		description:SizeToContents()
	end
end

function ENT:GetInventory()
	return ix.Inventory:Get(self:GetID())
end
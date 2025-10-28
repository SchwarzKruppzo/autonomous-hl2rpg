AddCSLuaFile()
DEFINE_BASECLASS("base_anim")

ENT.Type = "anim"
ENT.PrintName = "Plant"
ENT.Category = "Farming"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.IsPlant = true

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Water")
	self:NetworkVar("Bool", 0, "IsGrow")
	self:NetworkVar("String", 0, "Plant")
	self:NetworkVar("Int", 0, "GrowStatus")
end

function ENT:Initialize()
	self:SetModel("models/autonomous/farming/plant_tomato.mdl")
	self:PhysicsInit(SOLID_BBOX)
	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_NONE)
	
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	local physObj = self:GetPhysicsObject()

	if IsValid(physObj) then
		physObj:Sleep()
	end

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
end

if SERVER then
	function ENT:AddWorkerXP(client, xp)
		local id = isnumber(client) and client or client:GetCharacter():GetID()

		self.workers = self.workers or {}
		self.workers[id] = xp
	end

	function ENT:PayWorkers(stage)
		local info = self.Plant.Stages[stage]

		for id, xp in pairs(self.workers) do
			local character = ix.char.loaded[id]

			if character and IsValid(character:GetPlayer()) then
				character:DoAction("farming", xp, self.Plant)

				if info.Harvest then
					character:GetPlayer():RewardXP(self.Plant.RewardXP, "урожай")
				end
			end
		end

		self.workers = {}
	end

	function ENT:SetupPlant(id, owner)
		self.Plant = ix.Farming:GetPlant(id)

		self:SetModel(self.Plant.Model)

		self.value = 0

		self:SetPlant(id)
		self:SetStage(1)
		self:SetWater(0)
		self:SetGrowStatus(0)

		self.workers = {}

		if IsValid(owner) then
			self.character = owner:GetCharacter():GetID()
			
			self:AddWorkerXP(self.character, 30)
		end

		ix.Farming:AddPlant(self)
	end

	function ENT:SetStage(stage, wasRepeat)
		if stage > #self.Plant.Stages then return end

		local info = self.Plant.Stages[stage]

		self.stage = stage
		self.nextStage = self:GetNextStage()

		if info.Bodygroup then
			self:SetBodygroup(0, info.Bodygroup)
		end

		if info.Harvest then
			self:SetGrowStatus(4)
			self:SetIsGrow(true)
		end
	end

	function ENT:Use(activator)

	end

	function ENT:GetNextStage()
		local currentStage = self.Plant.Stages[self.stage]
		local nextStage = self.Plant.Stages[self.stage + 1]

		if !nextStage and !currentStage.RepeatTime then
			return
		elseif nextStage then
			return self.stage + 1
		end
		
		return self.stage
	end

	function ENT:ProgressPlant(time, hydrationCost, ruinedThreshold)
		local ticks = (time / FARMING_TICK)
		local waterPerTick = (hydrationCost / ticks)

		local water = self:GetWater()
		local newWater = (water - waterPerTick)
		local result

		if newWater >= 0 then
			self.value = self.value + FARMING_TICK

			self:SetGrowStatus(1)
		else
			self.value = self.value - (FARMING_TICK * 0.75)

			self:SetGrowStatus(2)

			if self.value <= ruinedThreshold then
				local ruinedStage = math.max(self.stage - 1, 1)

				if ruinedStage != 1 then
					self.value = 0
					self:SetStage(ruinedStage)
				else
					self:PlantRuined()
				end

				result = false
			end
		end

		self:SetWater(math.max(water - waterPerTick, 0))

		return result
	end

	function ENT:PlantRuined()
		self:Remove()
	end
	
	function ENT:OnTick()
		local rain = StormFox2.Weather.GetRainAmount()

		if rain > 0 then
			local water = self:GetWater()

			self:SetWater(math.Clamp(water + (2 * rain), 0, 150))
		end

		if self.nextStage then
			local info = self.Plant.Stages[self.nextStage]

			if !self:GetIsGrow() then
				local ruinedTime = self.Plant.Stages[self.stage].Time
				local result = self:ProgressPlant(info.Time, info.HydrationCost, -ruinedTime)

				if result == false then
					return
				end
			end

			if info.RepeatTime and self.wasHarvested then
				self:SetGrowStatus(3)
				
				if self.value >= info.RepeatTime then
					self.value = 0
					self.wasHarvested = false

					self:SetIsGrow(false)
				end

				return
			end

			if self.value >= info.Time then
				self.value = 0

				self:AddWorkerXP(self.character, self.Plant.SkillXP * self.nextStage)
				self:PayWorkers(self.nextStage)

				self:SetStage(self.nextStage, info.RepeatTime and true or false)
				return
			end
		end
	end
	
	function ENT:OnRemove()
		ix.Farming:RemovePlant(self)
	end

	function ENT:OnSelectHarvest(client)
		if self:GetIsGrow() and !self.wasHarvested then
			local info = self.Plant

			self.wasHarvested = true

			self:SetIsGrow(false)
			self:SetGrowStatus(3)

			if info.HarvestBodygroup then
				self:SetBodygroup(0, info.HarvestBodygroup)
			end
			
			local count = math.random(info.MinCount or 1, info.MaxCount or 1)

			for i = 1, count do
				local new_item = ix.Item:Instance(info.Result)
				local success = client:AddItem(new_item)

				if !success then
					timer.Simple(0.5, function()
						ix.Item:Spawn(client, nil, new_item)
					end)
				end
			end
		end
	end

	local waterItems = {
		"dirty_water",
		"canned_water",
		"breens_water",
		"smooth_breens_water",
		"special_breens_water",
		"purified_water",
	}
	function ENT:OnSelectRefill(client)
		local waterItem

		if client:GetLocalVar("bIsHoldingObject") then
			local hands = client:GetWeapon("ix_hands")

			if IsValid(hands) then
				local object = IsValid(hands.heldEntity) and hands.heldEntity

				if object and object.ixItemID then
					local item = ix.Item.instances[object.ixItemID]

					if table.HasValue(waterItems, item.uniqueID) and !item:GetData("closed") then
						waterItem = item
					end
				end
			end
		end

		if !waterItem then
			for k, v in ipairs(waterItems) do
				local item = client:FindItem(v, "main")

				if item and !item:GetData("closed") then
					waterItem = item
				end
			end
		end
		
		if !waterItem then
			return
		end

		local uses = waterItem:GetUses()
		local waterPerUse = (waterItem.stats.thirst * 2)
		local newWater = self:GetWater() + waterPerUse

		if newWater > 150 then
			return
		end

		client:GetCharacter():DoAction("farmingWater", 0.4 * waterPerUse, self.Plant)

		self:EmitSound("ambient/water/water_spray1.wav")
		
		self:SetWater(math.Clamp(newWater, 0, 150))

		if uses > 1 then
			waterItem:SetData("uses", uses - 1)
		else
			local junk = waterItem.junk
			local class = waterItem.uniqueID

			if IsValid(waterItem.entity) then
				local pos, ang = waterItem.entity:GetPos(), waterItem.entity:GetAngles()

				waterItem.entity:Remove()

				if junk then
					local new_item = ix.Item:Instance(junk)
					new_item:SetData("class", class)

					ix.Item:Spawn(pos, ang, new_item)
				end
			else
				waterItem:Remove()

				if junk then
					local new_item = ix.Item:Instance(junk)
					new_item:SetData("class", class)
					client:AddItem(new_item)
				end
			end
		end
	end
end

if CLIENT then
	ENT.PopulateEntityInfo = true

	local growStatus = {
		"Активный рост",
		"Голодание",
		"Период отдыха",
		"Можно собрать урожай"
	}

	function ENT:OnPopulateEntityInfo(container)
		local id = self:GetPlant()
		local status = self:GetGrowStatus()

		if id then
			local plantInfo = ix.Farming:GetPlant(id)

			local name = container:AddRow("name")
			name:SetImportant()
			name:SetText(plantInfo.Name)
			name:SetBackgroundColor(Color(64, 225, 64))
			name:SizeToContents()

			local water = container:AddRow("water")
			water:SetText(string.format("Вода: %s%%", math.Round(self:GetWater())))
			water:SetBackgroundColor(Color(64, 225, 225))
			water:SizeToContents()
			water.Think = function(this)
				if !IsValid(self) then
					return
				end
				
				this:SetText(string.format("Вода: %s%%", math.Round(self:GetWater())))
			end

			if status and (status > 0) then
				local info = container:AddRow("status")
				info:SetText(growStatus[status])
				info:SetBackgroundColor(Color(225, 225, 225))
				info:SizeToContents()
				info.Think = function(this)
					if !IsValid(self) then
						return
					end

					local status = self:GetGrowStatus()

					if status and (status > 0) then
						this:SetText(growStatus[status])
					end
				end
			end

			local desc = container:AddRow("desc")
			desc:SetText(plantInfo.Description)
			desc:SizeToContents()
		end
	end

	function ENT:GetEntityMenu(client)
		local menus = {}

		if self:GetIsGrow() then
			menus["Собрать урожай"] = function(panel)
				ix.menu.NetworkChoice(self, "Harvest")

				return false
			end
		end

		menus["Полить водой"] = function(panel)
			ix.menu.NetworkChoice(self, "Refill")

			return false
		end

		return menus
	end
end

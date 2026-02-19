local Appearance = ix.Appearance
local Outfit = class("Outfit")

function Outfit:__tostring() return "outfit" end
function Outfit:GetOwner() return self.owner end

function Outfit:Init(owner)
	Appearance.Entities[owner] = true

	self.character = nil
	self.owner = owner
	self.model = nil

	self.layers = {
		[Appearance.Layer.Main] = owner
	}
	self.displayIds = {}

	owner.model_parts = owner.model_parts or {}

	if SERVER then
		self.isModelChangedByOutfit = false

		self.armor = {}
		self.gasmask = nil

		owner:SetNWFloat("speed_debuff", 1)

		self:CreateLayer(Appearance.Layer.Top)
		self:CreateLayer(Appearance.Layer.Bottom)
	else
		self.modelClass = Appearance:GetModelClass(self.owner:GetModel())
	end
end

if SERVER then
	util.AddNetworkString("appearance.update")

	function Outfit:CreateLayer(layer)
		local owner = self.owner
		local foundLayer = owner.model_parts[layer] 

		if !IsValid(foundLayer) then
			local attachment = ents.Create("ix_attachment")
			attachment:SetModel("models/error.mdl")
			attachment:SetParent(owner)
			attachment:AddEffects(EF_BONEMERGE)
			attachment:SetLightingOriginEntity(owner)
			attachment:SetNoDraw(true)
			attachment:Spawn()

			owner:DeleteOnRemove(attachment)

			foundLayer = attachment
		end

		owner.model_parts[layer] = foundLayer
		self.layers[layer] = foundLayer

		return attachment
	end

	function Outfit:SetupItems()
		if !IsValid(self.owner) then
			return
		end

		if !self.prepareItems then
			return
		end

		self.prepareItems = nil
		self.owner:SetNWFloat("speed_debuff", 1)
		
		self.armor = {}
		self.gasmask = nil

		for k, v in pairs(self.owner:GetInventories()) do
			for z, x in ipairs(v:GetItemsID()) do
				local item = ix.Item.instances[x]

				if item and item.OnEquipped then
					if item:IsEquipped() then
						item:OnEquipped(self.owner)
					end
				end
			end
		end

		if self.loading then
			self.loading = false
		end
	end

	function Outfit:LoadCharacter(character)
		if self.loading then
			return
		end

		self.loading = true
		self.prepareItems = true
		self.character = character
		self.model = character:GetModel()

		timer.Simple(0, function()
			self:SetupItems()
		end)
	end

	function Outfit:Reset()
		if true then
			return
		end
		
		self.layers = {}

		local base = {
			item = false,
			model = self.client:GetCharacter():GetModel(),
			bodygroups = {}
		}

		for i = 0, (self.client:GetNumBodyGroups() - 1) do
			base.bodygroups[i] = 0
		end

		self.layers[1] = base
	end

	function Outfit:ModelChanged(model, oldModel)
		if !self.character or self.isModelChangedByOutfit or self.loading then
			self.isModelChangedByOutfit = false
			return
		end

		if self.owner:GetCharacter() != self.character then
			return
		end

		self.model = model
		self.prepareItems = true
		self:SetupItems()
	end

	function Outfit:AddItem(item)
		self:Add(item.displayID)
	end

	function Outfit:RemoveItem(item)
		self:Remove(item.displayID)
	end

	function Outfit:Add(displayId)
		local displayInfo = Appearance.Database[displayId]

		if !displayInfo then
			return
		end
		
		if self.displayIds[displayInfo.slot] then
			return
		end
		
		self.displayIds[displayInfo.slot] = displayInfo
	end

	function Outfit:ModifyItem(item, bodygroups)
		if true then
			return
		end

		for k, v in ipairs(self.layers) do
			if v.item == false then continue end

			if v.item == item.id then
				self.layers[k].bodygroups = table.Copy(bodygroups)
				return
			end
		end
	end

	function Outfit:Remove(displayId)
		local displayInfo = Appearance.Database[displayId]

		if !displayInfo then
			return
		end

		if !self.displayIds[displayInfo.slot] then
			return
		end

		self.displayIds[displayInfo.slot] = nil
	end

	function Outfit:SendTo(target)
		if !self.lastClientside then
			return
		end
		
		local payload = {}

		for id in pairs(self.lastClientside) do
			table.insert(payload, id)
		end

		net.Start("appearance.update")
			net.WriteUInt(self.owner:EntIndex(), 16)
			net.WriteUInt(#payload, 8)
			for _, id in ipairs(payload) do
				net.WriteUInt(id, 16)
			end
			net.WriteUInt(0, 8)
		net.Send(target)
	end

	function Outfit:SendClientUpdate(visible)
		local lastClientside = self.lastClientside or {}

		local added = {}
		local removed = {}

		for id in pairs(visible) do
			if !lastClientside[id] then
				table.insert(added, id)
			end
		end

		for id in pairs(lastClientside) do
			if !visible[id] then
				table.insert(removed, id)
			end
		end

		self.lastClientside = visible

		if #added > 0 or #removed > 0 then
			net.Start("appearance.update")
				net.WriteUInt(self.owner:EntIndex(), 16)
				net.WriteUInt(#added, 8) -- макс 255 изменений
				for _, id in ipairs(added) do
					net.WriteUInt(id, 16)
				end
				
				net.WriteUInt(#removed, 8)
				for _, id in ipairs(removed) do
					net.WriteUInt(id, 16)
				end
			net.Broadcast()
		end
	end

	function Outfit:Update()
		local charGen = self.character:CharGen()
		local fallbackModel = self.model

		self.modelClass = Appearance:GetModelClass(fallbackModel)

		-- определяем скрытые слоты и body-маски
		local hiddenSlots = {}
		local bodyMasks = {}

		for slot, displayInfo in pairs(self.displayIds) do
			local effect = Appearance.SlotEffect[slot]
			local variant = displayInfo.slotEffect

			local effectData = variant and variant or (effect and effect.default)
			
			if effectData then
				local bodyMask = displayInfo.bodyMask and displayInfo.bodyMask or effectData.bodyMask

				if effectData.hides then
					for _, hidden in ipairs(effectData.hides) do
						hiddenSlots[hidden] = true
					end
				end

				if bodyMask then
					local modelInfoDefault = Appearance.ModelInfo["default"]
					local modelInfo = (modelClass and Appearance.ModelInfo[self.modelClass]) or modelInfoDefault
					local mask = modelInfo and modelInfo[bodyMask] or modelInfoDefault[bodyMask]

					for group, value in pairs(mask or {}) do
						bodyMasks[group] = value
					end
				end
			end
		end

		-- группируем серверсайд одежду по слоям
		local visible = {
			[Appearance.Layer.Main] = {},
			[Appearance.Layer.Top] = {},
			[Appearance.Layer.Bottom] = {}
		}

		local visibleClientside = {}

		local params = {}
		local lastParams = self.lastPoseParams or {}

		for slot, displayInfo in pairs(self.displayIds) do
			if hiddenSlots[slot] then continue end

			local visualInfo = displayInfo
				
			if displayInfo.variants then
				visualInfo = displayInfo.variants[self.modelClass] or visualInfo
			end

			if visualInfo and visualInfo.params then
				for k, v in pairs(visualInfo.params) do
					params[k] = v
				end
			end

			if displayInfo.clientside then
				visibleClientside[displayInfo.id] = true
				continue 
			end
			
			local layer = displayInfo.layer or Appearance.Layer.Main
			table.insert(visible[layer], displayInfo)
		end

		for k, v in pairs(params) do
			if lastParams[k] != v then
				self.owner:SetPoseParameter(k, v)
			end
		end

		for k in pairs(lastParams) do
			if !params[k] then
				self.owner:SetPoseParameter(k, 0)
			end
		end

		self.lastPoseParams = params
		
		for layer, part in ipairs(self.layers) do
			if !IsValid(part) then continue end


			local targetModel = nil
			local bodyGroups = {}

			-- мерджим все компоненты (модель берём первую непустую)
			for _, displayInfo in ipairs(visible[layer]) do
				local visualInfo = displayInfo
				
				if displayInfo.variants then
					visualInfo = displayInfo.variants[self.modelClass] or visualInfo
				end
				
				if visualInfo then
					if visualInfo.model and not targetModel then
						targetModel = visualInfo.model
					end

					if visualInfo.bodyGroups then
						for g, v in pairs(visualInfo.bodyGroups) do
							bodyGroups[g] = v
						end
					end
				end
			end

			-- добавляем настройки бг из кастомизации + применяем маски от слоев на главный слой
			if layer == 1 then
				if charGen and charGen._bodygroups then
					for g, v in pairs(charGen._bodygroups) do
						bodyGroups[g] = v
					end
				end
				
				for g, v in pairs(bodyMasks) do
					bodyGroups[g] = v
				end

				if !targetModel then
					if part:GetModel() != fallbackModel then
						self.isModelChangedByOutfit = true
						part:SetModel(fallbackModel)
					end
				end
			end

			-- смена модели если изменилась
			if targetModel then
				if part:GetModel() != targetModel then
					if layer == 1 then
						self.isModelChangedByOutfit = true
					end

					part:SetModel(targetModel)
				end

				if layer == 1 then
					self.modelClass = Appearance:GetModelClass(targetModel) or self.modelClass
				end

				part:SetNoDraw(false)
			else
				part:SetNoDraw(layer != 1) -- тело всегда видно
			end

			for i = 0, part:GetNumBodyGroups() do
				local val = bodyGroups[i] or 0

				if val != nil and part:GetBodygroup(i) != val then
					part:SetBodygroup(i, val)
				end
			end
		end

		self:SendClientUpdate(visibleClientside)

		/*

		local bodygroups = table.Copy(self.layers[1].bodygroups)
		local model = self.client:GetCharacter():GetModel()
		local override = self.client:GetCharacter():GetData("model_override")
		local custom = {}

		for k, v in ipairs(self.layers) do
			if v.item == false then continue end

			for z, x in pairs(bodygroups) do
				bodygroups[z] = v.bodygroups[z] or x
			end

			local item = ix.Item.instances[v.item]

			if item.outfit_id then
				table.insert(custom, item.outfit_id)
			end
			
			model = v.model or model
		end

		if override then
			model = override
		end

		if model and self.client:GetModel() != model then
			self.isModelChangedByOutfit = true
			self.client:SetModel(model)
		end

		for k, v in pairs(bodygroups) do
			self.client:SetBodygroup(k, v)
		end

		self.client:SetNetVar("custom_outfit", custom)*/
	end
else

	function Outfit:CreateModel(displayInfo)
		if !displayInfo then return end

		local foundAttachment = self.owner.model_parts[displayInfo.tag]

		if IsValid(foundAttachment) then
			SafeRemoveEntity(foundAttachment)
		end
		
		local attachment = ents.CreateClientside("ix_attachment")
		local visualInfo = displayInfo
				
		if displayInfo.variants then
			visualInfo = displayInfo.variants[self.modelClass] or visualInfo
		end
		
		if visualInfo then
			if visualInfo.model then
				attachment:SetModel(visualInfo.model)
				attachment:SetNoDraw(false)

			else
				attachment:SetModel("models/error.mdl")
				attachment:SetNoDraw(true)
			end
		end

		if visualInfo.bodyGroups then
			for g, v in pairs(visualInfo.bodyGroups) do
				attachment:SetBodygroup(g, v)
			end
		end

		attachment:SetParent(self.owner)
		attachment:AddEffects(EF_BONEMERGE)
		attachment:Spawn()
		attachment.ProxyOwner = self.owner
		attachment.m_flFlexDelayedWeight = 0

		self.owner:CallOnRemove("ClearModelParts", function(ent) 
			local attachments = self.owner.model_parts

			timer.Simple(0, function()
				if !IsValid(self.owner) then
					for k, attachment in pairs(attachments) do
						if IsValid(attachment) then
							SafeRemoveEntity(attachment)
						end
					end
				end
			end)
		end)

		self.owner.model_parts[displayInfo.tag] = attachment

		return attachment
	end

	function Outfit:FetchPoseParametes(displayId, params, isAdded)
		local displayInfo = Appearance.Database[displayId]
		local visualInfo = displayInfo
			
		if displayInfo.variants then
			visualInfo = displayInfo.variants[self.modelClass] or visualInfo
		end

		if visualInfo and visualInfo.params then
			for k, v in pairs(visualInfo.params) do
				if isAdded then
					params[k] = v
				else
					local min, max = self.owner:GetPoseParameterRange(k)
					params[k] = min or 0
				end
			end
		end
	end

	function Outfit:Update(added, removed)
		self.modelClass = Appearance:GetModelClass(self.owner:GetModel())

		local params = self.lastPoseParams or {}

		for _, displayId in ipairs(removed or {}) do
			local attachment = self.owner.model_parts[displayId]

			self:FetchPoseParametes(displayId, params, false)

			if IsValid(attachment) then
				SafeRemoveEntity(attachment)
			end

			self.displayIds[displayId] = nil
			self.owner.model_parts[displayId] = nil
		end

		for _, displayId in ipairs(added or {}) do
			local attachment = self.owner.model_parts[displayId]
			local displayInfo = Appearance.Database[displayId]

			self:FetchPoseParametes(displayId, params, true)

			if IsValid(attachment) then
				SafeRemoveEntity(attachment)
			end

			self.displayIds[displayId] = true

			if self.owner:IsDormant() then
				self._hiddenModels = self._hiddenModels or {}
				self._hiddenModels[displayId] = true
			else
				self:CreateModel(displayInfo)
			end
		end

		for displayId in next, self.displayIds do
			local displayInfo = Appearance.Database[displayId]
			local visualInfo = displayInfo
				
			if displayInfo.variants then
				visualInfo = displayInfo.variants[self.modelClass] or visualInfo
			end

			if visualInfo and visualInfo.params then
				for k, v in pairs(visualInfo.params) do
					params[k] = v
				end
			end
		end

		self.owner:InvalidateBoneCache()

		self.lastPoseParams = params
		self.updatePoseParams = true
	end

	function Outfit:TemporaryHideParts()
		self._hiddenModels = self._hiddenModels or {}

		for displayID, attachment in pairs(self.owner.model_parts) do
			if IsValid(attachment) then
				SafeRemoveEntity(attachment)
			end

			self._hiddenModels[displayID] = true
			self.owner.model_parts[displayID] = nil
		end
	end

	function Outfit:RevealParts()
		timer.Simple(0, function()
			if !IsValid(self.owner) then
				return
			end

			for displayId in next, self._hiddenModels do
				if !self.displayIds[displayId] then
					goto CONTINUE
				end
				
				local displayInfo = Appearance.Database[displayId]
				self:CreateModel(displayInfo)

				::CONTINUE::
			end

			self._hiddenModels = {}
		end)

		self.isHidden = false
	end

	net.Receive("appearance.update", function()
		local entIndex = net.ReadUInt(16)
		local added, removed = {}, {}

		local count = net.ReadUInt(8)
		for i = 1, count do
			local id = net.ReadUInt(16)
			local displayInfo = Appearance:GetByID(id)

			if displayInfo then
				added[#added + 1] = displayInfo.tag
			end
		end

		count = net.ReadUInt(8)

		for i = 1, count do
			local id = net.ReadUInt(16)
			local displayInfo = Appearance:GetByID(id)

			if displayInfo then
				removed[#removed + 1] = displayInfo.tag
			end
		end

		local entity = Entity(entIndex)

		if IsValid(entity) then
			if !entity.char_outfit then
				entity.char_outfit = ix.meta.Outfit:New(entity)
			end

			entity.char_outfit:Update(added, removed)
		end
	end)

	hook.Add("NotifyShouldTransmit", "appearance.transmit", function(entity, state)
		if state then
			if entity.model_parts then
				for _, attachment in pairs(entity.model_parts) do
					if IsValid(attachment) then
						attachment:SetParent(entity)
					end
				end
			end
		else
			local outfit = entity.char_outfit

			if outfit then
				if !outfit.isHidden then
					outfit:TemporaryHideParts()

					outfit.isHidden = true
				end
			end
		end
	end)

	hook.Add("Think", "appearance.think", function()
		local client = LocalPlayer()

		if !IsValid(client) then 
			return 
		end


		for entity in next, Appearance.Entities do
			if !IsValid(entity) then
				Appearance.Entities[entity] = nil
				goto CONTINUE
			end

			if entity:IsDormant() then goto CONTINUE end

			local outfit = entity.char_outfit

			if outfit.isHidden then
				outfit:RevealParts()
			end

			::CONTINUE::
		end
	end)

	hook.Add("UpdateAnimation", "appearance.params", function(entity)
		local outfit = entity.char_outfit

		if outfit then
			local params = outfit.lastPoseParams or {}

			for k, v in pairs(params) do
				entity:SetPoseParameter(k, v)
			end
		end
	end)
end
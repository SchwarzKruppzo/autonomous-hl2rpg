local Outfit = class("Outfit")

function Outfit:__tostring() return "outfit" end
function Outfit:GetPlayer() return self.client end

function Outfit:Init(client)
	self.layers = {}
	self.client = client
	self.armor = {}
	self.gasmask = nil

	client:SetNWFloat("speed_debuff", 1)
end

function Outfit:SetupItems()
	if !IsValid(self.client) then
		return
	end

	if !self.prepareItems then
		return
	end
	
	self.prepareItems = nil
	self.client:SetNWFloat("speed_debuff", 1)
	
	self.armor = {}
	self.gasmask = nil

	for k, v in pairs(self.client:GetInventories()) do
		for z, x in ipairs(v:GetItemsID()) do
			local item = ix.Item.instances[x]

			if item and item.OnEquipped then
				if item:IsEquipped() then
					item:OnEquipped(self.client)
				end
			end
		end
	end
end

function Outfit:LoadCharacter(character, prevCharacter)
	self.loading = true
	self.prepareItems = true

	timer.Simple(0, function()
		self:SetupItems()
	end)
end

function Outfit:ModelChanged(model, oldModel)
	if self.loading then
		return
	end

	self:Reset()
	self.prepareItems = true
	self:SetupItems()
end

function Outfit:Reset()
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

	self.client:SetNetVar("custom_outfit", nil)
end

function Outfit:AddItem(item, mdl, bodygroups)
	local layer = {
		item = item.id,
		model = mdl or false,
		bodygroups = table.Copy(bodygroups)
	}

	table.insert(self.layers, layer)
end

function Outfit:ModifyItem(item, bodygroups)
	for k, v in ipairs(self.layers) do
		if v.item == false then continue end

		if v.item == item.id then
			self.layers[k].bodygroups = table.Copy(bodygroups)
			return
		end
	end
end

function Outfit:RemoveItem(item)
	for k, v in ipairs(self.layers) do
		if v.item == false then continue end

		if v.item == item.id then
			table.remove(self.layers, k)
			break
		end
	end
end

function Outfit:Update()
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
		self.loading = true
		self.client:SetModel(model)
	end

	for k, v in pairs(bodygroups) do
		self.client:SetBodygroup(k, v)
	end

	self.client:SetNetVar("custom_outfit", custom)
end
local ItemReagentContainer = class("ItemReagentContainer"):implements("Item")
ItemReagentContainer.isReagentHolder = true
ItemReagentContainer.reusable = false

function ItemReagentContainer:Init()
	self:AddData("closed", {
		Transmit = ix.transmit.owner,
	})

	self:AddData("value", {
		Transmit = ix.transmit.all,
		Write = function(item, value) net.WriteFloat(value) end,
		Read = function(item) return net.ReadFloat() end
	})

	self:AddData("reagents_data", {
		Transmit = ix.transmit.owner,
	})

	self.combine = self.combine or {}

	self.combine.fill = {
		name = "Перелить в",
		OnRun = function(item, targetItem)
			if !item.reagents or !targetItem.reagents then return end

			local amount = item.transfer_amount or (item.reagents.volume * 0.25)
			item.reagents:Transfer(targetItem, amount, item.player)
		end,
		OnCanRun = function(item, targetItem)
			if !targetItem.isReagentHolder then return false end
			if !ix.Reagents:IsDrainable(item) then return false end
			if !ix.Reagents:IsRefillable(targetItem) then return false end

			return (item:GetData("value") or 0) > 0.1
		end
	}

	self.combine.drain = {
		name = "Набрать из",
		OnRun = function(item, targetItem)
			if !item.reagents or !targetItem.reagents then return end

			local amount = item.transfer_amount or (targetItem.reagents.volume * 0.25)
			targetItem.reagents:Transfer(item, amount, item.player)
		end,
		OnCanRun = function(item, targetItem)
			if !targetItem.isReagentHolder then return false end
			if !ix.Reagents:IsRefillable(item) then return false end
			if !ix.Reagents:IsDrainable(targetItem) then return false end

			return (targetItem:GetData("value") or 0) > 0.1
		end
	}
end

function ItemReagentContainer:IsClosed()
	return false
end

function ItemReagentContainer:GetReagentFlags()
	return self.reagent_flags or 0
end

function ItemReagentContainer:GetVolume()
	return self:GetData("value") or 0
end

function ItemReagentContainer:GetMaxVolume()
	return self.volume or 100
end

function ItemReagentContainer:GetFillFraction()
	return math.Clamp(self:GetVolume() / self:GetMaxVolume(), 0, 1)
end

function ItemReagentContainer:OnDepleted()
	if self.reusable then
		if self.reagents then
			self.reagents:Clear()
		end

		return
	end

	local junk = self.junk
	local class = self.uniqueID

	if IsValid(self.entity) then
		local pos, ang = self.entity:GetPos(), self.entity:GetAngles()
		self.entity:Remove()

		if junk then
			local new_item = ix.Item:Instance(junk, {class = class})
			ix.Item:Spawn(pos, ang, new_item)
		end
	else
		self:Remove()

		if junk then
			local new_item = ix.Item:Instance(junk, {class = class})
			self.player:AddItem(new_item)
		end
	end
end

if SERVER then
	function ItemReagentContainer:OnInstanced(isCreated)
		if !self.reagents then
			local flags = self.GetReagentFlags and self:GetReagentFlags() or (self.reagent_flags or 0)
			self.reagents = ix.meta.ReagentHolder:New(self.volume or 100, flags)
			self.reagents.owner = self
		end

		if isCreated then
			self:OnFirstCreated()
		else
			local savedReagents = self:GetData("reagents_data")

			if savedReagents then
				self.reagents:Deserialize(savedReagents)
			end
		end
	end

	function ItemReagentContainer:OnFirstCreated()
		if self.add_reagents then
			self.reagents:AddReagents(self.add_reagents)
		end
	end

	function ItemReagentContainer:OnReagentUpdateTotal(value)
		self:SetData("value", value)
		self:SetData("reagents_data", self.reagents:Serialize())
	end
end

return ItemReagentContainer

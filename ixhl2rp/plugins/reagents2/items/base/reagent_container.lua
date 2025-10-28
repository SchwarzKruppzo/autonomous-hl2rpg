local ItemReagentContainer = class("ItemReagentContainer"):implements("Item")
ItemReagentContainer.isReagentHolder = true

function ItemReagentContainer:Init()
	self:AddData("value", {
		Transmit = ix.transmit.all,
		Write = function(item, value) net.WriteFloat(value) end,
		Read = function(item) return net.ReadFloat() end
	})
end

function ItemReagentContainer:IsClosed()
	return false
end

if SERVER then
	function ItemReagentContainer:OnInstanced(isCreated)
		if !self.reagents then
			self.reagents = ix.meta.ReagentHolder:New(self.volume, 0)
			self.reagents.owner = self
		end

		if isCreated and self.add_reagents then
			self.reagents:AddReagents(self.add_reagents, self.reagent_flags or 0)
		end
	end
end

return ItemReagentContainer
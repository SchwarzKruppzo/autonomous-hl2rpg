local ItemJunkDynamic = class("ItemJunkDynamic"):implements("Item")

function ItemJunkDynamic:Init()
	self.category = "Хлам"

	self:AddData("class", {
		Transmit = ix.transmit.owner,
	})
end

function ItemJunkDynamic:GetSkin()
	if !self.cachedSkin then
		local inherit = ix.Item:Get(self:GetData("class") or self.uniqueID)

		self.cachedSkin = inherit and (inherit.skin or 0) or 0
	end
	
	return self.cachedSkin
end

function ItemJunkDynamic:GetModel()
	if !self.cachedModel then
		local inherit = ix.Item:Get(self:GetData("class") or self.uniqueID)

		self.cachedModel = inherit and inherit.model or self.model
	end
	
	return self.cachedModel
end


return ItemJunkDynamic
local Station = class("CraftStation")

function Station:Init(uniqueID)
	self.name = self.name or "undefined"
	self.description = self.description or "undefined"
	self.uniqueID = uniqueID or "undefined"
end

function Station:GetModel()
	return self.model
end

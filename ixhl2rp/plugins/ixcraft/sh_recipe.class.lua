local PLUGIN = PLUGIN
local Recipe = class("CraftRecipe")

function Recipe:Init(uniqueID)
	self.name = self.name or "undefined"
	self.description = self.description or "undefined"
	self.category = self.category or "item.category.misc"
	self.uniqueID = uniqueID or "undefined"
end

function Recipe:GetName() return L(self.name) end
function Recipe:GetDescription() return L(self.description) end
function Recipe:GetSkin() return self.skin end
function Recipe:GetModel() return self.model end

function Recipe:AttemptCraft(client)
	return true
end

if SERVER then
	function Recipe:OnCraft(client)
		
	end
end

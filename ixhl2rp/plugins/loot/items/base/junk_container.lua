local ItemJunkContainer = class("ItemJunkContainer")
implements("ItemReagentContainer", "ItemJunkContainer")

ItemJunkContainer = ix.meta.ItemJunkContainer
ItemJunkContainer.reusable = true
ItemJunkContainer.volume = 330
ItemJunkContainer.useSound = {"npc/barnacle/barnacle_gulp1.wav", "npc/barnacle/barnacle_gulp2.wav"}

function ItemJunkContainer:Init()
	ix.meta.ItemReagentContainer.Init(self)

	self.category = "loot.categoryJunk"

	self:AddData("class", {
		Transmit = ix.transmit.owner,
	})

	self.functions.use = {
		name = "loot.useSip",
		OnRun = function(item)
			local client = item.player
			local character = client:GetCharacter()
			local sipAmount = item.sip_amount or (item:GetMaxVolume() * 0.2)
			sipAmount = math.min(sipAmount, item.reagents and item.reagents.volume or 0)

			if sipAmount <= 0 then return end

			local thirst, hunger = ix.Reagents:Consume(item.reagents, sipAmount, client)
			character:UpdateNeeds(thirst, hunger)

			if istable(item.useSound) then
				client:EmitSound(item.useSound[math.random(1, #item.useSound)])
			else
				client:EmitSound(item.useSound)
			end
		end,
		OnCanRun = function(item)
			if SERVER and item.reagents then return item.reagents.volume > 0.1 end
			if CLIENT then return (item:GetData("value") or 0) > 0.1 end
			return true
		end
	}

	self.functions.useall = {
		name = "loot.useSipAll",
		OnRun = function(item)
			local client = item.player
			local character = client:GetCharacter()
			local remaining = item.reagents and item.reagents.volume or 0

			if remaining <= 0.1 then return end

			local thirst, hunger = ix.Reagents:Consume(item.reagents, remaining, client)
			character:UpdateNeeds(thirst, hunger)

			if istable(item.useSound) then
				client:EmitSound(item.useSound[math.random(1, #item.useSound)])
			else
				client:EmitSound(item.useSound)
			end
		end,
		OnCanRun = function(item)
			if SERVER and item.reagents then return item.reagents.volume > 0.1 end
			if CLIENT then return (item:GetData("value") or 0) > 0.1 end
			return true
		end
	}

	self.functions.pour = {
		name = "loot.pourContents",
		OnRun = function(item)
			if item.reagents then
				item.reagents:Clear()
			end
		end,
		OnCanRun = function(item)
			if SERVER and item.reagents then return item.reagents.volume > 0.1 end
			if CLIENT then return (item:GetData("value") or 0) > 0.1 end
			return true
		end
	}
end

function ItemJunkContainer:GetClassItem()
	local classID = self:GetData("class")

	if classID then
		return ix.Item:Get(classID)
	end
end

function ItemJunkContainer:GetSkin()
	if !self.cachedSkin then
		local classItem = self:GetClassItem()
		self.cachedSkin = classItem and (classItem.skin or 0) or (self.skin or 0)
	end

	return self.cachedSkin
end

function ItemJunkContainer:GetModel()
	if !self.cachedModel then
		local classItem = self:GetClassItem()
		self.cachedModel = classItem and classItem.model or self.model
	end

	return self.cachedModel
end

function ItemJunkContainer:GetMaxVolume()
	if !self.cachedMaxVolume then
		local classItem = self:GetClassItem()
		self.cachedMaxVolume = classItem and classItem.volume or self.volume or 330
	end

	return self.cachedMaxVolume
end

function ItemJunkContainer:GetReagentFlags()
	return ix.Reagents.holder.open
end

if SERVER then
	function ItemJunkContainer:OnInstanced(isCreated)
		local classItem = self:GetClassItem()

		if classItem and classItem.volume then
			self.volume = classItem.volume
		end

		ix.meta.ItemReagentContainer.OnInstanced(self, isCreated)
	end
else
	function ItemJunkContainer:PopulateTooltip(tooltip)
		if !self:GetEntity() then
			local currentVolume = math.Round(self:GetVolume())
			local maxVolume = self:GetMaxVolume()

			local vol = tooltip:AddRowAfter("name")
			vol:SetBackgroundColor(derma.GetColor("Success", tooltip))
			vol:SetText(L("portionDesc", currentVolume, maxVolume))
		end
	end
end

return ItemJunkContainer

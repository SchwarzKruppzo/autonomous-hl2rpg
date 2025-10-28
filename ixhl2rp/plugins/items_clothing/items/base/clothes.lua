//ix.util.Include("equipable.lua", "shared")

local ItemCloth = class("ItemCloth")
implements("ItemEquipable", "ItemCloth")

ItemCloth = ix.meta.ItemCloth
ItemCloth.category = 'Clothes'

function ItemCloth:Init()
	ix.meta.ItemEquipable.Init(self)

	self.category = 'Одежда'

	self:AddData("filter", {
		Transmit = ix.transmit.none,
	})
end

function ItemCloth:OnEquipped(client)
	local model = false
	local char = client:GetCharacter()

	if isfunction(self.OnGetReplacement) then
		model = self:OnGetReplacement()
	elseif (self.replacement or self.replacements) then
		if (istable(self.replacements)) then
			if (#self.replacements == 2 and isstring(self.replacements[1])) then
				model = client:GetModel():gsub(self.replacements[1], self.replacements[2])
			else
				for _, v in ipairs(self.replacements) do
					model = client:GetModel():gsub(v[1], v[2])
				end
			end
		else
			model = self.replacement or self.replacements
		end
	elseif (self.genderReplacement) then
		model = self.genderReplacement[char:GetGender()] or self.genderReplacement[GENDER_MALE]
	end

	client.char_outfit:AddItem(self, model, self.bodyGroups or {})
	client.char_outfit:Update()

	if self.isGasmask then
		client.char_outfit.gasmask = self
	end
end

function ItemCloth:OnUnequipped(client)
	client.char_outfit:RemoveItem(self)
	client.char_outfit:Update()

	if self.isGasmask then
		client.char_outfit.gasmask = nil
	end
end

function ItemCloth:OnRegistered()
	local id = #ix.outfits + 1

	if isfunction(self.GetOutfitData) then
		ix.outfits[id] = self:GetOutfitData()

		self.outfit_id = id
	end
end

return ItemCloth
//ix.util.Include("equipable.lua", "shared")

local ItemCloth2 = class("ItemClothLegacy")
implements("ItemEquipable", "ItemClothLegacy")

ItemCloth2 = ix.meta.ItemClothLegacy
ItemCloth2.category = 'Clothes'

function ItemCloth2:IsEquipped()
	return self.inventory_type == 'main' and (self:GetData('equip') == true)
end

local function Write_Equip(item, value)
	net.WriteBool(value)
end

local function Read_Equip(item)
	return net.ReadBool(value)
end

function ItemCloth2:Init()
	ix.meta.ItemEquipable.Init(self)

	self.functions.equip = {
		tip = "equipTip",
		icon = "icon16/box.png",
		OnRun = function(item)
			item:Equip(item.player, true)

			item:SetData("equip", true)
		end,
		OnCanRun = function(item)
			local client = item.player

			return !item:GetEntity() and IsValid(client) and !item:IsEquipped()
		end
	}

	self.functions.unequip = {
		tip = "unequipTip",
		icon = "icon16/box.png",
		OnRun = function(item)
			item:Equip(item.player, false)

			item:SetData("equip", false)
		end,
		OnCanRun = function(item)
			local client = item.player

			return !item:GetEntity() and IsValid(client) and item:IsEquipped()
		end
	}

	self.category = "item.category.clothing"

	self:AddData("equip", {
		Transmit = ix.transmit.owner,
		Write = Write_Equip,
		Read = Read_Equip
	})

	self:AddData("filter", {
		Transmit = ix.transmit.none,
	})
end

function ItemCloth2:OnEquipped(client)
	local model = false
	local char = client:GetCharacter()

	if isfunction(self.OnGetReplacement) then
		model = self:OnGetReplacement(client, char)
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

	local bodyGroups = (self.bodyGroups or {})

	if self.GetOutfitBodyGroups then
		bodyGroups = self:GetOutfitBodyGroups(client)
	end

	client.char_outfit:AddItem(self, model, bodyGroups)
	client.char_outfit:Update()

	if self.isGasmask then
		client.char_outfit.gasmask = self
	end

	if self.skinGroups then
		for k, v in pairs(self.skinGroups or {}) do
			client:SetNWInt("sg_"..k, v)
		end
	end
end

function ItemCloth2:OnUnequipped(client)
	client.char_outfit:RemoveItem(self)
	client.char_outfit:Update()

	if self.isGasmask then
		client.char_outfit.gasmask = nil
	end

	if self.skinGroups then
		for k, v in pairs(self.skinGroups or {}) do
			client:SetNWInt("sg_"..k, 0)
		end
	end
end

function ItemCloth2:OnRegistered()
	local id = #ix.outfits + 1

	if isfunction(self.GetOutfitData) then
		ix.outfits[id] = self:GetOutfitData()

		self.outfit_id = id
	end
end

return ItemCloth2
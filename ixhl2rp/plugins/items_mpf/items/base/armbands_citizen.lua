local ItemArmbandCit = class("ItemArmbandCit")
implements("ItemCloth", "ItemArmbandCit")

ItemArmbandCit = ix.meta.ItemArmbandCit
ItemArmbandCit.model = "models/cellar/items/armband_citizen.mdl"
ItemArmbandCit.description = ""
ItemArmbandCit.iconCam = {
	pos = Vector(0, 0, 9.487096786499),
	ang = Angle(91.083457946777, -49.069404602051, 0),
	fov = 45,
}
ItemArmbandCit.bodyGroups = {
	[6] = 0,
}
ItemArmbandCit.equip_inv = 'arm'
ItemArmbandCit.equip_slot = nil

local flex_data = {
	[1] = 8,
	[8] = 8,
	[11] = 8,
	[13] = 8,
	[18] = 8,
	[19] = 8,
	[20] = 8,
	[21] = 8,
	[2] = 0,
	[5] = 0,
	[6] = 0,
	[9] = 3,
	[16] = 0,
	[17] = 0,
	[22] = 1,
	[26] = 2,
	[27] = 5,
	[28] = 6,
	[29] = 4,
	[30] = 7,
}

function ItemArmbandCit:GetOutfitData()
	return {
		slot = "arm",
		model = {
			[GENDER_MALE] = "models/cellar/male_citizen_armband.mdl",
			[GENDER_FEMALE] = "models/cellar/female_citizen_armband.mdl",
		},
		OnUpdate = function(part, client)
			local torso = client.outfit_parts["torso"]
			local flex = flex_data[client:GetBodygroup(1)]

			if torso and torso.fit then
				if torso.fit == 1 then
					part:SetFlexWeight(9, 1)
				end
			elseif flex then
				part:SetFlexWeight(flex, 1)
			else
				part:SetFlexWeight(0, 0)
			end
		end
	}
end

function ItemArmbandCit:Init()
	ix.meta.ItemCloth.Init(self)

	self.armband = self.armband or 0
	self.category = 'Повязки (Лояльность)'
end

function ItemArmbandCit:OnEquipped(client)
	ix.meta.ItemCloth.OnEquipped(self, client)

	client:SetNWInt("sg_armcit", self.armband)
end

function ItemArmbandCit:OnUnequipped(client)
	ix.meta.ItemCloth.OnUnequipped(self, client)

	client:SetNWInt("sg_armcit", 0)
end

return ItemArmbandCit
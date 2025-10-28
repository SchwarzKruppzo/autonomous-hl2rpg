local ItemClothMPF = class("ItemClothMPF")
implements("ItemClothArmor", "ItemClothMPF")

ItemClothMPF = ix.meta.ItemClothMPF
ItemClothMPF.model = "models/items/mpfequipment.mdl"
ItemClothMPF.equip_inv = 'torso'
ItemClothMPF.equip_slot = nil
ItemClothMPF.iconCam = {
	pos = Vector(-0.20621359348297, -84.556304931641, 423.92922973633),
	ang = Angle(78.628517150879, 90.203117370605, 0),
	fov = 3.2292894524527,
}
ItemClothMPF.isMPF = true

local vector_origin = vector_origin or Vector()

function ItemClothMPF:Init()
	ix.meta.ItemClothArmor.Init(self)

	self.width = 2
	self.height = 2

	self.uniform = self.uniform or 0
	self.primaryVisor = self.primaryVisor or vector_origin
	self.secondaryVisor = self.secondaryVisor or vector_origin
	self.specialization = self.specialization or nil

	self.category = 'Одежда (MPF)'

	self:AddData("armband", {
		Transmit = ix.transmit.owner,
	})
end

function ItemClothMPF:OnInstanced(isCreated)
	ix.meta.ItemClothArmor.OnInstanced(self, isCreated)

	if isCreated then
		self:SetData("armband", 0)
	end
end

local armbandRank = {
	[0] = "r",
	[1] = "i4",
	[2] = "i3",
	[3] = "i2",
	[4] = "i1",
	[5] = "is",
	[6] = "dl",
	[7] = "cc",
	[8] = "oo",
	[9] = "sF"
}

function ItemClothMPF:UpdateMPF(client, armband)
	if client:Team() == FACTION_MPF then
		local name = client:GetName()
		local format = "(CCA%:.*%.).*(%.%d+)"
		local ranks = string.match(name, "CCA%:.*%.(.*)%.%d+") or string.match(name, "CCA%:.*%:(.*)%.%d+")
		local a = string.Explode(":", ranks)
		local spec = Schema:GetPlayerCombineSpec(client)

		ranks = string.Replace(ranks, a[1], armbandRank[armband])

		if a[2] then
			if !self.specialization then
				ranks = string.Replace(ranks, ":"..a[2], "")
			else
				ranks = string.Replace(ranks, a[2], a[2] or self.specialization)
			end
		else
			ranks = ranks..(self.specialization and (":"..self.specialization) or "")
		end

		local newName = string.gsub(name, format, "%1"..ranks.."%2")

		client:GetCharacter():SetVar("oldName", name, true)
		client:GetCharacter():SetName(newName)
	end
end

function ItemClothMPF:OnEquipped(client)
	ix.meta.ItemClothArmor.OnEquipped(self, client)

	local armband = self:GetData("armband", 0)

	client:SetNWInt("sg_uniform", self.uniform)
	client:SetNWInt("sg_armband", armband)

	client:SetPrimaryVisorColor(self.primaryVisor)
	client:SetSecondaryVisorColor(self.secondaryVisor)
	
	self:UpdateMPF(client, armband)
end

function ItemClothMPF:OnUnequipped(client)
	ix.meta.ItemClothArmor.OnUnequipped(self, client)

	client:SetNWInt("sg_uniform", 0)
	client:SetNWInt("sg_armband", 0)

	client:SetPrimaryVisorColor(vector_origin)
	client:SetSecondaryVisorColor(vector_origin)
end

return ItemClothMPF
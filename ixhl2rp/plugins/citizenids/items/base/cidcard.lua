local Item = class("ItemCID")
implements("ItemEquipable", "ItemCID")

Item = ix.meta.ItemCID

Item.equip_inv = 'cid'
Item.equip_slot = nil
Item.stackable = true
Item.max_stack = 5
Item.cardType = 0

CARDTYPE_NONE = 0
CARDTYPE_MED = 1
CARDTYPE_CWU = 2
CARDTYPE_UNION = 3
CARDTYPE_CITY = 4

do
	local prime = 9999999787 -- prime % 4 = 3! DO NOT CHANGE EVER
	local offset = 100000 -- slightly larger than sqrt(prime) is ok. DO NOT CHANGE EVER
	local block = 100000000
	function Item:GenerateCardNumber(id)
		id = (id + offset) % prime

		local cardNum = 0

		for _ = 1, math.floor(id/block) do
			cardNum = (cardNum + (id * block) % prime) % prime
		end

		cardNum = (cardNum + (id * (id % block) % prime)) % prime

		if (2 * id < prime) then
			return Schema:ZeroNumber(cardNum, 10)
		else
			return Schema:ZeroNumber(prime - cardNum, 10)
		end
	end
end

do
	local prime = 99787 // prime % 4 = 3, don't change
	local offset = 318 // > sqrt(prime), don't change
	local block = 1000
	function Item:GenerateCitizenID(characterID)
		characterID = (characterID + offset) % prime

		local cid = 0

		for _ = 1, math.floor(characterID/block) do
			cid = (cid + (characterID * block) % prime) % prime
		end

		cid = (cid + (characterID * (characterID % block) % prime)) % prime

		if (2 * characterID < prime) then
			return Schema:ZeroNumber(cid, 5)
		else
			return Schema:ZeroNumber(prime - cid, 5)
		end
	end
end

function Item:GetDescription()
	return L(string.format("iCardDesc%s", self.cardType or 0), self:GetData("name", "nobody"))
end

function Item:GetRarity()
	return self.cardType
end

function Item:Init()
	ix.meta.ItemEquipable.Init(self)

	self.category = "item.category.cid"

	self.functions.devEdit = {
		name = "Admin Edit",
		icon = "icon16/wrench.png",
		OnClick = function(item)
			
		end,
		OnRun = function(item)
			netstream.Start(item.player, "ixCitizenIDEdit", item:GetID(), item.data)
			return false
		end,
		OnCanRun = function(item)
			return item.player:IsAdmin()
		end
	}

	self:AddData("name", {
		Transmit = ix.transmit.owner,
	})

	self:AddData("cid", {
		Transmit = ix.transmit.owner,
	})

	self:AddData("number", {
		Transmit = ix.transmit.owner,
	})

	self:AddData("access", {
		Transmit = ix.transmit.owner,
	})

	self:AddData("datafileID", {
		Transmit = ix.transmit.none,
	})

	self:AddData("nextRationTime", {
		Transmit = ix.transmit.none,
	})
end

function Item:OnInstanced(isCreated)
	if isCreated then
		local cardNumber = self:GenerateCardNumber(self:GetID())
		self:SetData("number", string.format("%s-%d",
			string.gsub(cardNumber, "^(%d%d)(%d%d%d%d)(%d%d%d%d)", "%1%-%2%-%3"),
			Schema:ZeroNumber(cardNumber % 97, 2)
		))

		self:SetData("access", self.access or {})
	end

	hook.Run("OnIDCardInstanced", self)
end

function Item:SetupCharacter(character)
	--self:SetData("name", character:GetName())
	--self:SetData("cid", "000-00")
	--self:SetData("datafileID", character:GetID())
end

function Item:CreateDatafile(client)
	if IsValid(client) then
		local character = client:GetCharacter()

		self:SetData("name", character:GetName())
		self:SetData("cid", self:GenerateCitizenID(character:GetID()))

		timer.Simple(0, function()
			hook.Run("OnIDCardUpdated", self)
		end)
	end
end

function Item:OnEquipped(client)
	--ix.Datafile:OnCardEquipped(client, self, true)

	--LEGACY:
	client.ixDatafile = self:GetData("datafileID", 0)
end

function Item:OnUnequipped(client)
	--ix.Datafile:OnCardEquipped(client, self, false) 

	--LEGACY:
	client.ixDatafile = nil
end

if CLIENT then
	function Item:PopulateTooltip(tooltip)
		local cid = self:GetData("cid")
		local number = self:GetData("number")

		if cid then
			local panel = tooltip:AddRowAfter("rarity", "cid")
			panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
			panel:SetText(L("cidCitizenIdLabel", cid))
			panel:SizeToContents()
		end

		if number then
			local panel = tooltip:AddRowAfter("rarity", "number")
			panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
			panel:SetText(L("cidCardIdLabel", number))
			panel:SizeToContents()
		end

		if self.cardType > 0 then
			local notice = tooltip:AddRowAfter("description", "notice")
			notice:SetMinimalHidden(true)
			notice:SetFont("ixMonoSmallFont")
			notice:SetText(L(string.format("cardNotice%s", self.cardType)))
			notice.Paint = function(_, width, height)
				surface.SetDrawColor(ColorAlpha(derma.GetColor("Error", tooltip), 11))
				surface.DrawRect(0, 0, width, height)
			end
			notice:SizeToContents()
		end
	end
end

return Item
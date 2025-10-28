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

local prime = 9999999787 -- prime % 4 = 3! DO NOT CHANGE EVER
local offset = 100000 -- slightly larger than sqrt(prime) is ok. DO NOT CHANGE EVER
local block = 100000000
local function generateCardNumber(id)
	id = (id + offset) % prime

	local cardNum = 0

	for _ = 1, math.floor(id/block) do
		cardNum = (cardNum + (id * block) % prime) % prime
	end

	cardNum = (cardNum + (id * (id % block) % prime)) % prime

	if (2 * id < prime) then
		return cardNum
	else
		return prime - cardNum
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

	self.category = 'Citizen ID'

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
		Transmit = ix.transmit.owner,
	})
end

function Item:OnInstanced(isCreated)
	if isCreated then
		local cardNumber = Schema:ZeroNumber(generateCardNumber(self:GetID()), 10)
		self:SetData("number", string.format("%s-%d",
			string.gsub(cardNumber, "^(%d%d)(%d%d%d%d)(%d%d%d%d)", "%1%-%2%-%3"),
			Schema:ZeroNumber(cardNumber % 97, 2)
		))

		self:SetData("access", self.access or {})
	end

	hook.Run("OnIDCardInstanced", self)
end

function Item:SetupCharacter(character)
	self:SetData("name", character:GetName())
	self:SetData("cid", "000-00")
	self:SetData("datafileID", character:GetID())
end

function Item:CreateDatafile(client)
	if IsValid(client) then
		local character = client:GetCharacter()

		self:SetData("name", character:GetName())
		self:SetData("cid", Schema:ZeroNumber(math.random(1, 99999), 5))

		hook.Run("OnIDCardUpdated", self)
	end
end

function Item:OnEquipped(client)
	ix.Datafile:OnCardEquipped(client, self, true)
end

function Item:OnUnequipped(client)
	ix.Datafile:OnCardEquipped(client, self, false)
end

if CLIENT then
	function Item:PopulateTooltip(tooltip)
		local cid = self:GetData("cid")
		local number = self:GetData("number")

		if cid then
			local panel = tooltip:AddRowAfter("rarity", "cid")
			panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
			panel:SetText("Citizen ID: #" .. cid)
			panel:SizeToContents()
		end

		if number then
			local panel = tooltip:AddRowAfter("rarity", "number")
			panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
			panel:SetText("Card ID: #" .. number)
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
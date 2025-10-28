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
		Transmit = ix.transmit.none,
	})

	self:AddData("nextRationTime", {
		Transmit = ix.transmit.none,
	})
end

function Item:OnInstanced(isCreated)
	if isCreated then
		self:SetData("access", self.access or {})
	end

	hook.Run("OnIDCardInstanced", self)
end

function Item:CreateDatafile(client)
	if IsValid(client) then
		local character = client:GetCharacter()

		self:SetData("name", character:GetName())
		self:SetData("cid", Schema:ZeroNumber(math.random(1, 99999), 5))
		self:SetData("number", string.format("%s-%d",
			string.gsub(math.random(100000000, 999999999), "^(%d%d%d)(%d%d%d%d)(%d%d)", "%1:%2:%3"),
			Schema:ZeroNumber(math.random(1, 99), 2)
		))

		hook.Run("OnIDCardUpdated", self)
	end
end

function Item:OnEquipped(client)
	client.ixDatafile = self:GetData("datafileID", 0)
end

function Item:OnUnequipped(client)
	client.ixDatafile = nil
end

if CLIENT then
	function Item:PopulateTooltip(tooltip)
		local cid = self:GetData("cid")
		local number = self:GetData("number")

		if cid then
			local panel = tooltip:AddRowAfter("rarity", "cid")
			panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
			panel:SetText("CID: #" .. cid)
			panel:SizeToContents()
		end

		if number then
			local panel = tooltip:AddRowAfter("rarity", "number")
			panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
			panel:SetText("RegID: #" .. number)
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
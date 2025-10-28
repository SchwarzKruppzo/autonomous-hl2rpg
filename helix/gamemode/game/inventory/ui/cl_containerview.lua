
local PANEL = {}

AccessorFunc(PANEL, "money", "Money", FORCE_NUMBER)

function PANEL:Init()
	local arrow = Material('cellar/main/tab/arrow.png')
	local arrowHovered = Material('cellar/main/tab/arrowhovered.png')

	self:SetTall(64)

	self.moneyLabel = self:Add("DLabel")
	self.moneyLabel:Dock(TOP)
	self.moneyLabel:SetFont("ixGenericFont")
	self.moneyLabel:SetText("")
	self.moneyLabel:SetTextInset(2, 0)
	self.moneyLabel:SizeToContents()

	self.amountEntry = self:Add("ixTextEntry")
	self.amountEntry:Dock(FILL)
	self.amountEntry:SetFont("ixGenericFont")
	self.amountEntry:SetNumeric(true)
	self.amountEntry:SetValue("0")

	self.transferButton = self:Add("DButton")
	self.transferButton:SetFont("ixIconsMedium")
	self:SetLeft(false)
	self.transferButton.DoClick = function()
		local amount = math.max(0, math.Round(tonumber(self.amountEntry:GetValue()) or 0))
		self.amountEntry:SetValue("0")

		if (amount != 0) then
			self:OnTransfer(amount)
		end
	end

	self.bNoBackgroundBlur = true
end

function PANEL:SetLeft(bValue)
	if (bValue) then
		self.transferButton:Dock(LEFT)
		self.transferButton:SetText("s")
	else
		self.transferButton:Dock(RIGHT)
		self.transferButton:SetText("t")
	end
end

function PANEL:SetMoney(money)
	local name = string.gsub(ix.util.ExpandCamelCase(ix.currency.plural), "%s", "")

	self.money = math.max(math.Round(tonumber(money) or 0), 0)
	self.moneyLabel:SetText(string.format("%s: %d", name, money))
end

function PANEL:OnTransfer(amount)
end

function PANEL:Paint(width, height)
	derma.SkinFunc("PaintBaseFrame", self, width, height)
end

vgui.Register("ixStorageMoney", PANEL, "EditablePanel")

DEFINE_BASECLASS("Panel")
PANEL = {}

AccessorFunc(PANEL, "fadeTime", "FadeTime", FORCE_NUMBER)
AccessorFunc(PANEL, "frameMargin", "FrameMargin", FORCE_NUMBER)
AccessorFunc(PANEL, "storageID", "StorageID", FORCE_NUMBER)

function PANEL:Init()
	if (IsValid(ix.gui.openedStorage)) then
		ix.gui.openedStorage:Remove()
	end

	ix.gui.openedStorage = self

	self:SetSize(ScrW(), ScrH())
	self:SetPos(0, 0)
	self:SetFadeTime(0.25)
	self:SetFrameMargin(4)

	self.storageTitle = self:Add("DLabel")
	self.storageTitle:SetFont("ixMenuButtonFont")
	self.storageTitle:SetText("")

	self.storageInventory = self:Add('ui.inv')
	self.storageInventory.OnRebuild = function(_)
		self:MoveToBack()
	end

	self.storageMoney = self:Add("ixStorageMoney")
	self.storageMoney:SetVisible(false)
	self.storageMoney.OnTransfer = function(_, amount)
		net.Start("ixStorageMoneyTake")
			net.WriteUInt(self.storageID, 32)
			net.WriteUInt(amount, 32)
		net.SendToServer()
	end
	
	self.local_inventory = self:Add('ui.inv')
	self.local_inventory.OnRebuild = function(_)
		self:MoveToBack()
	end

	self.local_character = self:Add("Panel")
	self.local_character:SetSize(ix.UI.Scale(480), ix.UI.Scale(630))

	local equipPanel = self.local_character:Add("ixEquipment")
	equipPanel:SetCharacter(LocalPlayer())
	equipPanel:Center()

	self.localMoney = self:Add("ixStorageMoney")
	self.localMoney:SetVisible(false)
	self.localMoney:SetLeft(true)
	self.localMoney.OnTransfer = function(_, amount)
		net.Start("ixStorageMoneyGive")
			net.WriteUInt(self.storageID, 32)
			net.WriteUInt(amount, 32)
		net.SendToServer()
	end

	self:SetAlpha(0)
	self:AlphaTo(255, self:GetFadeTime())

	self.hint = self:Add("DLabel")
	self.hint:SetFont("ixMediumFont")
	self.hint:SetText("[TAB] — close storage")
	self.hint:SizeToContents()
	self.hint:Center()
	self.hint:AlignBottom(16)

	

	self:MakePopup()
end

function PANEL:OnKeyCodePressed(key)
	local droppable = dragndrop.GetDroppable('ix.item')

	if self:HasFocus() and droppable then
		droppable = droppable[1]

		if key == KEY_R and IsValid(droppable) then
			droppable:Turn()

			local drop_slot = ix.inventory_drop_slot

			if IsValid(drop_slot) then
				drop_slot.is_hovered = false
				ix.inventory_drop_slot = nil
			end
		end
	end

	if key == KEY_TAB then
		net.Start("ixStorageClose")
		net.SendToServer()
		self:Remove()
	end
end

function PANEL:OnChildAdded(panel)
	panel:SetPaintedManually(true)
end

local function ClampInventory(panel)
	panel:SizeToContents()

	local w, h = panel:GetWide(), panel:GetTall()

	w = math.Clamp(w, 0, ScrW() / 2 - panel:GetParent():GetFrameMargin())
	h = math.Clamp(h, 0, ScrH() * 0.95 - 96)

	panel:SetSize(w, h)
end

function PANEL:SetLocalInventory(inventory)
	if !IsValid(ix.gui.menu) then
		
		self.local_inventory:SetInventoryID(inventory.id)
		self.local_inventory:Rebuild()
		ClampInventory(self.local_inventory)
		
		
		self.local_character:Center()
		self.local_character:SetPos(self:GetWide() / 2 + self:GetFrameMargin(), 10)

		self.local_inventory:SetPos(self.local_character:GetX() + self.local_character:GetWide() * 0.5 - self.local_inventory:GetWide() * 0.5)
		self.local_inventory:MoveBelow(self.local_character, 0)


		inventory.panel = self.local_inventory
	end
end

function PANEL:SetPlayerInventory(target)
	if target == LocalPlayer() then
		return
	end
	
	self.character = self:Add("Panel")
	self.character:SetSize(ix.UI.Scale(480), ix.UI.Scale(630))

	local equipPanel = self.character:Add("ixEquipment")
	equipPanel:SetCharacter(target)
	equipPanel:Center()

	self.character:Center()
	self.character:SetPos(self:GetWide() / 2 - self.character:GetWide() - self:GetFrameMargin(), 10)

	local halfWidth = self.storageInventory:GetWide() * 0.5
	self.storageInventory:SetPos(self.character:GetX() + self.character:GetWide() * 0.5 -halfWidth)
	self.storageInventory:MoveBelow(self.character, 0)

	local x, y = self.storageInventory:GetPos()

	self.storageTitle:SetPos(x + halfWidth - self.storageTitle:GetWide() * 0.5)
	self.storageTitle:MoveAbove(self.storageInventory, 5)
end

function PANEL:SetLocalMoney(money)
	if !self.localMoney:IsVisible() then
		self.localMoney:SetVisible(true)
		self.localMoney:SetWide(self.local_inventory:GetWide())
		self.localMoney:SetPos(self.local_inventory:GetPos())
		self.localMoney:MoveBelow(self.local_inventory, 5)
	end

	self.localMoney:SetMoney(money)
end

function PANEL:SetStorageTitle(title)
	self.storageTitle:SetText(L(title))
end

function PANEL:SetStorageInventory(inventory)
	self.storageInventory:SetInventoryID(inventory.id)
	self.storageInventory:Rebuild()
	ClampInventory(self.storageInventory)
	self.storageInventory:SetPos(self:GetWide() / 2 - self.storageInventory:GetWide() - self:GetFrameMargin(), self:GetTall() / 2 - self.storageInventory:GetTall() / 2)

	self.storageTitle:SizeToContents()
	self.storageTitle:SetPos(self.storageInventory:GetPos())
	self.storageTitle:MoveAbove(self.storageInventory, 5)

	inventory.panel = self.storageInventory
end

function PANEL:SetStorageMoney(money)
	if !self.storageMoney:IsVisible() then
		self.storageMoney:SetVisible(true)
		self.storageMoney:SetWide(self.storageInventory:GetWide())
		self.storageMoney:SetPos(self.storageInventory:GetPos())
		self.storageMoney:MoveBelow(self.storageInventory, 5)
	end

	self.storageMoney:SetMoney(money)
end

function PANEL:Paint(width, height)
	ix.util.DrawBlurAt(0, 0, width, height)

	for _, v in ipairs(self:GetChildren()) do
		v:PaintManual()
	end
end

function PANEL:Remove()
	self:SetAlpha(255)
	self:AlphaTo(0, self:GetFadeTime(), 0, function()
		BaseClass.Remove(self)
	end)
end

function PANEL:OnRemove()
	if !IsValid(ix.gui.menu) then
		self.storageInventory:Remove()
		self.local_inventory:Remove()
	end
end

vgui.Register("ixStorageView", PANEL, "EditablePanel")

net.Start("ixStorageClose")
		net.SendToServer()
if (IsValid(ix.gui.openedStorage)) then

	ix.gui.openedStorage:Remove()
end
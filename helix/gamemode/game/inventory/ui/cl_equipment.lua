local PANEL = {}
local scale = ix.UI.Scale
PANEL.IsEquipment = true

function PANEL:Init()
	ix.gui.equipment = self

	self:SetSize(scale(450) , scale(630 - 20))

	//self:Receiver("ixInventoryItem", self.ReceiveDrop)
end

local MODEL_ANGLE = Angle(0, 45, 0)
function PANEL:SetCharacter(client)
	self.model = self:Add("ixModelPanel")
	self.model:Dock(FILL)
	self.model:SetFOV(50)
	self.model:SetAlpha(255)

	self.character = client:GetCharacter()
	self.client = client

	if !client.inventories then
		client.inventories = {}

		for k, v in pairs(ix.Inventory:All()) do
			if v.owner == client then
				client.inventories[v.type] = v
			end
		end
	end

	if client != LocalPlayer() then
		self.model.LayoutEntity = function(self)
			local entity = self.Entity

			entity:SetAngles(MODEL_ANGLE)
			entity:SetIK(false)

			if (self.copyLocalSequence) then
				entity:SetSequence(LocalPlayer():GetSequence())
				entity:SetPoseParameter("move_yaw", 360 * LocalPlayer():GetPoseParameter("move_yaw") - 180)
			end

			self:RunAnimation()
		end
	end

	self:UpdateModel()

	local head = client:GetInventory("head"):CreatePanel(self)
	head:SetSlotSize(64)
	head:Rebuild()
	head:SizeToContents()
	head:AlignTop(16)
	head:SetTitle("ГОЛОВА")

	local face = client:GetInventory("mask"):CreatePanel(self)
	face:SetSlotSize(64)
	face:Rebuild()
	face:SizeToContents()
	face:MoveBelow(head, 16)
	face:SetTitle("ЛИЦО")

	local torso = client:GetInventory("torso"):CreatePanel(self)
	torso:SetSlotSize(64)
	torso:Rebuild()
	torso:SizeToContents()
	torso:MoveBelow(face, 16)
	torso:SetTitle("ТОРС")

	local cid = client:GetInventory("cid"):CreatePanel(self)
	cid:SetSlotSize(64)
	cid:Rebuild()
	cid:SizeToContents()
	cid:AlignBottom()
	cid:SetTitle("CITIZEN ID")

	local radio = client:GetInventory("radio"):CreatePanel(self)
	radio:SetSlotSize(64)
	radio:Rebuild()
	radio:SizeToContents()
	radio:MoveAbove(cid, 16)
	radio:SetTitle("РАЦИЯ")

	local ears = client:GetInventory("ears"):CreatePanel(self)
	ears:SetSlotSize(64)
	ears:Rebuild()
	ears:SizeToContents()
	ears:AlignTop(16)
	ears:AlignRight(0)
	ears:SetTitle("УШИ")

	local arm = client:GetInventory("arm"):CreatePanel(self)
	arm:SetSlotSize(64)
	arm:Rebuild()
	arm:SizeToContents()
	arm:MoveBelow(ears, 16)
	arm:AlignRight(0)
	arm:SetTitle("ПЛЕЧО")

	local legs = client:GetInventory("legs"):CreatePanel(self)
	legs:SetSlotSize(64)
	legs:Rebuild()
	legs:SizeToContents()
	legs:MoveBelow(arm, 16)
	legs:AlignRight(0)
	legs:SetTitle("НОГИ")

	local hands = client:GetInventory("hands"):CreatePanel(self)
	hands:SetSlotSize(64)
	hands:Rebuild()
	hands:SizeToContents()
	hands:MoveBelow(legs, 16)
	hands:AlignRight(0)
	hands:SetTitle("РУКИ")

	local backpack = client:GetInventory("backpack"):CreatePanel(self)
	backpack:SetSlotSize(64)
	backpack:Rebuild()
	backpack:SizeToContents()
	backpack:AlignBottom()
	backpack:AlignRight(0)
	backpack:SetTitle("РЮКЗАК")
end

function PANEL:GetCharacter()
	if self.character then
		return self.character
	end

	return nil
end

function PANEL:ReceiveDrop(panels, bDropped, menuIndex, x, y)
	return 
end

function PANEL:Think()
	if (IsValid(ix.gui.menu) and ix.gui.menu.bClosing) then
		if(self.model) then
			self.model:Remove()
		end
	end

	if IsValid(self.model) then
		if self.client:GetModel() != self.model:GetModel() then
			self:UpdateModel()
		end
	end
end

function PANEL:UpdateModel()
	if IsValid(self.model) then
		self.model:SetModel(self:GetCharacter().model or self.client:GetModel(), self:GetCharacter().vars.skin or self:GetCharacter():GetData("skin", 0))

		for i = 0, (self.client:GetNumBodyGroups() - 1) do
			self.model.Entity:SetBodygroup(i, self.client:GetBodygroup(i))
		end

		self.model.Entity.ProxyOwner = self.client
	end
end

function PANEL:Paint(w, h)

end

vgui.Register("ixEquipment", PANEL, "DPanel")


local PANEL = {}
local scale = ix.UI.Scale

local function DrawCorners(x, y, w, h)
	surface.SetDrawColor(16, 32, 48, 255 * 0.9)
	surface.DrawRect(0, 0, w, h)

	local size = ix.UI.Scale( (h / 4) * 0.1 )

	surface.SetDrawColor(0, 190, 255, 255)
	surface.DrawLine(x, y, x + size, y)
	surface.DrawLine(x, y, x, y + size)

	x, y = w - 1, y

	surface.DrawLine(x, y, x - size, y)
	surface.DrawLine(x, y, x, y + size)

	x, y = 0, h - 1

	surface.DrawLine(x, y, x + size, y)
	surface.DrawLine(x, y, x, y - size)

	x, y = w - 1, h - 1

	surface.DrawLine(x, y, x - size, y)
	surface.DrawLine(x, y, x, y - size)


	surface.SetDrawColor(0, 190, 255, 255 * 0.25)

	local halfW, halfH = w / 2, h /2
	local halfSize = size / 2

	x, y = halfW - size, 0
	surface.DrawLine(x, y, x + size * 2, y)
	y = h - 1
	surface.DrawLine(x, y, x + size * 2, y)
	x, y = 0, halfH - size
	surface.DrawLine(x, y, x, y + size * 2)
	x = w - 1
	surface.DrawLine(x, y, x, y + size * 2)
end

function PANEL:Paint(w, h)
	//DrawCorners(0, 0, w, h)
end

function PANEL:Setup(dock, size)
	size = size or scale(64)

	self.size = size

	if !dock then
		self:Dock(FILL)
		self:InvalidateParent(true)
	end

	local top = self:Add("Panel")
	top:Dock(TOP)
	top:DockMargin(10, 10, 10, 0)
	top:SetTall(scale(630))
	top:InvalidateParent(true)

	local frame = top:Add("Panel")
	frame:SetSize(scale(480), scale(630))
	frame.Paint = function(_, w, h)
		DrawCorners(0, 0, w, h)
	end

	local equipPanel = frame:Add("ixEquipment")
	equipPanel:SetCharacter(LocalPlayer())
	equipPanel:Center()

	//local health = top:Add("ui.health")
	//health:MoveRightOf(frame, 10)
	//health:AlignTop(0)
	local bottom = self:Add("Panel")
	bottom:Dock(FILL)
	bottom:DockMargin(10, 16, 10, 0)
	bottom:InvalidateParent(true)

	local canvas = bottom:Add("DTileLayout")

	local canvasLayout = canvas.PerformLayout
	canvas.PerformLayout = nil -- we'll layout after we add the panels instead of each time one is added
	canvas:SetBorder(0)
	canvas:SetSpaceX(5)
	canvas:SetSpaceY(5)
	canvas:Dock(FILL)

	ix.gui.menuInventoryContainer = self

	local panel = canvas:Add('ui.inv')
	panel:SetSlotSize(size, size)
	panel:SetInventoryID(LocalPlayer():GetInventory('main').id)
	panel:SetPos(0, 0)
	panel:SetTitle("ВЫ")
	panel.bNoBackgroundBlur = true
	panel.childPanels = {}
	panel:Rebuild()
	panel:SizeToContents()

	LocalPlayer():GetInventory('main').panel = panel

	local backpack = LocalPlayer():GetBackpack()

	if backpack then
		local panel = canvas:Add('ui.inv')
		panel:SetSlotSize(size, size)
		panel:SetInventoryID(backpack:GetInventory().id)
		panel:SetPos(0, 0)
		panel:SetTitle(backpack:GetName():utf8upper())
		panel.bNoBackgroundBlur = true
		panel.childPanels = {}
		panel:Rebuild()
		panel:SizeToContents()

		backpack:GetInventory().panel = panel
		self.backpack = panel
	end

	canvas.PerformLayout = canvasLayout
	canvas:Layout()

	self.canvas = canvas

	ix.gui.setup_backpack = function()
		if !IsValid(self) then
			return
		end
		
		self:SetupBackpack()
	end
end

function PANEL:SetupBackpack()
	local backpack = LocalPlayer():GetBackpack()

	if IsValid(self.backpack) then
		self.backpack:Remove()
		self.backpack = nil
	end
	
	if backpack then
		local panel = self.canvas:Add('ui.inv')
		panel:SetSlotSize(self.size, self.size)
		panel:SetInventoryID(backpack:GetInventory().id)
		panel:SetPos(0, 0)
		panel:SetTitle(backpack:GetName():utf8upper())
		panel.bNoBackgroundBlur = true
		panel.childPanels = {}
		panel:Rebuild()
		panel:SizeToContents()

		backpack:GetInventory().panel = panel
		self.backpack = panel
	end

	self.canvas:Layout()
end

vgui.Register("ui.equipment", PANEL, "EditablePanel")
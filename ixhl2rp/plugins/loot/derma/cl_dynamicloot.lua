DEFINE_BASECLASS("Panel")
local PANEL = {}

AccessorFunc(PANEL, "fadeTime", "FadeTime", FORCE_NUMBER)
AccessorFunc(PANEL, "frameMargin", "FrameMargin", FORCE_NUMBER)

local function DrawCorners(x, y, w, h)
	surface.SetDrawColor(16, 32, 48, 255 * 0.75)
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

function PANEL:Init()
	if IsValid(ix.gui.lootStorage) then
		ix.gui.lootStorage:Remove()
	end

	if IsValid(ix.gui.menu) then
		ix.gui.menu:Remove()
	end

	ix.gui.lootStorage = self

	self:SetSize(ScrW(), ScrH())
	self:SetPos(0, 0)
	self:SetFadeTime(0.25)
	self:SetFrameMargin(4)

	self.local_inventory = self:Add('ui.inv')
	self.local_inventory.OnRebuild = function(_)
		self:MoveToBack()
	end

	self.local_character = self:Add("Panel")
	self.local_character:SetSize(ix.UI.Scale(500), ix.UI.Scale(630))

	local clrTitle = Color(0, 210 * 0.9, 255 * 0.9, 225)
	self.scroll = self:Add("DScrollPanel")
	self.scroll:SetSize(ix.UI.Scale(480), ix.UI.Scale(630))
	self.scroll:Center()
	self.scroll.title = "TIER 1 CONTAINER"
	self.scroll.Paint = function(self, w, h)
		DisableClipping(true)
			surface.SetFont('inventory.title')
			local textW, textH = surface.GetTextSize(self.title)

			surface.SetTextColor(color_white)
			surface.SetTextPos(w / 2 - textW/2, -textH - 1)
			surface.DrawText(self.title)
		DisableClipping(false)
	end

	self.list = self.scroll:Add("DIconLayout")
	self.list:DockMargin(10, 10, 10, 10)
	self.list:Dock(TOP)
	self.list.LayoutIcons_TOP = function(self)
		local cache = 0
		local x = self.m_iBorder
		local y = self.m_iBorder
		local RowHeight = 0
		local MaxWidth = self:GetWide() - self.m_iBorder

		for k, v in ipairs( self:GetChildren() ) do

			if ( !v:IsVisible() ) then continue end

			local w, h = v:GetSize()
			if ( x + w > MaxWidth || ( v.OwnLine && x > self.m_iBorder ) ) then

				x = self.m_iBorder
				y = y + RowHeight + self.m_iSpaceY
				
				RowHeight = 0

			end

			cache = math.max(cache, y + h)
			v:SetPos( x, y )

			x = x + v:GetWide() + self.m_iSpaceX
			RowHeight = math.max( RowHeight, v:GetTall() )

			-- Start a new line if this panel is meant to be on its own line
			if ( v.OwnLine ) then
				x = MaxWidth + 1
			end

		end

		self.RowHeight = cache

		if self.Rescale then
			self:Rescale(cache)
		end
	end
	self.list.Rescale = function(x, y)
		self.scroll:SetTall(math.Clamp(self.list.RowHeight, 64, ix.UI.Scale(630)) + 20)
		self.scroll:Center()
	end

	local equipPanel = self.local_character:Add("ixEquipment")
	equipPanel:SetCharacter(LocalPlayer())
	equipPanel:Center()
	
	self.hint = self:Add("DLabel")
	self.hint:SetFont("ixMediumFont")
	self.hint:SetText("[TAB] — close storage")
	self.hint:SizeToContents()
	self.hint:Center()
	self.hint:AlignBottom(16)

	self:SetAlpha(0)
	self:AlphaTo(255, self:GetFadeTime())
	self:MakePopup()

	self:SetLocalInventory()
end

function PANEL:LootDrop(item, scroll)
	local drop_slot = ix.inventory_drop_slot
	local inventoryID = drop_slot.inventory_id
	local target_x, target_y, was_rotated = drop_slot.slot_x, drop_slot.slot_y, item:IsRotated()

	ix.inventory_drag_slot = nil
	ix.inventory_drop_slot = nil

	drop_slot.is_hovered = false

	net.Start("dynamic.loot.take")
		net.WriteUInt(item.id, 32)
		net.WriteUInt(inventoryID, 32)
		net.WriteUInt(target_x, 8)
		net.WriteUInt(target_y, 8)
		net.WriteBool(was_rotated)
	net.SendToServer()
end
function PANEL:Rebuild(inventory, title)
	if title then
		self.scroll.title = title:utf8upper()
	end
	
	self.list:Clear()

	for k, v in pairs(inventory) do
		local item = ix.Item.stored[v]
		local itemIcon = self.list:Add("craft.preview")
		itemIcon.id = k
		itemIcon.item_count = 1
		itemIcon.GetItemSize = function(self) if !self.rotated then return item.width, item.height else return item.height, item.width end end
		itemIcon.GetItemPos = function() return 1, 1 end
		itemIcon.OnLootDrop = function(item, scroll)
			item.hide = true
			self:LootDrop(item, scroll)
		end
		itemIcon.OnMousePressed = function(self, ...)
			self:SetVisible(false)
			self.mouse_pressed = CurTime()
			ix.inventory_drag_slot = self

			self.BaseClass.OnMousePressed(self, ...)
		end
		itemIcon.OnMouseReleased = function(self, ...)
			if !ix.inventory_drop_slot then
				self:SetVisible(true)
			end
			self.BaseClass.OnMouseReleased(self, ...)
		end
		itemIcon:Droppable( "ix.item" )
		itemIcon.OnDrop = function(self, invpanel)
			RememberCursorPosition()
			self:SetVisible(true)
			local drop_slot = ix.inventory_drop_slot
			ix.inventory_drop_slot = nil

			drop_slot.is_hovered = false
		end
		itemIcon.isLoot = true
		itemIcon.Turn = function(self)
			local w, h = self:GetSize()
			self:SetWidth(h)
			self:SetHeight(w)
			self.rotated = !self.rotated
			self:Rebuild(v, 64)
		end
		itemIcon:Rebuild(v, 64)
	end

	self.list:InvalidateLayout(true)
end

function PANEL:SetLocalInventory()
	if !IsValid(ix.gui.menu) then
		local inventory = LocalPlayer():GetInventory("main")
		local backpackID = LocalPlayer():GetFirstAtSlot(1, 1, 'backpack')
		local backpack = backpackID and ix.Item.instances[backpackID]
		local backpackInventory = backpack and backpack:GetInventory()

		if backpackInventory then
			self.back_inventory = self:Add('ui.inv')
			self.back_inventory.OnRebuild = function(_)
				self:MoveToBack()
			end
			
			self.back_inventory:SetTitle("РЮКЗАК")
			self.back_inventory:SetSlotSize(64, 64)
			self.back_inventory:SetInventoryID(backpackInventory.id)
			self.back_inventory:Rebuild()
			self.back_inventory:SizeToContents()

			backpackInventory.panel = self.back_inventory
		end

		self.local_inventory:SetTitle("ИНВЕНТАРЬ")
		self.local_inventory:SetSlotSize(64, 64)
		self.local_inventory:SetInventoryID(inventory.id)
		self.local_inventory:Rebuild()
		self.local_inventory:SizeToContents()
		
		self.local_character:Center()
		self.local_character:MoveLeftOf(self.scroll, self:GetFrameMargin())

		if !backpackInventory then
			self.local_inventory:MoveRightOf(self.scroll, self:GetFrameMargin() * 4)
			self.local_inventory:SetY(ScrH() * 0.5 - self.local_inventory:GetTall() * 0.5)
		else
			self.local_inventory:MoveRightOf(self.scroll, self:GetFrameMargin() * 4)
			self.local_inventory:SetY(ScrH() * 0.5 - self.local_inventory:GetTall() - self:GetFrameMargin())
			self.back_inventory:MoveRightOf(self.scroll, self:GetFrameMargin() * 4)
			self.back_inventory:SetY(ScrH() * 0.5 + self:GetFrameMargin() * 3)
		end

		inventory.panel = self.local_inventory
	end
end

function PANEL:OnKeyCodePressed(key)
	if key == KEY_TAB then
		self:Remove()
	end
end

function PANEL:Paint(w, h)
	ix.util.DrawBlurAt(0, 0, w, h)
end

function PANEL:Remove()
	net.Start("dynamic.loot.close")
	net.SendToServer()

	self:SetAlpha(255)
	self:AlphaTo(0, self:GetFadeTime(), 0, function()
		BaseClass.Remove(self)
	end)
end

vgui.Register("ui.dynamic.loot", PANEL, "EditablePanel")

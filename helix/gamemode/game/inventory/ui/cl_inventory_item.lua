local PANEL = {}
PANEL.item_data = nil
PANEL.item_count = 0
PANEL.instance_ids = {}
PANEL.slot_number = nil
PANEL.icon = nil
PANEL.icon_material = nil
PANEL.rotated = false

local RARITY_CLR = {
	[0] = Color(72, 72, 72, 128),
	[1] = Color(64, 100, 64, 200),
	[2] = Color(0, 64, 100, 200),
	[3] = Color(72, 32, 100, 200),
	[4] = Color(100, 32, 22, 200),
}

local RARITY_CLR2 = {
	[0] = Color(200, 200, 200, 64),
	[1] = Color(64, 200, 64, 225),
	[2] = Color(0, 128, 255, 225),
	[3] = Color(150, 64, 255, 225),
	[4] = Color(230, 188, 22, 255),
}
local shadow = Material('cellar/slot_shadow.png')

function PANEL:Paint(w, h)
	local draw_color
	local drop_slot = ix.inventory_drop_slot

	if IsValid(drop_slot) and drop_slot:GetInventoryID() == self:GetInventoryID() then
		local drag_slot = ix.inventory_drag_slot

		if IsValid(drag_slot) then
			local slot_w, slot_h = drag_slot:GetItemSize()
			local drop_x, drop_y = drop_slot:GetItemPos()
			local x, y = self:GetItemPos()

			if self.is_hovered or self:IsMultiSlot() and drop_x <= x and drop_y <= y
			and drop_x + slot_w > x and drop_y + slot_h > y then

				local item_obj = self.item_data

				if item_obj then
					if drag_slot.item_data != item_obj then
						local slot_data = drag_slot.item_data

						if slot_data.uniqueID == item_obj.uniqueID and ((slot_data.stackable
						and drag_slot.item_count < slot_data.max_stack
						and drop_slot.item_count < slot_data.max_stack) or slot_data.stackable_legacy) then
							draw_color = Color(200, 200, 60)
							ix.gui.can_drop = true
						else
							draw_color = Color(200, 60, 60, 160)
							ix.gui.can_drop = false
						end
					else
						draw_color = Color(128, 128, 128, 100)
						ix.gui.can_drop = false
					end
				else
					if drop_slot.out_of_bounds or drop_slot.disabled then
						draw_color = Color(200, 60, 60, 160)
						ix.gui.can_drop = false
					else
						draw_color = Color(60, 200, 60, 160)
						ix.gui.can_drop = true
					end
				end
			end
		end
	end


	surface.SetDrawColor(0, 34, 57, 255 * 0.75)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(0 * 0.75, 98 * 0.75, 118 * 0.75, 255)
		surface.DrawOutlinedRect(0, 0, w, h)
	
	if self.item_data then
		surface.SetDrawColor(RARITY_CLR[self.item_data:GetRarity() or 0])
		surface.DrawRect(1, 1, w, h)

		if IsValid(self.mdl) then
			self.mdl:PaintManual()
		end
		
		surface.SetDrawColor(RARITY_CLR2[self.item_data:GetRarity() or 0])
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

		if self.item_data.contraband then
			surface.SetDrawColor(255, 32, 64, 200)
			surface.DrawOutlinedRect(2, 2, w - 4, h - 4)

			surface.SetDrawColor(255, 32, 64, 200)
			surface.DrawRect(w - 4 - 4, 4, 4, 4)
		end
	end

	if self.item_data and self.item_data.PaintSlot then
		self.item_data:PaintSlot(w, h)
	end

	if draw_color then
		render.OverrideBlend(true, 4, 6, BLENDFUNC_ADD, 4, 1, BLENDFUNC_ADD)
			draw.RoundedBox(0, 0, 0, w, h, draw_color)
		render.OverrideBlend(false)
	end

	surface.SetDrawColor(255, 255, 255, 255 * 0.75)
	surface.SetMaterial(shadow)
	surface.DrawTexturedRect(1, 1, w, h)
	
end

surface.CreateFont("item.count", {
	font = "Blender Pro Bold",
	extended = true,
	size = 16,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

function PANEL:PaintOver(w, h)
	if self.item_count >= 2 then
		//DisableClipping(true)
			draw.SimpleText(self.item_count, 'item.count', w - math.scale(12), h - 16, Color(225, 225, 225))
		//DisableClipping(false)
	end

	if !self:IsDragging() and isnumber(self.slot_number) then
		DisableClipping(true)
			draw.SimpleText(self.slot_number, 'DermaDefault', math.scale(4), h - math.scale(14), Color(175, 175, 175))
		DisableClipping(false)
	end

	if self.item_data and self.item_data.PaintOver then
		self.item_data:PaintOver(w, h)
	end
end

function PANEL:OnMousePressed(...)
	self.mouse_pressed = CurTime()
	ix.inventory_drag_slot = self

	self.BaseClass.OnMousePressed(self, ...)
end

function PANEL:OnMouseReleased(mcode)
	local x, y = self:LocalToScreen(0, 0)
	local w, h = self:GetSize()

	if (!dragndrop.m_ReceiverSlot or dragndrop.m_ReceiverSlot.Name != 'ix.item') then
		ix.gui.hover_hediff = nil
		
		self:OnDrop(dragndrop.IsDragging())
	end

	if surface.MouseInRect(x, y, w, h) and self.item_data and self.mouse_pressed and self.mouse_pressed > (CurTime() - 0.15) then
		ix.Item:OpenItemMenu(self.instance_ids, self.inventory_id)
	end

	if self:EndBoxSelection() then return end

	self:MouseCapture(false)

	if self:DragMouseRelease(mcode) then
		return
	end
end

function PANEL:OnDrop(bDragging)
	self.scroll:OnDrop()
end

function PANEL:DragMouseRelease(mcode)
	if IsValid(dragndrop.m_DropMenu) then return end

	if dragndrop.IsDragging() and dragndrop.m_MouseCode != mcode then
		return self:DragClick(mcode)
	end

	if !dragndrop.IsDragging() then
		dragndrop.Clear()
		return false
	end

	self.procceed = nil

	dragndrop.Drop()
	
	if (!self.procceed) then
		ix.Inventory:Get(self:GetInventoryID()).panel:Rebuild()
	end

	self:MouseCapture(false)
	return true
end

function PANEL:SetItem(instance_id)
	if istable(instance_id) then
		if #instance_id > 1 then
			self:SetItemMulti(instance_id)

			return
		else
			return self:SetItem(instance_id[1])
		end
	end

	if isnumber(instance_id) then
		self.item_data = ix.Item.instances[instance_id]

		if self.item_data then
			self.item_count = 1
			self.instance_ids = { instance_id }
			self.rotated = self.item_data.rotated
		end

		self:Rebuild()
	end
end

function PANEL:SetItemMulti(ids)
	local item_data = ix.Item.instances[ids[1]]

	if item_data and !item_data.stackable then return end

	self.item_data = item_data
	self.item_count = #ids
	self.instance_ids = ids
	self.rotated = item_data.rotated
	self:Rebuild()
end

function PANEL:Combine(panel2)
	for i = 1, #panel2.instance_ids do
		if #self.instance_ids < self.item_data.max_stack then
			table.insert(self.instance_ids, panel2.instance_ids[1])
			table.remove(panel2.instance_ids, 1)
		end
	end

	self.item_count = #self.instance_ids
	self:Rebuild()

	panel2.item_count = #panel2.instance_ids

	if panel2.item_count > 0 then
		panel2:Rebuild()
	else
		panel2:Reset()
	end
end

function PANEL:Reset()
	self.instance_ids = {}
	self.item_data = nil
	self.item_count = 0
	self.rotated = false

	self:Rebuild()
	self:Undraggable()
end

function PANEL:Undraggable()
	self.m_DragSlot = nil
end

local function SetModel(self, strModelName, skin, mat)
	if IsValid(self.Entity) then
		self.Entity:Remove()
		self.Entity = nil
	end

	if !ClientsideModel then return end

	self.Entity = ClientsideModel(strModelName, RENDERGROUP_OTHER)
	if !IsValid(self.Entity) then return end

	self.Entity:SetNoDraw(true)
	self.Entity:SetIK(false)

	if skin then
		self.Entity:SetSkin(skin)
	end

	if mat then
		self.Entity:SetMaterial(mat)
	end
end

function PANEL:Rebuild()
	if !self.item_data then
		self:Undraggable()

		return
	else
		self:Droppable('ix.item')
	end

	if self.item_data then
		self:SetHelixTooltip(function(tooltip)
			ix.hud.PopulateItemTooltip(tooltip, self.item_data, self)
		end)
	end
	
	local icon

	if icon then

	else
		if IsValid(self.mdl) then
			self.mdl:Remove()
		end

		local model = self.item_data:GetIconModel() or self.item_data:GetModel()

		self.mdl = vgui.Create('DModelPanel', self)
		if self.item_data.isCustomBase and !ix.CustomItem.stored[self.item_data:GetData("checksum")] then
			self.mdl.reload = true
		end
		self.mdl.SetModel = SetModel
		self.mdl:Dock(FILL)
		self.mdl:DockMargin(1, 1, 1, 1)
		self.mdl:SetModel(model, self.item_data:GetSkin(), self.item_data:GetMaterial())
		self.mdl:SetMouseInputEnabled(false)
		self.mdl:SetAnimated(true)
		self.mdl:SetAmbientLight(Color(32, 64, 128))
		self.mdl:SetDirectionalLight(BOX_TOP, color_white)
		self.mdl:SetDirectionalLight(BOX_LEFT, color_white)
		self.mdl.LayoutEntity = function(pnl, ent) 
			if self.item_data and self.item_data.LayoutIcon then
				self.item_data:LayoutIcon(pnl, ent)
			end

			if self.item_data and self.item_data.isCustomBase and pnl.reload then
				local info = ix.CustomItem.stored[self.item_data:GetData("checksum")]

				if info then
					local model = self.item_data:GetIconModel() or self.item_data:GetModel()
					pnl:SetModel(model, self.item_data:GetSkin())
					pnl:SetupCamera()

					pnl.reload = nil
				end
			end
		end
		self.mdl.PreDrawModel = function(pnl, ent)
			render.SetColorModulation(2, 2, 2)
			render.SetBlend(surface.GetAlphaMultiplier())
		end
		self.mdl:SetPaintedManually(true)
		self.mdl.SetupCamera = function(_)
			local entity = _:GetEntity()
			local cam_data = table.Copy(self.item_data.GetIconData and self.item_data:GetIconData() or self.item_data.iconCam)

			entity:SetSequence(ACT_IDLE)

			if !cam_data then
				local data = PositionSpawnIcon(entity, entity:GetPos(), true)

				cam_data = {
					fov = data.fov * 0.75,
					pos = data.origin,
					ang = data.angles
				}
			end

			local pos, ang, fov = cam_data.pos, cam_data.ang, cam_data.fov
			local rotated = self:IsRotated()
			local w, h = self:GetItemSize()

			_:SetCamPos(pos)
			_:SetFOV(rotated and fov * (w / h) or fov)
			_:SetLookAng(rotated and Angle(ang.p, ang.y, ang.r - 90) or ang)
		end

		self.mdl:SetupCamera()
	end
end

function PANEL:GetItemSize()
	if self.item_data then
		if !self:IsRotated() then
			return self.item_data.width, self.item_data.height
		else
			return self.item_data.height, self.item_data.width
		end
	end

	return 1, 1
end

function PANEL:GetItemPos()
	return self.slot_x, self.slot_y
end

function PANEL:GetInventoryID()
	return self.inventory_id
end

function PANEL:IsMultiSlot()
	return self.multislot
end

function PANEL:Turn()
	local w, h = self:GetSize()
	self:SetWidth(h)
	self:SetHeight(w)
	self.rotated = !self.rotated
	self:Rebuild()
end

function PANEL:IsRotated()
	return self.rotated
end

function PANEL:WasRotated()
	return self.rotated != self.item_data.rotated
end

vgui.Register('ui.inv.item', PANEL, 'DPanel')
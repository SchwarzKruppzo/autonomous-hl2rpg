local PANEL = {}
PANEL.item_data = nil

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

function PANEL:Paint(w, h)
	surface.SetDrawColor(0, 34, 57, 255 * 0.75)
	surface.DrawRect(0, 0, w, h)
	
	if self.item_data then
		surface.SetDrawColor(RARITY_CLR[self.item_data:GetRarity() or 0])
		surface.DrawRect(1, 1, w, h)

		surface.SetDrawColor(RARITY_CLR2[self.item_data:GetRarity() or 0])
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

		if IsValid(self.mdl) then
			self.mdl:PaintManual()
		end
	end
end

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

function PANEL:IsRotated()
	return self.rotated
end

function PANEL:Rebuild(itemID, slotSize, customModel)
	self.item_data = ix.Item.stored[itemID]

	
	if !self:IsRotated() then
		self:SetSize((slotSize + 1) * self.item_data.width - 1, (slotSize + 1) * self.item_data.height - 1)
	else
		self:SetSize((slotSize + 1) * self.item_data.height - 1, (slotSize + 1) * self.item_data.width - 1)
	end
	
	self:SetHelixTooltip(function(tooltip)
		ix.hud.PopulateItemTooltip(tooltip, self.item_data, self)
	end)
	
	if IsValid(self.mdl) then
		self.mdl:Remove()
	end

	local model = customModel or self.item_data:GetIconModel() or self.item_data:GetModel()

	self.mdl = vgui.Create('DModelPanel', self)
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

		if customModel then
			cam_data = nil
		end
		
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
		local w, h = self:GetSize()

		_:SetCamPos(pos)
		_:SetFOV(rotated and fov * (w / h) or fov)
		_:SetLookAng(rotated and Angle(ang.p, ang.y, ang.r - 90) or ang)
	end

	self.mdl:SetupCamera()
end

vgui.Register("craft.preview", PANEL, "DPanel")
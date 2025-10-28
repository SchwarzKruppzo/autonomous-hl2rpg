surface.CreateFont("health.part.label", {
	font = "Blender Pro Medium",
	extended = true,
	size = ix.UI.Scale(14),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("health.diff.label", {
	font = "Blender Pro Medium",
	extended = true,
	size = ix.UI.Scale(16),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

local PANEL = {}
local function DrawCorners(self, w, h)
	local x, y = 0, 0
	surface.SetDrawColor(8, 32, 48, 128)
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

local function DrawCorners_Overlay(self, w, h, clr)
	render.OverrideBlend(true, 4, 1, BLENDFUNC_ADD, 4, 1, BLENDFUNC_ADD)
		if clr then
			surface.SetDrawColor(clr.r * 0.3, clr.g * 0.3, clr.b * 0.3, 128)
		else
			surface.SetDrawColor(0, 64, 100, 255 * 0.5)
		end
		surface.DrawRect(0, 0, w, h)
	render.OverrideBlend(false)
end

function PANEL:AddStatus(category, info)
	category.hediffs = category.hediffs or {}
	category.stacked_hediffs = category.stacked_hediffs or {}
	self.invisible = self.invisible or {}

	local visible = info:IsVisible()
	local isStack = info:CanMerge()
	local stack_panel = category.stacked_hediffs[info.uniqueID]

	if isStack and IsValid(stack_panel) then
		stack_panel.name = stack_panel.name or stack_panel:GetText()
		stack_panel.count = (stack_panel.count or 1) + 1
		
		stack_panel:SetText(string.format("%s x%s", stack_panel.name, stack_panel.count))

		return
	end

	local minSize = ix.UI.Scale(24)
	local part_label = category.hediff_container:Add("DLabel")
	if visible then
		part_label:Dock(TOP)
	else
		part_label:SetVisible(false)

		self.invisible[#self.invisible + 1] = part_label
	end

	local name = info.name

	if (info.tended_time and info.tended_time != -1) and !info.isMedical then
		name = name .. " " .. (info.tended_prefix or "(перебинтовано)")
	end

	part_label:DockMargin(0, 0, 0, 1)
	part_label:SetText(name)
	part_label.status = true
	part_label.info = info

	if info.Tooltip then
		part_label:SetHelixTooltip(function(tooltip)
			info:Tooltip(tooltip)
		end)
	end
	
	local color = info.color or color_white

	if info.GetColor then
		color = info:GetColor()
	end
	
	part_label:SetFont("health.diff.label")
	part_label:SizeToContents()
	part_label:SetTall(minSize)
	part_label:SetTextColor(color)
	part_label:SetTextInset(minSize * 0.2, 0)
	part_label.Paint = function(self, w, h)
		if info.Stage then
			self:SetText(info:Stage())
		end

		render.OverrideBlend(true, 4, 1, BLENDFUNC_ADD, 4, 1, BLENDFUNC_ADD)
			if color then
				surface.SetDrawColor(ColorAlpha(color, 255 * 0.1))
			else
				surface.SetDrawColor(255, 255, 255, 255 * 0.1)
			end

			surface.DrawOutlinedRect(0, 0, w, h)
			surface.DrawRect(0, 0, w, h)
		render.OverrideBlend(false)

		if ix.gui.hover_hediff and ix.gui.hover_hediff == self then
			render.OverrideBlend(true, 4, 1, BLENDFUNC_ADD, 4, 1, BLENDFUNC_ADD)
				surface.SetDrawColor(64, 255, 64, 255 * 0.25)
				surface.DrawRect(0, 0, w, h)
			render.OverrideBlend(false)
		end
	end
	
	category.hediff_container:InvalidateLayout(true)
	category.hediff_container:SizeToChildren(false, true)

	category:SizeToContents()

	if isStack then
		category.stacked_hediffs[info.uniqueID] = part_label
	else
		category.hediffs[info.id] = part_label
	end
end

function PANEL:CacheHealth()
	for k, v in pairs(self.categories) do
		v:UpdateColor()
	end
end

function PANEL:CreatePartCategory(num, part)
	self.categories = self.categories or {}

	local minSize = ix.UI.Scale(24)
	local panel = self.container:Add("Panel")
	panel:Dock(TOP)
	panel:DockMargin(0, num == 2 and 16 or 1, 0, 0)
	panel.Paint = function(self, w, h)
		DrawCorners_Overlay(self, w, h, self.clr)

		surface.SetDrawColor(self.clr.r, self.clr.g, self.clr.b, 255 * 0.1)
		surface.DrawOutlinedRect(0, 0, w, h)
	end
	panel.SizeToContents = function(self)
		self:SetTall(math.max(self.hediff_container:GetTall(), minSize))
	end

	local part_container = panel:Add("Panel")
	part_container:Dock(RIGHT)
	part_container:DockPadding(0, 0, 0, 0)
	part_container:SetWide(self.container:GetWide() * 0.6)
	part_container:SetTall(0)
	part_container.statux = true

	local part_label = panel:Add("DLabel")
	part_label:DockMargin(5, 3, 0, 0)
	part_label:Dock(LEFT)
	part_label:SetText(part.name:utf8upper())
	part_label:SetFont("health.part.label")
	part_label:SizeToContents()
	part_label:SetTall(minSize)
	part_label:SetContentAlignment(7)
	part_label:SetTextColor(Color(0, 200, 255, 255))
	part_label:SetHelixTooltip(function(tooltip)
		local hp = tooltip:AddRow("hp")
		hp:SetText(string.format("%s — %s/%s HP", part.name, self.health:GetPartHealth(num), part.health))
		hp:SetBackgroundColor(panel.clr)
		hp:SizeToContents()
	end)

	panel.UpdateColor = function(_)
		_.value = math.max(self.health:GetPartHealth(num) / part.health, 0)


		_.clr = HSVToColor(120 * _.value, 1, 1)
		part_label:SetTextColor(_.clr)
	end
	panel:UpdateColor()

	panel.hediff_container = part_container

	part_container:InvalidateLayout(true)
	part_container:SizeToChildren(false, true)
	panel:SizeToChildren(true, true)

	self.categories[num] = panel

	return panel
end

function PANEL:Think()
	if self.invisible and #self.invisible > 0 then
		if !self.nextVisibilityCheck or CurTime() >= self.nextVisibilityCheck then
			self.nextVisibilityCheck = CurTime() + 1

			for k, v in ipairs(self.invisible) do
				if v.info then
					if v.info:IsVisible() then
						table.remove(self.invisible, k)

						v:Dock(TOP)
						v:SetVisible(true)

						local diff_container = v:GetParent()
						local container = diff_container:GetParent()

						diff_container:InvalidateLayout(true)
						diff_container:SizeToChildren(false, true)

						container:SizeToContents()
					end
				end
			end
		end
	end
	
	if self.dirty then
		self.dirty = nil

		self:Validate()
	end
end

function PANEL:Test()
	self.categories[1].hediffs[8]:SetVisible(false)
end

function PANEL:Validate()
	for k, panel in pairs(self.categories) do
		local reAlign = false

		for _, label in pairs(panel.hediffs or {}) do
			if !label.info or !self.health.hediffs[label.info.id] then
				panel.hediffs[_] = nil
				label:Remove()
				reAlign = true
			end
		end

		if reAlign then
			panel.hediff_container:InvalidateLayout(true)
			panel.hediff_container:SizeToChildren(false, true)

			panel:SizeToContents()
		end
	end
end

function PANEL:Rebuild(character)
	character = character or LocalPlayer():GetCharacter()

	self.health = character:Health()
	self.health.panel = self

	self.container:Clear()
	self.container:InvalidateParent(true)
	
	for k, v in self.health:GetParts() do
		self:CreatePartCategory(k, v)
	end

	for k, v in pairs(self.health.hediffs) do
		self:AddStatus(self.categories[v.part], v)
	end
end

function PANEL:Init()
	if ix.gui.health then
		ix.gui.health:Remove()
		ix.gui.health = nil
	end
	
	ix.gui.health = self

	local margin = ix.UI.Scale(10)

	self.container = self:Add("DScrollPanel")
	self.container:Dock(FILL)
	self.container:DockMargin(margin, margin, margin, margin)
	
	self.container:Receiver("ix.item", function(receiver, dropped, is_dropped, menu_index, mouse_x, mouse_y)
		local slot = dropped[1]

		local target

		if IsValid(ix.inventory_drop_slot) then
			ix.inventory_drop_slot.is_hovered = nil
			ix.inventory_drop_slot = nil
		end

		if is_dropped then
			local hediff = ix.gui.hover_hediff

			if IsValid(hediff) then
				local itemID = slot.instance_ids[1]
				local item = ix.Item.instances[itemID]

				if item then
					net.Start('hediff.use')
						net.WriteUInt(item.inventory_id, 32)
						net.WriteUInt(item.x, 8)
						net.WriteUInt(item.y, 8)
						net.WriteUInt(hediff.info.character, 32)
						net.WriteUInt(hediff.info.id, 16)
					net.SendToServer()
				end
			end
			
			slot.scroll:Rebuild()
			ix.gui.hover_hediff = nil
		else
			target = vgui.GetHoveredPanel()

			if target.statux then
				local mouse_x, mouse_y = target:LocalCursorPos()

				target = target:GetClosestChild(mouse_x, mouse_y)

				ix.gui.hover_hediff = target
			elseif target.status then
				ix.gui.hover_hediff = target
			end
		end
	end)
end

function PANEL:Paint(w, h)
	DrawCorners(self, w, h)
end

vgui.Register("ui.health", PANEL, "EditablePanel")

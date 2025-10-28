local Scale = ix.UI.Scale

function ix.GetViewTrace()
	local eyepos, eyevec = EyePos(), gui.ScreenToVector(gui.MousePos())
	local ply = LocalPlayer()
	local filter = ply:GetViewEntity()

	if filter == ply then
		local veh = ply:GetVehicle()

		if veh:IsValid() and (!veh:IsVehicle() or !veh:GetThirdPersonMode()) then
			filter = {filter, veh, unpack(ents.FindByClass( "phys_bone_follower"))}
		end
	end

	local trace = util.TraceLine({
		start = eyepos,
		endpos = eyepos + eyevec * 4096,
		filter = filter
	})

	if !trace.Hit or !IsValid(trace.Entity) then
		trace = util.TraceLine({
			start = eyepos,
			endpos = eyepos + eyevec * 4096,
			filter = filter,
			mask = MASK_ALL
		})
	end

	return trace
end


do
	surface.CreateFont('tabmenu.btn', {
		font = 'Blender Pro Medium',
		extended = true,
		size = Scale(21),
		weight = 500,
		antialias = true,
	})

	surface.CreateFont('tabmenu.btn.small', {
		font = 'Blender Pro Book',
		extended = true,
		size = Scale(18),
		weight = 500,
		antialias = true,
	})
end

local styles = {
	[1] = {
		outline = Color(0, 190, 255, 48),
		outline2 = Color(0, 190, 255, 16),
		corners = Color(0, 225, 255, 255),
		text = Color(0, 225, 255, 255),
		hover = Color(32, 160, 190),
	},
	[2] = {
		outline = Color(255, 0, 0, 48),
		outline2 = Color(255, 0, 0, 16),
		corners = Color(255, 0, 0, 255),
		text = Color(255, 64, 64, 255),
		hover = Color(190, 32, 32),
	},
	[3] = {
		outline = Color(255, 200, 0, 48),
		outline2 = Color(255, 200, 0, 16),
		corners = Color(255, 200, 0, 255),
		text = Color(255, 225, 0, 255),
		hover = Color(190, 160, 32),
	},
	[4] = {
		outline = Color(64, 255, 100, 96),
		outline2 = Color(64, 255, 64, 16),
		corners = Color(72, 255, 72),
		text = Color(64, 225, 96, 255),
		hover = Color(32, 190, 72, 32),
	},
	[5] = {
		bg = Color(128, 128, 128, 32),
		outline = Color(150, 150, 150, 32),
		outline2 = Color(150, 150, 150, 8),
		corners = Color(225, 225, 225, 200),
		text = Color(225, 225, 225, 64),
		hover = Color(32, 190, 72, 0),
	},
}

local PANEL = {}
DEFINE_BASECLASS('DButton')

function PANEL:DrawCorners(x, y, w, h, size)
	if self.style.bg then
		surface.SetDrawColor(self.style.bg)
		surface.DrawRect(x, y, w, h)
	end

	surface.SetDrawColor(self.style.outline)
	surface.DrawOutlinedRect(x, y, w, h)

	local offset = 2
	surface.SetDrawColor(self.style.outline2)
	surface.DrawOutlinedRect(x + offset, y + offset, w - offset * 2, h - offset * 2)

	surface.SetDrawColor(self.style.corners)

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
end

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	self:SetText("TEST")
	self:SetFont("tabmenu.btn")
	self:SetCursor("hand")
	self:SetStyle(1)

	self.entered = false
	self.state = false

	self.padding = Scale(16) * 2
	self.corner_size = 8
end

function PANEL:SetStyle(id)
	if !styles[id] then return end
	
	self.style = styles[id]

	self:SetTextColor(self.style.text)
end

function PANEL:SetStyleSmall()
	self:SetFont("tabmenu.btn.small")

	self.padding = Scale(10) * 2
	self.corner_size = 2
end

function PANEL:OnCursorEntered()
	if self:GetDisabled() then return end

	self.entered = true
end

function PANEL:OnCursorExited()
	if self:GetDisabled() then return end

	self.entered = false
end

function PANEL:DoClick()
	if self:GetDisabled() then return end

	self.state = !self.state

	self:OnToggle(self.state)
end

function PANEL:OnMousePressed(code)
	if self:GetDisabled() then
		return
	end

	LocalPlayer():EmitSound("Helix.Press")

	if code == MOUSE_LEFT then
		self:DoClick(self)
	end
end

function PANEL:SizeToContents()
	surface.SetFont(self:GetFont())
	local w, h = surface.GetTextSize(self:GetText())

	self:SetWidth(w + self.padding)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(0, 0, 0, 128)
	surface.DrawRect(0, 0, w, h)

	self:DrawCorners(0,0, w, h, self.corner_size)
	
	local ft = FrameTime()

	self.hoverAlpha = math.Approach((self.hoverAlpha or 0), self.entered and 1 or 0, ft * 5)
	local hoverAlpha = math.ease.OutCubic(self.hoverAlpha)

	render.OverrideBlend(true, 4, 1, BLENDFUNC_ADD, 4, 1, BLENDFUNC_ADD)
		self.stateAlpha = math.Approach((self.stateAlpha or 0), self.state and 1 or 0, ft * 5)

		if (self.stateAlpha or 0) > 0 then
			local a = math.ease.OutCubic(self.stateAlpha)
			local offsetAlpha = (1 + (0.5 * hoverAlpha))

			local sizeW, sizeH = w * 2, h * 2
			surface.SetDrawColor(self.style.hover.r, self.style.hover.g, self.style.hover.b, 128 * a * offsetAlpha)
			surface.DrawRect(0, 0, w, h)
		end

		surface.SetDrawColor(self.style.hover.r, self.style.hover.g, self.style.hover.b, 128 * hoverAlpha)
		surface.DrawRect(0, 0, w, h)
	render.OverrideBlend(false)
end

vgui.Register('ui.tabmenu.btn', PANEL, 'DButton')


local Scale = ix.UI.Scale
local function DrawCorners(x, y, w, h, z)
	surface.SetDrawColor(8, 32, 48, 128)
	surface.DrawRect(x, y, w, h)

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

	if !z then
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
end













surface.CreateFont("ui.tab.stat.title", {
	font = "Blender Pro Medium",
	extended = true,
	size = ix.UI.Scale(16),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})
surface.CreateFont("ui.tab.stat.value", {
	font = "Blender Pro Bold",
	extended = true,
	size = ix.UI.Scale(14),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("ui.tab.smalltitle", {
	font = "Blender Pro Medium",
	extended = true,
	size = ix.UI.Scale(18),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("ui.tab.smalltitle2", {
	font = "Blender Pro Medium",
	extended = true,
	size = ix.UI.Scale(16),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("ui.skillpoints.title", {
	font = "Blender Pro Bold",
	extended = true,
	size = ix.UI.Scale(14),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})
surface.CreateFont("ui.profile.value", {
	font = "Blender Pro Book",
	extended = true,
	size = ix.UI.Scale(14),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})
surface.CreateFont("ui.skillpoints.value", {
	font = "Blender Pro Medium",
	extended = true,
	size = ix.UI.Scale(22),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("ui.specialpoints.title", {
	font = "Blender Pro Bold",
	extended = true,
	size = ix.UI.Scale(16),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

local PANEL = {}
AccessorFunc(PANEL, "title", "Title", FORCE_STRING)
AccessorFunc(PANEL, "value", "Value", FORCE_STRING)
AccessorFunc(PANEL, "delta", "Delta", FORCE_NUMBER)
AccessorFunc(PANEL, "bar_size", "BarSize", FORCE_NUMBER)

local lerp_speed = 0.025
function PANEL:Init()
	self.color = Color(0, 225, 255)
	self.bar_colors = {
		bar = ColorAlpha(self.color, 200),
		outline2 = ColorAlpha(self.color, 48),
		outline = ColorAlpha(self.color, 128)
	}
	self.color = Color(0, 225, 255, 200)

	self.bar_size = math.max(Scale(5), 5)

	self.old_delta = 0
end

function PANEL:UpdateColors(delta)
	if !self.hsv then return end
	
	local clr = HSVToColor(120 * delta, 1, 1)

	self.color = ColorAlpha(clr, 200)
	self.bar_colors.bar = ColorAlpha(clr, 200)
	self.bar_colors.outline2 = ColorAlpha(clr, 48)
	self.bar_colors.outline = ColorAlpha(clr, 128)
end

function PANEL:DrawBar(x, y, w, h, delta, clr)
	surface.SetDrawColor(self.bar_colors.bar)
	surface.DrawRect(x + 2, y + 2, (w - 4) * delta, h -4 )

	surface.SetDrawColor(self.bar_colors.outline)
	surface.DrawOutlinedRect(x, y, w, h)

	if self.bar_size > 5 then
		surface.SetDrawColor(self.bar_colors.outline2)
		local offset = 2
		surface.DrawOutlinedRect(x + offset, y + offset, w - offset * 2, h - offset * 2)
	end
end

function PANEL:Think()
	if !self.nextUpdate or CurTime() >= self.nextUpdate then
		local value, delta = self:OnUpdate()
		self:SetValue(value)
		self:SetDelta(delta)
		self.nextUpdate = CurTime() + 1
	end

	local delta = self:GetDelta()
	if self.old_delta != delta then
		self:UpdateColors(delta)
		self.old_delta = math.Approach(self.old_delta, delta, math.abs(delta - self.old_delta) * lerp_speed)
	end
end

function PANEL:SizeToContents()
	local value, delta = self:OnUpdate()
	self:UpdateColors(delta)

	surface.SetFont("ui.tab.stat.title")
	local w, h = surface.GetTextSize(self:GetTitle())

	self:SetTall(h + self.bar_size)
end

function PANEL:Paint(w, h)
	local title = self:GetTitle()
	local value = self:GetValue()

	draw.SimpleText(title, "ui.tab.stat.title", 0, h - self.bar_size, self.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(value, "ui.tab.stat.value", w, h - self.bar_size, self.color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

	self:DrawBar(0, h - self.bar_size, w, self.bar_size, self.old_delta, self.color)
end

vgui.Register("ui.tab.statbar", PANEL, "Panel")




local PANEL = {}
function PANEL:Init()
	self.left = self:Add("DLabel")
	self.left:SetText("")
	self.left:SetContentAlignment(4)
	self.left:Dock(LEFT)

	self.right = self:Add("DLabel")
	self.right:SetText("")
	self.right:SetContentAlignment(6)
	self.right:Dock(RIGHT)
end

function PANEL:SetFont(var1, var2)
	self.left:SetFont(var1)
	self.right:SetFont(var2)
end

function PANEL:SetTextColor(var1, var2)
	self.left:SetTextColor(var1)
	self.right:SetTextColor(var2)
end

function PANEL:SetText(var1, var2)
	self.left:SetText(var1)
	self.right:SetText(var2)
end

function PANEL:SizeToContents()
	self.left:SizeToContents()
	self.right:SizeToContents()
end

vgui.Register("ui.tab.statlabel", PANEL, "Panel")


local PANEL = {}
function PANEL:Init()
	self:InvalidateParent(true)

	self.buttons = {}
	self.tab = {}


	self.button_size = Scale(32)
	self.btn_container = self:Add("Panel")
	self.btn_container:Dock(TOP)
	self.btn_container:DockMargin(0, 0, 0, 2)
	self.btn_container:SetTall(self.button_size)
	self.btn_container:InvalidateParent(true)

	local health = self:AddButton("hp", 'СОСТОЯНИЕ ЗДОРОВЬЯ')
	local info = self:AddButton("info", 'РОЛЕВАЯ ИНФОРМАЦИЯ')
	local skills = self:AddButton("skills", 'ХАРАКТЕРИСТИКИ')
	local perks = self:AddButton("perks", 'ПЕРКИ')

	--health:SetDisabled(true)
	--health:SetStyle(5)

	perks:SetDisabled(true)
	perks:SetStyle(5)


	self.tab_container = self:Add("Panel")
	self.tab_container:Dock(FILL)
	self.tab_container:DockMargin(0, 0, 0, 0)
	//self.tab_container:SetTall(self.button_size)
	self.tab_container:InvalidateParent(true)


	self:AddTab(health, function(self, container)
		local hp_container = container:Add("ui.health")
		hp_container:Dock(RIGHT)
		hp_container:SetWide(container:GetWide() * 0.6)
		hp_container:InvalidateParent(true)
		hp_container:Rebuild(LocalPlayer():GetCharacter())

		local left_container = container:Add("Panel")
		left_container:Dock(FILL)
		left_container:DockMargin(0, 0, 2, 0)
		left_container:InvalidateParent(true)
		left_container.Paint = function(_, w, h)
			DrawCorners(0, 0, w, h)
		end

		local limb_size = Scale(180)
		local limb = left_container:Add("Panel")
		limb:Dock(TOP)
		limb:SetTall(limb_size * 2 + 10)
		limb:InvalidateParent(true)

		local limbs = limb:Add("ixLimbStatus")
		limbs:SetSize(limb_size, limb_size * 2)
		limbs:Center()

		local consc = left_container:Add("ui.tab.statbar")
		consc:SetTitle("СОЗНАНИЕ:")
		consc:Dock(TOP)
		consc:DockMargin(16, 5, 16, 0)
		consc.OnUpdate = function()
			local hp = LocalPlayer():GetCharacter():Health()
			local value = hp:GetConsciousness()
			
			return string.format("%s%%", math.Round(100 * value)), value
		end
		consc:SizeToContents()

		local pain = left_container:Add("ui.tab.statbar")
		pain:SetTitle("БОЛЬ:")
		pain:Dock(TOP)
		pain:DockMargin(16, 5, 16, 9)
		pain.OnUpdate = function()
			local hp = LocalPlayer():GetCharacter():Health()
			local pain = hp:GetPain()
			return string.format("%s%%", math.Round(100 * pain)), pain
		end
		pain:SizeToContents()
		
		local big_size = Scale(10)
		local food = left_container:Add("ui.tab.statbar")
		food:SetTitle("ГОЛОД:")
		food:Dock(BOTTOM)
		food:DockMargin(16, 0, 16, 16)
		food.hsv = true
		food.OnUpdate = function()
			local hunger = LocalPlayer():GetCharacter():GetHunger()
			local value = hunger / 100

			if value > 0 then
				return tostring(math.Round(100 * value)).."%", value
			end

			return "100%", 1
		end
		food:SetBarSize(big_size)
		food:SizeToContents()

		local water = left_container:Add("ui.tab.statbar")
		water:SetTitle("ЖАЖДА:")
		water:Dock(BOTTOM)
		water:DockMargin(16, 0, 16, 5)
		water.hsv = true
		water.OnUpdate = function()
			local hunger = LocalPlayer():GetCharacter():GetThirst()
			local value = hunger / 100

			if value > 0 then
				return tostring(math.Round(100 * value)).."%", value
			end

			return "100%", 1
		end
		water:SetBarSize(big_size)
		water:SizeToContents()

		local hp = left_container:Add("ui.tab.statbar")
		hp:SetTitle("ЗДОРОВЬЕ:")
		hp:Dock(BOTTOM)
		hp:DockMargin(16, 0, 16, 5)
		hp.hsv = true
		hp.OnUpdate = function()
			local hp = LocalPlayer():GetCharacter():Health()
			local value = hp:GetPercent()

			if value > 0 then
				return tostring(math.Round(100 * value)).."%", value
			end

			return "100%", 1
		end
		hp:SetBarSize(big_size)
		hp:SizeToContents()
	end)

	self:AddTab(info, function(self, container)
		local character = LocalPlayer():GetCharacter()

		local right_container = container:Add("Panel")
		right_container:Dock(RIGHT)
		right_container:SetWide(container:GetWide() * 0.6)
		right_container:InvalidateParent(true)
		right_container.Paint = function(_, w, h)
			DrawCorners(0, 0, w, h)
		end

		local label = right_container:Add("DLabel")
		label:SetTextColor(Color(0, 225, 255))
		label:SetText("ПРОФИЛЬ ПЕРСОНАЖА")
		label:SetFont("ui.tab.smalltitle")
		label:DockMargin(8, 8, 0, 5)
		label:SizeToContents()
		label:SetContentAlignment(4)
		label:Dock(TOP)

		local left_container = container:Add("Panel")
		left_container:Dock(FILL)
		left_container:DockMargin(0, 0, 2, 0)
		left_container:InvalidateParent(true)
		left_container.Paint = function(_, w, h)
			DrawCorners(0, 0, w, h)
		end

		local label = left_container:Add("DLabel")
		label:SetTextColor(Color(0, 225, 255))
		label:SetText("ОСНОВНОЕ")
		label:SetFont("ui.tab.smalltitle")
		label:DockMargin(8, 8, 0, 5)
		label:SizeToContents()
		label:SetContentAlignment(4)
		label:Dock(TOP)

		local function AddLabel(text1, text2)
			local label = left_container:Add("DLabel")
			label:SetTextColor(Color(0, 225, 255, 255))
			label:SetText(text1)
			label:SetFont("ui.tab.smalltitle2")
			label:DockMargin(16, 16, 0, 0)
			label:SizeToContents()
			label:SetContentAlignment(4)
			label:Dock(TOP)

			local value = left_container:Add("DLabel")
			value:SetTextColor(color_white)
			value:SetText(text2)
			value:SetFont("ui.specialpoints.title")
			value:DockMargin(32, 5, 0, 0)
			value:SizeToContents()
			value:SetContentAlignment(4)
			value:Dock(TOP)
		end
		
		AddLabel("ИМЯ", character:GetName())

		local genders = ix.plugin.list["!character"]
		AddLabel("ПОЛ", L(genders.Genders[character:GetGender()] or "unknown"))

		local faction = ix.faction.indices[character:GetFaction()]
		AddLabel("ПРИНАДЛЕЖНОСТЬ", L(faction.name))

		local card = LocalPlayer():GetIDCard()
		AddLabel("ГРАЖДАНСКИЙ НОМЕР", string.format("%s", card and card:GetData("cid") or "Н/Д"))
		
		

		local label = right_container:Add("DLabel")
		label:SetTextColor(Color(255, 72, 72))
		label:SetText("Панель находится на стадии разработки.")
		label:SetFont("ui.specialpoints.title")
		label:DockMargin(16, 16, 16, 16)
		label:SizeToContents()
		label:SetContentAlignment(5)
		label:Dock(TOP)

		local function AddTextBox(value, minHeight, onClick)
			local textbox = right_container:Add("DLabel")
			textbox:Dock(TOP)
			textbox:DockMargin(16, 5, 16, 0)
			textbox:SetFont("ui.profile.value")
			textbox:SetTextColor(color_white)
			textbox:SetContentAlignment(7)
			textbox:SetMouseInputEnabled(true)
			textbox:SetCursor("hand")
			textbox.Paint = function(this, width, height)
				surface.SetDrawColor(8, 225, 255, 16)
				surface.DrawRect(0, 0, width, height)

				DrawCorners(0, 0, width, height, true)
			end
			textbox.OnMousePressed = function(this, code)
				if (code == MOUSE_LEFT) then
					onClick()
				end
			end
			local wide = right_container:GetWide() - 32
			textbox.SizeToContents = function(this)
				if (this.bWrap) then
					-- sizing contents after initial wrapping does weird things so we'll just ignore (lol)
					return
				end

				local width, height = this:GetContentSize()
				if (width > wide) then
					this:SetWide(wide)
					this:SetTextInset(8, 8)
					this:SetWrap(true)
					this:SizeToContentsY()
					this:SetTall(this:GetTall() + 16) -- eh

					-- wrapping doesn't like middle alignment so we'll do top-center
					this:SetContentAlignment(7)
					this.bWrap = true
				else
					this:SetTextInset(8, 8)
					this:SetSize(width + 16, math.max(height + 16, minHeight + 16))
				end
			end

			textbox:SetText(value)
			textbox:SizeToContents()
		end

		local label = right_container:Add("DLabel")
		label:SetTextColor(Color(0, 225, 255, 255))
		label:SetText("ФИЗИЧЕСКОЕ ОПИСАНИЕ")
		label:SetFont("ui.tab.smalltitle2")
		label:DockMargin(16, 16, 0, 0)
		label:SizeToContents()
		label:SetContentAlignment(4)
		label:Dock(TOP)

		AddTextBox(character:Genetic():GetDesc(), 0, function() 
		end)

		local label = right_container:Add("DLabel")
		label:SetTextColor(Color(0, 225, 255, 255))
		label:SetText("ВНЕШНЕЕ ОПИСАНИЕ")
		label:SetFont("ui.tab.smalltitle2")
		label:DockMargin(16, 16, 0, 0)
		label:SizeToContents()
		label:SetContentAlignment(4)
		label:Dock(TOP)

		AddTextBox(character:GetDescription(), 0, function() 
			ix.gui.menu:CloseFrame("character")
			ix.command.Send("CharDesc") 
		end)
		
		local label = right_container:Add("DLabel")
		label:SetTextColor(Color(0, 225, 255, 255))
		label:SetText("ЛИЧНЫЕ ЗАПИСИ")
		label:SetFont("ui.tab.smalltitle2")
		label:DockMargin(16, 16, 0, 0)
		label:SizeToContents()
		label:SetContentAlignment(4)
		label:Dock(TOP)
		
		local dataKey = "notes-"..string.gsub(game.GetIPAddress(), "%p", "").."-"..character:GetID()
        local notes = ix.data.Get(dataKey, "", true, true)
		AddTextBox(notes, 32, function() 
			ix.gui.menu:CloseFrame("character")
			ix.command.Send("MyNotes") 
		end)

		right_container:InvalidateParent(true)
	end)

	self:AddTab(skills, function(self, container)
		local right_container = container:Add("Panel")
		right_container:Dock(RIGHT)
		right_container:SetWide(container:GetWide() * 0.6)
		right_container:InvalidateParent(true)
		right_container.Paint = function(_, w, h)
			DrawCorners(0, 0, w, h)
		end

		local label = right_container:Add("DLabel")
		label:SetTextColor(Color(0, 225, 255))
		label:SetText("НАВЫКИ")
		label:SetFont("ui.tab.smalltitle")
		label:DockMargin(8, 8, 0, 5)
		label:SizeToContents()
		label:SetContentAlignment(4)
		label:Dock(TOP)

		local left_container = container:Add("Panel")
		left_container:Dock(FILL)
		left_container:DockMargin(0, 0, 2, 0)
		left_container:InvalidateParent(true)
		left_container.Paint = function(_, w, h)
			DrawCorners(0, 0, w, h)
		end

		local label = left_container:Add("DLabel")
		label:SetTextColor(Color(0, 225, 255))
		label:SetText("ХАРАКТЕРИСТИКИ")
		label:SetFont("ui.tab.smalltitle")
		label:DockMargin(8, 8, 0, 5)
		label:SizeToContents()
		label:SetContentAlignment(4)
		label:Dock(TOP)

		local points_panel = left_container:Add("ui.tab.statlabel")
		points_panel:DockMargin(16, 10, 16, 16)
		points_panel:Dock(TOP)
		points_panel:SetTextColor(Color(64, 255, 225, 255), color_white)
		points_panel:SetFont("ui.skillpoints.title", "ui.skillpoints.value")
		points_panel:SetText("", "")
		points_panel:SizeToContents()
		points_panel:SizeToChildren(true, true)

		local character = LocalPlayer():GetCharacter()

		for k, v in pairs(ix.specials.list) do
			local name = L(v.name)
			local desc = L(v.description)
			local attribute = left_container:Add("ui.tab.statlabel")
			attribute:DockMargin(32, 0, 32, 5)
			attribute:Dock(TOP)
			attribute:SetTextColor(color_white, Color(0, 255, 255))
			attribute:SetFont("ui.specialpoints.title", "ui.specialpoints.title")
			attribute:SetText(name:utf8upper(), character:GetSpecial(k))
			attribute:SizeToContents()
			attribute:SizeToChildren(true, true)
			attribute:SetAutonomousTooltip(function(tooltip)
				tooltip:SetTitle(name:utf8upper())
				tooltip:AddSmallText("ХАРАКТЕРИСТИКА ПЕРСОНАЖА")
				tooltip:AddDivider()

				if v.Tooltip then
					v.Tooltip(v, tooltip)
				end
				
				tooltip:Resize()
			end)
		end

		local label = right_container:Add("DLabel")
		label:SetTextColor(Color(255, 72, 72))
		label:SetText("Панель находится на стадии разработки.")
		label:SetFont("ui.specialpoints.title")
		label:DockMargin(16, 16, 16, 16)
		label:SizeToContents()
		label:SetContentAlignment(5)
		label:Dock(TOP)

		local categories = {}
		for k, v in pairs(ix.skills.list) do
			categories[k] = L(v.name)
		end

		for k, v in SortedPairs(categories) do
			local skill = ix.skills.list[k]
			local name = v
			local desc = L(skill.description)
			local value = character:GetSkill(k)

			local attribute = right_container:Add("ui.tab.statlabel")
			attribute:DockMargin(32, 0, 32, 5)
			attribute:Dock(TOP)
			attribute:SetTextColor(color_white, value > 0 and Color(0, 255, 255) or Color(128, 128, 128))
			attribute:SetFont("ui.specialpoints.title", "ui.specialpoints.title")
			attribute:SetText(name:utf8upper(), value)
			attribute:SizeToContents()
			attribute:SizeToChildren(true, true)
			attribute:SetHelixTooltip(function(tooltip)
				local title = tooltip:AddRow("name")
				title:SetImportant()
				title:SetText(name)
				title:SizeToContents()
				title:SetMaxWidth(math.max(title:GetMaxWidth(), ScrW() * 0.5))

				local skills = character:GetSkills()

				local xp = tooltip:AddRow("description")
				xp:SetText(L("levelXP", math.Round(skills[k][2]), math.Round(skill:GetRequiredXP(skills, skills[k][1]))))
				xp:SizeToContents()

				local description = tooltip:AddRow("description")
				description:SetText(desc)
				description:SizeToContents()
			end)
		end

		right_container:InvalidateParent(true)
	end)

	timer.Simple(0, function()
		if !self.active then
			health.state = true
			health:OnToggle(true)
		end
	end)
end

function PANEL:AddButton(id, text)
	local btn = self.btn_container:Add('ui.tabmenu.btn')
	btn.id = id
	btn:Dock(LEFT)
	btn:DockMargin(0, 0, 2, 0)
	btn:SetStyleSmall()
	btn:SetStyle(1)
	btn:SetText(text)
	btn:SizeToContents()
	btn:SetTall(self.button_size)
	btn.OnToggle = function(_, state)
		if !state then
			_.state = true
		end

		for k, v in pairs(self.buttons) do
			if v == _ then continue end

			v.state = false
		end

		if self.active != _.id then
			self.tab_container:Clear()

			if isfunction(self.tab[id]) then
				self.tab[id](self, self.tab_container)
			end

			self.active = _.id
		end
	end

	self.buttons[id] = btn

	return btn
end

function PANEL:AddTab(btn, callback)
	if !btn.id then 
		return
	end
	
	self.tab[btn.id] = callback
end


vgui.Register("ui.tab.character", PANEL, "EditablePanel")













local PANEL = {}
function PANEL:Init()
	self.left = self:Add("Panel")
	self.left:Dock(LEFT)
	self.left:DockMargin(0, 0, 1, 0)
	self.left.Paint = function(panel, w, h)
		DrawCorners(0, 0, w, h)
	end

	self.right = self:Add("Panel")
	self.right:Dock(FILL)
	self.right:DockMargin(1, 0, 0, 0)
	self.right.Paint = function(panel, w, h)
		DrawCorners(0, 0, w, h)
	end
end

function PANEL:Setup(right)
	local slot_size = Scale(64)
	self:Dock(FILL)
	self:InvalidateParent(true)

	self.left:SetSize(self:GetWide() * (1 - right), self:GetTall())
	self.right:InvalidateParent(true)

	local padding = Scale(10) * 2
	local label = self.right:Add('DLabel')
	label:Dock(TOP)
	label:DockMargin(8, 8, 0, 0)
	label:SetText("ИНВЕНТАРЬ")
	label:SetTextColor(Color(0, 225, 255))
	label:SetFont("ui.tab.smalltitle")

	local main = LocalPlayer():GetInventory('main')
	local panel = self.right:Add('ui.inv')
	panel:SetSlotSize(slot_size, slot_size)
	panel:SetInventoryID(main.id)
	panel.bNoBackgroundBlur = true
	panel.childPanels = {}
	panel:Rebuild()
	panel:Dock(TOP)
	panel:DockMargin(padding, 5, 0, 0)
	panel:SetTall(self.right:GetTall() / 2.45)
	main.panel = panel

	local label = self.right:Add('DLabel')
	label:Dock(TOP)
	label:DockMargin(8, 0, 0, 0)
	label:SetText("РЮКЗАК")
	label:SetTextColor(Color(0, 225, 255))
	label:SetFont("ui.tab.smalltitle")

end

function PANEL:ValidateBackpack()
	local inv = LocalPlayer():GetInventory("backpack")
	local instance_ids = inv:GetSlot(1, 1)

	if self.backpack and IsValid(self.backpack) then
		self.backpack:Remove()
	end

	if instance_ids and #instance_ids > 0 then
		local item = ix.Item.instances[instance_ids[1]]

		if item and item.inventory_data then
			local inventory
			for k, v in pairs(ix.Inventory:All()) do
				if v.instance_id == item.id then
					inventory = v
					break
				end
			end

			if inventory then
				local slot_size = Scale(64)
				local padding = Scale(10) * 2

				self.backpack = vgui.Create('ui.inv', self.right)
				self.backpack:SetSlotSize(slot_size, slot_size)
				self.backpack:SetInventoryID(inventory.id)
				self.backpack:Rebuild()
				self.backpack:SizeToContents()
				self.backpack:Dock(FILL)
				self.backpack:DockMargin(padding, 5, 0, 0)
				
				inventory.panel = self.backpack
			end
		end
	end
end

function PANEL:OpenLeftPanel(callback)
	self.left:Clear()

	local container = self.left:Add('Panel')
	container:Dock(FILL)
	container:DockMargin(5, 5, 5, 5)
	container:InvalidateParent(true)

	callback(container)
end

vgui.Register("ui.tab.equip", PANEL, "EditablePanel")


local PANEL = {}
DEFINE_BASECLASS('EditablePanel')

local vignette = Material('helix/gui/vignette.png', 'smooth')

local buttons = {
	primary = {
		[1] = {
			id = "character",
			text = "ПЕРСОНАЖ",
			width = 800,
			height = 640,
			OnShow = function(parent, x)
				x:DockPadding(2, 22 + 2, 2, 2)

				local container = x:Add("ui.tab.character")
				container:SizeToContents()
				container:Dock(FILL)
			end
		},
		[2] = {
			id = "inventory",
			text = "СНАРЯЖЕНИЕ",
			width = 1000,
			height = 700,
			OnShow = function(parent, x)
				x:DockPadding(2, 22 + 2, 2, 2)

				local container = x:Add("ui.tab.equip")
				container:Setup(0.5)
				container:SizeToContents()
				container:Dock(FILL)

				container:OpenLeftPanel(function(parent)
					local button_size = Scale(32)

					local buttons = parent:Add("Panel")
					buttons:Dock(TOP)
					buttons:DockMargin(0, 5, 0, 16)
					buttons:SetTall(button_size)
					buttons:InvalidateParent(true)

					local btn2 = buttons:Add('ui.tabmenu.btn')
					//btn:Dock(LEFT)
					//btn:DockMargin(0, 0, 5, 0)
					btn2:SetStyleSmall()
					btn2:SetText('ВЕРХНЯЯ ОДЕЖДА')
					btn2:SetStyle(4)
					btn2:SetAlpha(255)
					btn2:SizeToContents()
					btn2:SetTall(button_size)
					btn2:SetDisabled(true)
					btn2:Center()
					btn2:SetX(btn2:GetX() - btn2:GetWide() * 0.5 - 2.5)
					btn2.state = true

					local btn = buttons:Add('ui.tabmenu.btn')
					btn:SetStyleSmall()
					btn:SetStyle(5)
					btn:SetText('НИЖНЯЯ ОДЕЖДА')
					btn:SetAlpha(255)
					btn:SizeToContents()
					btn:SetTall(button_size)
					btn:MoveRightOf(btn2, 2.5)
					btn:SetDisabled(true)

					local parent = parent:Add("Panel")
					parent:Dock(FILL)
					parent:InvalidateParent(true)

					local slot_size_small = Scale(72)
					local slot_size = slot_size_small * 2

					local client = LocalPlayer()
					local torso = client:GetInventory("torso"):CreatePanel(parent)
					torso:SetSlotSize(slot_size)
					torso:Rebuild()
					torso:SizeToContents()
					torso:Center()
					torso:SetTitle("ТОРС")

					local head = client:GetInventory("head"):CreatePanel(parent)
					head:SetSlotSize(slot_size)
					head:Rebuild()
					head:SizeToContents()
					head:MoveAbove(torso, 16)
					head:CenterHorizontal()
					head:SetTitle("ГОЛОВА")

					local legs = client:GetInventory("legs"):CreatePanel(parent)
					legs:SetSlotSize(slot_size)
					legs:Rebuild()
					legs:SizeToContents()
					legs:MoveBelow(torso, 16)
					legs:CenterHorizontal()
					legs:SetTitle("НОГИ")

					local face = client:GetInventory("mask"):CreatePanel(parent)
					face:SetSlotSize(slot_size_small)
					face:Rebuild()
					face:SizeToContents()
					face:SetY(head:GetY())
					face:MoveLeftOf(head, 5)
					face:SetTitle("ЛИЦО")

					local ears = client:GetInventory("ears"):CreatePanel(parent)
					ears:SetSlotSize(slot_size_small)
					ears:Rebuild()
					ears:SizeToContents()
					ears:SetY(head:GetY())
					ears:MoveRightOf(head, 5)
					ears:SetTitle("УШИ")

					local arm = client:GetInventory("arm"):CreatePanel(parent)
					arm:SetSlotSize(slot_size_small)
					arm:Rebuild()
					arm:SizeToContents()
					arm:MoveBelow(head, 16)
					arm:MoveLeftOf(torso, 5)
					arm:SetTitle("ПЛЕЧО")
					
					local hands = client:GetInventory("hands"):CreatePanel(parent)
					hands:SetSlotSize(slot_size_small)
					hands:Rebuild()
					hands:SizeToContents()
					hands:MoveBelow(head, 16)
					hands:MoveLeftOf(arm, 5)
					hands:SetTitle("РУКИ")

					local cid = client:GetInventory("cid"):CreatePanel(parent)
					cid:SetSlotSize(slot_size_small)
					cid:Rebuild()
					cid:SizeToContents()
					cid:MoveBelow(torso, 16)
					cid:MoveRightOf(legs, 5)
					cid:SetTitle("CITIZEN ID")

					local radio = client:GetInventory("radio"):CreatePanel(parent)
					radio:SetSlotSize(slot_size_small)
					radio:Rebuild()
					radio:SizeToContents()
					radio:MoveBelow(torso, 16)
					radio:MoveLeftOf(legs, 5)
					radio:SetTitle("РАЦИЯ")

					local backpack = client:GetInventory("backpack"):CreatePanel(parent)
					backpack:SetSlotSize(slot_size)
					backpack:Rebuild()
					backpack:SizeToContents()
					backpack:Center()
					backpack:MoveRightOf(torso, 5)
					backpack:SetTitle("РЮКЗАК")
					backpack.OnRebuild = function()
						container:ValidateBackpack()
					end

					container:ValidateBackpack()
				end)
			end
		},
		[3] = {
			id = "craft",
			text = "СОЗДАНИЕ ВЕЩЕЙ",
			width = 1000,
			height = 720,
			OnShow = function(parent, x)
				x:DockPadding(2, 22 + 2, 2, 2)
				
				local container = x:Add("ui.craft")
				container:Setup()
				container:SizeToContents()
				container:Dock(FILL)
			end
		},
	},
	secondary = {
		[1] = {
			id = "exit",
			text = "В ГЛАВНОЕ МЕНЮ",
			style = 2,
			OnClick = function()
				ix.gui.menu:Close()
				vgui.Create("ixCharMenu")
			end
		},
		[2] = {
			id = "settings",
			text = "НАСТРОЙКИ",
			width = 1400,
			height = 800,
			OnShow = function(parent, x)
				local panel = x:Add("ixSettings")
				panel:SetSearchEnabled(false)

				for category, options in SortedPairs(ix.option.GetAllByCategories(true)) do
					category = L(category)
					panel:AddCategory(category)

					-- sort options by language phrase rather than the key
					table.sort(options, function(a, b)
						return L(a.phrase) < L(b.phrase)
					end)

					for _, data in pairs(options) do
						local key = data.key
						local row = panel:AddRow(data.type, category)
						local value = ix.util.SanitizeType(data.type, ix.option.Get(key))

						row:SetText(L(data.phrase))
						row:Populate(key, data)

						-- type-specific properties
						if (data.type == ix.type.number) then
							row:SetMin(data.min or 0)
							row:SetMax(data.max or 10)
							row:SetDecimals(data.decimals or 0)
						end

						row:SetValue(value, true)
						row:SetShowReset(value != data.default, key, data.default)
						row.OnValueChanged = function()
							local newValue = row:GetValue()

							row:SetShowReset(newValue != data.default, key, data.default)
							ix.option.Set(key, newValue)
						end

						row.OnResetClicked = function()
							row:SetShowReset(false)
							row:SetValue(data.default, true)

							ix.option.Set(key, data.default)
						end

						row:GetLabel():SetHelixTooltip(function(tooltip)
							local title = tooltip:AddRow("name")
							title:SetImportant()
							title:SetText(key)
							title:SizeToContents()
							title:SetMaxWidth(math.max(title:GetMaxWidth(), ScrW() * 0.5))

							local description = tooltip:AddRow("description")
							description:SetText(L(data.description))
							description:SizeToContents()
						end)
					end
				end

				panel:SizeToContents()
				panel:Dock(FILL)
			end
		},
		[3] = {
			id = "help",
			text = "ПОМОЩЬ",
			width = 1400,
			height = 800,
			OnShow = function(parent, x)
				local container = x:Add("ixHelpMenu")
				container:SizeToContents()
				container:Dock(FILL)
				container:RequestFocus()

				x:MakePopup()
			end
		},
		[4] = {
			id = "scoreboard",
			text = "ИГРОКИ",
			width = 1000,
			height = 720,
			OnShow = function(parent, x)
				local container = x:Add("ixScoreboard")
				container:SizeToContents()
				container:Dock(FILL)
			end
		},
		[5] = {
			id = "config",
			text = "СЕРВЕР",
			width = 1400,
			height = 800,
			OnShow = function(parent, x)
				local container = x:Add("ixConfigManager")
				container:SizeToContents()
				container:Dock(FILL)
				
				x:MakePopup()
			end,
			CanUse = function()
				if !CAMI.PlayerHasAccess(LocalPlayer(), "Helix - Manage Config", nil) then
					return
				end

				return true
			end
		}
	}
}

local saved = {}

function PANEL:OnMouseWheeled(scrollDelta)
	ix.Item:RotatePreview(scrollDelta)
end


surface.CreateFont("ui.tabmenu.level", {
	font = "Blender Pro Bold",
	extended = true,
	size = ix.UI.Scale(48),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("ui.tabmenu.leveltext", {
	font = "Blender Pro Heavy",
	extended = true,
	size = ix.UI.Scale(18),
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

surface.CreateFont("ui.tabmenu.levelmini", {
	font = "Blender Pro Medium",
	extended = true,
	size = ix.UI.Scale(14),
	weight = 500,
	blursize = 0,
	antialias = true,
})
surface.CreateFont("ui.tabmenu.time", {
	font = "Blender Pro Medium",
	extended = true,
	size = ix.UI.Scale(18),
	weight = 500,
	antialias = true,
})

surface.CreateFont("ui.tabmenu.money", {
	font = "Blender Pro Book",
	extended = true,
	size = ix.UI.Scale(28),
	weight = 500,
	antialias = true,
})
surface.CreateFont("ui.tabmenu.moneytext", {
	font = "Blender Pro Bold",
	extended = true,
	size = ix.UI.Scale(15),
	weight = 500,
	antialias = true,
})

local function DrawLevelXP(x, y, w, h, delta, clr)
	surface.SetDrawColor(ColorAlpha(clr, 200))
	surface.DrawRect(x + 2, y + 2, (w - 4) * delta, h -4 )

	surface.SetDrawColor(ColorAlpha(clr, 128))
	surface.DrawOutlinedRect(x, y, w, h)

	local offset = 2
	surface.SetDrawColor(ColorAlpha(clr, 48))
	surface.DrawOutlinedRect(x + offset, y + offset, w - offset * 2, h - offset * 2)
end

local yel = Color(255, 210, 0)
local lvl_colors = {
	[1] = color_white,
	[2] = color_white,
	[3] = yel,
	[4] = yel,
	[5] = yel,
	[6] = Color(255, 92, 80),
	[7] = Color(255, 92, 80),
	[8] = Color(255, 92, 80),
	[9] = Color(42, 237, 255),
	[10] = Color(42, 237, 255),
}

local function FormatMoney(number)
	local _, _, minus, int, fraction = tostring(number):find("([-]?)(%d+)([.]?%d*)")
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

function PANEL:PaintPanel(w, h)
	surface.SetDrawColor(16, 32, 48, 100)
	surface.DrawRect(0, 0, w, h)

	DisableClipping(true)
		surface.SetDrawColor(0, 190 * 0.5, 255 * 0.5, 96)
		surface.DrawRect(0, h, w, 1)
	DisableClipping(false)
end

function PANEL:Init()
	if IsValid(ix.gui.menu) then
		ix.gui.menu:Remove()
	end

	ix.gui.menu = self

	local scrW, scrH = ScrW(), ScrH()

	self:SetSize(scrW, scrH)

	gui.EnableScreenClicker(true)
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	self:RequestFocus()

	self:Receiver('ix.item', function(receiver, dropped, is_dropped, menu_index, mouse_x, mouse_y)
		local dropped = dropped[1]
		local dropped_itemID = dropped.instance_ids[1]
		local item = ix.Item.instances[dropped_itemID]

		if is_dropped then
			RememberCursorPosition()

			local pos, ang = ix.Item:GetDropAngles()

			net.Start('item.drop')
				net.WriteUInt(dropped_itemID, 32)
				net.WriteVector(pos)
				net.WriteAngle(ang)
			net.SendToServer()
		else
			local drop_slot = ix.inventory_drop_slot

			if IsValid(drop_slot) then
				drop_slot.is_hovered = false
				ix.inventory_drop_slot = nil
			end

			ix.Item:DropPreview(true, item)
		end
	end)

	local c = Color(32, 200, 255, 255)

	hook.Add('PreDrawHalos', self, function()
		local trace = ix.GetViewTrace()
		local ent = trace.Entity

		if !ent.GetEntityMenu then
			ent = nil
		end
		
		halo.Add({ent, ix.gui.entityMenu and ix.gui.entityMenu.ent}, c, 1, 1, 1, true, false)
	end)

	hook.Add('VGUIMousePressed', self, self.VGUIMousePressed)
	hook.Add('PostDrawTranslucentRenderables', self, self.Draw3DCursor)
	hook.Add('StartCommand', self, self.StartCommand)
	hook.Add('PlayerBindPress', self, self.PlayerBindPress)

	local tab_size = math.max(Scale(32), 20)

	self.top_tab = self:Add("Panel")
	self.top_tab:SetWide(ScrW())
	self.top_tab:DockMargin(0, 0, 0, 0)
	self.top_tab:Dock(TOP)
	self.top_tab:SetTall(tab_size)
	self.top_tab.Paint = self.PaintPanel

	self.bottom_tab = self:Add("Panel")
	self.bottom_tab:SetWide(ScrW())
	self.bottom_tab:DockMargin(0, 0, 0, 0)
	self.bottom_tab:Dock(BOTTOM)
	self.bottom_tab:SetTall(math.max(Scale(32), 20))
	self.bottom_tab.Paint = self.PaintPanel

	self.tab = self:Add("Panel")
	self.tab:SetWide(ScrW())
	self.tab:DockMargin(0, Scale(16), 0, 0)
	self.tab:Dock(TOP)
	self.tab:SetTall(Scale(48))

	local level_padding, level_bar_h, level_bar_w = Scale(32), math.max(8, Scale(14)), Scale(300)
	local LEVEL_PLUGIN = ix.plugin.list["!!levelsystem"]

	self.tab.Paint = function(this, w, h)
		local x, y = level_padding, 0

		local character = LocalPlayer():GetCharacter()
		local level = character:GetLevel()
		local xp = character:GetLevelXP()
		local xp_max = LEVEL_PLUGIN:GetRequiredLevelXP(level)
		local xp_delta = xp / xp_max

		surface.SetFont("ui.tabmenu.level")
		local level_w, level_h = surface.GetTextSize(level)
		local level_clr = lvl_colors[level] or lvl_colors[1]

		draw.SimpleText("УРОВЕНЬ", "ui.tabmenu.leveltext", x + level_w + 8, 0, level_clr, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(level, "ui.tabmenu.level", x, 0, level_clr, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

		x = x + level_w + 8
		y = h * 0.5 - (level_bar_h * 0.5) + 1

		DrawLevelXP(x, y, level_bar_w, level_bar_h, xp_delta, level_clr)

		y = y + level_bar_h

		DisableClipping(true)
			draw.SimpleText("ДО СЛЕДУЮЩЕГО: ".. math.Round(xp_max - xp).." XP", "ui.tabmenu.levelmini", x + level_bar_w, y, level_clr, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
		DisableClipping(false)
	end

	local credits_clr = Color(0, 225, 255, 8)
	local credits1 = self.bottom_tab:Add("DLabel")
	credits1:SetFont("ui.tabmenu.time")
	credits1:Dock(RIGHT)
	credits1:SetTextColor(credits_clr)
	credits1:DockMargin(0, 0, level_padding * 0.5, 0)
	credits1:SetText("AUTONOMOUS HL2 RPG — VERSION #28.6")
	credits1:SizeToContents()

	local credits1 = self.bottom_tab:Add("DLabel")
	credits1:SetFont("ui.tabmenu.time")
	credits1:Dock(LEFT)
	credits1:SetTextColor(credits_clr)
	credits1:DockMargin(level_padding * 0.5	, 0, 0, 0)
	credits1:SetText("DIRECTED AND DEVELOPED BY SCHWARZ KRUPPZO")
	credits1:SizeToContents()

	self.time = self.top_tab:Add("DLabel")
	self.time:SetFont("ui.tabmenu.time")
	self.time:Dock(RIGHT)
	self.time:SetTextColor(Color(0, 225, 255, 64))
	self.time:DockMargin(0, 0, level_padding * 0.5, 0)
	self.time:SetText("99:99:99 - 99.99.2024")
	self.time:SizeToContents()

	local money = self.tab:Add("DLabel")
	money:SetFont("ui.tabmenu.moneytext")
	money:Dock(RIGHT)
	money:SetTextColor(Color(32, 255, 128))
	money:DockMargin(0, 0, level_padding, 0)
	money:SetText("ТОКЕНОВ")
	money:SizeToContents()

	self.money = self.tab:Add("DLabel")
	self.money:SetFont("ui.tabmenu.money")
	self.money:Dock(RIGHT)
	self.money:SetContentAlignment(6)
	self.money:SetTextColor(Color(32, 255, 128))
	self.money:DockMargin(0, 0, 5, 0)
	self.money:SetText(FormatMoney(999999999))
	self.money:SizeToContents()
/*
	self.limbs = self:Add("ixLimbStatus")
	self.limbs:AlignLeft(0)
	self.limbs:AlignBottom(self.tab:GetTall())
	self.limbs:SetAlpha(64)
*/
	self.frames = {}


	local btn_list = self.tab:Add("Panel")
	btn_list:SetTall(self.tab:GetTall())

	for category, entries in pairs(buttons) do
		local parent = category == "primary" and btn_list or self.top_tab

		for k, v in ipairs(entries) do
			local button = parent:Add("ui.tabmenu.btn")

			if category == "primary" then
				if k != #buttons then
					button:DockMargin(0, 0, Scale(16), 0)
				end
			else
				button:SetStyleSmall()
				button:DockMargin(2, 2, 0, 2)
			end

			if v.style then
				button:SetStyle(v.style)
			end

			button:SetSize(48, parent:GetTall())
			button:SetText(v.text)
			button:SizeToContents()
			button:Dock(LEFT)

			if v.OnClick then
				button.DoClick = function()
					v.OnClick(self)
				end
			else
				button.OnToggle = function(this, state)
					if v.CanUse and !v.CanUse() then
						return
					end
					
					if state then
						local frame = self:Add("ui.tab.frame")
						frame:SetTitle(v.text:utf8upper())
						frame:SetSize(Scale(v.width), Scale(v.height))
						frame:Center()
						frame:DockPadding(16, 22 + 16, 16, 16)
						frame.btn = button
						frame.frameID = v.id

						v.OnShow(self, frame)

						frame:InvalidateLayout(true)
						frame:SizeToChildren(false, true)
						frame:Center()

						ix.util.TabFocus(frame, frame)

						local saveData = saved[v.id]

						if saveData then
							frame:SetPos(saveData.posX, saveData.posY)
							frame:SetSize(saveData.sizeX, saveData.sizeY)
						end

						ix.util.TabRequestFocus(frame)

						self.frames[v.id] = frame
					else
						self:CloseFrame(v.id, true)
					end
				end

				if saved[v.id] and saved[v.id].show then
					button:DoClick()
				end
			end
		end
	end

	btn_list:InvalidateLayout( true )
	btn_list:SizeToChildren( true, false )
	btn_list:Center()

	hook.Run("OnTabMenuCreated", self)
	
	self.currentAlpha = 0
	self:SetAlpha(0)

	self:CreateAnimation(0.5, {
		target = {currentAlpha = 255},
		easing = "outQuint",

		Think = function(animation, panel)
			panel:SetAlpha(panel.currentAlpha)
		end
	})
end

function PANEL:CloseFrame(id, btn)
	local frame = self.frames[id]
	if frame then
		local saveX, saveY = frame:GetPos()
		local saveW, saveH = frame:GetSize()

		saved[id] = {
			posX = saveX,
			posY = saveY,
			sizeX = saveW,
			sizeY = saveH,
			show = false
		}

		frame:Remove()
		self.frames[id] = nil

		if !btn and frame.btn then
			frame.btn.state = false
		end
	end
end

function PANEL:Think()
	local character = LocalPlayer():GetCharacter()
	local date = os.date("%H:%M:%S - %d.%m")

	self.time:SetText(date..".2026")

	if !self.nextSlowThink or self.nextSlowThink <= CurTime() then
		self.money:SetText(FormatMoney(character:GetMoney()))
		self.nextSlowThink = CurTime() + 1
	end
end

function PANEL:OpenWorldInteraction()
	local trace = ix.GetViewTrace()
	local entity = trace.Entity

	if IsValid(entity) and entity.GetEntityMenu then
		local options = entity:GetEntityMenu(LocalPlayer())

		if istable(options) and !table.IsEmpty(options) then
			ix.menu.Open(options, entity)
		end
	end
end

function PANEL:OnFrameFocus(newPanel)
	for id, panel in pairs(self.frames) do
		panel:AlphaTo(panel == newPanel and 255 or 100, 0.1)
	end
end

function PANEL:VGUIMousePressed(code)
	local x = vgui.GetHoveredPanel()

	if IsValid(x) then
		ix.util.TabRequestFocus(x)
	end
end

function PANEL:OnMousePressed(code)
	if code == MOUSE_RIGHT then
		self:OpenWorldInteraction()
	end
end

function PANEL:PlayerBindPress(client, bind, pressed, key)
	local droppable = dragndrop.GetDroppable('ix.item')

	if droppable then
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
end

function PANEL:Close()
	if self.bClosing then
		return
	end

	for id, panel in pairs(self.frames) do
		local saveX, saveY = panel:GetPos()
		local saveW, saveH = panel:GetSize()

		saved[id] = {
			posX = saveX,
			posY = saveY,
			sizeX = saveW,
			sizeY = saveH,
			show = true
		}
	end

	self:Remove()
end

function PANEL:Remove()
	self.bClosing = true

	hook.Remove('PreDrawHalos', self)
	hook.Remove('VGUIMousePressed', self)
	hook.Remove('PostDrawTranslucentRenderables', self)
	hook.Remove('StartCommand', self)
	hook.Remove('PlayerBindPress', self)

	gui.EnableScreenClicker(false)

	self:CreateAnimation(0.25, {
		target = {currentAlpha = 0},
		easing = "outQuint",

		Think = function(animation, panel)
			panel:SetAlpha(panel.currentAlpha)
		end,
		OnComplete = function(animation, panel)
			if (IsValid(panel.projectedTexture)) then
				panel.projectedTexture:Remove()
			end

			BaseClass.Remove(panel)
		end
	})
end


function PANEL:Paint(w, h)
	surface.SetDrawColor(0, 0, 0)
	surface.SetMaterial(vignette)
	surface.DrawTexturedRect(-w*0.5, 0, w*2, h*2)
end

do
	local f, b = Vector(0, 0, 0), Angle(0, 90, 90)
	local function Circle(sx, sy, radius, vertexCount, color, angle)
		local vertices = {}
		local ang = -math.rad(angle or 0)
		local c = math.cos(ang)
		local s = math.sin(ang)
		for i = 0, 360, 360 / vertexCount do
			local radd = math.rad(i)
			local x = math.cos(radd)
			local y = math.sin(radd)

			local tempx = x * radius * c - y * radius * s + sx
			y = x * radius * s + y * radius * c + sy
			x = tempx

			vertices[#vertices + 1] = {
				x = x,
				y = y,
				u = u,
				v = v
			}
		end

		if vertices and #vertices > 0 then
			draw.NoTexture()
			surface.SetDrawColor(color)
			surface.DrawPoly(vertices)
		end
	end

	function PANEL:Draw3DCursor()
		local dir = LocalPlayer():EyeAngles():Forward()
		local trace = ix.GetViewTrace()

		if !trace then
			return
		end

		local hitNormal = trace.Hit and trace.HitNormal or -dir

		if math.abs(hitNormal.z) > .98 then
			hitNormal:Add(-dir * .01)
		end

		local pos, ang = LocalToWorld(f, b, trace.HitPos, hitNormal:Angle())
		cam.Start3D2D(pos, ang, math.pow(trace.Fraction, .1) * (a or .2))
			cam.IgnoreZ(true)
				render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD, BLEND_DST_ALPHA, BLEND_DST_ALPHA, BLENDFUNC_ADD)

				Circle(0, 0, 8, 18, Color(0, 200, 255), 0)

				render.OverrideBlend(false)
			cam.IgnoreZ(false)
		cam.End3D2D()
	end
end

local show_cursor = true

function PANEL:StartCommand(_, cmd)
	local droppable = dragndrop.GetDroppable()

	if input.IsMouseDown(MOUSE_LEFT) then
		local x = vgui.GetHoveredPanel()

		if IsValid(x) then
			if x.isTabFrame then
				ix.util.TabRequestFocus(x)
				return
			end
		end
	end

	if droppable then
		cmd:ClearButtons()
		return
	end

	if IsValid(ix.usePnl) or (input.IsMouseDown(MOUSE_LEFT) and (!self:IsChildHovered() or self.isDraggingWindow)) then
		RememberCursorPosition()

		if show_cursor then
			gui.EnableScreenClicker(false)
		end

		show_cursor = false
	elseif !cmd:KeyDown(IN_ATTACK) and !show_cursor then
		if !show_cursor then
			gui.EnableScreenClicker(true)
			RestoreCursorPosition()
		end

		show_cursor = true
	end

	if show_cursor and !vgui.CursorVisible() then
		gui.EnableScreenClicker(true)
		RestoreCursorPosition()
	end
end

vgui.Register('ui.tabmenu', PANEL, 'EditablePanel')

if (IsValid(ix.gui.menu)) then
	ix.gui.menu:Remove()
end
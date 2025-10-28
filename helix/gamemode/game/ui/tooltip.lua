local Scale = ix.UI.Scale

surface.CreateFont("autonomous.hint.title", {
	font = "Blender Pro Book",
	size = Scale(25),
	extended = true,
	weight = 500
})
surface.CreateFont("autonomous.hint.small", {
	font = "Blender Pro Medium",
	size = Scale(16),
	extended = true,
	weight = 500
})
surface.CreateFont("autonomous.hint.info", {
	font = "Blender Pro Medium",
	size = Scale(16),
	extended = true,
	weight = 500
})
surface.CreateFont("autonomous.hint.infobig", {
	font = "Blender Pro Bold",
	size = Scale(18),
	extended = true,
	weight = 500
})


local PANEL = {}

function PANEL:Init()
	self.text = ""
	self.markup = nil

	self.alignx = nil
	self.aligny = nil
end

function PANEL:SetMarkup(text, x, y, w)
	self.text = text
	self.alignx = x
	self.aligny = y

	self.markup = markup.Parse(self.text, w)

	self:SetTall(self.markup:GetHeight())
end

function PANEL:Paint(width, height)
	local x, y = 0, 0

	if self.alignx == TEXT_ALIGN_CENTER then
		x = x + width * 0.5
	end

	if self.alignx == TEXT_ALIGN_RIGHT then
		x = x + width
	end

	if self.aligny == TEXT_ALIGN_CENTER then
		y = y + height * 0.5
	end
	
	self.markup:Draw(x, y, self.alignx, self.aligny, 255)
end

vgui.Register("hint.textpanel", PANEL, "Panel")

local RT_HINT = GetRenderTargetEx("autonomous_hint_rt", 512, 256, RT_SIZE_OFFSCREEN, MATERIAL_RT_DEPTH_NONE, 0, 0, IMAGE_FORMAT_RGBA8888)
local HINT_FX = CreateMaterial("autonomous_hint_fx", "Modulate", {
	["$basetexture"] = "autonomous/ui/terminal/cmb_bg_animated",
	["$selfillum"] = 1,
	["$vertexalpha"] = 1,
	["Proxies"] = {
		["AnimatedTexture"] = {
			["animatedTextureVar"] = "$basetexture",
			["animatedTextureFrameNumVar"] = "$frame",
			["animatedTextureFrameRate"] = 30
		}
	}
})

local PANEL = {}
PANEL.colors = {}

AccessorFunc(PANEL, "mousePadding", "MousePadding", FORCE_NUMBER)

local pos, ang = vector_origin, Angle()

local y = -239.188995/2
local x = -239.188995/2

local dividerColor = Color(0, 220, 255, 8)
function PANEL:AddDivider(padding)
	padding = padding or Scale(8)
	local divider = self.container:Add("Panel")
	divider:Dock(TOP)
	divider:SetTall(padding * 2)
	divider.Paint = function(this, w, h)
		local pos = h / 2
		surface.SetDrawColor(dividerColor)
		surface.DrawLine(0, pos, w, pos)
	end

	return divider
end

local smallColor = Color(130, 130, 130)
function PANEL:AddSmallText(value, alignment, color)
	local text = self.container:Add("DLabel")
	text:Dock(TOP)
	text:SetFont("autonomous.hint.small")
	text:SetText(value)
	text:SetTextColor(color and color or smallColor)
	text:SetContentAlignment(alignment and alignment or 4)
	text:SizeToContents()

	return text
end

function PANEL:AddMarkup(value, alignmentX, alignmentY, offset)
	local paddingLeft, paddingTop, paddingRight, paddingBottom = self.container:GetDockPadding()

	local text = self.container:Add("hint.textpanel")
	text:Dock(TOP)
	text:SetMarkup(value, alignmentX and alignmentX or TEXT_ALIGN_LEFT, alignmentY and alignmentY or TEXT_ALIGN_TOP, (self.container:GetWide() - paddingLeft - paddingRight - (offset or 0)))

	self.markups[#self.markups + 1] = text

	return text
end

function PANEL:SetTitle(text)
	self.title:SetText(text)
end

function PANEL:Init()
	Material("autonomous/hint1"):SetTexture("$basetexture", RT_HINT)

	local padding = 30


	self.fraction = 1
	self.mousePadding = 8
	self.minWidth = Scale(640)
	self.minHeightBottom = 64

	self.z = ScrH()
	self.scale = 0.8 + (1 - (self.z / 900))
	self._size = Vector(0, -x, -y) * self.scale
	self.mdl_pos = nil

	self.mdl = ClientsideModel('models/autonomous/hint1.mdl', RENDERGROUP_OPAQUE)
	self.mdl:SetNoDraw(true)
	self.mdl:SetupBones()

	self:SetAlpha(255)
	self:SetDrawOnTop(true)
	self:SetSize(self.minWidth, 200)
	self:Center()

	self.markups = {}

	local paddingLeft = Scale(36)
	local paddingTop = Scale(16)

	self.padding = paddingLeft

	self.container = self:Add("EditablePanel")
	self.container:Dock(TOP)
	self.container:SetWide(self.minWidth)
	--self.container:SetAlpha(0)
	self.container:DockPadding(paddingLeft, 0, paddingLeft * 0.5, paddingTop)

	self.title = self.container:Add("DLabel")
	self.title:Dock(TOP)
	self.title:DockMargin(0, paddingTop, 0, 0)
	self.title:SetFont("autonomous.hint.title")
	self.title:SetTextColor(Color(0, 255, 255))
	self.title:SizeToContents()

	self:AddDivider()
/*
	self:CreateAnimation(1, {
		index = 1,
		target = {fraction = 1},
		easing = "outQuint",

		Think = function(animation, panel)
			panel.container:SetAlpha(panel.fraction * 255)
		end
	})*/
end

function PANEL:Resize()
	self.container:InvalidateLayout(true)

	for k, v in ipairs(self.markups) do
		v:InvalidateLayout(true)
	end

	self.container:SizeToChildren(true, true)

	self:InvalidateLayout(true)
	self:SizeToChildren(false, true)
end

function PANEL:GetCursorPosition()
	local width, height = self:GetSize()
	local mouseX, mouseY = gui.MousePos()

	return math.Clamp(mouseX + self.mousePadding, 0, ScrW() - width), math.Clamp(mouseY + self.mousePadding, 0, ScrH() - height)
end

function PANEL:Think()
	if self.parent then
		if self.parent.update_tooltip then
			self.parent.update_tooltip = false
			self:Clear()
			self.parent.OverrideTooltip(self)
			self:SizeToContents()
		end
	end

	local newX, newY = self:GetCursorPosition()

	self:SetPos(newX, newY)
	self.lastX, self.lastY = newX, newY

	self:MoveToFront() -- dragging a panel w/ tooltip will push the tooltip beneath even the menu panel(???)
end

local bg = Material("devtest/dif1.png")
local blendFX = Color(255, 255, 255, 255)

local m = Matrix()
m:Translate(pos)
function PANEL:RecacheHintSize(w, h)
	local size = (w / 2 - 2)
	local sizeh = (h / 2 - 2)

	self.mdl_pos = {}
	self.mdl_pos[1] = Vector(0, -size, sizeh) * self.scale
	self.mdl_pos[2] = Vector(0, size, sizeh) * self.scale
	self.mdl_pos[3] = Vector(0, -size, -sizeh) * self.scale
	self.mdl_pos[4] = Vector(0, size, -sizeh) * self.scale
end

function PANEL:Paint(w, h)
	render.PushRenderTarget(RT_HINT)
		render.Clear(0, 0, 0, 0)

		cam.Start2D()
		--surface.SetAlphaMultiplier(0.1)

			surface.SetMaterial(bg)
			surface.SetDrawColor(color_white)
			surface.DrawTexturedRect(0, 0, 512, 256)
			

			render.OverrideBlend(true, 9, 1, BLENDFUNC_ADD, 4, 1, BLENDFUNC_ADD)
				surface.SetMaterial(HINT_FX)
				surface.SetDrawColor(blendFX)
				surface.DrawTexturedRect(0, 0, 256, 256)
				surface.DrawTexturedRect(0, 0, 256, 256)
			render.OverrideBlend(false)

			surface.SetDrawColor(0, 240, 255, 32)
			surface.DrawRect(0, 0, self.padding * 0.75 * (256 / w), 256)

			surface.DrawRect(self.padding * 0.75 * (256 / w) + 1, 0, 1, 256)

			surface.SetDrawColor(0, 240, 255, 200)
			surface.DrawRect(256, 0, 21, 256)
		cam.End2D()
	render.PopRenderTarget()



	cam.Start3D(pos, ang, 0, 0, w, h)
		render.SetViewPort(self:GetX(), self:GetY(), w, h)
		cam.StartOrthoView(-w/2 * self.scale, h/2 * self.scale, w/2 * self.scale, -h/2 * self.scale)
			render.SuppressEngineLighting(true)
			cam.PushModelMatrix(m, true)
			
			self.mdl:SetupBones()

			if !self.mdl_pos then
				self:RecacheHintSize(w, h)
			else
				local mat = self.mdl:GetBoneMatrix(1)
				mat:SetTranslation(self.mdl_pos[1])
				self.mdl:SetBoneMatrix(1, mat)

				local mat = self.mdl:GetBoneMatrix(0)
				mat:SetTranslation(self.mdl_pos[2])
				self.mdl:SetBoneMatrix(0, mat)

				local mat = self.mdl:GetBoneMatrix(2)
				mat:SetTranslation(self.mdl_pos[3])
				self.mdl:SetBoneMatrix(2, mat)

				local mat = self.mdl:GetBoneMatrix(3)
				mat:SetTranslation(self.mdl_pos[4])
				self.mdl:SetBoneMatrix(3, mat)
			end

			self.mdl:SetPos(self._size)
			render.SetBlend(1)
			self.mdl:DrawModel()

			cam.PopModelMatrix()

			render.SuppressEngineLighting(false)
		cam.EndOrthoView()
	cam.End3D()
end

vgui.Register("autonomous.tooltip", PANEL, "EditablePanel")

do
	local PANEL = FindMetaTable("Panel")
	local ixChangeTooltip = ChangeTooltip
	local ixRemoveTooltip = RemoveTooltip
	local tooltip
	local lastHover

	function PANEL:SetAutonomousTooltip(callback, panel)
		self:SetMouseInputEnabled(true)
		self.OverrideTooltip = callback
		self.OverrideTooltipPanel = panel or "autonomous.tooltip"
	end

	function ChangeTooltip(panel, ...) -- luacheck: globals ChangeTooltip
		if (!panel.OverrideTooltip) then
			return ixChangeTooltip(panel, ...)
		end

		RemoveTooltip()

		timer.Create("ixTooltip", 0.1, 1, function()
			if (!IsValid(panel) or lastHover != panel) then
				return
			end

			tooltip = vgui.Create(panel.OverrideTooltipPanel)
			panel.OverrideTooltip(tooltip)
			tooltip.parent = panel
			tooltip:SizeToContents()
		end)

		lastHover = panel
	end

	function RemoveTooltip() -- luacheck: globals RemoveTooltip
		if (IsValid(tooltip)) then
			tooltip:Remove()
			tooltip = nil
		end

		timer.Remove("ixTooltip")
		lastHover = nil

		return ixRemoveTooltip()
	end
end
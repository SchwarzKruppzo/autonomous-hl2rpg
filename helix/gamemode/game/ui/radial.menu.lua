local PANEL = {}
local RADIUS_INNER = 100
local RADIUS_OUTER = 250

surface.CreateFont("autonomous.radialmenu.btn", {
	font = "Blender Pro Medium",
	extended = true,
	size = 21,
	weight = 500,
})

function PANEL:Init()
	if IsValid(ix.gui.radialMenu) then
		ix.gui.radialMenu:Remove()
	end
	
	ix.gui.radialMenu = self

	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
	self:SetSize(ScrW(), ScrH())

	self.categories = {}
	self.options = {}
	self.optionCount = 0
	self.optionSelected = -1

	self.sectionAngle = 0
	self.sectionAngleDeg = 0
	self.segmentAngles = {}

	self.alpha = 0
	self.innerColor = Color(16, 32, 48, 0)

	self.centerX = ScrW() * 0.5
	self.centerY = ScrH() * 0.5
	self.cursorX = 0
	self.cursorY = 0
	self.cursorHandledByInput = false

	self:SetVisible(false)
end

function PANEL:PrecalculateSegments()
	self.sectionAngle = math.pi * 2 / self.optionCount
	self.sectionAngleDeg = 359.99 / self.optionCount
	self.segmentAngles = {}
	
	for i = 1, self.optionCount do
		local startDeg = (i - 1) * self.sectionAngleDeg
		local finishDeg = i * self.sectionAngleDeg

		self.segmentAngles[i] = {
			start = startDeg,
			finish = finishDeg,
		}
	end
end

function PANEL:ParseOptions(options)
	return ix.util.Imap(options, function(option)
		return {
			text = option.text or "Untitled",
			callback = option.callback or option.options,
			anim = 0,
		}
	end)
end

function PANEL:SetMultiOptions(options, default)
	for category, categoryOptions in pairs(options) do
		self.categories[category] = self:ParseOptions(categoryOptions)
	end

	if default then
		self:SetOptions(default)
	end
end

function PANEL:SetOptions(options)
	if isstring(options) then
		self.options = self.categories[options] or {}
	else
		self.options = self:ParseOptions(options)
	end

	self.optionCount = #self.options

	self:PrecalculateSegments()
end

function PANEL:ChooseOption(id)
	local info = self.options[id]

	if !info then return end
	
	LocalPlayer():EmitSound("Helix.Press")

	local callback = info.callback

	if callback then
		if isstring(callback) then
			self.alpha = 0.5
			self:SetOptions(callback)

			for k, v in ipairs(self.options) do
				v.anim = 0
			end

			self:Open(self:IsHandledByInput())
		else
			local ret = callback(self, id)

			return ret and ret or false
		end
	end
end

function PANEL:OnOptionHovered(id)
	LocalPlayer():EmitSound("Helix.Rollover")
end

function PANEL:IsHandledByInput()
	return self.cursorHandledByInput
end

function PANEL:IsReady()
	return self.alpha > 0.25
end

function PANEL:Open(isInput)
	self:SetVisible(true)

	if !isInput then
		self:MakePopup()
	else
		self:SetMouseInputEnabled(false)
		self:SetKeyboardInputEnabled(false)
	end

	self.cursorHandledByInput = isInput

	self:CreateAnimation(1, {
		target = {
			alpha = 1
		},
		easing = "outCubic",
		OnComplete = function()
			
		end
	})
end

function PANEL:Close()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)

	self.isReady = false

	self:CreateAnimation(0.2, {
		target = {
			alpha = 0
		},
		easing = "outCubic",
		OnComplete = function()
			self:Remove()
		end
	})
end

do
	function PANEL:InputMouseApply(cmd, x, y, ang)
		if !self:IsReady() then return end
		
		local cursor = self.cursor or Vector()

		cursor.x = (cursor.x + x)
		cursor.y = (cursor.y + y)

		if cursor:LengthSqr() > 1e4 then
			cursor = cursor:GetNormalized() * 100
		end

		self.cursor = cursor

		cmd:SetMouseX(0)
		cmd:SetMouseY(0)

		return true
	end
	
	local vec_zero = Vector()
	function PANEL:HandleSelected()
		local selected = 0
		local cursor = self.cursor or vec_zero

		if !self:IsHandledByInput() then
			local cursorX, cursorY = gui.MouseX(), gui.MouseY()

			cursor.x = (cursorX - self.centerX)
			cursor.y = (cursorY - self.centerY)

			if cursor:LengthSqr() > 1e4 then
				cursor = cursor:GetNormalized() * 100
			end

			self.cursor = cursor
		end

		if cursor.x ^ 2 + cursor.y ^ 2 > 4e3 then
			local angle = math.atan2(cursor.y, cursor.x) + math.pi / 2
			angle = angle > math.pi and angle - 2 * math.pi or angle
			angle = (angle / math.pi + 1) / 2

			local step = 1 / self.optionCount
			selected = math.Round((angle + step / 2) * self.optionCount)
		end

		return selected
	end

	function PANEL:Think()
		if self.alpha > 0 then
			local FT = FrameTime()

			self.optionSelected = self:HandleSelected()

			if (self.lastSelected or 0) != self.optionSelected then
				self:OnOptionHovered(self.optionSelected)

				self.lastSelected = self.optionSelected
			end

			for i = 1, self.optionCount do
				if self.optionSelected == i then
					self.options[i].anim = math.Approach(self.options[i].anim, 1, FT / 0.1)
				else
					self.options[i].anim = math.Approach(self.options[i].anim, 0, FT / 0.25)
				end
			end
		end
	end

	local wasPressedLMB = false
	local wasPressedRMB = false
	function PANEL:CreateMove(cmd)
		if !wasPressedLMB then
			if cmd:KeyDown(IN_ATTACK) then
				if self.optionSelected > 0 then
					if self:ChooseOption(self.optionSelected) == false then
						self:Close()
					end
				end
			end
		end

		if !wasPressedRMB then
			if cmd:KeyDown(IN_ATTACK2) then
				self:Close()
			end
		end
		
		wasPressedRMB = cmd:KeyDown(IN_ATTACK2)
		wasPressedLMB = cmd:KeyDown(IN_ATTACK)

		cmd:RemoveKey(IN_ATTACK)
		cmd:RemoveKey(IN_ATTACK2)
	end

	function PANEL:OnMouseReleased(mousecode)
		if mousecode == MOUSE_LEFT then
			if self.optionSelected > 0 then
				if self:ChooseOption(self.optionSelected) == false then
					self:Close()
				end
			end
		end

		if mousecode == MOUSE_RIGHT then
			self:Close()
		end
	end

	function PANEL:Paint(w, h)
		if self.alpha <= 0 then return end

		local centerX, centerY = self.centerX, self.centerY
		local alpha = math.ease.OutQuad(self.alpha)

		local dx = ix.DX and ix.DX()

		local innerRadius = math.max(RADIUS_INNER * alpha, 0) * 1.5
		local outerRadius = (RADIUS_OUTER * alpha) * 2

		self.innerColor.a = 120 * alpha

		dx.Circle(centerX, centerY, outerRadius)
			:Blur(1)
			:Rotation(-90)
			:Outline(innerRadius)
			:StartAngle(0)
			:EndAngle(360)
		:Draw()

		dx.Circle(centerX, centerY, outerRadius)
			:Outline(innerRadius)
			:StartAngle(0)
			:EndAngle(360)
			:Color(self.innerColor)
		:Draw()

		dx.Circle(centerX, centerY, outerRadius - (innerRadius * 2))
			:Outline(1)
			:StartAngle(0)
			:EndAngle(360)
			:Color(ix.Palette.autonomousblue)
		:Draw()

		for i = 1, self.optionCount do
			local hoverFrac = math.ease.OutQuad(self.options[i].anim)

			local hoverColor = self.options[i].hoverColor or Color(16, 32, 48)
			hoverColor.a = 100 * hoverFrac
			self.options[i].hoverColor = hoverColor

			if hoverFrac != 0 then
				local hoverInner = hoverFrac * 5

				dx.Circle(centerX, centerY, outerRadius)
					:Rotation(-90)
					:Outline(innerRadius)
					:StartAngle(self.segmentAngles[i].start)
					:EndAngle(self.segmentAngles[i].finish)
					:Color(hoverColor)
				:Draw()

				dx.Circle(centerX, centerY, outerRadius - (innerRadius * 2))
					:Rotation(-90)
					:Outline(hoverInner)
					:StartAngle(self.segmentAngles[i].start)
					:EndAngle(self.segmentAngles[i].finish)
					:Color(ix.Palette.autonomousblue)
				:Draw()
			end

			local angCenter = self.sectionAngle * (i - 0.5) + (math.pi / 2)
			local posX, posY = math.cos(angCenter), math.sin(angCenter)

			local textColor = self.options[i].textColor or Color(0, 200, 255)
			textColor.a = (150 + 105 * hoverFrac) * alpha
			self.options[i].textColor = textColor

			draw.SimpleText(self.options[i].text, "autonomous.radialmenu.btn", centerX + posX * (outerRadius - innerRadius) * 0.5, centerY + posY * (outerRadius - innerRadius) * 0.5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end
	
vgui.Register("ui.radial.menu", PANEL, "EditablePanel")

/*
local options = {
	page1 = {
		{text = "Debug 1", callback = "page2"},
		{text = "Debug 2"},
		{text = "Debug 3"},
		{text = "Debug 4"},
		{text = "Debug 5"},
		{text = "Debug 6"},
	},
	page2 = {
		{text = "Page 1", callback = "page1"},
		{text = "Page 2"},
		{text = "Page 3"},
	},
}

local a = vgui.Create("ui.radial.menu")

a:SetMultiOptions(options, "page1")

a:Open()
*/
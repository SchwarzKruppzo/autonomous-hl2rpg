local abs   = math.abs
local Round = math.Round
local sqrt  = math.sqrt
local exp   = math.exp
local log   = math.log
local sin   = math.sin
local cos   = math.cos
local sinh  = math.sinh
local cosh  = math.cosh
local acos  = math.acos

local deg2rad = math.pi/180
local rad2deg = 180/math.pi

local function Scale(px)
	return math.ceil(math.max(480, ScrH()) * (px / 1080))
end

local function qNormalize(q)
	local len = sqrt(q[1]^2 + q[2]^2 + q[3]^2 + q[4]^2)
	q[1] = q[1]/len
	q[2] = q[2]/len
	q[3] = q[3]/len
	q[4] = q[4]/len
end

local function qDot(q1, q2)
	return q1[1]*q2[1] + q1[2]*q2[2] + q1[3]*q2[3] + q1[4]*q2[4]
end

local function qmul(lhs, rhs)
	local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
	local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
	return {
		lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
		lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
		lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
		lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
	}
end

local function quat(ang)
	local p, y, r = ang[1], ang[2], ang[3]
	p = p*deg2rad*0.5
	y = y*deg2rad*0.5
	r = r*deg2rad*0.5
	local qr = {cos(r), sin(r), 0, 0}
	local qp = {cos(p), 0, sin(p), 0}
	local qy = {cos(y), 0, 0, sin(y)}
	return qmul(qy,qmul(qp,qr))
end

local function nlerp(t, q0, q1)
	local t1 = 1 - t
	local q2
	if qDot(q0, q1) < 0 then
		q2 = { q0[1] * t1 - q1[1] * t, q0[2] * t1 - q1[2] * t, q0[3] * t1 - q1[3] * t, q0[4] * t1 - q1[4] * t }
	else
		q2 = { q0[1] * t1 + q1[1] * t, q0[2] * t1 + q1[2] * t, q0[3] * t1 + q1[3] * t, q0[4] * t1 + q1[4] * t }
	end

	qNormalize(q2)
	return q2
end

local function toAngle(this)
	local l = sqrt(this[1]*this[1]+this[2]*this[2]+this[3]*this[3]+this[4]*this[4])
	if l == 0 then return {0,0,0} end
	local q1, q2, q3, q4 = this[1]/l, this[2]/l, this[3]/l, this[4]/l

	local x = Vector(q1*q1 + q2*q2 - q3*q3 - q4*q4,
		2*q3*q2 + 2*q4*q1,
		2*q4*q2 - 2*q3*q1)

	local y = Vector(2*q2*q3 - 2*q4*q1,
		q1*q1 - q2*q2 + q3*q3 - q4*q4,
		2*q2*q1 + 2*q3*q4)

	local ang = x:Angle()
	if ang.p > 180 then ang.p = ang.p - 360 end
	if ang.y > 180 then ang.y = ang.y - 360 end

	local yyaw = Vector(0,1,0)
	yyaw:Rotate(Angle(0,ang.y,0))

	local roll = acos(math.Clamp(y:Dot(yyaw), -1, 1))*rad2deg

	local dot = q2*q1 + q3*q4
	if dot < 0 then roll = -roll end

	return Angle(ang.p, ang.y, roll)
end



local PANEL = {}

AccessorFunc( PANEL, "m_fAnimSpeed",	"AnimSpeed" )
AccessorFunc( PANEL, "Entity",			"Entity" )
AccessorFunc( PANEL, "vCamPos",			"CamPos" )
AccessorFunc( PANEL, "fFOV",			"FOV" )
AccessorFunc( PANEL, "vLookatPos",		"LookAt" )
AccessorFunc( PANEL, "fLookDist",		"LookDist" )
AccessorFunc( PANEL, "aLookAngle",		"LookAng" )
AccessorFunc( PANEL, "colAmbientLight",	"AmbientLight" )
AccessorFunc( PANEL, "colColor",		"Color" )
AccessorFunc( PANEL, "bAnimated",		"Animated" )
AccessorFunc( PANEL, "bDrawFloor",		"DrawFloor" )

local xDeg, yDeg = 0, 0

function PANEL:Init()
	self.Entity = nil
	self.LastPaint = 0
	self.DirectionalLight = {}
	self.FarZ = 256

	self:SetCamPos(Vector(0, 0, -40))
	self:SetLookAt(Vector( 0, 0, 40))
	self:SetLookDist(120)
	self:SetFOV(75)
	self:SetDrawFloor(true)

	self:SetText("")
	self:SetAnimSpeed(0.5)
	self:SetAnimated(false)

	self:SetAmbientLight(Color(0, 0, 0))

	self:SetColor( color_white )
	self:SetModel("models/player/hla/metropolice_npc.mdl")

	self:SetCursor("sizeall")
end

function PANEL:SetModel(strModelName)
	if IsValid(self.Entity) then
		self.Entity:Remove()
		self.Entity = nil
	end

	if !ClientsideModel then return end

	//self.Entity = ClientsideModel(strModelName, RENDERGROUP_OTHER)
	self.Entity = ents.CreateClientside("base_anim")
	self.Entity:SetModel(strModelName)
	
	if !IsValid(self.Entity) then return end

	self.Entity:SetNoDraw(true)
	self.Entity:SetIK(false)

	-- Try to find a nice sequence to play
	local iSeq = self.Entity:SelectWeightedSequence(ACT_IDLE)
	if ( iSeq <= 0 ) then iSeq = self.Entity:LookupSequence( "WalkUnarmed_all" ) end
	if ( iSeq <= 0 ) then iSeq = self.Entity:LookupSequence( "walk_all_moderate" ) end

	if ( iSeq > 0 ) then self.Entity:ResetSequence( iSeq ) end
end

function PANEL:GetModel()
	if !IsValid(self.Entity) then return end

	return self.Entity:GetModel()
end

function PANEL:DrawModel()
	local curparent = self
	local leftx, topy = self:LocalToScreen( 0, 0 )
	local rightx, bottomy = self:LocalToScreen( self:GetWide(), self:GetTall() )
	while ( curparent:GetParent() != nil ) do
		curparent = curparent:GetParent()

		local x1, y1 = curparent:LocalToScreen( 0, 0 )
		local x2, y2 = curparent:LocalToScreen( curparent:GetWide(), curparent:GetTall() )

		leftx = math.max( leftx, x1 )
		topy = math.max( topy, y1 )
		rightx = math.min( rightx, x2 )
		bottomy = math.min( bottomy, y2 )
		previous = curparent
	end

	-- Causes issues with stencils, but only for some people?
	-- render.ClearDepth()

	render.SetScissorRect( leftx, topy, rightx, bottomy, true )

	local ret = self:PreDrawModel( self.Entity )
	if ( ret != false ) then
		self.Entity:DrawModel()
		self:PostDrawModel( self.Entity )
	end

	render.SetScissorRect(0, 0, 0, 0, false)
end


function PANEL:PreDrawModel( ent )
	return true 
end

function PANEL:PostDrawModel(ent)
end

local tabs = {
	[1] = {
		type = MATERIAL_LIGHT_DIRECTIONAL,
		color = Vector(0.5, 0.8, 1) * 4,
		dir = Vector(-1, -1, -1),
		range = 1,
	},
	[2] = {
		type = MATERIAL_LIGHT_DIRECTIONAL,
		color = Vector(1, 0.8, 0.5),
		dir = Vector(1, 1, 0),
		range = 1,
	},
}

local radial = Material("helix/gui/radial-gradient.png", "smooth")
local radial_clr = Color(15, 40, 55)

local angles = Angle()
local rotation_ang = Angle()
local curAng

local function RotateBehindTarget()
	local targetRotationAngle = LocalPlayer():EyeAngles().y
	local currentRotationAngle = angles.y
	
	

	local targetAng = quat(Angle(18 + -yDeg, 185 + xDeg, 0))

	curAng = quat(rotation_ang)

	curAng = nlerp(30 * FrameTime(), curAng, targetAng)

	rotation_ang = toAngle(curAng)
end

local function ClampAngle(angle, min, max)
	if angle < -360 then
		angle = angle + 360
	end

	if angle > 360 then
  		angle = angle - 360
  	end
  	
	return math.Clamp(angle, min, max)
end

local vecUp = Vector(0, 0, 1)
local floorColors = {
	Color(64, 130, 160, 100),
	Color(30, 40, 45, 255),
	Color(0, 0, 0, 128)
}
function PANEL:Paint(w, h)
	if !IsValid(self.Entity) then return end

	local x, y = self:LocalToScreen( 0, 0 )

	self:LayoutEntity( self.Entity )

	if self.dragging then
		local x, y = gui.MousePos()
		xDeg = xDeg + (self.dragX - x)
		yDeg = yDeg + (self.dragY - y)

		self.dragX = x
		self.dragY = y
	end

	yDeg = ClampAngle(yDeg, -90, 16)
	RotateBehindTarget()
	local rotation = rotation_ang

	local vTargetOffset = self:GetCamPos()
    local position = -(rotation:Forward() * self:GetLookDist() + vTargetOffset) 

    angles = rotation

	cam.Start3D(position, angles, self:GetFOV(), x, y, w, h, 5, self.FarZ )
		render.SuppressEngineLighting( true )
		render.SetLightingOrigin( self.Entity:GetPos() )
		render.ResetModelLighting( self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255 )
		render.SetColorModulation( self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255 )
		render.SetBlend( ( self:GetAlpha() / 255 ) * ( self.colColor.a / 255 )  * surface.GetAlphaMultiplier()) -- * surface.GetAlphaMultiplier()

		if self:GetDrawFloor() then
			render.SetMaterial(radial)
			render.DrawQuadEasy(vecUp, vecUp, 1024, 1024, radial_clr, 0)
			render.DrawQuadEasy(vecUp, vecUp, 196, 196, floorColors[1], 0)
			
			render.DrawQuadEasy(vecUp, vecUp, 64, 64, floorColors[2], 0)
			render.DrawQuadEasy(vecUp, vecUp, 32, 32, floorColors[3], 0)
		end
		
		render.ResetModelLighting(0.25, 0.25, 0.25)
		render.SetLocalModelLights(tabs)
		self:DrawModel()
		render.SuppressEngineLighting(false)
	cam.End3D()

	self.LastPaint = RealTime()
end

function PANEL:RunAnimation()
	self.Entity:FrameAdvance( ( RealTime() - self.LastPaint ) * self.m_fAnimSpeed )
end

function PANEL:DragMousePress()
	self.dragX, self.dragY = gui.MousePos()
	self.dragging = true

	if self.isTabFrame then
		self.isTabFrame:OnFocusChanged(true)
	end
end

function PANEL:DragMouseRelease() 
	self.dragging = false
end

function PANEL:LayoutEntity(Entity)
	self:RunAnimation()
end

function PANEL:OnRemove()
	if IsValid(self.Entity) then
		self.Entity:Remove()
	end
end
vgui.Register("ui.character.model", PANEL, "DButton")


do
	surface.CreateFont("char.create.title", {
		font = "Blender Pro Book",
		extended = true,
		size = Scale(48),
		weight = 500,
		antialias = true,
	})
	surface.CreateFont("char.create.subtitle", {
		font = "Blender Pro Medium",
		extended = true,
		size = Scale(30),
		weight = 500,
		antialias = true,
	})
	surface.CreateFont("char.create.container", {
		font = "Blender Pro Medium",
		extended = true,
		size = Scale(20),
		weight = 500,
		antialias = true,
	})
	surface.CreateFont("char.create.text", {
		font = "Blender Pro Book",
		extended = true,
		size = Scale(19),
		weight = 500,
		antialias = true,
	})
	surface.CreateFont("char.create.button", {
		font = "Blender Pro Book",
		extended = true,
		size = Scale(30),
		weight = 500,
		antialias = true,
	})
end

local PANEL = {}
function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)
	self:SetText("")
	self:SetCursor("hand")

	self.padding = Scale(5)

	self:Dock(TOP)
	self:DockPadding(self.padding, 0, 0, 0)

	self.title = self:Add("DLabel")
	self.title:SetFont("char.create.container")
	self.title:SetTextColor(ColorAlpha(color_white, 255 * 0.5))
	self.title:Dock(LEFT)

	self.value = self:Add("DLabel")
	self.value:SetFont("char.create.container")
	self.value:SetTextColor(ColorAlpha(color_white, 255))
	self.value:Dock(FILL)

	self:SetAlpha(255 * 0.5)

	self.format = nil
	self.max_width = 0
	self.entered = false
end

function PANEL:OnCursorEntered()
	if self:GetDisabled() then return end
	
	self:AlphaTo(255, 0.25, 0)
	self.entered = true
end
function PANEL:OnCursorExited()
	if self:GetDisabled() then return end

	self:AlphaTo(255 * 0.5, 0.25, 0)
	self.entered = false
end

function PANEL:SetTitle(title)
	self.title:SetText(title)
	self.title:SizeToContents()

	self.max_width = self.title:GetWide() + self.value:GetWide()

	self:InvalidateLayout( true )
	self:SizeToChildren( false, true )
end

function PANEL:SetValue(value, format)
	self.format = format and format or self.format

	self.var = value
	self.value:SetText(self.format and string.format(self.format, value) or value)
	self.value:SizeToContents()

	self.max_width = self.title:GetWide() + self.value:GetWide()

	self:InvalidateLayout(true)
	self:SizeToChildren(false, true)
end

function PANEL:GetValue(value)
	return self.var
end

function PANEL:DoClick()
	if self:GetDisabled() then return end

	local menu = ix.SimpleMenu()

	if self.CreateMenu then
		self.CreateMenu(self, menu)
	end

	menu:Open()
end

function PANEL:SetValueColor(clr)
	self.value:SetTextColor(clr)
end

function PANEL:Paint(w, h) 
	if self.entered then
		DisableClipping(true)
			surface.SetDrawColor(ColorAlpha(color_white, self:GetAlpha()))
			surface.DrawRect(self.padding, h, self.max_width, 1)
		DisableClipping(false)
	end
end

vgui.Register("ui.character.selector", PANEL, "DLabel")

local PANEL = {}
function PANEL:Init()
	self:SetFont("char.create.button")
	self:SetTextColor(color_white)
	self:SetPaintBackground(false)

	self.entered = false
	self.currentAlpha = 0.5
	self:SetAlpha(255 * 0.5)
end

function PANEL:OnCursorEntered()
	if self:GetDisabled() then return end
	
	self.entered = true
	self:CreateAnimation(0.25, {
		target = {currentAlpha = 1},
		Think = function(animation, panel)
			panel:SetAlpha(255 * panel.currentAlpha)
		end
	})

	LocalPlayer():EmitSound("Helix.Rollover")
end

function PANEL:OnCursorExited()
	if self:GetDisabled() then return end

	self.entered = false
	self:CreateAnimation(0.25, {
		target = {currentAlpha = 0.5},
		Think = function(animation, panel)
			panel:SetAlpha(255 * panel.currentAlpha)
		end
	})
end

function PANEL:OnMousePressed(code)
	if self:GetDisabled() then
		return
	end

	LocalPlayer():EmitSound("Helix.Press")

	if code == MOUSE_LEFT and self.DoClick then
		self:DoClick(self)
	elseif code == MOUSE_RIGHT and self.DoRightClick then
		self:DoRightClick(self)
	end
end

function PANEL:Paint(w, h) 
	if self.entered then
		DisableClipping(true)
			surface.SetDrawColor(ColorAlpha(color_white, 255 * self.currentAlpha))
			surface.DrawRect(0, h, w, 2)
		DisableClipping(false)
	end
end

vgui.Register("ui.character.button", PANEL, "DButton")

local EyeColors = {
	{"eyes1", Color(15, 178, 242)},
	{"eyes2", Color(67, 117, 18)},
	{"eyes3", Color(128, 72, 28)},
	{"eyes4", Color(189, 149, 102)},
	{"eyes5", Color(232, 162, 21)},
	{"eyes6", Color(128, 128, 128)}
}

local HairColors = {
	{"hair1", Color(102, 58, 23)},
	{"hair2", Color(254, 229, 126)},
	{"hair3", Color(16, 16, 16)},
	{"hair4", Color(200, 48, 0)},
	{"hair5", Color(160, 120, 85)},
	{"hair6", Color(255, 96, 0)},
	{"hair7", Color(128, 128, 128)},
	{"hair8", color_white},
	{"hair9", color_white},
}

local BodyShapes = {
	[1] = {"shape1_1", "shape1_2", "shape1_3", "shape1_4", "shape1_5"}, -- skinny
	[2] = {"shape2_1", "shape2_2", "shape2_3", "shape2_4", "shape2_5"}, -- slender
	[3] = {"shape3_1", "shape3_2", "shape3_3", "shape3_4", "shape3_5"}, -- average
	[4] = {"shape4_1", "shape4_2", "shape4_3", "shape4_4", "shape4_5"}, -- large
}

DEFINE_BASECLASS("ixCharMenuPanel")

local gradient = Material("vgui/gradient-u")
local vignette = Material("helix/gui/vignette.png", "smooth")

local Scale = ix.UI.Scale
local Payload = class("CharacterPayload")

function Payload:Init()
	self.genders = {true, true}
	self.data = {
		faction = 0,
		name = "",
		description = "",
		model = 0,
		gender = 1,
		genetic = {},
		specials = {
			["st"] = 0,
			["ag"] = 0,
			["en"] = 0,
			["in"] = 0,
			["pe"] = 0,
			["lk"] = 0
		},
		primaryStat = {},
		languages = {},
		face = {1, 1}
	}
end

function Payload:Set(id, value)
	self.data[id] = value
end

function Payload:Get(id)
	return self.data[id]
end

surface.CreateFont("attribute.slider", {
	font = "Blender Pro Medium",
	extended = true,
	size = Scale(64),
	weight = 500,
	antialias = true,
})

surface.CreateFont("attribute.title", {
	font = "Blender Pro Medium",
	extended = true,
	size = Scale(32),
	weight = 500,
	antialias = true,
})

surface.CreateFont("attribute.desc", {
	font = "Blender Pro Book",
	extended = true,
	size = Scale(19),
	weight = 500,
	antialias = true,
})

surface.CreateFont("attribute.slider.fx", {
	font = "autonomous-extra",
	extended = true,
	size = Scale(35),
	weight = 1000,
	antialias = true,
})

surface.CreateFont("attribute.maxpoints", {
	font = "Blender Pro Medium",
	extended = true,
	size = Scale(80),
	weight = 500,
	antialias = true,
})

surface.CreateFont("attribute.star", {
	font = "autonomous-star",
	extended = true,
	size = Scale(32),
	weight = 500,
	antialias = true,
})

local PANEL = {}

function PANEL:Init()
	self.container = self:Add("Panel")
end

function PANEL:AddLabel(content, font, clr)
	local text = self.container:Add("DLabel")
	text:Dock(TOP)
	text:SetFont(font or "cmb.terminal.light30")
	text:SetText(content)
	text:SetContentAlignment(5)
	text:SizeToContents()
	text:SetTextColor(clr or ix.Palette.combineblue)

	self.container:InvalidateLayout(true)
	self.container:SizeToChildren(false, true)

	return text
end

function PANEL:PerformLayout(w)
	self.container:SetWide(w)
	self.container:Center()
end

vgui.Register("attribute.frame.info", PANEL, "Panel")

local PANEL = {}
PANEL.style = {
	checked = ix.Palette.combinegreen,
	notcheck = ix.Palette.combineblue
}
function PANEL:Init()
	self:SetFont("attribute.star")
	self:SetText("A")


	self:SetChecked(false)
end

function PANEL:SetChecked(value)
	self.checked = value
	self:SetAlpha(value and (255 * 0.5) or 30)

	self.currentAlpha = self:GetAlpha()

	self:SetTextColor(value and self.style.checked or self.style.notcheck)
	self:SetText(self.checked and "B" or "A")
end

function PANEL:OnCursorEntered()
	if self:GetDisabled() then return end

	self.entered = true

	self:CreateAnimation(0.25, {
		target = {currentAlpha = 255},
		Think = function(animation, panel)
			panel:SetAlpha(panel.currentAlpha)
		end
	})

	LocalPlayer():EmitSound("Helix.Rollover")
end

function PANEL:OnCursorExited()
	if self:GetDisabled() then return end

	self.entered = false

	self:CreateAnimation(0.25, {
		target = {currentAlpha = (self.checked and (255 * 0.5) or 30)},
		Think = function(animation, panel)
			panel:SetAlpha(panel.currentAlpha)
		end
	})
end

function PANEL:SetDisabled(bDisabled)
	self.m_bDisabled = bDisabled

	if bDisabled then
		self:SetAlpha(25)
		self:SetMouseInputEnabled(false)
	else
		self:SetAlpha(self.entered and 255 or (self.checked and (255 * 0.5) or 30))
		self:SetMouseInputEnabled(true)
	end
end

function PANEL:OnMousePressed(code)
	if self:GetDisabled() then return end

	LocalPlayer():EmitSound("Helix.Press")

	if code == MOUSE_LEFT then
		local bool = !self.checked

		if self:OnChanged(bool) != false then
			self:SetChecked(bool)
		end
	end
end

function PANEL:OnChanged() end
function PANEL:Paint() end

vgui.Register("attribute.star.button", PANEL, "DButton")

local PANEL = {}
PANEL.style = {
	hover = ix.Palette.combinegreen,
	normal = ix.Palette.combinegreen
}
function PANEL:Init()
	self:SetFont("attribute.slider.fx")

	self:SetAlpha(255 * 0.5)
	self.currentAlpha = 0.5

	self:SetTextColor(self.style.normal)
end

function PANEL:OnCursorEntered()
	if self:GetDisabled() then return end

	self.entered = true

	self:CreateAnimation(0.25, {
		target = {currentAlpha = 1},
		Think = function(animation, panel)
			panel:SetAlpha(255 * panel.currentAlpha)
		end
	})

	self:SetTextColor(self.style.hover)

	LocalPlayer():EmitSound("Helix.Rollover")
end

function PANEL:OnCursorExited()
	if self:GetDisabled() then return end

	self.entered = false

	self:CreateAnimation(0.25, {
		target = {currentAlpha = 0.5},
		Think = function(animation, panel)
			panel:SetAlpha(255 * panel.currentAlpha)
		end
	})

	self:SetTextColor(self.style.normal)
end

function PANEL:SetDisabled(bDisabled)
	self.m_bDisabled = bDisabled

	if bDisabled then
		self:StopAnimations(true)

		self:SetAlpha(25)
		self:SetMouseInputEnabled(false)
	else
		self:SetAlpha(self.entered and 255 or 255 * 0.5)
		self:SetMouseInputEnabled(true)
	end
end

function PANEL:OnMousePressed(code)
	if self:GetDisabled() then return end

	LocalPlayer():EmitSound("Helix.Press")

	if code == MOUSE_LEFT and self.DoClick then
		self:DoClick(self)
	end
end

function PANEL:Paint() end

vgui.Register("attribute.slider.button", PANEL, "DButton")

local PANEL = {}
function PANEL:Init()
	local buttonW = Scale(45)
	local textW = Scale(100)

	local plus = self:Add("attribute.slider.button")
	plus:SetText("B")
	plus:SetWide(buttonW)
	plus:Dock(RIGHT)
	plus.DoClick = function(this)
		self.delta = 1
		self:DoChange()
	end

	local minus = self:Add("attribute.slider.button")
	minus:SetText("A")
	minus:SetWide(buttonW)
	minus:Dock(LEFT)
	minus.DoClick = function(this)
		self.delta = -1
		self:DoChange()
	end

	local text = self:Add("DLabel")
	text:SetFont("attribute.slider")
	text:SetText("1")
	text:SetTextColor(ix.Palette.combinegreen)
	text:SizeToContents()
	text:SetContentAlignment(5)
	text:Dock(FILL)

	self:SetSize(textW + buttonW * 2, Scale(100))

	self.min = 1
	self.max = 100
	self.delta = 0
	self.value = 0
	self.text = text
	self.plus = plus
	self.minus = minus
end

function PANEL:SetMax(value) self.max = value end
function PANEL:SetMin(value) self.min = value end

function PANEL:SetValue(value, updateText)
	value = math.Clamp(value, self.min, self.max)

	if updateText then
		self.text:SetText(value)
	end
	self.value = value
end

function PANEL:GetValue()
	return self.value
end

function PANEL:DoChange()
	if ((self.value == self.min and self.delta == -1) or (self.value == self.max and self.delta == 1)) then
		return
	end

	if self:OnChanged(self.delta) != false then
		self:SetValue(self.value + self.delta)
	end
end

function PANEL:OnChanged(difference) end

vgui.Register("ui.attribute.slider", PANEL, "EditablePanel")

surface.CreateFont("gender.selector.fx", {
	font = "autonomous-gender",
	extended = true,
	size = Scale(72),
	weight = 500,
	antialias = true,
})

local PANEL = {}

AccessorFunc(PANEL, "selected_color", "SelectedColor", FORCE_COLOR)
AccessorFunc(PANEL, "unselected_color", "UnselectedColor", FORCE_COLOR)

function PANEL:Init()
	self:SetFont("gender.selector.fx")
	self:SetActive(false)
end

function PANEL:SetActive(active)
	self.active = active

	local fracAlpha = self.active and 0.8 or 0.25

	self:SetTextColor(active and self.selected_color or self.unselected_color)
	self:SetAlpha(255 * fracAlpha)
	self.currentAlpha = fracAlpha
end

function PANEL:OnCursorEntered()
	if self:GetDisabled() then return end

	self.entered = true

	self:CreateAnimation(0.25, {
		target = {currentAlpha = 1},
		Think = function(animation, panel)
			panel:SetAlpha(255 * panel.currentAlpha)
		end
	})

	self:SetTextColor(self.selected_color)

	LocalPlayer():EmitSound("Helix.Rollover")
end

function PANEL:OnCursorExited()
	if self:GetDisabled() then return end

	self.entered = false

	local targetAlpha = self.active and 0.8 or 0.25

	self:CreateAnimation(0.25, {
		target = {currentAlpha = targetAlpha},
		Think = function(animation, panel)
			panel:SetAlpha(255 * panel.currentAlpha)
		end
	})

	self:SetTextColor(self.active and self.selected_color or self.unselected_color)
end

function PANEL:SetDisabled(bDisabled)
	self.m_bDisabled = bDisabled

	if bDisabled then
		self:SetAlpha(25)
		self:SetMouseInputEnabled(false)
	else
		self:SetAlpha(self.entered and 255 or 255 * 0.5)
		self:SetMouseInputEnabled(true)
	end
end

function PANEL:OnMousePressed(code)
	if self:GetDisabled() then return end

	LocalPlayer():EmitSound("Helix.Press")

	if code == MOUSE_LEFT and self.DoClick then
		self:DoClick(self)
	end
end

function PANEL:Paint() end

vgui.Register("gender.button", PANEL, "DButton")


DEFINE_BASECLASS("ixCharMenuPanel")

local PANEL = {}
PANEL.clr = {
	title = Color(0, 190, 255, 64)
}

local factionsTest = {
	[1] = {
		icon = Material("autonomous/factions/citizen.png"),
		title = "ГРАЖДАНИН",
		desc = "Fusce rhoncus vehicula consectetur. Cras sed libero eget lectus faucibus porta. Praesent auctor pharetra mauris, vehicula aliquam lorem convallis eu. Proin finibus pretium pellentesque. Mauris at dignissim turpis. Phasellus tempor ligula ex, at placerat ante porta ut. Maecenas nec dolor auctor, facilisis turpis et, dignissim urna. Phasellus lacinia accumsan lorem. Phasellus ultrices metus nec elementum fermentum. Sed quis interdum turpis. Fusce mauris justo, vestibulum dignissim varius at, tincidunt vel neque. Praesent non nulla ac erat vehicula blandit eget ut erat. Nulla vehicula imperdiet nisl."
	},
	[2] = {
		icon = Material("autonomous/factions/cca.png"),
		title = "ГРАЖДАНСКАЯ ОБОРОНА",
		desc = "Fusce rhoncus vehicula consectetur. Cras sed libero eget lectus faucibus porta. Praesent auctor pharetra mauris, vehicula aliquam lorem convallis eu. Proin finibus pretium pellentesque. Mauris at dignissim turpis. Phasellus tempor ligula ex, at placerat ante porta ut. Maecenas nec dolor auctor, facilisis turpis et, dignissim urna. Phasellus lacinia accumsan lorem. Phasellus ultrices metus nec elementum fermentum. Sed quis interdum turpis. Fusce mauris justo, vestibulum dignissim varius at, tincidunt vel neque. Praesent non nulla ac erat vehicula blandit eget ut erat. Nulla vehicula imperdiet nisl."
	},
	[3] = {
		icon = Material("autonomous/factions/vortigaunt.png"),
		title = "ВОРТИГОНТ",
		desc = "Fusce rhoncus vehicula consectetur. Cras sed libero eget lectus faucibus porta. Praesent auctor pharetra mauris, vehicula aliquam lorem convallis eu. Proin finibus pretium pellentesque. Mauris at dignissim turpis. Phasellus tempor ligula ex, at placerat ante porta ut. Maecenas nec dolor auctor, facilisis turpis et, dignissim urna. Phasellus lacinia accumsan lorem. Phasellus ultrices metus nec elementum fermentum. Sed quis interdum turpis. Fusce mauris justo, vestibulum dignissim varius at, tincidunt vel neque. Praesent non nulla ac erat vehicula blandit eget ut erat. Nulla vehicula imperdiet nisl."
	},
	[4] = {
		icon = Material("autonomous/factions/conscripts_africa.png"),
		title = "РЕЗЕРВ АРМИИ НАДЗОРА",
		desc = [[Армия Надзора — военная структура Альянса, созданная незадолго после завершения Семичасовой войны на основе миротворческих войск ООН, НАТО и ОДКБ. Следуя стандартным армейским практикам, Надзор активно использует земную военную технику. Основной задачей армии Надзора считается гарантии безопасности, стабильности - и восстановления планеты Земля под контролем Альянса.

Служба в армии Надзора является добровольной, но весьма прибыльной. Для обычных граждан - это способ выжить, получить лучший паек и заработав большие деньги продвинутся по социальной лестнице. Для лоялистов же - это престижная запись в личном деле.]]
	},
}

surface.CreateFont("char.create.factionTitle", {
	font = "Blender Pro Book",
	extended = true,
	size = Scale(30),
	weight = 500,
	antialias = true,
})
surface.CreateFont("char.create.factionDesc", {
	font = "Blender Pro Book",
	extended = true,
	size = Scale(21),
	weight = 500,
	antialias = true,
})

function PANEL:CreateFactionStage()
	local w, h = ScrW(), ScrH()
	local factionSizeW, factionSizeH = Scale(500) * 0.8, Scale(833) * 0.8
	local infoBlockH = Scale(256)
	local factionBG = Material("autonomous/charcreate/faction_bg.png")

	self.factionPanel = self:AddSubpanel("selectFaction", true)
	self.factionPanel:SetSize(w, h)
	self.factionPanel:SetTitle(nil)
	self.factionPanel.OnSetActive = function()
		-- if we only have one faction, we are always selecting that one so we can skip to the description section
		--if (#self.factionButtons == 1) then
		--	self:SetActiveSubpanel("description", 0)
		--end
	end
	self.factionPanel.Paint = function(_, w, h)
		ix.DX.DrawMaterial(0, 0, 0, w, h, color_white, factionBG)
	end

	local padding = Scale(24)
	local title = self.factionPanel:Add("DLabel")
	title:SetFont("char.create.title")
	title:SetTextColor(self.clr.title)
	title:SetContentAlignment(6)
	title:SetText("ПРИНАДЛЕЖНОСТЬ  /// СОЗДАНИЕ ПЕРСОНАЖА")
	title:SizeToContents()
	title:AlignRight(padding)
	title:AlignTop(padding)


	local factionName = self.factionPanel:Add("DLabel")
	local factionInfoOffset = Scale(32)
	factionName:SetFont("char.create.factionTitle")
	factionName:SetTextColor(ix.Palette.combineblue:Alpha(225))
	factionName:SetContentAlignment(5)
	factionName:SetText("ГРАЖДАНИН")
	factionName:SizeToContents()
	factionName:Center()

	local offset = Scale(64)
	local panelWidth = 4 * factionSizeW + ((4 - 1) * offset)

	local panelLoad = self:Add("Panel")
	panelLoad:SetSize(panelWidth, factionSizeH + infoBlockH)
	panelLoad:Center()
	panelLoad:SetY(padding * 2.5 + title:GetTall())


	self.factionPanelList = panelLoad:Add("Panel")
	self.factionPanelList:SetSize(panelLoad:GetWide(), factionSizeH)

	self.factionPanelList:Center()
	local x, y = self.factionPanelList:GetPos()
	self.factionPanelList:SetPos(x, 0)

	self.factionPanelInfo = panelLoad:Add("Panel")
	self.factionPanelInfo:SetSize(panelLoad:GetWide() - offset, infoBlockH)
	self.factionPanelInfo:MoveBelow(self.factionPanelList, 0)
	self.factionPanelInfo:SetX(offset)

	local maxDescWidth = panelLoad:GetWide() - offset

	local function UpdateFactionInfo(info)
		factionName:SetVisible(true)
		self.factionPanelInfo:SetVisible(true)

		factionName:SetText(info.name:utf8upper())
		factionName:SizeToContents()
		factionName:CenterHorizontal()

		self.factionPanelInfo.text = ix.markup.Parse([[<font=char.create.factionDesc><color=150,214,248>]]..info.info..[[</color></font>]], maxDescWidth * 0.9)
	end

	local function HideFactionInfo()
		factionName:SetVisible(false)
		self.factionPanelInfo:SetVisible(false)
	end

	
	factionName:MoveBelow(panelLoad, -infoBlockH + factionInfoOffset * 2)

	self.factionPanelInfo.Paint = function(this, w, h)
		if this.text then
			this.text:draw(w / 2, factionName:GetTall() + factionInfoOffset * 3, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 150)
		end
	end

	local i = 0
	for _, info in SortedPairs(ix.faction.teams) do
		if !info.showCreationMenu then continue end

		local disable = !ix.faction.HasWhitelist(info.index)
	--for i = 1, #factionsTest do
		local panel = self.factionPanelList:Add("DButton")
		panel:Dock(LEFT)
		panel:SetText("")
		panel:SetAlpha(0)
		panel.index = info.index
		panel.currentAlpha = 0
		panel.showBorder = false
		panel.borderClr = disable and ix.Palette.combinered:Alpha(255) or ix.Palette.autonomousblue:Alpha(255)
		panel.hoverClr = disable and Color(40, 5, 5) or Color(0, 15, 80)
		panel:DockMargin(0, 0, offset, 0)
		panel:SetSize(factionSizeW, factionSizeH)
		panel.Paint = function(self, w, h)
			local ft = FrameTime()

			ix.DX.DrawMaterial(0, 0, 0, w, h, color_white, info.icon)

			self.hoverAlpha = math.Approach((self.hoverAlpha or 0), self.hovered and 1 or 0, ft * 5)
			local hoverAlpha = math.ease.OutCubic(self.hoverAlpha)

			self.hoverClr.a = 100 - (100 * self.hoverAlpha)

			ix.DX.Draw(0, 0, 0, w, h, self.hoverClr)

			self.borderClr.a = 64 + (190 * self.hoverAlpha)
			surface.SetDrawColor(self.borderClr)
			surface.DrawOutlinedRect(0, 0, w, h)
		end
		panel.OnCursorEntered = function(self)
			local faction = ix.faction.indices[self.index]

			UpdateFactionInfo(faction)

			self.hovered = true
		end
		panel.OnCursorExited = function(self)
			HideFactionInfo()

			self.hovered = false
		end

		panel.DoClick = function(this)
			if disable then
				return
			end
			
			ix.CharacterPayload:Set("faction", this.index)

			self.updateFactionVisual = true
			self:SetActiveSubpanel("selectModel")
		end

		panel:CreateAnimation(1 + (0.5 * i), {
			index = 1,
			target = {currentAlpha = 255},
			easing = "inOutBounce",

			Think = function(animation, panel)
				panel:SetAlpha(panel.currentAlpha)
			end,

			OnComplete = function(animation, panel)
				panel.showBorder = true
			end
		})

		i = i + 1
	end

	local parent = self:GetParent()
	local padding = Scale(80)

	panelLoad:InvalidateLayout(true)
	local back = panelLoad:Add("ui.character.button")
	back:SetText(L"charcreate_back")
	back:SizeToContents()

	local x, y = panelLoad:GetPos()
	back:AlignLeft(padding - x)
	back:AlignBottom(padding - y / 2.5)
	back.DoClick = function()
		parent.mainPanel:Undim()
	end
end

function PANEL:CreateVisualStage(container)
	local w, h = ScrW(), ScrH()

	self.view = container:Add("ui.character.model")
	self.view:SetPos(0, 0)
	self.view:SetSize(w, h)
	self.view.PaintOver = function(this, w, h)
		surface.SetDrawColor(0, 0, 0)
		surface.SetMaterial(vignette)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	self.SetModel = function(this, model)
		self.view:SetModel(model)
	end

	local padding = Scale(24)
	local title = container:Add("DLabel")
	title:SetFont("char.create.title")
	title:SetTextColor(self.clr.title)
	title:SetContentAlignment(6)
	title:SetText("ВНЕШНОСТЬ  /// СОЗДАНИЕ ПЕРСОНАЖА")
	title:SizeToContents()
	title:AlignRight(padding)
	title:AlignTop(padding)

	self.container_width = Scale(400)

	local padding_x = Scale(40)
	local padding_y = Scale(138)

	container.left = container:Add("DLabel")
	container.left:SetFont("char.create.subtitle")
	container.left:SetTextColor(ColorAlpha(color_white, 255 * 0.25))
	container.left:SetText(L"charcreate_left")
	container.left:SizeToContents()
	container.left:AlignLeft(padding_x)
	container.left:AlignTop(padding_y)

	container.right = container:Add("DLabel")
	container.right:SetFont("char.create.subtitle")
	container.right:SetTextColor(ColorAlpha(color_white, 255 * 0.25))
	container.right:SetText(L"charcreate_right")
	container.right:SizeToContents()
	container.right:AlignRight(padding_x)
	container.right:AlignTop(padding_y)

	container.last_left = container.left
	container.last_right = container.right

	container.containers = {
		[1] = {},
		[2] = {}
	}

	self:CreateContainer(1, L"charcreate_name", function(container)
		local entry = container:Add("DTextEntry")
		entry:Dock(TOP)
		entry:DockMargin(0, Scale(8), 0, 0)
		entry:SetFont("char.create.text")
		entry:SetTextColor(ColorAlpha(color_white, 255 * 0.5))
		entry:SetPaintBackground(false)
		entry:SetTall(Scale(32))
		entry.OnChange = function(this)
			ix.CharacterPayload:Set("name", this:GetValue())
		end
		entry.Paint = function(this, w, h)
			surface.SetDrawColor(0, 0, 0, 255 * 0.5)
			surface.DrawRect(0, 0, w, h)

			this:DrawTextEntryText(this:GetTextColor(), this:GetHighlightColor(), color_white)
		end

		self.SetCharName = function(this, value)
			ix.CharacterPayload:Set("name", value)

			entry:SetValue(value)
		end

		local randomize = container:Add("ui.character.selector")
		randomize:SetTitle(L"charcreate_random")
		randomize:SetValue(0, "")
		randomize.DoClick = function()
			local gender = ix.CharacterPayload:Get("gender")
			local factionID = ix.CharacterPayload:Get("faction")
			local faction = ix.faction.indices[factionID]
			local result = ""

			if faction.RandomizeName then
				result = faction:RandomizeName(LocalPlayer(), gender)
			else
				local name = ""

				if gender == 1 then
					name = ix.NameData.Male[math.random(#ix.NameData.Male)]
				else
					name = ix.NameData.Female[math.random(#ix.NameData.Female)]
				end

				local lastname = ix.NameData.Last[math.random(#ix.NameData.Male)]
				result = name:utf8sub(1, 1)..name:utf8sub(2):utf8lower().." "..lastname:utf8sub(1, 1)..lastname:utf8sub(2):utf8lower()
			end
			
			self:SetCharName(result)
		end
	end)

	self:CreateContainer(1, L"charcreate_visual", function(container)
		local entry = container:Add("DTextEntry")
		entry:Dock(TOP)
		entry:DockMargin(0, Scale(8), 0, 0)
		entry:SetFont("char.create.text")
		entry:SetTall(Scale(150))
		entry:SetTextColor(ColorAlpha(color_white, 255 * 0.5))
		entry:SetPaintBackground(false)
		entry:SetMultiline(true)
		entry.OnChange = function(this)
			ix.CharacterPayload:Set("description", this:GetValue())
		end
		entry.Paint = function(this, w, h)
			surface.SetDrawColor(0, 0, 0, 255 * 0.5)
			surface.DrawRect(0, 0, w, h)

			this:DrawTextEntryText(this:GetTextColor(), this:GetHighlightColor(), color_white)
		end

		self.SetCharDesc = function(this, value)
			ix.CharacterPayload:Set("description", value)
			
			entry:SetValue(value)
		end
	end)

	self:CreateContainer(1, L"charcreate_phys", function(container)
		container.title:DockMargin(0, 0, 0, Scale(18))

		local age = container:Add("ui.character.selector")
		age:SetTitle(L"char_age")
		age.CreateMenu = function(this, menu)
			local factionID = ix.CharacterPayload:Get("faction")
			local faction = ix.faction.indices[factionID]

			if faction.ageSelector then
				for k, v in ipairs(faction.ageSelector) do
					local title = L(v)

					menu:AddOption(title, function()
						self:SetAge(k, title)
					end)
				end
			else
				local value = vgui.Create("DNumberWang", menu)
				value:SetMin(18)
				value:SetMax(60)
				value:SetValue(this:GetValue())
				value.OnValueChanged = function(this)
					self:SetAge(this:GetValue())
				end

				menu:AddPanel(value)
			end
		end

		self.RandomizeAge = function(this)
			local factionID = ix.CharacterPayload:Get("faction")
			local faction = ix.faction.indices[factionID]

			if faction.ageSelector then
				local id = math.random(#faction.ageSelector)

				this:SetAge(id, L(faction.ageSelector[id]))
			else
				this:SetAge(math.random(18, 60))
			end
		end
		
		self.SetAge = function(this, value, title)
			age:SetValue(title and title:utf8upper() or value)

			local genetics = ix.CharacterPayload:Get("genetic")
			genetics[3] = value

			ix.CharacterPayload:Set("genetic", genetics)
		end

		local height = container:Add("ui.character.selector")
		height:SetTitle(L"char_height")
		height:SetValue(0, "%s см")
		height.CreateMenu = function(this, menu)
			local value = vgui.Create("DNumberWang", menu)
			value:SetMin(155)
			value:SetMax(190)
			value:SetValue(this:GetValue())
			value.OnValueChanged = function(this)
				self:SetPhysHeight(this:GetValue())
			end

			menu:AddPanel(value)
		end

		self.SetPhysHeight = function(this, value)
			height:SetValue(value)

			local genetics = ix.CharacterPayload:Get("genetic")
			genetics[2] = value

			ix.CharacterPayload:Set("genetic", genetics)
		end

		local eyes = container:Add("ui.character.selector")
		eyes:SetTitle(L"char_eye")
		eyes:SetValue("")
		eyes:SetValueColor(Color(64, 64, 255))
		eyes.CreateMenu = function(this, menu)
			local factionID = ix.CharacterPayload:Get("faction")
			local faction = ix.faction.indices[factionID]

			for k, v in ipairs(faction.eyeColors and faction.eyeColors or EyeColors) do
				local title = L(v[1])

				menu:AddOption(title, function()
					self:SetEyes(k, title, v[2])
				end)
			end
		end

		self.RandomizeEyes = function(this)
			local factionID = ix.CharacterPayload:Get("faction")
			local faction = ix.faction.indices[factionID]

			local eyes = faction.eyeColors and faction.eyeColors or EyeColors

			local id = math.random(#eyes)

			this:SetEyes(id, L(eyes[id][1]), eyes[id][2])
		end

		self.SetEyes = function(this, value, title, color)
			eyes:SetValue(title:utf8upper())
			eyes:SetValueColor(color)

			local genetics = ix.CharacterPayload:Get("genetic")
			genetics[4] = value

			ix.CharacterPayload:Set("genetic", genetics)
		end

		local shape = container:Add("ui.character.selector")
		shape:SetTitle(L"char_shape")
		shape.CreateMenu = function(this, menu)
			local shape_types = {"shape1", "shape2", "shape3", "shape4"}

			for z, v in ipairs(BodyShapes) do
				local sub = menu:AddSubMenu(L(shape_types[z]))

				for k, v in ipairs(v) do
					sub:AddOption(L(v), function()
						self:SetBodyShape(z, k)
					end)
				end
			end
		end

		self.SetBodyShape = function(this, category, value)
			local data = BodyShapes[category]
			local frac = 192 * (value / 4)

			shape:SetValue(L(data[value]):utf8upper())
			shape:SetValueColor(Color(63 + frac, 63 + frac, 63 + frac))

			local genetics = ix.CharacterPayload:Get("genetic")
			genetics[1] = (category - 1) * 5 + value

			ix.CharacterPayload:Set("genetic", genetics)
		end
	end)

	self:CreateContainer(1, L"charcreate_secondary", function(container)
		container.title:DockMargin(0, 0, 0, Scale(18))

		local languages = {}

		for k, v in pairs(ix.languages.stored) do
			if v.notSelectable then continue end
			
			languages[#languages + 1] = {icon = v.icon, text = v.name, value = v.uniqueID}
		end

		table.SortByMember(languages, "text", true)

		local lang = container:Add("ui.character.selector")
		lang:SetTitle(L"char_lang")
		lang.CreateMenu = function(this, menu)
			for k, v in ipairs(languages) do
				local btn = menu:AddOption(v.text, function()
					self:SetKnownLanguage(v.value, v.text)
				end)
				btn:SetImage(v.icon)
			end
		end

		self.RandomizeLang = function(this)
			local id = math.random(#languages)

			this:SetKnownLanguage(languages[id].value, languages[id].text)
		end

		self.SetKnownLanguage = function(this, value, title)
			lang:SetValue(title:utf8upper())
			
			ix.CharacterPayload:Set("languages", {value})
		end
	end)

	self:CreateContainer(2, L"charcreate_type", function(container)
		container.title:DockMargin(0, 0, 0, Scale(18))

		local size = Scale(72)

		local panel = container:Add("EditablePanel")
		panel:Dock(TOP)
		panel:SetTall(size)
		
		local gendersButtons = {}

		local body2 = panel:Add("gender.button")
		body2:Dock(RIGHT)
		body2:SetSelectedColor(Color(248, 56, 100))
		body2:SetUnselectedColor(Color(200, 56, 56))
		body2:DockMargin(size * 0.24, 0, 0, 0)
		body2:SetSize(size)
		body2:SetText("B")
		body2.DoClick = function(this)
			self:SelectGender(2)
		end

		local body1 = panel:Add("gender.button")
		body1:SetSelectedColor(Color(56, 248, 232))
		body1:SetUnselectedColor(Color(56, 200, 200))
		body1:Dock(RIGHT)
		body1:SetSize(size)
		body1:SetText("A")
		body1.DoClick = function(this)
			self:SelectGender(1)
		end

		gendersButtons[1] = body1
		gendersButtons[2] = body2

		ix.CharacterPayload.genders = {true, true}

		self.UpdateAvailableGenders = function(this)
			local factionID = ix.CharacterPayload:Get("faction")
			local faction = ix.faction.indices[factionID]

			if faction.genders then
				for k, v in ipairs(gendersButtons) do
					genders[v]:SetVisible(false)

					ix.CharacterPayload.genders[v] = false
				end
			else
				body1:SetVisible(true)
				body2:SetVisible(true)

				ix.CharacterPayload.genders = {true, true}
			end
		end

		self.SelectGender = function(this, type)
			local factionID = ix.CharacterPayload:Get("faction")
			local faction = ix.faction.indices[factionID]

			local models = faction:GetModels(LocalPlayer(), type)
			local model = table.KeyFromValue(models, models[math.random(#models)])

			ix.CharacterPayload:Set("gender", type)
			ix.CharacterPayload:Set("model", model)

			self:SetModel(models[model])
			self:UpdateAvailableModels(faction, type)

			for k, v in pairs(gendersButtons) do
				v:SetActive(k == type)
			end
		end
	end)

	self:CreateContainer(2, L"charcreate_model", function(container)
		container.title:DockMargin(0, 0, 0, Scale(18))

		local scroller = container:Add("DHorizontalScroller")
		scroller:Dock(TOP)
		scroller:SetTall(64)
		scroller:SetOverlap(-4)
		scroller:DockMargin(0, 0, 0, Scale(18))
		
		local faceClr = Color(32, 225, 255)
		local face = container:Add("ui.character.selector")
		face:SetTitle("ЛИЦО: ")
		face:SetValue(1)
		face:SetValueColor(faceClr)

		local hair = container:Add("ui.character.selector")
		hair:SetTitle("ВОЛОСЫ: ")
		hair:SetValue(1)
		hair:SetValueColor(faceClr)
		
		self.UpdateAvailableModels = function(this, faction, gender)
			scroller:Clear()

			local models = faction:GetModels(LocalPlayer(), gender)

			for k, v in SortedPairs(models) do
				local icon = scroller:Add("SpawnIcon")
				icon:SetSize(64, 64)
				icon:InvalidateLayout(true)
				icon.DoClick = function(this)
					local faceInfo = AutonomousFaceList[v]

					if faceInfo then
						local faceType, hairType = faceInfo[1], faceInfo[2]
						local faceMapCount = AutonomousTextureMaps[faceType] and #AutonomousTextureMaps[faceType] or -1
						local hairMapCount = AutonomousTextureMaps[hairType] and #AutonomousTextureMaps[hairType] or -1

						face.CreateMenu = function(this, menu)
							for i = 1, faceMapCount do
								menu:AddOption(tostring(i), function()
									this:SetValue(i)

									if self.view.Entity.MorphData then
										self.view.Entity.MorphData.face = i
									end

									local customize = ix.CharacterPayload:Get("face")
									customize[1] = i
									ix.CharacterPayload:Set("face", customize)
								end)
							end
						end

						hair.CreateMenu = function(this, menu)
							for i = 1, hairMapCount do
								menu:AddOption(tostring(i), function()
									this:SetValue(i)

									if self.view.Entity.MorphData then
										self.view.Entity.MorphData.hair = i
									end

									local customize = ix.CharacterPayload:Get("face")
									customize[2] = i
									ix.CharacterPayload:Set("face", customize)
								end)
							end
						end
					end

					face:SetValue(1)
					hair:SetValue(1)
					ix.CharacterPayload:Set("face", {1, 1})
					ix.CharacterPayload:Set("model", k)
					
					self:SetModel(v)
				end
				icon.PaintOver = function(this, w, h)
					if ix.CharacterPayload:Get("model") == k then
						local color = color_white

						surface.SetDrawColor(color.r, color.g, color.b, 200)

						for i = 1, 3 do
							local i2 = i * 2
							surface.DrawOutlinedRect(i, i, w - i2, h - i2)
						end
					end
				end

				if isstring(v) then
					icon:SetModel(v)
				else
					icon:SetModel(v[1], v[2] or 0, v[3])
				end

				scroller:AddPanel(icon)
			end
		end
	end)

	local parent = self:GetParent()
	local padding = Scale(80)

	local back = container:Add("ui.character.button")
	back:SetText(L"charcreate_back")
	back:SizeToContents()
	back:AlignLeft(padding)
	back:AlignBottom(padding)
	back.DoClick = function()
		self:SetActiveSubpanel("selectFaction")
	end

	local proceed = container:Add("ui.character.button")
	proceed:SetText(L"charcreate_next")
	proceed:SizeToContents()
	proceed:AlignRight(padding)
	proceed:AlignBottom(padding)
	proceed.DoClick = function()
		self:SetActiveSubpanel("selectSkills")
	end

	-- setup character creation hooks
	net.Receive("ixCharacterAuthed", function()
		timer.Remove("ixCharacterCreateTimeout")
		self.awaitingResponse = false

		local id = net.ReadUInt(32)
		local indices = net.ReadUInt(6)
		local charList = {}

		for _ = 1, indices do
			charList[#charList + 1] = net.ReadUInt(32)
		end

		ix.characters = charList

		if (!IsValid(self) or !IsValid(parent)) then
			return
		end

		if (LocalPlayer():GetCharacter()) then
			parent.mainPanel:Undim()
			parent:ShowNotice(2, L("charCreated"))
		elseif (id) then
			self.bMenuShouldClose = true

			net.Start("ixCharacterChoose")
				net.WriteUInt(id, 32)
			net.SendToServer()
		else
			parent.mainPanel:Undim()
		end
	end)

	net.Receive("ixCharacterAuthFailed", function()
		timer.Remove("ixCharacterCreateTimeout")
		self.awaitingResponse = false

		local fault = net.ReadString()
		local args = net.ReadTable()

		parent:ShowNotice(3, L(fault or "unknownError", unpack(args)))
	end)
end

function PANEL:SendPayload()
	for k, v in SortedPairsByMemberValue(ix.char.vars, "index") do
		local value = ix.CharacterPayload:Get(k)

		if !v.bNoDisplay or v.OnValidate then
			if v.OnValidate then
				local result = {v:OnValidate(value, ix.CharacterPayload.data, LocalPlayer())}

				if result[1] == false then
					self:GetParent():ShowNotice(3, L(result[2] or "unknownError", result[3]))
					return false
				end
			end
		end
	end

	if self.awaitingResponse then
		return
	end

	self.awaitingResponse = true

	timer.Create("ixCharacterCreateTimeout", 10, 1, function()
		if IsValid(self) and self.awaitingResponse then
			local parent = self:GetParent()

			self.awaitingResponse = false
			
			parent.mainPanel:Undim()
			parent:ShowNotice(3, L("unknownError"))
		end
	end)
	
	net.Start("ixCharacterCreate")
		net.WriteUInt(table.Count(ix.CharacterPayload.data), 8)

		for k, v in pairs(ix.CharacterPayload.data) do
			net.WriteString(k)
			net.WriteType(v)
		end
	net.SendToServer()
end

function PANEL:PrepareVisualStage()
	self:UpdateAvailableGenders()

	local genderCount = 0
	local availableGender = 0
	for k, v in ipairs(ix.CharacterPayload.genders) do
		if v then
			availableGender = v
			genderCount = genderCount + 1
		end
	end

	if genderCount > 1 then
		self:SelectGender(math.random(1, 2))
	else
		self:SelectGender(availableGender)
	end

	self:RandomizeAge()
	self:SetPhysHeight(math.random(155, 190))
	self:RandomizeEyes()
	self:SetBodyShape(math.random(1, 4), math.random(1, 5))
	self:RandomizeLang()
end

function PANEL:CreateContainer(side, title, callback)
	local stage2 = self.visualPanel

	local padding_x = Scale(40)
	local padding_y = #stage2.containers[side] < 1 and Scale(40) or Scale(25)

	local container = stage2:Add("EditablePanel")
	container:SetWide(self.container_width)
	container:SetTall(100)

	local text = container:Add("DLabel")
	text:SetFont("char.create.container")
	text:SetTextColor(ColorAlpha(color_white, 255 * 0.5))
	text:SetText(title or "TITLE")
	text:Dock(TOP)
	text:SizeToContents()

	container.title = text

	if callback then
		callback(container)
	end
	
	container:InvalidateLayout(true)
	container:SizeToChildren(false, true)

	stage2.containers[side][#stage2.containers[side] + 1] = container

	if side == 1 then
		container:MoveLeftOf(stage2.left, -container:GetWide() - padding_x)
		container:MoveBelow(stage2.last_left, padding_y)

		stage2.last_left = container
	else
		text:SetContentAlignment(9)
		container:MoveRightOf(stage2.right, -container:GetWide(),  padding_x)
		container:MoveBelow(stage2.last_right, padding_y)

		stage2.last_right = container
	end
end

local STAT_SECONDARY_COST = 4

local ValueChangeException = ix.meta.ValueChangeException
local AddValueModifier = ix.meta.AddValueModifier
local ValueModifier  = ix.meta.ValueModifier
local AddStatModifier = class("AddStatModifier"):implements("ValueModifier")

function AddStatModifier:Init(order, primary, refundCallback)
	ValueModifier.Init(self, order)

	self.isPrimary = primary
	self.callback = refundCallback
end

function AddStatModifier:Modify(fromValue, toValue)
	if !self.isPrimary then
		local spend = (toValue - fromValue)
		local refund = (spend % STAT_SECONDARY_COST)

		self.callback(refund)
	end
	
	return self.isPrimary and toValue or (fromValue + math.floor((toValue - fromValue) / 4))
end

function PANEL:CreateSkillsStage()
	local w, h = ScrW(), ScrH()
	local factionSizeW, factionSizeH = Scale(500) * 0.8, Scale(833) * 0.8
	local infoBlockH = Scale(256)
	local statBG = Material("autonomous/charcreate/stat_bg.png")

	self.skillsPanel = self:AddSubpanel("selectSkills", true)
	self.skillsPanel:SetSize(w, h)
	self.skillsPanel:SetTitle(nil)
	self.skillsPanel.OnSetActive = function()
		-- if we only have one faction, we are always selecting that one so we can skip to the description section
		--if (#self.factionButtons == 1) then
		--	self:SetActiveSubpanel("description", 0)
		--end
	end
	self.skillsPanel.Paint = function(_, w, h)
		ix.DX.DrawMaterial(0, 0, 0, w, h, color_white, statBG)
	end

	local padding = Scale(24)
	local title = self.skillsPanel:Add("DLabel")
	title:SetFont("char.create.title")
	title:SetTextColor(self.clr.title)
	title:SetContentAlignment(6)
	title:SetText("ХАРАКТЕРИСТИКИ  /// СОЗДАНИЕ ПЕРСОНАЖА")
	title:SizeToContents()
	title:AlignRight(padding)
	title:AlignTop(padding)

	local pointFrame = self.skillsPanel:Add("attribute.frame.info")
	pointFrame:SetSize(Scale(300), h)
	pointFrame:AddLabel("ДОСТУПНО", "char.create.button", ix.Palette.combineblue)
	local PointsLabel = pointFrame:AddLabel("0", "attribute.maxpoints", ix.Palette.combineyellow)
	pointFrame:AddLabel("СВОБОДНЫХ ОЧКОВ", "char.create.button", ix.Palette.combineyellow)
	pointFrame:AlignLeft(Scale(80))

	local focusFrame = self.skillsPanel:Add("attribute.frame.info")
	focusFrame:SetSize(Scale(300), h)
	focusFrame:AddLabel("ВЫБЕРИТЕ", "char.create.button", ix.Palette.combineblue)
	local PrimaryLabel = focusFrame:AddLabel("", "attribute.maxpoints", ix.Palette.combineyellow)
	local primaryAtt = focusFrame:AddLabel("ОСНОВНЫХ АТРИБУТА", "char.create.button", ix.Palette.combineyellow)
	primaryAtt:SetAutonomousTooltip(function(tooltip)
		tooltip:SetTitle("ОСНОВНОЙ АТРИБУТ")
		tooltip:AddSmallText("ХАРАКТЕРИСТИКА ПЕРСОНАЖА")
		tooltip:AddDivider()

		tooltip:AddMarkup([[<font=autonomous.hint.info><colour=210,240,250>Влияет на стоимость повышения характеристики персонажа. Основная характеристика повышается без штрафов, в то время как стоимость остальных характеристик будет составлять 4 очка.</colour></font>]])		
	end)
	focusFrame:AlignRight(Scale(80))

	local attributes = self.skillsPanel:Add("EditablePanel")
	attributes:SetWide(h * 0.8)

	local availablePrimaryStats = 2
	local availablePoints = hook.Run("GetDefaultSpecialPoints", LocalPlayer(), ix.CharacterPayload.data)
	PointsLabel.Think = function(this)
		if this:GetText() != tostring(availablePoints) then
			this:SetText(availablePoints)
		end
	end
	PrimaryLabel.Think = function(this)
		if this:GetText() != tostring(availablePrimaryStats) then
			this:SetText(availablePrimaryStats)
		end
	end

	local specials = {}
	local primaryStats = {}

	for k, v in SortedPairsByMemberValue(ix.specials.list, "weight") do
		local primary = AddStatModifier:New(1, false, function(val)
			availablePoints = availablePoints + val

			local stat = specials[k]
			stat.spendPoints._toAdd = stat.spendPoints._toAdd - val

			local payloadSpecials = ix.CharacterPayload:Get("specials")
			payloadSpecials[k] = stat.spendPoints._toAdd
			ix.CharacterPayload:Set("specials", payloadSpecials)
		end)

		local exception = ValueChangeException:New(1, 1)
		exception.stat = k
		exception.spendPoints = AddValueModifier:New(0, 0)
		exception.primary = primary

		exception:AddModifier(exception.spendPoints)
		exception:AddModifier(exception.primary)

		specials[k] = exception

		local panel = attributes:Add("Panel")
		panel:Dock(TOP)
		panel:SetTall(100)
		panel:DockMargin(0, 0, 0, 2)

		local selector = panel:Add("ui.attribute.slider")
		selector:Dock(LEFT)
		selector:SetValue(exception:GetModifiedValue(),true)
		selector:DockMargin(0, (panel:GetTall() - selector:GetTall())/ 2, 0, (panel:GetTall() - selector:GetTall()) / 2)
		selector.OnChanged = function(this, difference)
			local stat = specials[k]
			local value = stat.spendPoints._toAdd
			local price = stat.primary.isPrimary and 1 or STAT_SECONDARY_COST
			local spend = (price * difference)

			if (value + spend) < 0 then
				return false
			end

			if (availablePoints - spend) < 0 then
				return false
			end

			availablePoints = availablePoints - spend
			stat.spendPoints._toAdd = stat.spendPoints._toAdd + spend

			this.text:SetText(stat:GetModifiedValue())

			local payloadSpecials = ix.CharacterPayload:Get("specials")
			payloadSpecials[k] = stat.spendPoints._toAdd
			ix.CharacterPayload:Set("specials", payloadSpecials)
		end
		selector.Think = function(this)
			local stat = specials[k]
			local value = stat.spendPoints._toAdd
			local isDisabled = this.minus:GetDisabled()

			if value <= 0 and !isDisabled then
				this.minus:SetDisabled(true)
			elseif value > 0 and isDisabled then
				this.minus:SetDisabled(false)
			end
		end

		selector.minus:SetDisabled(true)

		local fav = panel:Add("attribute.star.button")
		fav:DockMargin(0, 0, 0, 0)
		fav:SetWide(Scale(64))
		fav:Dock(RIGHT)
		fav.OnChanged = function(this, bool)
			if bool then
				if (availablePrimaryStats - 1) < 0 then
					return false
				end

				table.insert(primaryStats, k)
			else
				for z, v in ipairs(primaryStats) do
					if v == k then
						table.remove(primaryStats, z)
					end
				end
			end

			local stat = specials[k]
			stat.primary.isPrimary = bool

			local modified = stat:GetModifiedValue()
			selector.value = modified
			selector.text:SetText(modified)

			availablePrimaryStats = 2 - #primaryStats

			local payloadPrimaryStats = {}
			for k, v in ipairs(primaryStats) do
				payloadPrimaryStats[v] = true
			end

			ix.CharacterPayload:Set("primaryStat", payloadPrimaryStats)
		end

		local name = panel:Add("DLabel")
		name:SetFont("attribute.title")
		name:SetTextColor(ix.Palette.combineblue:Alpha(255))
		name:Dock(TOP)
		name:SetContentAlignment(1)
		name:DockMargin(padding, padding * 0.25, 0, 0)
		name:SetText(L(v.name):utf8upper())
		name:SizeToContentsX()
		name:SetTall(panel:GetTall() * 0.4)
		name:SetAutonomousTooltip(function(tooltip)
			tooltip:SetTitle(name:GetText())
			tooltip:AddSmallText("ХАРАКТЕРИСТИКА ПЕРСОНАЖА")
			tooltip:AddDivider()

			if v.Tooltip then
				v.Tooltip(v, tooltip)
			end
		end)

		local descMarkup
		local desc = panel:Add("Panel")
		desc:Dock(FILL)
		desc:DockMargin(padding, 0, padding, 0)
		desc.PerformLayout = function(this, w, h)
			descMarkup = ix.markup.Parse([[<font=attribute.desc><color=150,214,248>]]..L(v.description)..[[</color></font>]], w)
		end
		desc:InvalidateLayout(true)
		desc.Paint = function(_, w, h)
			if descMarkup then
				descMarkup:draw(0, 0, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 150)
			end
		end
	end

	attributes:InvalidateLayout(true)
	attributes:SizeToChildren(false, true)
	attributes:Center()

	local parent = self:GetParent()
	local padding = Scale(80)

	local back = self.skillsPanel:Add("ui.character.button")
	back:SetText(L"charcreate_back")
	back:SizeToContents()
	back:AlignLeft(padding)
	back:AlignBottom(padding)
	back.DoClick = function()
		self:SetActiveSubpanel("selectModel")
	end

	local proceed = self.skillsPanel:Add("ui.character.button")
	proceed:SetText(L"charcreate_apply")
	proceed:SizeToContents()
	proceed:AlignRight(padding)
	proceed:AlignBottom(padding)
	proceed.DoClick = function()
		self:SendPayload()
	end
end

function PANEL:Init()
	ix.CharacterPayload = Payload:New()

	local w, h = ScrW(), ScrH()

	self.fadeColor = Color(0, 0, 0, 255)

	self:CreateFactionStage()

	-- STAGE 2
	self.visualPanel = self:AddSubpanel("selectModel", true)
	self.visualPanel:SetSize(w, h)
	self.visualPanel:SetTitle(nil)
	self.visualPanel.OnSetActive = function(this)
		if self.updateFactionVisual then
			self:PrepareVisualStage()

			self.updateFactionVisual = nil
		end
	end
	self.visualPanel.Paint = function(_, w, h)
		surface.SetDrawColor(radial_clr)
		surface.DrawRect(0, 0, w, h)
	end

	-- STAGE 3
	self:CreateSkillsStage()
	self:CreateVisualStage(self.visualPanel)

	self:SetActiveSubpanel("selectFaction", 0)

	self.currentSubFade = 0
end

function PANEL:AddSubpanel(name)
	local id = #self.subpanels + 1
	local panel = self:Add("ixSubpanel")
	panel.subpanelName = name
	panel.subpanelID = id
	panel:SetTitle(name)

	self.subpanels[id] = panel
	self:SetupSubpanelReferences()

	panel:SetPos(0, 0)
	panel:SetVisible(false)

	return panel
end

function PANEL:SetActiveSubpanel(id, length)
	if (isstring(id)) then
		for i = 1, #self.subpanels do
			if (self.subpanels[i].subpanelName == id) then
				id = i
				break
			end
		end
	end

	local activePanel = self.subpanels[id]

	if (!activePanel) then
		return false
	end

	if (length == 0 or !self.activeSubpanel) then
		activePanel:SetVisible(true)
	else
 		self.animFraction = 0

 		local lastPanel = self.subpanels[self.activeSubpanel]

 		self:CreateAnimation(0.5, {
			index = 420,
			target = {
				currentFade = 1,
			},
			easing = "outCubic",
			OnComplete = function(anim, self)
				activePanel:SetAlpha(0)
 				activePanel:SetVisible(true)
				lastPanel:SetVisible(false)
				activePanel:SetAlpha(255)
						
				self:CreateAnimation(0.5, {
					index = 421,
					target = {
						currentFade = 0,
					},
					easing = "inCubic",
					OnComplete = function(anim, self)
					end
				})
			end
		})
	end

	self.activeSubpanel = id
	activePanel:OnSetActive()

	return true
end

function PANEL:OnSlideUp()
end

function PANEL:OnSlideDown()
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(16, 32, 48, 255 * 0.9)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(16, 32, 48)
	surface.SetMaterial(gradient)
	surface.DrawTexturedRect(0, 0, w, h / 2)

	BaseClass.Paint(self, w, h)
end

function PANEL:PaintOver(width, height)
	local amount = self.currentFade

	self.fadeColor.a = 255 * amount

	surface.SetDrawColor(self.fadeColor)
	surface.DrawRect(0, 0, width, height)
end


vgui.Register("ui.character.create", PANEL, "ixCharMenuPanel")
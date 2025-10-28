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

vgui.Register("ui.button", PANEL, "DButton")



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
local radial_clr = Color(50, 60, 65)
local bg_clr = Color(40, 44, 42)
local angles = Angle()
local rotation_ang = Angle()
local curAng

local function RotateBehindTarget()
	local targetRotationAngle = LocalPlayer():EyeAngles().y
	local currentRotationAngle = angles.y
	
	local targetAng = quat(Angle(-yDeg, xDeg, 0))
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
			render.SetMaterial( radial ) -- If you use Material, cache it!
			render.DrawQuadEasy( Vector( 0, 0, 1 ), Vector( 0, 0, 1 ), 1024, 1024, radial_clr, 0)
			render.DrawQuadEasy( Vector( 0, 0, 1 ), Vector( 0, 0, 1 ), 196, 196, Color(142, 156, 160, 100), 0)
			
			render.DrawQuadEasy( Vector( 0, 0, 1 ), Vector( 0, 0, 1 ), 64, 64, Color(30, 40, 45, 255), 0)
			render.DrawQuadEasy( Vector( 0, 0, 1 ), Vector( 0, 0, 1 ), 32, 32, Color(0, 0, 0, 128), 0)
		end
		
		render.ResetModelLighting(0.25, 0.25, 0.25)
			render.SetLocalModelLights(tabs)
			self:DrawModel()
		render.SuppressEngineLighting( false )
	cam.End3D()

	self.LastPaint = RealTime()
end

function PANEL:RunAnimation()
	self.Entity:FrameAdvance( ( RealTime() - self.LastPaint ) * self.m_fAnimSpeed )
end

function PANEL:DragMousePress()
	self.dragX, self.dragY = gui.MousePos()
	self.dragging = true
/*
	if self.isTabFrame then
		self.isTabFrame:OnFocusChanged(true)
	end
*/
end

function PANEL:DragMouseRelease() 
	self.dragging = false
end

function PANEL:LayoutEntity(Entity)
	/*
	Entity:SetBodygroup(5, 6)
	Entity:SetBodygroup(6, 2)
	Entity:SetBodygroup(8, 1)
*/
	self:RunAnimation()
end

function PANEL:OnRemove()
	if IsValid(self.Entity) then
		self.Entity:Remove()
	end
end
vgui.Register("ui.character.model", PANEL, "DButton")
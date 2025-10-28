local frameInterval = 60
local BLEEDING_DISTANCE = 2048 ^ 2
local bleedingPlayers = {}

function PLUGIN:Think()
	self.coroutine = self.coroutine and coroutine.status(self.coroutine) != "dead" and self.coroutine or coroutine.create(function()
		while (true) do
			bleedingPlayers = {}

			local origin = LocalPlayer():EyePos()
			local PVS = NikNaks.CurrentMap:PVSForOrigin(origin)

			for _, client in ipairs(player.GetAll()) do
				local pos = client:GetPos()
				local isVisibleInPVS = (PVS and PVS:TestPosition(pos))
				local isEnoughDistance = (pos:DistToSqr(origin) <= BLEEDING_DISTANCE)

				if isEnoughDistance and isVisibleInPVS then
					if client:GetNetVar("isBleeding") and client:Alive() then
						bleedingPlayers[#bleedingPlayers + 1] = client
					end
				end
			end

			coroutine.yield()
		end
	end)

	if (FrameNumber() % frameInterval != 0) then return end
	local succ, err = coroutine.resume(self.coroutine)

	if (succ) then return end

	ErrorNoHalt(err)
end

do
	local EFFECT = {}
	local gravity = Vector(0, 0, -500)

	local function ParticleCollides(particle, position, normal)
		if !particle.Painted then
			if particle.Entity and IsValid(particle.Entity) and particle.Entity == LocalPlayer() then
				if position:IsEqualTol(LocalPlayer():GetPos(), 16) then
					return
				end
			end
			
			if math.random() <= 0.005 then
				util.Decal("Blood", position + normal, position - normal, particle.Entity)
			end

			particle.Painted = true
		end
	end

	function EFFECT:Init(data)
		local pos = data:GetOrigin()
		local ang = data:GetAngles()
		self.Entity = data:GetEntity()
		self.Emitter = ParticleEmitter(pos)

		local lcol = render.GetLightColor(pos) * 255
		lcol.r = math.Clamp(lcol.r, 50, 150)

		for i = 1, 5 do
			local smoke = self.Emitter:Add("particle/smokesprites_000"..math.random(1,6), pos + VectorRand()*2)
			smoke:SetVelocity(ang:Up())
			smoke:SetDieTime(FrameTime() * 4)
			smoke:SetStartAlpha(math.random(200,255))
			smoke:SetStartSize(math.random(5,10))
			smoke:SetEndSize(0)
			smoke:SetColor(255, 0, 0)
			smoke:SetGravity(vector_origin)
		end

		for i = 1, 5 do
			local smoke = self.Emitter:Add("effects/blooddrop", pos + VectorRand()*2)
			smoke:SetVelocity((ang:Up()*-math.Rand(.5, 1) + ang:Forward()*math.Rand(-1, 1) + ang:Right()*math.Rand(-1, 1)) * 15)
			smoke:SetDieTime(math.Rand(.8, .12))
			smoke:SetStartSize(1)
			smoke:SetEndSize(3)
			smoke:SetColor(255, 0, 0)
			smoke:SetGravity(gravity)
			smoke.Entity = self.Entity
			smoke:SetCollideCallback(ParticleCollides)
			smoke:SetCollide(true)
		end

		self.Emitter:Finish()
	end

	function EFFECT:Think()
		return false
	end

	function EFFECT:Render()
	end

	effects.Register(EFFECT, "bleeding")
end

local offset = Vector(0,0,32)
function PLUGIN:DrawBleeding()
	if !bleedingPlayers or #bleedingPlayers <= 0 then
		return
	end
	
	for _, v in ipairs(bleedingPlayers) do
		if !IsValid(v) then continue end

		local doll = v:GetNetVar("doll") and Entity(v:GetNetVar("doll"))
		doll = IsValid(doll) and doll or nil

		local object = v:GetNetVar("doll") and doll or v
		local boneID = v:LookupBone("ValveBiped.Bip01_Spine1")
		if !object or !boneID then continue end

		local pos, ang = object:GetBonePosition(boneID)
		local effectData = EffectData()
			effectData:SetEntity(v)
			effectData:SetOrigin(pos or (v:GetPos() + offset))
			effectData:SetAngles(ang or angle_zero)
		util.Effect("bleeding", effectData, true, true)
	end
end

do
	local oldST
	local targetAng = Angle()
	function PLUGIN:CalcView(client, origin, angles, fov)
		if !IsValid(client) then return end

		local character = client:GetCharacter()

		if !character or client:GetLocalVar("ragdoll", 0) != 0 then
			return
		end

		local health = character:Health()
		local pain = health:GetPain()

		if pain <= 0 then return end

		pain = pain * 0.2

		local delta
		local st = SysTime()

		oldST = oldST or st
		delta = math.min(st - oldST, FrameTime(), 1 / 30)
		oldST = st

		local mulRand = math.Clamp((1 - pain) - 0.3, 0, 1)
		local rand = 15 * mulRand 

		targetAng = LerpAngle(delta * (10 + (20 * pain)), targetAng, Angle(math.Rand(-rand, rand), math.Rand(-rand, rand), 0))
		targetAng.r = 0

		local eyeAngle = client:EyeAngles()
		eyeAngle = LerpAngle(delta * (10 * pain), eyeAngle, eyeAngle + targetAng)
		eyeAngle.r = 0
		
		client:SetEyeAngles(eyeAngle)
	end
end

do
	local modify = {
		["$pp_colour_addr"] = 0, 
		["$pp_colour_addg"] = 0, 
		["$pp_colour_addb"] = 0, 
		["$pp_colour_brightness"] = 0, 
		["$pp_colour_contrast"] = 1, 
		["$pp_colour_colour"] = 1, 
		["$pp_colour_mulr"] = 0, 
		["$pp_colour_mulg"] = 0, 
		["$pp_colour_mulb"] = 0
	}

	local oldST, dmg
	dmg = 0

	function PLUGIN:RenderScreenspaceEffects()
		local character = LocalPlayer():GetCharacter()

		if character then
			local health = character:Health()
			local hp = health:GetPercent()

			if hp < 1 then
				local deltaX = 0.25 + (hp * 0.75)
				local st = SysTime()

				oldST = oldST or st
				local delta = st - oldST
				oldST = st
				
				modify["$pp_colour_colour"] = math.Clamp(deltaX, 0, 1)

				DrawColorModify(modify)
			end
			
			DrawBloom(0.2, dmg, 6, 16, 1, 0, 1, 1, 1)

			if dmg > 0 then
				dmg = Lerp(delta * 10, dmg, 0)
			end
		end
	end

	net.Receive("shock.pain", function()
		local data = net.ReadUInt(3) or 1
		dmg = dmg + data
	end)
end

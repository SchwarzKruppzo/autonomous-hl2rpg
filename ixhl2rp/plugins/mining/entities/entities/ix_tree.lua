AddCSLuaFile()
DEFINE_BASECLASS("base_anim")

ENT.Type = "anim"
ENT.Author = "Schwarz Kruppzo"

ENT.PrintName = "Tree Trunk"
ENT.RespawnTime = 3600

ENT.Category = "HL2 RP Mining"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar("Vector", 0, "HitPos")
	self:NetworkVar("Bool", 0, "Depleted")
end

ENT.BreakSounds = {
	"physics/wood/wood_panel_break1.wav", 
	"physics/wood/wood_plank_break3.wav", 
	"physics/wood/wood_plank_break4.wav", 
	"physics/wood/wood_box_break2.wav"
}

ENT.Points = {
	[1] = {
		Vector(24.260132,4.976410,15.518555),
		Vector(16.178589,7.316711,12.886719),
		Vector(10.947571,2.581238,17.590820),
		Vector(-0.807495,6.777344,13.845703),
		Vector(33.227966,7.382111,12.459961),
		Vector(-2.056030,3.244873,17.927734),
		Vector(-11.678894,-9.324341,15.923828),
		Vector(0.912659,-5.347626,18.254883),
		Vector(11.309387,-8.596130,15.592773),
		Vector(-8.535767,-3.644897,19.312500)
	}
}

ENT.DepletedTypes = {
	"models/autonomous/tree_trunk.mdl"
}

if SERVER then
	function ENT:Initialize()
		self:SetModel("models/autonomous/tree_trunk.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
		
		self.hitPoint = 1
		self.oreValue = 100
		self.depletedType = 1
		self.boost = 1

		self:RandomizePoint(true)
		self:SetDepleted(false)

	end

	function ENT:SwitchType(type)
		if self.depletedType == type then
			return
		end
		
		self.depletedType = type
		self:EmitSound("physics/wood/wood_box_break2.wav")

		self.boost = 1
		self:RandomizePoint()

		if self.depletedType == 4 then
			self.respawn = CurTime() + self.RespawnTime

			self:SetDepleted(true)
		end
	end
	
	function ENT:TakeOre(value)
		local newValue = (self.oreValue + value)

		if newValue <= 0 then
			self:SwitchType(4)
		elseif newValue < 50 then
			self:SwitchType(3)
		elseif newValue < 75 then
			self:SwitchType(2)
		end

		self.oreValue = newValue
	end

	function ENT:RandomizePoint(random)
		if self.depletedType == 4 then
			self:SetHitPos(vector_origin)
			return
		end
		
		local points = self.Points[1]
		local nextPoint = self.hitPoint + 1

		self.hitPoint = random and math.random(1, #points) or (points[nextPoint] and nextPoint or 1)

		local pos = points[self.hitPoint]
		pos = pos + (1 * VectorRand())

		self:SetHitPos(pos)
	end

	function ENT:AddStack(client, item, stack)
		item:SetData("stack", stack)

		local inventory = client:GetInventory("main")
		local x, y, need_rotation = inventory:FindPosition(item, item.width, item.height)

		if !x or !y then
			inventory = nil
		end

		if inventory then
			local success, error = inventory:AddItem(item, x, y)

			inventory:Sync()

			return success, error
		end
	end

	function ENT:OnTakeDamage(damageInfo)
		local client = damageInfo:GetAttacker()

		if IsValid(client) and client:IsPlayer() then
			local activeWeapon = tostring(client:GetActiveWeapon())

			if string.find(activeWeapon, "tfa_nmrih_hatchet") or string.find(activeWeapon, "tfa_nmrih_machete") then
				local activeWeapon = client:GetActiveWeapon()
				local dmg = damageInfo:GetDamage()
				local isPower = dmg >= activeWeapon.Secondary.Damage

				self:EmitSound(self.BreakSounds[math.random(1, #self.BreakSounds)])

				if self.depletedType < 4 then
					local item = activeWeapon.ixItem

					if IsValid(activeWeapon) and item then
						if item:GetData("durability", 4) <= 0 then
							client:NotifyLocalized("mining.notify.toolBroken")
							return
						end

						item:AddDurability(-0.1)
					end
					
					self:TakeOre(-1)

					local chance = isPower and 10 or 5
					local damagePos = damageInfo:GetDamagePosition()

					local hitPos = self:GetHitPos()
					hitPos:Rotate(self:GetAngles())
					hitPos = self:GetPos() + hitPos

					if hitPos:IsEqualTol(damagePos, 2.75) then
						local boostFactor = math.Clamp(self.boost, 1, 5)
						chance = chance + (isPower and (7 * boostFactor) or (2 * boostFactor))

						self.boost = self.boost + 1
						self:TakeOre(isPower and -boostFactor or -1)

						self:RandomizePoint()

						net.Start("pickaxe.fx")
							net.WriteVector(damagePos)
							net.WriteVector(client:GetEyeTrace().HitNormal)
						net.SendPVS(hitPos)
					else
						self.boost = 1
					end

					if math.random(1, 100) <= chance then
						client:Emote("it", "woodworkEmote")

						local instance = ix.Item:Instance("mat_wood")

						if !self:AddStack(client, instance, 1) then
							ix.Item:Spawn(client, nil, instance)
						end

						client:RewardXP(5, "xp.gathering")
					end
				else
					client:NotifyLocalized("mining.notify.emptyTree")
				end
			end
		end
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_PVS
	end

	function ENT:RespawnVein()
		self.hitPoint = 1
		self.oreValue = 100
		self.depletedType = 1
		self.boost = 1

		self:RandomizePoint(true)
		self:SetDepleted(false)
	end

	function ENT:Think()
		local CT = CurTime()

		if self.respawn and self.respawn < CT then
			self.respawn = nil

			self:RespawnVein()
		end

		self:NextThink(CT + 1)
	end
else
	local flare = Material("sprites/orangeflare1_gmod")
	local clr = Color(200, 200, 50, 255)

	function ENT:Initialize()
		self.pixvis = util.GetPixelVisibleHandle()
	end
	
	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:DrawTranslucent()
		local client = LocalPlayer()
		local distance = client:GetPos():DistToSqr(self:GetPos())

		if distance >= 44100 then return end

		local isDepleted = self:GetDepleted()

		if isDepleted then return end

		local pos = self:GetHitPos()
		pos:Rotate(self:GetAngles())
		pos = self:GetPos() + pos

		local visible = util.PixelVisible(pos, 4, self.pixvis)	

		if visible <= 0.5 then return end
		
		cam.IgnoreZ(true)

		local cos = math.sin(SysTime() * 4)
		local size = 12 + cos
		
		render.SetMaterial(flare)
		render.DrawSprite(pos, size * visible, size * visible, clr)

		cam.IgnoreZ(false)
	end
end


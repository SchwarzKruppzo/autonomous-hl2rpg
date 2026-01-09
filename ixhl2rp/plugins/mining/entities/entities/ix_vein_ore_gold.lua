AddCSLuaFile()
DEFINE_BASECLASS("base_anim")

ENT.Type = "anim"
ENT.Author = "Schwarz Kruppzo"

ENT.PrintName = "Gold Vein"
ENT.RespawnTime = 3600 * 2.5

ENT.Category = "HL2 RP Mining"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar("Vector", 0, "HitPos")
end

ENT.BreakSounds = {
	"physics/concrete/boulder_impact_hard1.wav", 
	"physics/concrete/boulder_impact_hard2.wav", 
	"physics/concrete/boulder_impact_hard3.wav", 
	"physics/concrete/boulder_impact_hard4.wav"
}

ENT.Points = {
	[1] = {
		Vector(19.261597, -12.829742, 25.946289),
		Vector(21.484192,1.764740,25.450195),
		Vector(19.259949,-5.287109,32.746094),
		Vector(20.301208,7.191620,38.464844),
		Vector(16.824463,-6.809296,41.730469),
		Vector(11.225708,-1.965302,55.140625),
		Vector(20.881287,-3.428864,26.762695),
		Vector(13.258240,16.223999,23.089844),
		Vector(14.293274,13.061005,46.010742),
		Vector(9.904419,5.747986,55.095703),
		Vector(21.932983,-5.220673,17.441406),
		Vector(17.205200,-2.878448,43.577148)
	},
	[2] = {
		Vector(19.11138,-12.940857,24.791016),
		Vector(19.507141,2.275818,26.558594),
		Vector(11.614685,-12.106354,34.903320),
		Vector(13.790710,5.812500,39.707031),
		Vector(14.113525,15.268433,32.358398),
		Vector(22.466492,4.645081,10.267578),
		Vector(5.672363,-4.330688,41.847656),
		Vector(21.703369,-6.768372,18.327148)
	},
	[3] = {
		Vector(20.484436,1.825073,12.435547),
		Vector(17.613647,-12.829163,17.894531),
		Vector(13.744751,2.851318,20.766602),
		Vector(7.920776,-13.222748,22.430664),
		Vector(15.374023,-6.544983,20.267578),
		Vector(8.035217,12.637512,19.974609),
		Vector(4.184387,0.716370,23.538086),
		Vector(-1.505859,-11.275024,24.325195),
		Vector(-9.059692,8.709229,19.958984),
		Vector(12.683167,-5.952209,21.977539)
	}
}

ENT.DepletedTypes = {
	"models/autonomous/mining/vein_ore01.mdl",
	"models/autonomous/mining/vein_ore02.mdl",
	"models/autonomous/mining/vein_ore03.mdl",
	"models/autonomous/mining/vein_ore04.mdl"
}

if SERVER then
	util.AddNetworkString("pickaxe.fx")

	function ENT:Initialize()
		self:SetModel("models/autonomous/mining/vein_ore01.mdl")
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
		self:SetSkin(3)
	end

	function ENT:SwitchType(type)
		if self.depletedType == type then
			return
		end
		
		self.depletedType = type
		self:SetModel(self.DepletedTypes[type])

		self:EmitSound("physics/concrete/concrete_break2.wav")

		self.boost = 1
		self:RandomizePoint()

		if self.depletedType == 4 then
			self.respawn = CurTime() + self.RespawnTime
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
		
		local points = self.Points[self.depletedType]
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

			if string.find(activeWeapon, "tfa_nmrih_pickaxe") then
				local activeWeapon = client:GetActiveWeapon()
				local dmg = damageInfo:GetDamage()
				local isPower = dmg >= activeWeapon.Secondary.Damage

				self:EmitSound(self.BreakSounds[math.random(1, #self.BreakSounds)])

				if self.depletedType < 4 then
					local item = activeWeapon.ixItem

					if IsValid(activeWeapon) and item then
						if item:GetData("durability", 4) <= 0 then
							client:Notify("Кирка сломана и не дает какого-либо результата!")
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
						chance = chance + (isPower and (10 * boostFactor) or (2 * boostFactor))

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
						client:Emote("it", "miningEmote")

						local instance = ix.Item:Instance("mat_ore_gold")

						if !self:AddStack(client, instance, math.random(1, 2)) then
							ix.Item:Spawn(client, nil, instance)
						end

						client:RewardXP(10, "добычу ресурсов")
					end
				else
					client:Notify("Эта жила истощена!")
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

		self:SetModel("models/autonomous/mining/vein_ore01.mdl")
		self:RandomizePoint(true)
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
AddCSLuaFile()

ENT.PrintName = "Recycler"
ENT.Category = "HL2RP Recycler"
ENT.Type = "anim"
ENT.Spawnable = true
ENT.AdminSpawnable = true

sound.Add({
	name = "machine_moving",
	volume = 1.0,
	sound = "ambient/levels/labs/machine_moving_loop4.wav"
})

sound.Add({
	name = "refill_sound",
	volume = 1.0,
	sound = "ambient/water/water_in_boat1.wav"
})

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "RawResource")
	self:NetworkVar("Bool", 1, "Manufacturing")
	self:NetworkVar("Int", 2, "FuelAmount")
	self:NetworkVar("Bool", 3, "Broken")
	self:NetworkVar("Entity", 1, "PlayerUsing")
	self:NetworkVar("String", 0, "Product")
end

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/props_mining/elevator_winch_empty.mdl")
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetTrigger(true)
		
		local vPhys = self:GetPhysicsObject()

		if vPhys:IsValid() then
			vPhys:Wake()
		end

		self:SetFuelAmount(100)
	else
		self.NextSmoke = -1
		self.Emitter = ParticleEmitter(self:GetPos())
		self.EmitterFinished = false
	end
end

local allowedItems = {
	mat_plastic = {
		junk_paintcan = 1,
		junk_vcr = 1,
		junk_monitor = 3,
		junk_keyboard = 1,
		junk_calculator = 1,
		junk_deskfan = 1,
		junk_desklamp = 1,
		junk_plasticcrate = 1,
		junk_plasticbucket = 1,
		empty_plastic_can = 1,
		empty_plastic_bottle = 1,
		empty_jug = 1,
		junk_harddrive = 2,
		junk_tv = 2,
		empty_ration = 1,
		junk_audiosystem = 2,
		junk_geiger = 1,
		junk_gurevich = 1,
		junk_lamp = 2
	},
	metal_reclaimed = {
		junk_axel = 4,
		junk_muffler = 4,
		junk_bicycle = 5,
		junk_engine = 5,
		junk_pot = 1,
		junk_lantern = 1,
		junk_cardoor = 3,
		junk_metalgascan = 2,
		empty_can = 1,
		empty_tin_can = 1,
		junk_propane = 1,
		junk_radiator = 4,
		junk_pipe = 2,
		junk_metalbucket = 1,
		junk_metalpot = 1,
		junk_citizenradio = 1,
		junk_cid = 1,
		junk_metalbucket2 = 2,
		junk_pot2 = 2,
		junk_chair = 3,
		junk_paintcan = 1
	},
	mat_glass = {
		empty_glass_bottle = 2,
	},
	mat_wood = {
		junk_huladoll = 1,
		junk_clock = 1,
		junk_cupboard = 3,
		junk_drawerchunk = 2,
		junk_woodchair = 2,
		junk_clock2 = 1,
		junk_doll = 1,
	},
	mat_resine = {
		junk_tire = 5,
	},
	mat_leather = {
		junk_cwuturtle = 1,
		junk_shoe = 1,
	},
}

local allowedEntities = {
	["ix_item"] = {
		StartTouch = function(factory, entity)
			local itemTable = entity:GetItem()

			if itemTable.isFactoryFuel then
				local currentFuel = factory:GetFuelAmount()

				if currentFuel < 100 then
					factory:SetFuelAmount(100)
					factory:EmitSound("refill_sound")

					timer.Simple(2, function()
						factory:StopSound("refill_sound")
					end)
				end
				
				SafeRemoveEntity(entity) 
			else
				if factory:GetRawResource() >= 5 then return end

				local hasItem
				for product, items in pairs(allowedItems) do
					local has_item = items[itemTable.uniqueID]

					if has_item then
						if (factory:GetProduct() == "") or factory:GetProduct() == product then
							hasItem = has_item
							factory:SetProduct(product)
							break
						end
					end
				end

				if !hasItem then
					return
				end

				factory:SetRawResource(factory:GetRawResource() + hasItem)

				if factory:GetRawResource() >= 5 then
					factory:EmitSound("buttons/button18.wav")
				end

				//eEntity:EmitSound("foley/industrial/dump_resource_machine"..math.random(1, 3)..".mp3")

				SafeRemoveEntity(entity) 
			end
		end
	}
}

if SERVER then
	function ENT:CreateProduct(activator)
		timer.Simple(0.1, function()
			if self:GetProduct() == "" then
				return
			end
			
			local instance = ix.Item:Instance(self:GetProduct())
			local vPos = self:GetPos() + self:GetUp() * 16 + self:GetRight() * -25 + self:GetForward() * -80

			ix.Item:Spawn(vPos, Angle(), instance)

			self:SetProduct("")
		end)

		self:SetRawResource(0)
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_PVS
	end

	function ENT:StartTouch(activator)
		local entity = allowedEntities[activator:GetClass()]
		if !entity then return end

		timer.Simple(0, function() 
			if !IsValid(activator) or !IsValid(self) then return end

			entity.StartTouch(self, activator)
		end)
	end

	function ENT:Think()
		if CLIENT then return end

		if self:GetManufacturing() then
			local eEnt = self:GetPlayerUsing()

			if eEnt and !IsValid(eEnt) then
				self:SetManufacturing(false)
				self:StopSound("machine_moving")

				self:EmitSound("ambient/levels/labs/machine_stop1.wav")
			end
		end

		self:NextThink(CurTime() + 1)

		return true
	end

	function ENT:OnRemove()
		self:StopSound("machine_moving")
	end

	function ENT:Use(activator)
		if self:GetManufacturing() or self:GetBroken() then return end

		if (self.iNextResourceCreation or 0) > CurTime() then return end
		if self:GetRawResource() < 5 then return end

		if self:GetFuelAmount() <= 0 then
			self:EmitSound("ambient/machines/sputter1.wav")
			activator:Notify("В этом переработчике закончилось топливо.")

			self.iNextResourceCreation = CurTime() + 2
			return
		end

		self:SetManufacturing(true)
		self:SetPlayerUsing(activator)

		activator:ForceSequence("Open_door_away")

		timer.Simple(1, function()
			self:EmitSound("machine_moving")
			util.ScreenShake(activator:GetPos(), 5, 5, 4, 62)
		end)

		activator:SetAction("", 25)
		activator:DoStaredAction(self, function()
			self:StopSound("machine_moving")
			self:SetManufacturing(false)
			self:SetPlayerUsing(nil)

			self:CreateProduct(activator)

			local nNewFuelAmount = self:GetFuelAmount() - 10

			self:SetFuelAmount(nNewFuelAmount)
			if nNewFuelAmount <= 0 then
				self:EmitSound("ambient/machines/sputter1.wav")
			end

			self.iNextResourceCreation = CurTime() + 2

			self:EmitSound("ambient/levels/labs/machine_stop1.wav")
			util.ScreenShake(activator:GetPos(), 5, 5, 0.5, 62)
		end, 25, function()
			activator:SetAction()

			if !self:GetManufacturing() then return end

			self:StopSound("machine_moving")
			self:SetManufacturing(false)
			self.iNextResourceCreation = CurTime() + 2
		end)
	end
else
	ENT.PopulateEntityInfo = true

	function ENT:OnPopulateEntityInfo(container)
		local name = container:AddRow("name")
		name:SetImportant()
		name:SetText("Переработчик")
		name:SizeToContents()

		local value = container:AddRow("value")
		value:SetText(string.format("Загруженность %s из 5", self:GetRawResource()))
		value:SetBackgroundColor(derma.GetColor("Info", container))
		value:SizeToContents()

		local productname = self:GetProduct()
		if productname != "" then
			local item = ix.Item:Get(productname)

			if item then
				local product = container:AddRow("product")
				product:SetText(string.format("Перерабатывает в: %s", L(item.name):utf8lower()))
				product:SetBackgroundColor(derma.GetColor("Success", container))
				product:SizeToContents()
			end
		end
	end

	local mGlow = Material("sprites/glow04_noz")

	function ENT:DrawSmokeEffect()
		if !self:GetManufacturing() and IsValid(self.Emitter) then
			self.Emitter:Finish()
		end

		local pos = self:GetPos()
		local up, right, forward = self:GetUp(), self:GetRight(), self:GetForward()
		if self:GetManufacturing() and self.NextSmoke < CurTime() then
			if not IsValid(self.Emitter) then
				self.Emitter = ParticleEmitter(pos)
			end

			self.Emitter:SetPos(pos)
			self.NextSmoke = CurTime() + 1

			local iRandom = math.random( 1, 16 )
			local sSmokeMat = "particle/smokesprites_00" .. (iRandom < 10 and "0" .. iRandom or iRandom)
			local oSmokePos = pos + up * 55 + right * -48 + forward * -80

			local oSmoke = self.Emitter:Add( sSmokeMat, oSmokePos )
			oSmoke:SetVelocity( self:GetVelocity() )
			oSmoke:SetDieTime( 30 )
			oSmoke:SetStartAlpha( 20 )
			oSmoke:SetEndAlpha( 0 )
			oSmoke:SetStartSize( math.Rand( 10, 16 ) )
			oSmoke:SetEndSize( 3 )
			oSmoke:SetGravity( Vector( 0, 0, 10 ) )
			oSmoke:SetColor( 230, 230, 230 )
			oSmoke:SetAirResistance( 100 )
		end
	end

	local colors = {
		[1] = Color(255, 32, 32),
		[2] = Color(255, 225, 32),
		[3] = Color(32, 255, 32)
	}

	function ENT:DrawOnlineEffects()
		//if self:GetBroken() then return end
		local pos = self:GetPos()
		local up, right, forward = self:GetUp(), self:GetRight(), self:GetForward()

		local vFirstSprite = pos + up * 16 + right * -46 + forward * -64.5
		local vSecondSprite = pos + up * 16 + right * -5 + forward * -64.5

		render.SetMaterial(mGlow)

		local cColor = colors[1]
		
		if self:GetRawResource() >= 1 and self:GetRawResource() < 5 then
			cColor = colors[2]
		elseif self:GetRawResource() >= 5 then
			cColor = colors[3]
		end

		render.DrawSprite(vFirstSprite, 5.5, 5.5, cColor)
		render.DrawSprite(vSecondSprite, 5.5, 5.5, cColor)
	end

	function ENT:Draw()
		self:DrawModel()

		self:DrawOnlineEffects()
		self:DrawSmokeEffect()
	end
end
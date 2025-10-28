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
		self.workers = {}
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
		junk_monitor = 5,
		junk_keyboard = 3,
		junk_calculator = 2,
		junk_deskfan = 3,
		junk_desklamp = 4,
		junk_plasticcrate = 3,
		junk_plasticbucket = 1,
		empty_plastic_can = 1,
		empty_plastic_bottle = 1, 
		empty_jug = 1,
		junk_harddrive = 2,
		junk_tv = 2,
		empty_ration = 2,
		junk_audiosystem = 5,
		junk_geiger = 2,
		junk_gurevich = 1,
		junk_lamp = 3,
		workerhelmet = 5,		  
		gasmask_early = 5,
		eyes_glasses_regular = 2,
	},
	metal_reclaimed = {
		junk_axel = 4,
		junk_muffler = 4,
		junk_bicycle = 5,
		junk_engine = 5,
		junk_pot = 2,
		junk_lantern = 3,
		junk_cardoor = 5,
		junk_metalgascan = 2,
		empty_can = 1,
		empty_tin_can = 1,
		junk_propane = 2,
		junk_radiator = 5,
		junk_pipe = 2,
		junk_metalbucket = 3,
		junk_metalpot = 2,
		junk_citizenradio = 2,
		junk_cid = 1,
		junk_metalbucket2 = 2,
		junk_pot2 = 2,
		junk_chair = 3,
		junk_paintcan = 2,
		metal_scrap = 3,
		mat_ore_titan = 5,
		hatchet = 5,
		machete = 5,
		knife = 5,
		sledgehammer = 5,
		pickaxe = 5,
		uspmatch = 5,
		shotgun = 5,
		rpg = 5,
		m70 = 5,
		magnum = 5,
		stunstick = 5,
		crowbar = 5,
		mp133 = 5,
		ar25u = 5,
		ar25 = 5,
		ar29 = 5,
		broken_pistol = 5,
		broken_mp7 = 5,
		broken_shotgun = 5,
		broken_357 = 5,
		gun_shotgun_frame = 5,
		gun_smg_frame = 5,
		gun_pistol_frame = 2,
		gun_pistol_receiver = 2,
		gun_shotgun_grip = 2,
		gun_smg_receiver = 4,
		gun_weapon_barrel = 3,
		gun_pistol_barrel = 1,
		gun_smg_grip = 2,
		tool_pot = 3,
		tool_kettle = 2,
		tool_pan = 2,
		tool_wrench = 2,
		tool_hammer = 2,
		tool_hacksaw = 1,
		tool_scissors = 1, 
		tool_screw = 1,
		chain = 2,
		mat_weaponparts = 2,
	},
	gold_reclaimed = {
		mat_ore_gold = 3,
	},
	mat_glass = {
		empty_glass_bottle = 5, 
		eyes_glasses_aviators = 5,
		eyes_glasses_police = 5,
	},
	mat_wood = { 
		junk_huladoll = 5,
		junk_clock = 5,
		junk_cupboard = 5,
		junk_drawerchunk = 5,
		junk_woodchair = 5,
		junk_clock2 = 5,
		junk_doll = 5,
		tool_woodhammer = 5,
	},
	mat_resine = {
		junk_tire = 5,  
		hazmat_regular = 5,
		hazmat_medic = 5,
		gasmask_standard = 5,
	},
	mat_leather = {
		junk_cwuturtle = 5,
		junk_shoe = 5,
	},
	mat_cloth_reclaimed = {
		mask_scarf = 2,
		legs_cargo = 5,
		legs_suit_2 = 5,
		torso_suit_4 = 5,
		mask_scarf = 5,
		torso_suit_5 = 5,
		head_baseball_black = 1,
		torso_qamis_black = 5,
		labcoat_medic = 5,
		head_eastwrap = 5,
		torso_suit_1 = 5,
		torso_suit_3 = 5,
		head_easthat_black = 2,
		torso_worker_blue = 5,
		torso_worker_blue_short = 5,
		legs_jeans = 5,
		legs_jeans_boots = 5,
		legs_casual_red = 5,
		legs_jeans_green = 5,
		legs_jeans_green_boots = 5,
		head_bandana = 1,
		head_baseball_green = 2,
		torso_tshirt_blue = 5,
		torso_shirt_blue = 5,
		legs_casual_blue = 5,
		torso_shirt_gray = 5,
		head_eastwrap_white = 2,
		head_easthat_white = 2,
		legs_casual_yellow = 5,
		torso_tshirt_yellow = 5,
		gloves = 1,
		gloves_full = 1,
		head_boonie = 2,
		torso_tshirt_orange = 5,
		head_baseball_olive = 2,
		head_bandana_full = 1,
		surgerymask = 1,
		head_eastbandana = 2,
		head_poncho_red = 3,
		torso_tshirt_redblack = 5,
		torso_tshirt_red = 5,
		torso_shirt_red = 5,
		legs_suit_1 = 5,
		head_poncho = 2,
		legs_cargo_green = 5,
		torso_tshirt_green = 5,
		torso_shirt_green = 5,
		torso_worker_yellow = 5,
		torso_worker_yellow_short = 5,
		legs_jungleshorts = 5,
		head_millitary_cap = 2,
		torso_millitary_shirt = 5,
		torso_millitary_jacket = 5,
		head_medical_blue = 1,
		torso_shirt_hawai = 5,
		head_medical_white = 1,
		legs_suit_3 = 5,
		torso_tshirt_white = 5,
		torso_shirt_white = 5,
		torso_qamis_white = 5,
		neck_shemagh = 2,
		head_jimmys = 2,
		head_army_cap = 2,
		harness_army_1 = 5,
		harness_army_2 = 5,
		harness_army_3 = 5,
		mat_cloth = 1,
		medicbag = 5,
		bag = 5,
		bag_cp = 5,
		smallbag = 5,
		junk_clothes = 2,
		junk_cwuturtle = 1,
		junk_gloves = 1,
	},
	mat_kevlar = {
		broken_armor_light = 5,
		head_army_helmet_mp = 5,
		head_army_helmet_mp_googles = 5,
		head_army_helmet = 5,
		head_army_helmet_googles = 5,
		armor_army_vest = 5,
		padded_green_jeans = 5,
		padded_blue_jeans = 5,
		torso_nato_tier2 = 5,
		legs_nato_tier2 = 5,
		torso_armor_tier1 = 5,
		torso_armor_tier2 = 5,
		torso_shirt_tier1 = 5,
		head_helmet_tier2 = 5,
		torso_armor_tier3 = 5,
		torso_armor2_tier1 = 5,
		torso_medic_tier1 = 5,
		torso_armor_tier0 = 5,
		mpf_dl = 5,
		mpf_engineer = 5,
		mpf_engineer_i1 = 5,
		mpf_comissar = 5,
		mpf_medic = 5,
		mpf_medic_i1 = 5,
		mpf_ofc = 5,
		mpf_engineer_ofc = 5,
		mpf_medic_ofc = 5,
		mpf_guard_ofc = 5,
		mpf_support_ofc = 5,
		mpf_investigator_ofc = 5,
		mpf_sf = 5,
		mpf_guard = 5,
		mpf_guard_i1 = 5,
		mpf_support = 5,
		mpf_support_i1 = 5,
		mpf_investigator = 5,
		mpf_investigator_i1 = 5,
		mpf_regular = 5, 	
		mpf_i1 = 5,
		gasmask_m40 = 5,
	},
}

local allowedEntities = {
	["ix_item"] = {
		StartTouch = function(factory, entity)
			local itemTable = entity:GetItem()

			if itemTable.isFactoryFuel then
				local currentFuel = factory:GetFuelAmount()

				if currentFuel < 100 then
					local isBadGascan = itemTable.uniqueID == "gascan_bad"
					local value = isBadGascan and 50 or 100

					factory:SetFuelAmount(math.Clamp(currentFuel + value, 0, 100))
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

				local heldOwner = IsValid(entity.ixHeldOwner) and entity.ixHeldOwner or (IsValid(entity.ixLastHeldOwner) and entity.ixLastHeldOwner)
				if IsValid(heldOwner) and heldOwner:IsPlayer() then
					local id = heldOwner:GetCharacter():GetID()
					factory.workers[id] = (factory.workers[id] or 0) + 1
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

			local workerCount = table.Count(self.workers)
			for charID, points in pairs(self.workers) do
				local character = ix.char.loaded[charID]
				if character and IsValid(character:GetPlayer()) then
					character:DoAction("craft_recycle", math.Clamp(points * 20, 5, 100))
				end
			end

			self.workers = {}
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

		local id = activator:GetCharacter():GetID()

		self.workers[id] = (self.workers[id] or 0) + 1

		activator:SetAction("", 25)
		activator:DoStaredAction(self, function()
			self:StopSound("machine_moving")
			self:SetManufacturing(false)
			self:SetPlayerUsing(nil)

			self:CreateProduct(activator)

			local nNewFuelAmount = self:GetFuelAmount() - 2

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
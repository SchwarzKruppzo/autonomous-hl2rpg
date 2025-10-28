AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Ration Dispenser"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.bNoPersist = true
ENT.IsRationDispenser = true 

ENT.Displays = {
	[1] = {Vector(0, 1, 0)}, // ENABLED
	[2] = {Vector(1, 1, 1)}, // WAITING FOR COUPON
	[3] = {Vector(0, 0, 0)}, // DISPENSING
	[4] = {Vector(1, 0, 0)}, // ERROR
	[5] = {Vector(1, 0, 1)}, // UNLOCKED
}

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Display")
	self:NetworkVar("Bool", 1, "Enabled")
	self:NetworkVar("Float", 0, "RationTime")
end

if SERVER then
	util.AddNetworkString("ration.dispenser.action")
	function ENT:SpawnFunction(client, trace)
		local dispenser = ents.Create("ix_rationdispenser")

		dispenser:SetPos(trace.HitPos)
		dispenser:SetAngles(trace.HitNormal:Angle())
		dispenser:Spawn()
		dispenser:Activate()
		dispenser:SetEnabled(true)

		Schema:SaveRationDispensers()
		return dispenser
	end

	function ENT:Initialize()
		self:SetModel("models/props_junk/watermelon01.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:DrawShadow(false)
		self:SetUseType(SIMPLE_USE)
		self:SetDisplay(1)
		self:SetEnabled(true)

		self.dispenser = ents.Create("prop_dynamic")
		self.dispenser:SetModel("models/autonomous/combine_dispenser.mdl")
		self.dispenser:SetPos(self:GetPos())
		self.dispenser:SetAngles(self:GetAngles())
		self.dispenser:SetParent(self)
		self.dispenser:Spawn()
		self.dispenser:Activate()
		self:DeleteOnRemove(self.dispenser)

		local physics = self.dispenser:GetPhysicsObject()
		physics:EnableMotion(false)
		physics:Sleep()

		self.canUse = true
		self.nextUseTime = CurTime()
	end

	function ENT:CreateDummyRation()
		local entity = ents.Create("prop_physics")
		
		entity:SetAngles(self:GetAngles())
		entity:SetModel("models/weapons/w_package.mdl")
		entity:Spawn()
		
		return entity
	end

	local coupons = {
		["coupon_ration0"] = "ration_tier_0",
		["coupon_ration1"] = "ration_tier_1",
		["coupon_ration2"] = "ration_tier_1",
		["coupon_ration3"] = "ration_tier_4",
		["coupon_ration4"] = "ration_tier_3"
	}

	function ENT:SpawnRation(client, coupon, callback, releaseDelay)
		releaseDelay = releaseDelay or 1.2

		-- TODO: move to callback in faction function
		local character = client:GetCharacter()
		//local faction = ix.faction.indices[character:GetFaction()]

		local ration = coupons[coupon]

		//ration = faction.GetRationType and faction:GetRationType(character) or ration

		local entity = self:CreateDummyRation()
		entity:SetModel("models/hls/alyxports/ration_package.mdl")
		entity:SetNotSolid(true)
		entity:SetParent(self.dispenser)

		timer.Simple(0, function()
			entity:Fire("SetParentAttachment", "package_attachment", 0)

			if (callback) then
				callback(entity)
			end
		end)

		timer.Simple(releaseDelay, function()
			local position = entity:GetPos()
			local angles = entity:GetAngles()
			
			entity:CallOnRemove("CreateRation", function()
				local new_item = ix.Item:Instance(ration)

				ix.Item:Spawn(position, angles, new_item)
			end)
			
			entity:SetNoDraw(true)
			entity:Remove()

			timer.Simple(releaseDelay, function()
				self.canUse = true

				self:SetDisplay(self.cid and 2 or 1)
			end)

			client:ChatNotify("*** Раздатчик вновь замигал белым индикатором в ожидании следующего купона.")
			client:ChatNotify("Не забудьте забрать карту из устройства: внимательно присмотритесь.")
		end)
	end

	function ENT:StartDispense(client, delay, coupon)
		self:SetDisplay(3)
		self:SetRationTime(CurTime() + delay)
		self:EmitSound("ambient/machines/combine_terminal_idle3.wav")

		timer.Create("Ration"..self:EntIndex(), delay, 1, function()
			if !IsValid(self) then
				return
			end
			
			self:SpawnRation(client, coupon, function()
				self.dispenser:Fire("SetAnimation", "dispense_package")
				self:EmitSound("ambient/machines/combine_terminal_idle4.wav")
			end)
		end)
	end

	function ENT:DisplayError(id, length)
		id = id or 6
		length = length or 2

		self:SetDisplay(4)
		self:EmitSound("buttons/combine_button_locked.wav")
		self.canUse = false

		timer.Simple(length, function()
			self:SetDisplay(1)
			self.canUse = true
		end)
	end

	function ENT:InsertCID(client)
		local item_id = client:GetInventory('cid'):GetFirstAtSlot(1, 1)
		local item = ix.Item.instances[item_id]
		
		if item then
			ix.Item:DropItem(client, item.id)

			local ent = item.entity
			local ang, pos = self:GetAngles(), self:GetPos()

			pos = pos + ang:Forward() * 10 - ang:Right() * 1.25 + ang:Up() * 7

			ang:RotateAroundAxis(ang:Right(), -90)
			ang:RotateAroundAxis(ang:Forward(), 90)

			ent:GetPhysicsObject():EnableMotion(false)
			ent:SetPos(pos)
			ent:SetAngles(ang)
			ent:CallOnRemove('rationCard',function()
				self:SetDisplay(1)
				self.cid = nil
			end)

			self.cid = item

			client:ChatNotify("*** Вы вставили идентификационную карту в разьём раздатчика.")

			timer.Simple(3, function()
				client:ChatNotify("*** Раздатчик замигал белым индикатором, судя по всему, в ожидании купона Альянса.")
				client:ChatNotify("Возьмите купон в руки и воспользуйтесь раздатчиком через [TAB], используя [ПКМ].")
			end)

			self:SetDisplay(2)
			self:EmitSound("buttons/button6.wav")
		end
	end
	
	function ENT:Use(client)
		if !self.canUse or self.nextUseTime > CurTime() then
			return
		end
	end

	function ENT:OnRemove()
		if !ix.shuttingDown then
			Schema:SaveRationDispensers()
		end
	end

	net.Receive("ration.dispenser.action", function(_, client)
		local action = net.ReadBool()
		local entity = net.ReadEntity()

		if !IsValid(entity) or !entity.IsRationDispenser then
			return
		end
/*
		if !entity.canUse or entity.nextUseTime > CurTime() then
			return
		end*/

		local display = entity:GetDisplay()


		if display == 1 and !action then
			entity:InsertCID(client)
		elseif display == 2 and action then
			local coupon

			if client:GetLocalVar("bIsHoldingObject") then
				local hands = client:GetWeapon("ix_hands")

				if IsValid(hands) then
					local object = IsValid(hands.heldEntity) and hands.heldEntity

					if object and object.ixItemID then
						local item = ix.Item.instances[object.ixItemID]

						if item.bases["coupon"] then
							coupon = item.uniqueID

							hands:DropObject(false)
							object:Remove()
						end
					end
				end
			end
			
			if coupon then
				entity:StartDispense(client, 8, coupon)
			end
		end

		entity.nextUseTime = CurTime() + 2
	end)
else
	function ENT:GetIndicatorColor()
		return self.indicator_clr
	end
	
	function ENT:Draw()
		local enabled = self:GetEnabled()

		if enabled then
			local display = self:GetDisplay()

			if !self.indicator_clr then
				self.indicator_clr = vector_origin
			end

			local curTime = CurTime()
			local rationTime = self:GetRationTime()

			if rationTime > curTime then
				local timeLeft = rationTime - curTime
				
				if !self.nextFlash or curTime >= self.nextFlash or (self.flashUntil and self.flashUntil > curTime) then
					if !self.flashUntil or curTime >= self.flashUntil then
						self.indicator_clr = Vector(1,1,0)
						self.nextFlash = curTime + (timeLeft / 4)
						self.flashUntil = curTime + (FrameTime() * 4)
						self:EmitSound("hl1/fvox/boop.wav")

						timer.Simple(FrameTime() * 16, function()
							self.indicator_clr = Vector(0,0,0)
						end)
					end
				end
			else
				if self:GetDisplay() == 2 then
					local a = math.sin(SysTime() * 9)

					if !self.beep and a > 0 then
						self.indicator_clr = Vector(1,1,1)
						self.beep = true
					elseif self.beep and a < 0 then
						self.indicator_clr = vector_origin
						self.beep = false
					end
				else
					self.indicator_clr = self.Displays[display][1]
				end
			end
			/*
			local ct = CurTime()
			if !self.nextFlash or ct >= self.nextFlash or (self.flashUntil and self.flashUntil > ct) then
				self.indicator_clr = Vector(1, 1, 1)
				
				if !self.flashUntil or ct >= self.flashUntil then
					self.indicator_clr = Vector(0,0,0)

					self.nextFlash = ct + 5
					self.flashUnnextFlashtil = ct + (FrameTime() * 4)
					self:EmitSound("hl1/fvox/boop.wav")
				end
			end*/

			
			local position, angles = self:GetPos(), self:GetAngles()

			local eDLight = DynamicLight(self:EntIndex(), true)

			if eDLight then
				eDLight.Pos = position + angles:Forward() * 12 - angles:Right() + angles:Up() * 22
				eDLight.r = self.indicator_clr[1] * 255
				eDLight.g = self.indicator_clr[2] * 255
				eDLight.b = self.indicator_clr[3] * 255
				eDLight.Brightness = 4
				eDLight.Size = 20
				eDLight.Decay = 25 * 5
				eDLight.DieTime = CurTime() + 1
				eDLight.Style = 12
			end
		else
			self.indicator_clr = vector_origin
		end

		/*
		local display = self:GetEnabled() and self.Displays[self:GetDisplay()] or self.Displays[6]

		angles:RotateAroundAxis(angles:Forward(), 90)
		angles:RotateAroundAxis(angles:Right(), 270)

		cam.Start3D2D(position + self:GetForward() * 7.6 + self:GetRight()*  8.5 + self:GetUp() * 3, angles, 0.1)
			render.PushFilterMin(TEXFILTER.NONE)
			render.PushFilterMag(TEXFILTER.NONE)

			surface.SetDrawColor(color_black)
			surface.DrawRect(10, 16, 153, 40)

			surface.SetDrawColor(60, 60, 60)
			surface.DrawOutlinedRect(9, 16, 155, 40)

			local alpha = display[3] and 255 or math.abs(math.cos(RealTime() * 2) * 255)
			local color = ColorAlpha(display[2], alpha)

			draw.SimpleText(display[1], "ixRationDispenser", 86, 36, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			render.PopFilterMin()
			render.PopFilterMag()
		cam.End3D2D()*/
	end
end

function ENT:GetEntityMenu(client)
	local display = self:GetDisplay()
	local menus = {}

	if display == 1 then
		menus["Insert CID"] = function(panel)
			net.Start("ration.dispenser.action")
				net.WriteBool(false)
				net.WriteEntity(self)
			net.SendToServer()
		end
		/*
	elseif display == 2 then
		menus["Insert Coupon"] = function(panel)
			net.Start("ration.dispenser.action")
				net.WriteBool(true)
				net.WriteEntity(self)
			net.SendToServer()
		end*/
	end

	return menus
end
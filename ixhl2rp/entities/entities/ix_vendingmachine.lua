AddCSLuaFile()

local ENT = ENT

ENT.Type = "anim"
ENT.PrintName = "Vending Machine"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.bNoPersist = true

ENT.MaxRenderDistance = math.pow(256, 2)
ENT.MaxStock = 5
ENT.Items = {
	{"REGULAR", "breens_water", 7},
	{"SMOOTH", "smooth_breens_water", 18},
	{"SPECIAL", "special_breens_water", 33}
}

function ENT:GetStock(id)
	return self:GetNetVar("stock", {})[id] or 0
end

function ENT:GetAllStock()
	return self:GetNetVar("stock", {})
end

hook.Add("InitializeCities", "VendingMachines", function()
	ix.City:RegisterRestock("ix_vendingmachine", function(city, entity)
		local stock = city.stock

		entity.isFirstRestock = entity.isFirstRestock
		entity.supplyOrders = entity.supplyOrders or {}
		entity.demandOrders = entity.demandOrders or {}

		print("Is Not First Restock?", entity.isFirstRestock)

		for i = 1, #entity.Items do
			local item = entity.Items[i]
			local itemClass = item[2]

			local supplyOrder, demandOrder = entity.supplyOrders[i], entity.demandOrders[i]

			if !entity.isFirstRestock then
				supplyOrder = stock:AddSupplyOrder(itemClass)
				demandOrder = stock:AddDemandOrder(itemClass)

				entity.supplyOrders[i] = supplyOrder
				entity.demandOrders[i] = demandOrder
			end

			local stored = entity:GetStock(i)
			local neededToRefill = math.max(entity.MaxStock - stored, 0)

			print("Needed to Refill", itemClass, neededToRefill)

			supplyOrder:Add(neededToRefill)
			entity:SetStock(i, stored + neededToRefill)
		end

		if !entity.isFirstRestock then
			entity.isFirstRestock = true
		end
	end)
end)

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/autonomous/vending_machine.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local physics = self:GetPhysicsObject()
		physics:EnableMotion(false)
		physics:Sleep()

		self:SetSkin(math.random(0, self:SkinCount() - 1))
		self.nextUseTime = 0
		self:SetNetVar("stock", {})
	else
		sound.PlayFile("sound/vendingmachinehum_loop.wav", "3d noplay noblock", function(station, errCode, errStr)
			if IsValid(station) then
				station:Set3DFadeDistance(80, 2048)
				station:SetVolume(0.05)
				station:SetPos(self:GetPos())
				station:EnableLooping(true)
				station:Play()

				self.Station = station
			end
		end)
	end
end

if SERVER then
	function ENT:SpawnFunction(client, trace)
		local vendor = ents.Create("ix_vendingmachine")

		vendor:SetPos(trace.HitPos + Vector(0, 0, 48))
		vendor:SetAngles(Angle(0, (vendor:GetPos() - client:GetPos()):Angle().y - 180, 0))
		vendor:Spawn()
		vendor:Activate()

		vendor.city = "main"
		ix.City:Restock(vendor)

		Schema:SaveVendingMachines()
		return vendor
	end

	function ENT:GetClosestButton(client)
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client
		local trace = util.TraceLine(data)
		local tracePosition = trace.HitPos

		if tracePosition then
			for k, v in ipairs(self.Items) do
				local position = self:GetPos() + self:GetForward() * 17.5 + self:GetRight() * -24.4 + (self:GetUp() * 4.3 - Vector(0, 0, (k - 1) * 2.1))

				if position:DistToSqr(tracePosition) <= 1 then
					return k
				end
			end
		end
	end

	function ENT:SetStock(id, amount)
		if istable(id) then
			self:SetNetVar("stock", id)
			return
		end

		local stock = self:GetNetVar("stock", {})
		stock[id] = math.Clamp(amount, 0, self.MaxStock)

		self:SetNetVar("stock", stock)
	end

	function ENT:ResetStock(id)
		local stock = self:GetNetVar("stock", {})

		-- reset stock of all items if no id is specified
		if id then
			stock[id] = self.MaxStock
		else
			for k, v in ipairs(self.Items) do
				stock[k] = self.MaxStock
			end
		end

		self:SetNetVar("stock", stock)
	end

	function ENT:RemoveStock(id)
		self:SetStock(id, self:GetStock(id) - 1)

		local demandOrder = self.demandOrders[id]
		demandOrder:Add(1)

		print("Player->Buy Water #"..id, "Demand Value:", demandOrder.value)
	end

	function ENT:Use(client)
		local buttonID = self:GetClosestButton(client)

		if buttonID then
			client:EmitSound("buttons/lightswitch2.wav", 40, 150)
		else
			return
		end

		if self.nextUseTime > CurTime() then
			return
		end

		local character = client:GetCharacter()

		local itemInfo = self.Items[buttonID]
		local price = itemInfo[3]

		if !character:HasMoney(price) then
			self:EmitSound("buttons/button2.wav", 50)
			self.nextUseTime = CurTime() + 1

			client:NotifyLocalized("vendingNeedMoney", ix.currency.Get(price))
			return false
		end

		if self:GetStock(buttonID) > 0 then
			local new_item = ix.Item:Instance(itemInfo[2])
			local angles = self:GetAngles()
			angles:RotateAroundAxis(self:GetForward(), 90)
			local x = ix.Item:Spawn(self:GetPos() + self:GetForward() * 16.9 + self:GetRight() * 4 + self:GetUp() * -22, angles, new_item)

			self:EmitSound("buttons/button4.wav", 60)

			character:TakeMoney(price)
			client:NotifyLocalized("vendingPurchased", ix.currency.Get(price))

			self:RemoveStock(buttonID)
			self.nextUseTime = CurTime() + 3
		else
			self:EmitSound("buttons/button2.wav", 50)
		end

		self.nextUseTime = CurTime() + 1
	end

	function ENT:OnRemove()
		if (!ix.shuttingDown) then
			Schema:SaveVendingMachines()
		end
	end
else
	surface.CreateFont("ixVendingMachine", {
		font = "Blender Pro Book",
		size = 13,
		weight = 500,
		antialias = false
	})

	local glowMaterial = Material("sprites/glow04_noz")
	local color_red = Color(255, 76, 53)
	local color_green = Color(48, 255, 76)

	function ENT:Draw()
		self:DrawModel()

		local position = self:GetPos()
		local distance = LocalPlayer():GetPos():DistToSqr(position)

		if distance > self.MaxRenderDistance * 10 then
			return
		end

		local angles = self:GetAngles()
		local forward, right, up = self:GetForward(), self:GetRight(), self:GetUp()

		angles:RotateAroundAxis(angles:Up(), 90)
		angles:RotateAroundAxis(angles:Forward(), 90)

		render.SetMaterial(glowMaterial)

		local client = LocalPlayer()
		local data = {}
		data.start = client:GetShootPos()
		data.endpos = data.start + client:GetAimVector() * 96
		data.filter = client
		local trace = util.TraceLine(data)
		local tracePosition = trace.HitPos

		local selected = nil
		for i = 1, #self.Items do
			local item = self.Items[i]
			local stockAmount = self:GetStock(i)
			local color = color_red

			if item then
				if stockAmount > 0 then
					color = color_green
				end

				local pos = position + forward * 17.75 + right * -24.5 + up * 4.3 - up * ((i - 1) * 2.1)

				if pos:DistToSqr(tracePosition) <= 1 then
					color = color:Darken(64)
					selected = i
				end

				render.DrawSprite(pos, 2.5, 2.5, color)
			end
		end

		if distance > self.MaxRenderDistance then
			return
		end

		cam.Start3D2D(position + forward * 17.55 + right * -19.2 + up * 5.4, angles, 0.06)
			render.PushFilterMin(TEXFILTER.NONE)
			render.PushFilterMag(TEXFILTER.NONE)

			local width = 78
			local height = 32
			local iHalfWidth = width / 2
			local iHalfWeight = height / 2

			for i, item in ipairs(self.Items) do
				local x = 0
				local y = (i - 1) * 34
				local stockAmount = self:GetStock(i)

				local color = (stockAmount > 0) and color_green or color_red

				if i == selected then
					color = color:Darken(64)
				end
				
				if item then
					draw.SimpleText(item[1], "ixVendingMachine", x + iHalfWidth - 5, y + iHalfWeight + 4, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end

				render.OverrideBlend(true, 4, 1, BLENDFUNC_ADD, 4, 1, BLENDFUNC_ADD)
					surface.SetDrawColor(ColorAlpha(color, 8))
					surface.DrawRect(x - 2, y + 4 + 4, width - 4, height - 8)

					surface.SetDrawColor(ColorAlpha(color, 58))
					surface.DrawRect(x + 82, y + 4 + 4, 14, height - 8)
				render.OverrideBlend(false)
			end

			render.PopFilterMin()
			render.PopFilterMag()
		cam.End3D2D()
	end
end

local ItemFood = class("ItemFood")
implements("ItemReagentContainer", "ItemFood")

ItemFood = ix.meta.ItemFood

ItemFood.junk = nil
ItemFood.useSound = {"npc/barnacle/barnacle_gulp1.wav", "npc/barnacle/barnacle_gulp2.wav"}
ItemFood.volume = 200
ItemFood.portion_amount = 50
ItemFood.reagent_flags = ix.Reagents.holder.injectable

function ItemFood:Init()
	ix.meta.ItemReagentContainer.Init(self)

	self.category = "categoryFood"

	self.stats = {
		container = false,
		hunger = 0,
		thirst = 0,
		freezeSpeed = 2 * 60 * 60,
		unfreezeSpeed = 60 * 60,
		expireTime = 24 * 60 * 60,
		expireMultiplier = {
			cold = 999
		}
	}

	self.functions.open = {
		name = "useOpen",
		OnRun = function(item)
			item:SetData("closed", false)
			item:StartRotProgress()

			item.player:EmitSound("foley/crushable/tin_can_break.mp3")
			return true
		end,
		OnCanRun = function(item) return (item:IsClosed() == true) end
	}

	self.functions.use = {
		name = "useFood",
		OnRun = function(item)
			local client = item.player
			local character = client:GetCharacter()
			local portionAmount = math.min(item.portion_amount, item.reagents and item.reagents.volume or 0)

			if portionAmount <= 0 then
				return
			end

			local portionScale = portionAmount / item.portion_amount
			local thirst = (item.stats.thirst or 0) * portionScale
			local hunger = (item.stats.hunger or 0) * portionScale

			local reagentThirst, reagentHunger = ix.Reagents:Consume(item.reagents, portionAmount, client)
			thirst = thirst + reagentThirst
			hunger = hunger + reagentHunger

			character:UpdateNeeds(thirst, hunger)

			if item.stats.stamina then
				client:RestoreStamina(item.stats.stamina * portionScale)
			end

			if item.stats.blood then
				character:SetBlood(math.min(character:GetBlood() + item.stats.blood * portionScale, 5000))
			end

			if istable(item.useSound) then
				client:EmitSound(item.useSound[math.random(1, #item.useSound)])
			else
				client:EmitSound(item.useSound)
			end

			if item.CustomEffect then
				item:CustomEffect(client, portionAmount)
			end

			if item.reagents.volume <= 0.1 then
				item:OnDepleted()
			end
		end,
		OnCanRun = function(item)
			if item:IsClosed() then return false end
			if SERVER and item.reagents then return item.reagents.volume > 0.1 end
			if CLIENT then return (item:GetData("value") or 0) > 0.1 end
			return true
		end
	}

	self.functions.useall = {
		name = "useFoodAll",
		OnRun = function(item)
			local client = item.player
			local character = client:GetCharacter()
			local remaining = item.reagents and item.reagents.volume or 0

			if remaining <= 0.1 then
				return
			end

			local portions = remaining / item.portion_amount
			local thirst = (item.stats.thirst or 0) * portions
			local hunger = (item.stats.hunger or 0) * portions

			local reagentThirst, reagentHunger = ix.Reagents:Consume(item.reagents, remaining, client)
			thirst = thirst + reagentThirst
			hunger = hunger + reagentHunger

			character:UpdateNeeds(thirst, hunger)

			local totalFraction = remaining / item.volume
			if item.stats.stamina then
				client:RestoreStamina(item.stats.stamina * totalFraction)
			end

			if item.stats.blood then
				character:SetBlood(math.min(character:GetBlood() + item.stats.blood * totalFraction, 5000))
			end

			if istable(item.useSound) then
				client:EmitSound(item.useSound[math.random(1, #item.useSound)])
			else
				client:EmitSound(item.useSound)
			end

			if item.CustomEffect then
				item:CustomEffect(client, remaining)
			end

			item:OnDepleted()
		end,
		OnCanRun = function(item)
			if item:IsClosed() then return false end
			if SERVER and item.reagents then return item.reagents.volume > 0.1 end
			if CLIENT then return (item:GetData("value") or 0) > 0.1 end
			return true
		end
	}

	self:AddData("expire", {
		Transmit = ix.transmit.owner,
	})
	self:AddData("expire_last", {
		Transmit = ix.transmit.owner,
	})

	self:AddData("delta_time", {
		Transmit = ix.transmit.owner,
	})
	self:AddData("delta_seconds", {
		Transmit = ix.transmit.owner,
	})

	self:AddData("freezed_time", {
		Transmit = ix.transmit.none,
	})
end

function ItemFood:IsClosed()
	if self.stats.container then
		return self:GetData("closed")
	end

	return false
end

function ItemFood:GetReagentFlags()
	if self:IsClosed() then
		return 0
	end

	return ix.Reagents.holder.injectable
end

if SERVER then
	function ItemFood:OnFirstCreated()
		self:SetData("closed", self.stats.container or false)

		self.reagents:AddReagent("food_matter", self.volume, 300, true)
		self.reagents:UpdateTotal()

		if !self:IsClosed() then
			self:StartRotProgress()
		end
	end

	function ItemFood:OnMigrateData()
		local savedUses = self:GetData("uses")
		local maxUses = math.floor(self.volume / self.portion_amount + 0.5)

		if savedUses and maxUses > 0 then
			local remaining = (savedUses / maxUses) * self.volume
			self.reagents:AddReagent("food_matter", remaining, 300, true)
			self.reagents:UpdateTotal()
		else
			self.reagents:AddReagent("food_matter", self.volume, 300, true)
			self.reagents:UpdateTotal()
		end
	end
end

function ItemFood:StartRotProgress()
	if self.stats.noExpire then
		return
	end

	self:SetData("expire", os.time() + self.stats.expireTime)
	self:SetData("expire_last", nil)
	self:SetData("delta_time", nil)
	self:SetData("delta_seconds", nil)
	self:SetData("freezed_time", nil)
end

function ItemFood:GetRottenTime()
	local currentTime = os.time()

	local expireNew = self:GetData("expire") or 0
	local expireLast = self:GetData("expire_last") or 0
	local deltaTime = self:GetData("delta_time") or 0
	local deltaSeconds = self:GetData("delta_seconds") or 0

	local delta = (1 - math.Clamp(((deltaTime + deltaSeconds) - currentTime) / deltaSeconds, 0, 1))
	local rottenTime = Lerp(delta, expireLast, expireNew)

	return rottenTime
end

function ItemFood:IsRotten()
	return self.stats.noExpire and false or (os.time() >= self:GetRottenTime())
end

function ItemFood:OnTransfer(newInventory, oldInventory)
	if self.stats.noExpire then
		return
	end

	local currentTime = os.time()
	local expireTime = (self:GetData("expire") or 0)
	local rottenTime = self:GetRottenTime()

	if currentTime >= rottenTime then
		return
	end

	if !newInventory or newInventory.type != "container" then
		local freezedTime = self:GetData("freezed_time") or 0
		local remainingTime = expireTime - freezedTime
		local expireLast = (self:GetData("expire_last") or 0)

		self:SetData("freezed_time",  nil)

		self:SetData("expire_last", expireLast + (rottenTime - expireLast))
		self:SetData("expire", currentTime + (remainingTime / self.stats.expireMultiplier.cold))

		self:SetData("delta_time", currentTime)
		self:SetData("delta_seconds", self.stats.unfreezeSpeed)
	elseif newInventory and newInventory.type == "container" then
		local remainingTime = expireTime - currentTime

		self:SetData("freezed_time", currentTime)

		self:SetData("expire_last", expireTime)
		self:SetData("expire", currentTime + (remainingTime * self.stats.expireMultiplier.cold))

		self:SetData("delta_time", currentTime)
		self:SetData("delta_seconds", self.stats.freezeSpeed)
	end
end

if CLIENT then
	local orderedDurationUnits = {
		{525600, "год", "года", "лет"},
		{43200, "месяц", "месяцев"},
		{10080, "неделю", "недель"},
		{1440, "день", "дней"},
		{60, "час", "часов"},
		{1, "минута", "минут"},
	}

	local function ParseDuration(input)
		local number = tonumber(input)

		if number then
			local output = {}

			if number <= 0 or number > 525600 then
				return "бессрочно"
			end

			for k, v in ipairs(orderedDurationUnits) do
				if number >= v[1] then
					local count = math.floor(number / v[1])
					local txt = tostring(count)

					if count > 4 and v[4] then
						output[#output + 1] = txt.." "..v[4]
					elseif count > 1 then
						output[#output + 1] = txt.." "..v[3]
					else
						output[#output + 1] = txt.." "..v[2]
					end

					number = number - (v[1] * count)
				end
			end

			return table.concat(output, ", ")
		end
	end

	function ItemFood:PopulateTooltip(tooltip)
		if !self:GetEntity() then
			local expDateT

			if !self.stats.noExpire and !self:IsClosed() then
				local expirationDate = self:GetRottenTime()

				if os.time() < expirationDate then
					expDateT = tooltip:AddRowAfter("name", "expirationDate")
					expDateT:SetBackgroundColor(derma.GetColor("Error", tooltip))
					expDateT:SetTextColor(derma.GetColor("Warning", expDateT))
					expDateT:SetText(L("expirationDatePrefix") .. ParseDuration((expirationDate - os.time()) / 60))
				end
			end

			local currentVolume = math.Round(self:GetVolume())
			local maxVolume = self:GetMaxVolume()

			local vol = tooltip:AddRowAfter(expDateT and "expirationDate" or "name")
			vol:SetBackgroundColor(derma.GetColor("Success", tooltip))
			vol:SetText(L("portionDesc", currentVolume, maxVolume))
		end
	end
end

return ItemFood

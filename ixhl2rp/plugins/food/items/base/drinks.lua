local ItemDrink = class("ItemDrink")
implements("ItemReagentContainer", "ItemDrink")

ItemDrink = ix.meta.ItemDrink

ItemDrink.junk = nil
ItemDrink.useSound = {"npc/barnacle/barnacle_gulp1.wav", "npc/barnacle/barnacle_gulp2.wav"}
ItemDrink.volume = 330
ItemDrink.sip_amount = 66
ItemDrink.reagent_type = "water"

function ItemDrink:Init()
	ix.meta.ItemReagentContainer.Init(self)

	self.category = "Напитки"

	self.stats = {
		container = false,
		freezeSpeed = 2 * 60 * 60,
		unfreezeSpeed = 60 * 60,
		expireTime = 24 * 60 * 60,
		expireMultiplier = {
			cold = 999
		}
	}

	self.functions.open = {
		name = "Вскрыть",
		OnRun = function(item)
			item:SetData("closed", false)
			item:StartRotProgress()

			if SERVER and item.reagents then
				item.reagents.flags = item:GetReagentFlags()
			end

			item.player:EmitSound("foley/crushable/tin_can_break.mp3")
			return true
		end,
		OnCanRun = function(item)
			if IsValid(item:GetEntity()) then
				return false
			end

			return (item:IsClosed() == true)
		end
	}

	self.functions.use = {
		name = "Отпить",
		OnRun = function(item)
			local client = item.player
			local character = client:GetCharacter()
			local sipAmount = math.min(item.sip_amount, item.reagents and item.reagents.volume or 0)

			if sipAmount <= 0 then
				return
			end

			local thirst, hunger = ix.Reagents:Consume(item.reagents, sipAmount, client)
			character:UpdateNeeds(thirst, hunger)

			if item.stats.stamina then
				local fraction = sipAmount / item.volume
				client:RestoreStamina(item.stats.stamina * fraction)
			end

			if item.stats.blood then
				local fraction = sipAmount / item.volume
				character:SetBlood(math.min(character:GetBlood() + item.stats.blood * fraction, 5000))
			end

			if istable(item.useSound) then
				client:EmitSound(item.useSound[math.random(1, #item.useSound)])
			else
				client:EmitSound(item.useSound)
			end

			if item.CustomEffect then
				item:CustomEffect(client, sipAmount)
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
		name = "Отпить всё",
		OnRun = function(item)
			local client = item.player
			local character = client:GetCharacter()
			local remaining = item.reagents and item.reagents.volume or 0

			if remaining <= 0.1 then
				return
			end

			local thirst, hunger = ix.Reagents:Consume(item.reagents, remaining, client)
			character:UpdateNeeds(thirst, hunger)

			if item.stats.stamina then
				local fraction = remaining / item.volume
				client:RestoreStamina(item.stats.stamina * fraction)
			end

			if item.stats.blood then
				local fraction = remaining / item.volume
				character:SetBlood(math.min(character:GetBlood() + item.stats.blood * fraction, 5000))
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

	self.functions.pour = {
		name = "Вылить содержимое",
		OnRun = function(item)
			if item.reagents then
				item.reagents:Clear()
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

function ItemDrink:IsClosed()
	if self.stats.container then
		return self:GetData("closed")
	end

	return false
end

function ItemDrink:GetReagentFlags()
	if self:IsClosed() then
		return ix.Reagents.holder.injectable
	end

	return ix.Reagents.holder.open
end

if SERVER then
	function ItemDrink:OnFirstCreated()
		self:SetData("closed", self.stats.container or false)

		self.reagents:AddReagent(self.reagent_type, self.volume, 300, true)
		self.reagents:UpdateTotal()

		if !self:IsClosed() then
			self:StartRotProgress()
		end
	end

	function ItemDrink:OnMigrateData()
		local savedUses = self:GetData("uses")
		local maxUses = math.floor(self.volume / self.sip_amount + 0.5)

		if savedUses and maxUses > 0 then
			local remaining = (savedUses / maxUses) * self.volume
			self.reagents:AddReagent(self.reagent_type, remaining, 300, true)
			self.reagents:UpdateTotal()
		else
			self.reagents:AddReagent(self.reagent_type, self.volume, 300, true)
			self.reagents:UpdateTotal()
		end
	end
end

function ItemDrink:StartRotProgress()
	if self.stats.noExpire then
		return
	end

	self:SetData("expire", os.time() + self.stats.expireTime)
	self:SetData("expire_last", nil)
	self:SetData("delta_time", nil)
	self:SetData("delta_seconds", nil)
	self:SetData("freezed_time", nil)
end

function ItemDrink:GetRottenTime()
	local currentTime = os.time()

	local expireNew = self:GetData("expire") or 0
	local expireLast = self:GetData("expire_last") or 0
	local deltaTime = self:GetData("delta_time") or 0
	local deltaSeconds = self:GetData("delta_seconds") or 0

	local delta = (1 - math.Clamp(((deltaTime + deltaSeconds) - currentTime) / deltaSeconds, 0, 1))
	local rottenTime = Lerp(delta, expireLast, expireNew)

	return rottenTime
end

function ItemDrink:IsRotten()
	return self.stats.noExpire and false or (os.time() >= self:GetRottenTime())
end

function ItemDrink:OnTransfer(newInventory, oldInventory)
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
	};


	local function ParseDuration(input)
		local number = tonumber(input)

		if number then
			local output = {}

			if number <= 0 then
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

	function ItemDrink:PopulateTooltip(tooltip)
		if !self:GetEntity() then
			local expDateT

			if !self.stats.noExpire and !self:IsClosed() then
				local expirationDate = self:GetRottenTime()

				if os.time() < expirationDate then
					expDateT = tooltip:AddRowAfter("name", "expirationDate")
					expDateT:SetBackgroundColor(derma.GetColor("Error", tooltip))
					expDateT:SetTextColor(derma.GetColor("Warning", expDateT))
					expDateT:SetText("Испортится через: " .. ParseDuration((expirationDate - os.time()) / 60))
				end
			end

			local currentVolume = math.Round(self:GetVolume())
			local maxVolume = self:GetMaxVolume()

			local vol = tooltip:AddRowAfter(expDateT and "expirationDate" or "name")
			vol:SetBackgroundColor(derma.GetColor("Success", tooltip))
			vol:SetText(L("volumeDesc", currentVolume, maxVolume))
		end
	end
end

return ItemDrink

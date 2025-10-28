local ItemFood = class("ItemFood"):implements("Item")

ItemFood.junk = nil
ItemFood.useSound = {"npc/barnacle/barnacle_gulp1.wav", "npc/barnacle/barnacle_gulp2.wav"}

function ItemFood:Init()
	self.category = "Еда"

	self.stats = {
		container = false,
		thirst = 0,
		hunger = 0,
		uses = 1,
		freezeSpeed = 2 * 60 * 60, -- 2 hours
		unfreezeSpeed = 60 * 60, -- 1 hour
		--noExpire = true,
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

			item.player:EmitSound("foley/crushable/tin_can_break.mp3")
			return true
		end,
		OnCanRun = function(item) return (item:IsClosed() == true) end
	}
	self.functions.use = {
		name = "Съесть",
		OnRun = function(item)
			local uses = item:GetUses()
			local client, character = item.player, item.player:GetCharacter()

			character:UpdateNeeds(item.stats.thirst, item.stats.hunger)

			if item.stats.stamina then
				client:RestoreStamina(item.stats.stamina)
			end

			if item.stats.blood then
				character:SetBlood(math.min(character:GetBlood() + item.stats.blood, 5000))
			end

			if istable(item.useSound) then
				client:EmitSound(item.useSound[math.random(1, #item.useSound)])
			else
				client:EmitSound(item.useSound)
			end

			if item.CustomEffect then
				item:CustomEffect(client, 1)
			end

			if uses > 1 then
				item:SetData("uses", uses - 1)
			else
				local junk = item.junk

				if IsValid(item.entity) then
					local pos, ang = item.entity:GetPos(), item.entity:GetAngles()

					item.entity:Remove()

					if junk then
						local new_item = ix.Item:Instance(junk)

						ix.Item:Spawn(pos, ang, new_item)
					end
				else
					item:Remove()

					if junk then
						local new_item = ix.Item:Instance(junk)

						client:AddItem(new_item)
					end
				end
			end
		end,
		OnCanRun = function(item) return !item:IsClosed() end
	}
	self.functions.useall = {
		name = "Съесть всё",
		OnRun = function(item)
			local uses = item:GetUses()
			local client, character = item.player, item.player:GetCharacter()

			character:UpdateNeeds(item.stats.thirst * uses, item.stats.hunger * uses)

			if item.stats.stamina then
				client:RestoreStamina(item.stats.stamina * uses)
			end

			if item.stats.blood then
				character:SetBlood(math.min(character:GetBlood() + (item.stats.blood * uses), 5000))
			end

			if istable(item.useSound) then
				client:EmitSound(item.useSound[math.random(1, #item.useSound)])
			else
				client:EmitSound(item.useSound)
			end

			if item.CustomEffect then
				item:CustomEffect(client, uses)
			end

			local junk = item.junk
			local class = item.uniqueID
			
			if IsValid(item.entity) then
				local pos, ang = item.entity:GetPos(), item.entity:GetAngles()

				item.entity:Remove()
				
				if junk then
					local new_item = ix.Item:Instance(junk)

					ix.Item:Spawn(pos, ang, new_item)
				end
			else
				item:Remove()

				if junk then
					local new_item = ix.Item:Instance(junk)

					item.player:AddItem(new_item)
				end
			end
		end,
		OnCanRun = function(item) return !item:IsClosed() end
	}

	self:AddData("closed", {
		Transmit = ix.transmit.owner,
	})

	self:AddData("uses", {
		Transmit = ix.transmit.owner,
	})

	/*
	self:AddData("test", {
		Transmit = bit.bor(ix.transmit.closelook, ix.transmit.owner),
	})*/

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

function ItemFood:GetUses()
	return self:GetData("uses") or self.stats.uses
end

function ItemFood:IsClosed()
	if self.stats.container then
		return self:GetData("closed")
	end

	return false
end

function ItemFood:OnInstanced(isCreated)
	if isCreated then
		self:SetData("uses", self.stats.uses or 1)
		self:SetData("closed", self.stats.container or false)

		if !self:IsClosed() then
			self:StartRotProgress()
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

				if os.time() >= expirationDate then

				else
					expDateT = tooltip:AddRowAfter("name", "expirationDate")
					expDateT:SetBackgroundColor(derma.GetColor("Error", tooltip))
					expDateT:SetTextColor(derma.GetColor("Warning", expDateT))
					expDateT:SetText("Испортится через: " .. ParseDuration((expirationDate - os.time()) / 60))
				end
			end
			
			local uses = tooltip:AddRowAfter(expDateT and "expirationDate" or "name")
			uses:SetBackgroundColor(derma.GetColor("Success", tooltip))
			uses:SetText(L("usesDesc", self:GetUses(), self.stats.uses))
		end
	end
end

return ItemFood
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
		expireTime = 24 * 60 * 60,
		expireMultiplier = {
			cold = 2
		}
	}
	
	self.functions.open = {
		name = "Вскрыть",
		OnRun = function(item)
			item:SetData("closed", false)
			item:SetData("expire_time", os.time() + self.stats.expireTime)

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

	self:AddData("expire_time", {
		Transmit = ix.transmit.owner,
	})
	self:AddData("expire_delta", {
		Transmit = ix.transmit.owner,
	})
	self:AddData("expire_delta_time", {
		Transmit = ix.transmit.owner,
	})

	self:AddData("expire_mul_last", {
		Transmit = ix.transmit.owner,
	})
	self:AddData("expire_mul", {
		Transmit = ix.transmit.owner,
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
		self:SetData("expire_time", !self:IsClosed() and (os.time() + self.stats.expireTime) or 0)
	end
end

function ItemFood:CalculateExpireMultiplier()
	local dateDelta = self:GetData("expire_delta") or 0
	local dateDeltaTime = self:GetData("expire_delta_time") or 0

	local mul = 0

	if dateDeltaTime > 0 then
		mul = (1 - math.Clamp((((dateDelta + dateDeltaTime) - os.time()) / dateDeltaTime), 0, 1))
	end

	mul = math.Remap(mul, 0, 1, self:GetData("expire_mul_last") or 1, self:GetData("expire_mul") or 0)

	return mul
end

function ItemFood:OnTransfer(newInventory, oldInventory)
	self:SetData("expire_mul_last", self:CalculateExpireMultiplier())

	if !newInventory or newInventory.type != "container" then
		self:SetData("expire_delta", os.time())
		self:SetData("expire_delta_time", 24 * 60 * 60)
		self:SetData("expire_mul", 1)
	elseif newInventory and newInventory.type == "container" then
		self:SetData("expire_delta", os.time())
		self:SetData("expire_delta_time", 24 * 2 * 60 * 60)
		self:SetData("expire_mul", self.stats.expireMultiplier.cold)
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

	function ItemFood:PopulateTooltip(tooltip)
		if !self:GetEntity() then
			local expDateT

			if !self:IsClosed() then
				local expirationDate = (self:GetData("expire_time") or 0) * self:CalculateExpireMultiplier()

				expDateT = tooltip:AddRowAfter("name", "expirationDate")
				expDateT:SetBackgroundColor(derma.GetColor("Error", tooltip))
				expDateT:SetTextColor(derma.GetColor("Warning", expDateT))
				
				expDateT:SetText("Испортится через: " .. ParseDuration((expirationDate - os.time()) / 60))
			end
			
			local uses = tooltip:AddRowAfter(expDateT and "expirationDate" or "name")
			uses:SetBackgroundColor(derma.GetColor("Success", tooltip))
			uses:SetText(L("usesDesc", self:GetUses(), self.stats.uses))
		end
	end
end

return ItemFood
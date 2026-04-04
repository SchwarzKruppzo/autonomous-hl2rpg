local Reagents, hasFlag = ix.Reagents, bit.band

local ReagentHolder = class 'ReagentHolder'
ReagentHolder.reagent_holder = true

function ReagentHolder:__tostring() return 'ReagentHolder' end
function ReagentHolder:Init(maxVolume, flags)
	self.owner = nil

	self.volume = 0
	self.max_volume = maxVolume or 100
	self.reagents = {}
	self.flags = flags or 0

	self.addiction_tick = 1
	self.addiction_list = {}
end

function ReagentHolder:RecacheReagents()
	if !self.recached then
		self.cached_reagents = {}

		for id, reagent in ipairs(self.reagents) do
			self.cached_reagents[reagent.uniqueID] = id
		end

		self.recached = true
	end
end

function ReagentHolder:UpdateTotal(callUpdate)
	self.volume = 0

	for id, reagent in ipairs(self.reagents) do
		if reagent.volume < 0.1 then
			self:DeleteReagent(id)
		else
			self.volume = self.volume + reagent.volume
		end
	end

	if callUpdate then
		self:OnUpdate()
	end

	return self.volume
end

function ReagentHolder:OnUpdate()
	if self.owner and self.owner.OnReagentUpdateTotal then
		self.owner:OnReagentUpdateTotal(self.volume)
	end
end

function ReagentHolder:DeleteReagent(id)
	local reagent

	if isnumber(id) then
		reagent = self.reagents[id]
	else
		for num, _reagent in ipairs(self.reagents) do
			if _reagent.uniqueID == id then
				id = num
				reagent = _reagent
				break
			end
		end
	end

	if reagent then
		reagent = nil
		table.remove(self.reagents, id)
		self:UpdateTotal()

		self.recached = false
	end
end

function ReagentHolder:RemoveReagent(id, amount, noReaction)
	amount = amount or 0

	if amount <= 0 then
		return false
	end

	self:RecacheReagents()

	local reagent = self.reagents[id]
	if reagent then
		amount = math.Clamp(amount, 0, reagent.volume)
		reagent.volume = reagent.volume - amount

		self:UpdateTotal()

		if !noReaction then
			self:HandleReactions()
		end

		return true
	end

	return false
end

function ReagentHolder:AddReagent(reagentID, amount, reagentTemp, noReaction, noUpdate)
	amount = amount or 0
	reagentTemp = reagentTemp or 300

	if amount <= 0 then
		return false
	end

	local cached_total = self:UpdateTotal()
	if cached_total + amount > self.max_volume then
		amount = (self.max_volume - cached_total)

		if amount <= 0 then
			return false
		end
	end

	self:RecacheReagents()

	local id = self.cached_reagents[reagentID]
	if id then
		local reagent = self.reagents[id]
		reagent.volume = reagent.volume + amount
	else
		local reagent = ix.Reagents:New(reagentID)

		if !reagent then
			return false
		end

		reagent.holder = self
		reagent.volume = amount
		table.insert(self.reagents, reagent)

		self.recached = false
	end

	self:UpdateTotal(!noUpdate)

	if !noReaction then
		self:HandleReactions()
	end
end

function ReagentHolder:AddReagents(reagents)
	for reagentID, amount in pairs(reagents) do
		self:AddReagent(reagentID, amount, nil, nil, true)
	end

	self:OnUpdate()
end

function ReagentHolder:Transfer(target, amount, user, method, multiplier, noReaction)
	amount = amount or 1
	multiplier = multiplier or 1

	if amount < 0 then
		return
	end

	local targetOwner

	if target.reagent_holder then
		targetOwner = target.owner
	else
		if !target.reagents then
			return
		end

		targetOwner = target
		target = target.reagents
	end

	amount = math.min(math.min(amount, self.volume), target.max_volume - target.volume)
	local part = amount / self.volume

	for id, reagent in ipairs(self.reagents) do
		local transfer_amount = reagent.volume * part

		target:AddReagent(reagent.uniqueID, transfer_amount * multiplier, 300, true, true)
		self:RemoveReagent(id, transfer_amount)
	end

	self:UpdateTotal()
	target:UpdateTotal()

	if !noReaction then
		target:HandleReactions()
		self:HandleReactions()
	end

	self:OnUpdate()
	target:OnUpdate()

	return amount
end

function ReagentHolder:HandleReactions()
	if hasFlag(self.flags, Reagents.holder.noreact) then
		return
	end
end

function ReagentHolder:Serialize()
	local data = {}

	for _, reagent in ipairs(self.reagents) do
		data[#data + 1] = {id = reagent.uniqueID, volume = reagent.volume}
	end

	return data
end

function ReagentHolder:Deserialize(data)
	self.reagents = {}
	self.volume = 0
	self.recached = false

	if data then
		for _, entry in ipairs(data) do
			self:AddReagent(entry.id, entry.volume, 300, true, true)
		end
	end

	self:OnUpdate()
end

function ReagentHolder:Clear()
	self.reagents = {}
	self.volume = 0
	self.recached = false

	self:OnUpdate()
end

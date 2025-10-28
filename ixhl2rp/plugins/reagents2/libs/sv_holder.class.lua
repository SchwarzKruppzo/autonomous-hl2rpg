local Reagents, hasFlag = ix.Reagents, bit.band

local ReagentHolder = class 'ReagentHolder'
ReagentHolder.reagent_holder = true

function ReagentHolder:__tostring() return 'ReagentHolder' end
function ReagentHolder:Init(maxVolume, flags)
	self.owner = nil

	self.volume = 0
	self.max_volume = maxVolume or 100
	self.reagents = {}
	self.flags = flags

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

function ReagentHolder:UpdateTotal()
	self.volume = 0

	for id, reagent in ipairs(self.reagents) do
		if reagent.volume < 0.1 then
			self:DeleteReagent(id)
		else
			self.volume = self.volume + reagent.volume
		end
	end

	if self.owner and self.owner.OnReagentUpdateTotal then
		self.owner:OnReagentUpdateTotal(self.volume)
	end

	return self.volume
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
		/*if (my_atom && isliving(my_atom))
			var/mob/living/M = my_atom
			if(R.metabolizing)
				R.metabolizing = FALSE
				R.on_mob_end_metabolize(M)
			R.on_mob_delete(M)
		end*/
		
		reagent = nil
		table.remove(self.reagents, id)
		self:UpdateTotal()

		/*if (my_atom)
			my_atom.on_reagent_change(DEL_REAGENT)*/

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

		if !noReaction then //So it does not handle reactions when it need not to
			self:HandleReactions()
		end

		//if(my_atom)
		//	my_atom.on_reagent_change(REM_REAGENT)

		return true
	end
	
	return false
end

function ReagentHolder:AddReagent(reagentID, amount, reagentTemp, noReaction)
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
	
	local new_total = cached_total + amount

	self:RecacheReagents()

	/*
	var/cached_temp = chem_temp
	//Equalize temperature - Not using specific_heat() because the new chemical isn't in yet.
	var/specific_heat = 0
	var/thermal_energy = 0
	for(var/i in cached_reagents)
		var/datum/reagent/R = i
		specific_heat += R.specific_heat * (R.volume / new_total)
		thermal_energy += R.specific_heat * R.volume * cached_temp
	specific_heat += D.specific_heat * (amount / new_total)
	thermal_energy += D.specific_heat * amount * reagtemp
	chem_temp = thermal_energy / (specific_heat * new_total)
	*/

	local id = self.cached_reagents[reagentID]
	if id then
		local reagent = self.reagents[id]
		reagent.volume = reagent.volume + amount
		//R.on_merge(data, amount)
	else
		local reagent = ix.Reagents:New(reagentID)
		reagent.holder = self
		reagent.volume = amount
		table.insert(self.reagents, reagent)

		self.recached = false
	end

	self:UpdateTotal()

	if self.owner then
		--my_atom.on_reagent_change(ADD_REAGENT)
	end
	
	if !noReaction then
		self:HandleReactions()
	end
end

function ReagentHolder:AddReagents(reagents)
	for reagentID, amount in pairs(reagents) do
		self:AddReagent(reagentID, amount)
	end
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
		/*
		if(remove_blacklisted && !T.can_synth)
			continue
		*/

		local transfer_amount = reagent.volume * part

		target:AddReagent(reagent.uniqueID, transfer_amount * multiplier, 300, true)

		/*
		if(method)
			R.react_single(T, target_atom, method, part, show_message)
			T.on_transfer(target_atom, method, transfer_amount * multiplier)
		*/

		self:RemoveReagent(id, transfer_amount)
	end

	self:UpdateTotal()
	target:UpdateTotal()
	
	if !noReaction then
		target:HandleReactions()
		self:HandleReactions()
	end
	
	return amount
end

function ReagentHolder:HandleReactions()
	if hasFlag(self.flags, Reagents.holder.noreact) then
		return
	end
end

// TEST SECTION
/*


ix.meta.Reagent:Register("water", {})
ix.meta.Reagent:Register("chlore", {})

local holder1 = ReagentHolder:New(1000, 0)
local holder2 = ReagentHolder:New(1000, 0)
holder1:AddReagent("water", 500)
holder1:AddReagent("chlore", 500)
holder1:Transfer(holder2, 35)



PrintTable(holder2)*/
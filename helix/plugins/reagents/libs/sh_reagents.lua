local Reagents = ix.util.Lib("Reagents", {
	stored = {},
	solid = 1,
	liquid = 2,
	gas = 3,
	action = {
		touch = 1,
		ingest = 2,
		vapor = 3,
		patch = 4,
		inject = 5
	},
	holder = {
		injectable = 1,
		drawable = 2,
		refillable = 4,
		drainable = 8,
		transparent = 16,
		visible = 32,
		noreact = 64,
		open = 28 -- refillable | drainable
	},
})

ix.util.Include("sh_reagent.class.lua")
ix.util.Include("sv_holder.class.lua")

function Reagents:All() return self.stored end
function Reagents:Get(uniqueID) return self.stored[uniqueID] end

function Reagents:New(uniqueID)
	local reagentClass = self.stored[uniqueID]

	if reagentClass then
		local reagent = setmetatable({data = {}}, {
			__index = reagentClass,
			__eq = reagentClass.__eq,
			__tostring = reagentClass.__tostring
		})

		return reagent
	else
		ErrorNoHalt("[Helix] Attempt to instance unknown reagent '"..uniqueID.."'\n")
	end
end

function Reagents:Register(uniqueID, data, copy)
	if !uniqueID then
		ErrorNoHalt("[Helix] Attempt to register a reagent without a valid ID!\n")
		return
	end
	
	local reagent = ix.meta.Reagent:New(uniqueID)

	if copy then
		local baseData

		if istable(copy) then
			baseData = copy
		elseif isstring(copy) then
			baseData = self.stored[copy]
		end

		for k, v in pairs(baseData or {}) do
			reagent[k] = v
		end
	end

	for k, v in pairs(data) do
		reagent[k] = v
	end

	self.stored[uniqueID] = reagent

	return reagent
end

do
	local FLAGS = ix.Reagents.holder

	local function getFlags(target)
		if target.GetReagentFlags then
			return target:GetReagentFlags()
		end

		return target.reagent_flags or 0
	end

	function Reagents:IsRefillable(target)
		return (target.reagents or target.isReagentHolder) and bit.band(getFlags(target), FLAGS.refillable) == FLAGS.refillable
	end

	function Reagents:IsDrainable(target)
		return (target.reagents or target.isReagentHolder) and bit.band(getFlags(target), FLAGS.drainable) == FLAGS.drainable
	end

	function Reagents:IsDrawable(target)
		local flags = bit.band(getFlags(target), bit.bor(FLAGS.drawable, FLAGS.drainable))
		return (target.reagents or target.isReagentHolder) and ((flags == FLAGS.drainable) or (flags == FLAGS.drawable))
	end

	function Reagents:IsInjectable(target)
		local flags = bit.band(getFlags(target), bit.bor(FLAGS.injectable, FLAGS.refillable))
		return (target.reagents or target.isReagentHolder) and ((flags == FLAGS.refillable) or (flags == FLAGS.injectable))
	end

	function Reagents:IsOpenContainer(target)
		return self:IsRefillable(target) and self:IsDrainable(target)
	end
end

-- Consume a given volume from holder, return thirst/hunger values and apply effects
function Reagents:Consume(holder, amount, client)
	if !holder or holder.volume <= 0 then
		return 0, 0
	end

	amount = math.min(amount, holder.volume)
	local part = amount / holder.volume
	local totalThirst, totalHunger = 0, 0

	for id, reagent in ipairs(holder.reagents) do
		local reagentClass = self.stored[reagent.uniqueID]
		local consumed = reagent.volume * part

		if reagentClass then
			totalThirst = totalThirst + (reagentClass.thirst or 0) * consumed
			totalHunger = totalHunger + (reagentClass.hunger or 0) * consumed

			if reagentClass.OnConsume and IsValid(client) then
				reagentClass:OnConsume(client, consumed)
			end
		end

		holder:RemoveReagent(id, consumed, true)
	end

	holder:UpdateTotal(true)

	return totalThirst, totalHunger
end

local function BlendRGB(RGB1, RGB2, amount)
	RGB1.r = math.Round(RGB1.r + (RGB2.r - RGB1.r) * amount, 1)
	RGB1.g = math.Round(RGB1.g + (RGB2.g - RGB1.g) * amount, 1)
	RGB1.b = math.Round(RGB1.b + (RGB2.b - RGB1.b) * amount, 1)
end

function Reagents:GetMixedColor(reagents)
	local mixcolor
	local vol_counter = 0
	local vol_temp = 0

	if reagents then
		for _, info in ipairs(reagents) do
			local reagentClass = self.stored[info.id]
			local color = reagentClass.clr

			if isbool(color) and color == true then continue end
			
			vol_temp = info.volume
			vol_counter = vol_counter + vol_temp

			if !mixcolor then
				mixcolor = color
			else
				BlendRGB(mixcolor, color, vol_temp / vol_counter)
			end
		end
	end

	return mixcolor or color_white
end
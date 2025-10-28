local Reagents = ix.Reagents
local Reagent = class 'Reagent'

function Reagent:__tostring() return 'Reagent['..self.uniqueID..']' end
function Reagent:Init(uniqueID)
	self.uniqueID = uniqueID
end
function Reagent:Register(uniqueID, data, copy)
	if !uniqueID then
		ErrorNoHalt("[Helix] Attempt to register an reagent without a valid ID!\n")
		return
	end

	local reagent = self:New(uniqueID)
	
	if copy then
		local baseData

		if istable(copy) then
			baseData = copy
		elseif isstring(copy) then
			baseData = Reagents.stored[copy]
		end
		
		for k, v in pairs(baseData or {}) do
			reagent[k] = v
		end
	end
	
	for k, v in pairs(data) do
		reagent[k] = v
	end

	Reagents.stored[uniqueID] = reagent

	return reagent
end
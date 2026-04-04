local Reagents = ix.Reagents
local Reagent = class 'Reagent'

function Reagent:__tostring() return 'Reagent['..self.uniqueID..']' end
function Reagent:Init(uniqueID)
	self.uniqueID = uniqueID
	self.clr = true
end

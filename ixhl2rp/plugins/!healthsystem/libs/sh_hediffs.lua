local Hediffs = ix.util.Lib("Hediffs", {
	list = {}
})

Hediffs.network_list = {}
Hediffs.network_max = Hediffs.network_max or 0

function Hediffs:All() return self.list end
function Hediffs:Get(uniqueID) return self.list[uniqueID] end
function Hediffs:NetworkID(networkID) return self.list[self.network_list[networkID] or 0] end

function Hediffs:New(uniqueID, baseID)
	local object = ix.meta[baseID]:New()
	local networkID = #self.network_list + 1

	object.networkID = networkID
	object.uniqueID = uniqueID

	self.list[uniqueID] = object
	self.network_list[networkID] = uniqueID

	self.network_max = net.ChooseOptimalBits(networkID)

	return object
end

local PLUGIN = PLUGIN

util.AddNetworkString("clientprop.prop")
util.AddNetworkString("clientprop.recreate")
util.AddNetworkString("clientprop.clear")
util.AddNetworkString("clientprop.sync")

function PLUGIN:BroadcastProp(data)
	if !data then
		return
	end

	net.Start("clientprop.prop")
		net.WriteTable(data)
	net.Broadcast()
end


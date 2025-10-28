
local PLUGIN = PLUGIN

PLUGIN.nName = "N/A"
PLUGIN.aparts = "N/A"
PLUGIN.nRecords = 0
PLUGIN.cRecords = 0
PLUGIN.mRecords = 0
PLUGIN.status = "N/A"
PLUGIN.points = 0

net.Receive("ixTerminalResponse", function(len)
	local name = net.ReadString()
	local aparts = net.ReadString()
	local status = net.ReadString()
	local points = net.ReadInt(16)

	if (isstring(name)) then
		PLUGIN.nName = name
	end

	if (isstring(aparts)) then
		PLUGIN.aparts = aparts
	end
	
	if (isstring(status)) then
		PLUGIN.status = status
	end

	if (isnumber(points)) then
		PLUGIN.points = points
	end
end)
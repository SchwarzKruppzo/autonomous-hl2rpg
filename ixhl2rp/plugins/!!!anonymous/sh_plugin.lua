local PLUGIN = PLUGIN

PLUGIN.name = "Disabled Anonymous System"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

do
	local PLAYER = FindMetaTable("Player")

	function PLAYER:GetAnonID()
		return self:SteamID()
	end
end
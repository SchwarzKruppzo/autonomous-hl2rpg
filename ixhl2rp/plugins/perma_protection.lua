local PLUGIN = PLUGIN

PLUGIN.name = "Perma All Protection"
PLUGIN.description = "Utilities to prevent Perma All errors and abuse."
PLUGIN.author = "maxxoft"

if SERVER then
	ix.log.AddType("permaall", function(client, entity)
		return L("%s used Perma All on %s.", client:Name(), tostring(entity))
	end, FLAG_NORMAL)

	function PLUGIN:CanTool(ply, trace, toolname)
		local entity = trace.Entity

		if IsValid(entity) and toolname == "permaall" then
			if string.StartWith(entity:GetClass(), "ix_") then
				return false
			end
		end
	end
end

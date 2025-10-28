local PLUGIN = PLUGIN

PLUGIN.name = "Dupe Protection"
PLUGIN.description = ""
PLUGIN.author = ""

if SERVER then
	function PLUGIN:CanTool(ply, trace, toolname)
		local entity = trace.Entity

		if IsValid(entity) and toolname == "duplicator" then
			if string.StartWith(entity:GetClass(), "ix_") then
				return false
			end
		end
	end
end


local PLUGIN = PLUGIN

PLUGIN.name = "Edict Limit Checker"
PLUGIN.author = "alexgrist"
PLUGIN.description = "Prevents multiple entity type spawns when close to edict limit."

ix.lang.AddTable("ru", {
	["edictlimit.tooClose"] = "Сервер слишком близок к лимиту edict, чтобы создать это!",
})
ix.lang.AddTable("en", {
	["edictlimit.tooClose"] = "The server is too close to the edict limit to spawn this!",
})
ix.lang.AddTable("fr", {
	["edictlimit.tooClose"] = "Le serveur est trop proche de la limite d'edict pour créer ceci !",
})
ix.lang.AddTable("es-es", {
	["edictlimit.tooClose"] = "¡El servidor está demasiado cerca del límite de edict para crear esto!",
})

function PLUGIN:CheckEdictLimit(client, class)
	local bEditLimit = ents.GetEdictCount() >= 7900

	if (bEditLimit) then
		ErrorNoHalt(string.format("[Helix] %s attempted to spawn '%s' but edict limit is too high!\n", client:Name(), class))
			client:NotifyLocalized("edictlimit.tooClose")
		return false
	end
end

PLUGIN.PlayerSpawnObject = PLUGIN.CheckEdictLimit

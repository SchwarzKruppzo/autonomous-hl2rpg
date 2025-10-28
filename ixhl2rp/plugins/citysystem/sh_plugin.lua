local PLUGIN = PLUGIN

ix.util.Include("sv_city.class.lua")

function PLUGIN:LoadData()
	local city = ix.meta.City:New("main")

	print("Created City.")

	hook.Run("InitializeCities")
end
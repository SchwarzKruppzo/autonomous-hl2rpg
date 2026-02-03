--[[--
Multi-language phrase support.

Languages will be loaded from the schema and any plugins in `languages/languagename.lua`. The structure of a language file is a table of phrases with the key
as its phrase ID and the value as its translation for that language. For example, in `plugins/area/languages/english.lua`:
	ix.Locale:Build("en") -- gmod internal language id is used

	area = "Area",
	areas = "Areas",
	areaEditMode = "Area Edit Mode",
	-- etc.


The phrases defined in these language files can be used with the `L` global function:
	print(L("areaEditMode"))
	> Area Edit Mode

All phrases are formatted with `string.format`, so if you wish to add some info in a phrase you can use standard Lua string
formatting arguments:
	print(L("areaDeleteConfirm", "Test"))
	> Are you sure you want to delete the area "Test"?

Phrases are also usable on the server, but only when trying to localize a phrase based on a client's preferences. The server
does not have a set language. An example:
	Entity(1):ChatPrint(L("areaEditMode"))
	> -- "Area Edit Mode" will print in the player's chatbox
]]

local Locale = ix.util.Lib("Locale", {
	stored = {
		en = {}
	},
	lang = nil
})

local stored = Locale.stored -- or {}
--Locale.stored = stored

function Locale:AddTable(lang, data)
	lang = tostring(lang):lower()

	if isfunction(data) then
		self:Build(lang, data)

		data()
	else
		stored[lang] = table.Merge(stored[lang] or {}, data)
	end
end

function Locale:Build(lang, fEnv)
	local data = {}
	local reverseData = {}

	stored[lang] = stored[lang] or {}

	local builder 
	builder = {
		__index = function(self, subCategory)
			local subID = string.format("%s%s.", reverseData[self] or "", subCategory)

			if data[subID] then return data[subID] end

			local category = setmetatable({}, builder)
			reverseData[category] = subID
			data[subID] = category

			return category
		end,
		__newindex = function(self, key, value)
			local subID = string.format("%s%s", reverseData[self] or "", key)

			stored[lang][subID] = value
		end
	}

	local object = setmetatable({}, builder)
	setfenv(fEnv and fEnv or 2, object)

	return object
end

if SERVER then
	function l(key, ...) -- this is for serverside naming (logs and such)
		local info = stored.en

		return string.format(info and info[key] or key, ...)
	end
	
	function L(key, client, ...)
		local langKey = client:GetInfo("gmod_language")
		local info = stored[langKey] or stored.en

		return string.format(info and info[key] or stored.en[key] or key, ...)
	end

	function L2(key, client, ...)
		local langKey = client:GetInfo("gmod_language")
		local info = stored[langKey] or stored.en

		if info and info[key] then
			return string.format(info[key], ...)
		end
	end
else
	Locale.lang = Locale.lang or GetConVar("gmod_language"):GetString()

	function L(key, ...)
		local info = stored[Locale.lang] or stored.en

		return string.format(info and info[key] or stored.en[key] or key, ...)
	end

	function L2(key, ...)
		local info = stored[Locale.lang] or stored.en

		if info and info[key] then
			return string.format(info[key], ...)
		end
	end

	cvars.AddChangeCallback("gmod_language", function(convar_name, value_old, value_new)
	    Locale.lang = value_new
	end)
end

function Locale:LoadFromDir(directory)
	for _, v in ipairs(file.Find(directory.."/*.lua", "LUA")) do
		local id = v:sub(0, -5):lower()

		ix.util.Include(directory.."/"..v, "shared")
	end
end

-- backward compatibility (will be removed lately)
ix.lang = ix.lang or {}
ix.lang.AddTable = function(lang, data) Locale:AddTable(lang, data) end
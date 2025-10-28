PLUGIN.name = "Cooking"
PLUGIN.author = ""
PLUGIN.description = ""


ix.Craft:LoadFromDir(PLUGIN.folder.."/stations", "station")
ix.Craft:LoadFromDir(PLUGIN.folder.."/cooking", "recipe", "Кулинария")
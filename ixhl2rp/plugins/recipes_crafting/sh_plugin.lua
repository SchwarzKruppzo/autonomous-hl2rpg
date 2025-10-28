PLUGIN.name = "Recipes"
PLUGIN.author = ""
PLUGIN.description = ""

for i = 0, 10 do
	ix.Craft:LoadFromDir(PLUGIN.folder.."/tailoring/"..i, "recipe")
end

for i = 0, 10 do
	ix.Craft:LoadFromDir(PLUGIN.folder.."/crafting/"..i, "recipe")
end

for i = 0, 10 do
	ix.Craft:LoadFromDir(PLUGIN.folder.."/electric/"..i, "recipe")
end

for i = 0, 10 do
	ix.Craft:LoadFromDir(PLUGIN.folder.."/medical/"..i, "recipe")
end
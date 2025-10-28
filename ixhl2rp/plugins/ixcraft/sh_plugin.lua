local PLUGIN = PLUGIN

PLUGIN.name = "Better Crafting"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = "Adds a better crafting solution to helix."

if CLIENT then
	surface.CreateFont("ui.craft.large", {
		font = "Blender Pro Medium",
		extended = true,
		size = ix.UI.Scale(19),
		weight = 550,
		antialias = true,
	})
	surface.CreateFont("ui.craft.xp", {
		font = "Blender Pro Bold",
		extended = true,
		size = ix.UI.Scale(15),
		weight = 550,
		antialias = true,
	})
	surface.CreateFont("craft.item.title", {
		font = "Blender Pro Medium",
		extended = true,
		size = ix.UI.Scale(24),
		weight = 500,
		antialias = true,
	})
	surface.CreateFont("craft.item.key", {
		font = "Blender Pro Bold",
		extended = true,
		size = ix.UI.Scale(21),
		weight = 500,
		antialias = true,
	})
	surface.CreateFont("craft.item.value", {
		font = "Blender Pro Medium",
		extended = true,
		size = ix.UI.Scale(21),
		weight = 500,
		antialias = true,
	})
	surface.CreateFont('craft.component.count', {
		font = 'Blender Pro Bold',
		extended = true,
		size = ix.UI.Scale(24),
		weight = 500,
		antialias = true,
	})
	surface.CreateFont('craft.button', {
		font = 'Blender Pro Bold',
		extended = true,
		size = ix.UI.Scale(24),
		weight = 500,
		antialias = true,
	})
end

ix.util.Include("sh_recipe.class.lua", "shared")
ix.util.Include("sh_station.class.lua", "shared")

ix.util.Include("sh_hooks.lua", "shared")
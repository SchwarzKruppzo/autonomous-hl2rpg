function PLUGIN:LoadFonts(font, genericFont)
	surface.CreateFont("autonomous.hud.lvl", {
		font = "Blender Pro Bold",
		extended = true,
		size = ix.UI.Scale(28),
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
	})

	surface.CreateFont("autonomous.hud.lvltext", {
		font = "Blender Pro Heavy",
		extended = true,
		size = ix.UI.Scale(12),
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
	})
end
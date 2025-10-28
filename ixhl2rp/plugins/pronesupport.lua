local PLUGIN = PLUGIN

PLUGIN.name = "Prone Support"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

function PLUGIN:DoPlayerDeath(player)
	if player:IsProne() then
		prone.Exit(player)
	end
end

function PLUGIN:PlayerLoadedCharacter(player)
	if player:IsProne() then
		prone.Exit(player)
	end
end
/*
local colorModify = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0.1,
	["$pp_colour_contrast"] = 0.75,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}
local vignette = Material("helix/gui/vignette.png")
local clr = Color(128, 128, 150, 64)

hook.Add("RenderScreenspaceEffects", "event", function()
	
	DrawColorModify(colorModify)


	surface.SetMaterial(vignette)
	surface.SetDrawColor(clr)
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
end)*/
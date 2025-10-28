local PLUGIN = PLUGIN

PLUGIN.name = "Outlands Warfare"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

ix.Net:AddPlayerVar("inOutlands", true, nil, ix.Net.Type.Bool)

do
	local META = FindMetaTable("Player")

	function META:InOutlands()
		return false
	end
end

if SERVER then
	function PLUGIN:InitPostEntity()
		/*
		if game.GetMap() == "autonomous_city8_c" then
			local zone = ents.Create("outland_zone")
			zone:Spawn()
			zone:SetupZone(Vector(-1922, 164, -655), Vector(-11974, -15409, 1135))
		end*/
	end
	/*
	local staticMat = CreateMaterial("outlandnoise", "UnlitGeneric", {
		["$basetexture"] = "vgui/grain",
		["$vertexalpha"] = 1,
		["$vertexcolor"] = 1,
		["$additive"] = 1,
		["Proxies"] = {
			["AnimatedTexture"] = {
				["animatedtexturevar"] = "$basetexture",
				["animatedtextureframenumvar"] = "$frame",
				["animatedtextureframerate"] = "20"
			},
		}
	})

	local alpha = 0
	function PLUGIN:HUDPaint()
		if LocalPlayer():InOutlands() then
			alpha = Lerp(FrameTime(), alpha, 4)
		else
			alpha = Lerp(FrameTime(), alpha, 0)
		end

		if alpha <= 0 then
			return
		end

		local w, h = ScrW(), ScrH()

		surface.SetDrawColor(255, 255, 255, alpha)
		surface.SetMaterial(staticMat)

		for i = 1, 3 do
			surface.DrawTexturedRect(0, 0, w, h)
		end
	end*/
end
PLUGIN.name = "Local Sound"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = "Provides a command to broadcast audio within a defined proximity range."

ix.lang.AddTable("english", {
    cmdLocalSound = "Broadcast audio within a specified proximity."
})

ix.lang.AddTable("russian", {
    cmdLocalSound = "Воспроизвести аудио в заданном радиусе действия."
})

ix.command.Add("LocalSound", {
	description = "@cmdLocalSound",
	adminOnly = true,
	arguments = {
		ix.type.string,
		bit.bor(ix.type.number, ix.type.optional)
	},
	OnRun = function(_, client, sound, radius)
		radius = (radius and radius != "") and radius or 260000

		local pos = client:GetPos()
		local players = {}

		for _, v in ipairs(player.GetAll()) do
			if (pos - v:GetPos()):LengthSqr() <= radius then
				players[#players + 1] = v
			end
		end

		if #players <= 0 then
			return
		end

		net.Start("localsound.play")
			net.WriteString(sound)
		net.Send(players)
	end
})

if SERVER then
	util.AddNetworkString("localsound.play")

	return
end

local sphereColor = Color(255, 150, 0, 100)

function PLUGIN:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if bDrawingDepth or bDrawingSkybox then
		return
	end

	if ix.chat.currentCommand == "localsound" then
		render.SetColorMaterial()
		render.DrawSphere(LocalPlayer():GetPos(), -(tonumber(ix.chat.currentArguments[2]) or 512), 24, 24, sphereColor)
	end
end

net.Receive("localsound.play", function()
	surface.PlaySound(net.ReadString())
end)
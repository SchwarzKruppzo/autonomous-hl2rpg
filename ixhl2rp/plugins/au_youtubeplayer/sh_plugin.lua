PLUGIN.name = "Yoube Player"
PLUGIN.author = "Krieg & Schwarz Kruppzo"
PLUGIN.description = "Play videos and song from YouTube links."

ix.util.Include("cl_hooks.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")

ix.lang.AddTable("english", {
cmdPlaySong = "Проиграть песню с YouTube для каждого игрока на сервере.",
cmdStopSong = "Остановить текущую песню с YouTube.",
songPlaying = "Вы начали воспроизведение песни.",
songStopped = "Вы остановили текущую песню.",
invalidURL = "Это недействительная ссылка на видео YouTube!"
})

do
	local COMMAND = {}
	COMMAND.description = "@cmdPlaySong"
	COMMAND.adminOnly = true

	COMMAND.arguments = {
		ix.type.string,
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional)
	}

	COMMAND.argumentNames = {
		"Song URL",
		"Start Time",
		"Radius"
	}

	function COMMAND:OnRun(client, url, time, radius)
		time = time or 0

		if (!string.find(url, "https://www.youtube.com/watch?v", 1, true) and !string.find(url, "https://youtu.be/", 1, true)) then
			return "@invalidURL"
		end

		if (radius) then
			local receivers = {}

			for _, player in pairs(ents.FindInSphere(client:GetPos(), radius)) do
				if (!IsValid(player) or !player:IsPlayer()) then continue end

				receivers[#receivers + 1] = player
			end

			net.Start("YoutubePlayerPlay")
			net.WriteString(url)
			net.WriteFloat(time)
			net.Send(receivers)
		else
			net.Start("YoutubePlayerPlay")
			net.WriteString(url)
			net.WriteFloat(time)
			net.Broadcast()
		end

		return "@songPlaying"
	end

	ix.command.Add("PlaySong", COMMAND)
end

do
	local COMMAND = {}
	COMMAND.description = "@cmdStopSong"
	COMMAND.adminOnly = true

	function COMMAND:OnRun(client)
		net.Start("YoutubePlayerStop")
		net.Broadcast()

		return "@songStopped"
	end

	ix.command.Add("StopSong", COMMAND)
end

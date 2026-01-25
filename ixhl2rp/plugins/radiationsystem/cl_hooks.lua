local PLUGIN = PLUGIN

do -- remove after HUD update
	ix.bar.Add(function()
		local client = LocalPlayer()
		local character = client:GetCharacter()

		if character then
			local radLevel = client:GetNetVar("radDmg") or 0
			local geiger = client:HasGeigerCounter()

			if geiger and radLevel > 0 then
				return (radLevel / 100)
			end
		end
	end, "cellar/ui/geiger.png", 7, "geiger")

	ix.bar.Add(function()
		local client = LocalPlayer()
		local character = client:GetCharacter()

		if character then
			local filter = client:HasWearedFilter()

			if filter then
				filter = ix.Item.instances[filter]
				
				return filter:GetFilterQuality() / filter.filterQuality
			end
		end
	end, "cellar/ui/filter.png", 8, "filter")
end

timer.Create("ixGeigerThink", 0.06, 0, function()
	if IsValid(LocalPlayer()) and LocalPlayer():GetCharacter() then
		PLUGIN:GeigerThink(LocalPlayer():GetCharacter())
	end
end)

do
	local sounds = {
		[1] = {
			Sound("player/geiger1.wav"),
			Sound("player/geiger2.wav")
		},
		[2] = {
			Sound("player/geiger2.wav"),
			Sound("player/geiger3.wav")
		}
	}

	local pct = 0
	local flvol = 0
	local highsound = 0

	function PLUGIN:GeigerThink(character)
		local client = LocalPlayer()
		local radDmg = client:GetNetVar("radDmg")

		if !radDmg then
			return
		end

		if !client:HasGeigerCounter() then
			return
		end

		if radDmg > 199 then
			pct = 90
			flvol = 0.475
		elseif radDmg > 140 then
			pct = 80
			flvol = 0.45
		elseif radDmg > 90 then
			pct = 60
			flvol = 0.425
		elseif radDmg > 49 then
			pct = 40
			flvol = 0.4
		elseif radDmg > 24 then
			pct = 28
			flvol = 0.39
		elseif radDmg > 19 then
			pct = 8
			flvol = 0.35
		elseif radDmg > 9 then
			pct = 8
			flvol = 0.3
		elseif radDmg > 5 then
			pct = 4
			flvol = 0.25
		elseif radDmg > 0 then
			pct = 2
			flvol = 0.2
		end

		if radDmg > 19 then
			highsound = 2
		else
			highsound = 1
		end

		flvol = (flvol * (math.random(0, 127)) / 255) + 0.25

		if math.random(0, 127) < pct then
			LocalPlayer():EmitSound(sounds[highsound][math.random(1, 2)], 80, math.random(90, 110), flvol)
		end
	end
end
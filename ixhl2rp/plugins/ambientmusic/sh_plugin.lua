local PLUGIN = PLUGIN

PLUGIN.name = "Ambient Music"
PLUGIN.description = "Ambient Music"
PLUGIN.author = "Schwarz Kruppzo"

if SERVER then 
	return
end

local timerID = "ixAmbient"
local ambients = {
	[1] = {"autonomous/ambient/ambient_1.ogg", 95},
	//[2] = {"autonomous/ambient/ambient_2.ogg", 447},
	[2] = {"autonomous/ambient/ambient_3.ogg", 185},
	[3] = {"autonomous/ambient/ambient_4.ogg", 190},
	[4] = {"autonomous/ambient/ambient_5.ogg", 162},
	[5] = {"autonomous/ambient/ambient_6.ogg", 252},
	[6] = {"autonomous/ambient/ambient_7.ogg", 198},
	[7] = {"autonomous/ambient/ambient_8.ogg", 169},
	[8] = {"autonomous/ambient/ambient_9.ogg", 286},
	[9] = {"autonomous/ambient/ambient_10.ogg", 264},
	[10] = {"autonomous/ambient/ambient_11.mp3"},
	//[12] = {"autonomous/ambient/ambient_12.mp3"},
	[11] = {"autonomous/ambient/ambient_13.ogg", 198},
	[12] = {"autonomous/ambient/ambient_14.ogg", 268},
	[13] = {"autonomous/ambient/ambient_30.mp3"},
	[14] = {"autonomous/ambient/ambient_16.ogg", 179},
	//[17] = {"autonomous/ambient/ambient_17.ogg", 411},
	[15] = {"autonomous/ambient/ambient_18.mp3"},
	//[19] = {"autonomous/ambient/ambient_19.mp3"},
	[16] = {"autonomous/ambient/ambient_20.mp3"},
	//[17] = {"autonomous/ambient/ambient_21.mp3"},
	[17] = {"autonomous/ambient/ambient_22.ogg", 351},
	[18] = {"autonomous/ambient/ambient_23.ogg", 437},
	//[24] = {"autonomous/ambient/ambient_24.ogg", 505},
	[19] = {"autonomous/ambient/ambient_25.ogg", 286},
	[20] = {"autonomous/ambient/ambient_26.ogg", 328},
	[21] = {"autonomous/ambient/ambient_27.mp3"},
	[22] = {"autonomous/ambient/ambient_28.mp3"},
	[23] = {"autonomous/ambient/ambient_29.mp3"},
}

local function SetVolume(volume)
	if PLUGIN.snd then 
		PLUGIN.snd:ChangeVolume(volume)
	end
end

local function StopAmbient()
	if timer.Exists(timerID) then
		timer.Remove(timerID)
	end

	if PLUGIN.snd then
		PLUGIN.snd:Stop()
		PLUGIN.snd = nil
	end
end

local function PlayAmbient(ambientData)
	StopAmbient()

	PLUGIN.snd = CreateSound(LocalPlayer(), ambientData[1])
	PLUGIN.snd:Play()
	
	timer.Simple(0, function()
		PLUGIN.snd:ChangeVolume(ix.option.Get("ambientVol"), 0)
	end)

	local time = ambientData[2]

	if !time then
		time = SoundDuration(ambientData[1])
	end
	
	timer.Create(timerID, time + ix.option.Get("ambientTime", 0), 1, function()
		PlayAmbient(ambients[math.random(1, #ambients)])
	end)
end

function PLUGIN:CharacterLoaded(character)
	if timer.Exists(timerID) or !ix.option.Get("ambientToggle") then
		return
	end

	PlayAmbient(ambients[math.random(1, #ambients)])
end

ix.option.Add("ambientToggle", ix.type.bool, true, {
	category = "Музыка",
	OnChanged = function(_, value)
		if !value then
			StopAmbient()
			return
		end

		PlayAmbient(ambients[math.random(1, #ambients)])
	end
})

ix.option.Add("ambientVol", ix.type.number, 1, {
	category = "Музыка",
	decimals = 2,
	min = 0.01, 
	max = 1, 
	OnChanged = function(_, value)
		SetVolume(value)
	end
})

ix.option.Add("ambientTime", ix.type.number, 0, {
	category = "Музыка",
	decimals = 0,
	min = 0, 
	max = 600
})

ix.lang.AddTable("english", {
	optAmbientToggle = "Toggle music",
	optAmbientVol = "Music volume",
	optAmbientTime = "Time between music (sec)",
})

ix.lang.AddTable("russian", {
	optAmbientToggle = "Включить музыку",
	optAmbientVol = "Громкость музыки",
	optAmbientTime = "Время между музыкой (сек)"
})
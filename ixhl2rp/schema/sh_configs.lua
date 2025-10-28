ix.config.language = "russian"

ix.config.SetDefault("scoreboardRecognition", true)
ix.config.SetDefault("music", "music/hl2_song19.mp3")
ix.config.SetDefault("maxAttributes", 60)

ix.config.Add("rationInterval", 300, "How long a person needs to wait in seconds to get their next ration", nil, {
	data = {min = 0, max = 86400},
	category = "economy"
})

ix.option.Add("ColorModify", ix.type.bool, true, {
    category = "general"
})

ix.option.Add("ColorSaturation", ix.type.number, 0, {
	category = "general",
	min = -3, max = 3, decimals = 2
})

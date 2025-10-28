PLUGIN.name = "Enhanced Visuals"
PLUGIN.author = ""
PLUGIN.description = ""

ix.lang.AddTable("russian", {
	optEnableLensFlare = "Включить блики света",
	optdEnableLensFlare = "Включает реалистичные блики от источников света на экране.",

	optEnableDirtyLens = "Включить следы пыли",
	optdEnableDirtyLens = "Включает эффект постобработки загрязнённого экрана у источников света.",

	optEnableChromaticAberration = "Включить хроматическую аберрацию",
	optdEnableChromaticAberration = "Включает эффект постобработки хроматических аберраций, делая цвета более насыщенными и приятными.",

	optEnableFilmGrain = "Включить зернистость",
	optdEnableFilmGrain = "Включает эффект зернистости экрана для большего погружения.",
})

ix.util.IncludeDir(PLUGIN.folder .. "/effects", true)
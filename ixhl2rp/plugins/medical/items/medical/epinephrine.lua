ITEM.name = "item.epinephrine"
ITEM.description = "item.epinephrine.desc"
ITEM.model = Model("models/items/adrenaline.mdl")
ITEM.useSound = "items/medshot4.wav"
ITEM.rarity = 1
ITEM.stats.uses = 1
ITEM.stats.time = 5
ITEM.iconCam = {
	pos = Vector(88.934715270996, 1.296471953392, 94.069549560547),
	ang = Angle(46.604175567627, 180.83518981934, 0),
	fov = 3.5272163345147,
}

function ITEM:OnConsume(player, injector, mul, character)
	local health = character:Health()
	local effect = 500

	health:AddHediff("epinephrine", 0, {severity = effect, tended_start = os.time(), tended_time = (5 * 60)})

	return {dmg = effect * 2}
end

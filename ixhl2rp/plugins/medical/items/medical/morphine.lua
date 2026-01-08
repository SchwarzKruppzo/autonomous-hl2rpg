ITEM.name = "item.morphine"
ITEM.description = "item.morphine.desc"
ITEM.model = Model("models/items/morphine.mdl")
ITEM.useSound = "items/medshot4.wav"
ITEM.cost = 100
ITEM.rarity = 1
ITEM.stats.uses = 1
ITEM.stats.time = 5
ITEM.iconCam = {
	pos = Vector(88.934715270996, 1.296471953392, 94.069549560547),
	ang = Angle(46.604175567627, 180.83518981934, 0),
	fov = 3.5272163345147,
}
function ITEM:OnConsume(player, injector, mul, character)
	local fractures = {}
	local health = character:Health()
	for k, v in health:GetHediffs() do
		if !v.isFracture then continue end
		if v.tended_time != -1 then continue end
	
		fractures[#fractures + 1] = {diff = v, severity = v.severity}
	end
	
	local healed = 0
	if #fractures > 0 then
		table.sort(fractures, function(a, b) return a.severity > b.severity end)

		local fracture = fractures[1]
		healed = fracture.severity
		health:TendHediff(fracture.diff, (30 * 60) * mul)
	end

	return {limbs = healed}
end
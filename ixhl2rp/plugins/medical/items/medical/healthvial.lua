ITEM.name = "item.healthvial"
ITEM.description = "item.healthvial.desc"
ITEM.model = Model("models/healthvial.mdl")
ITEM.useSound = "items/medshot4.wav"
ITEM.width = 1
ITEM.height = 2
ITEM.cost = 25
ITEM.rarity = 2
ITEM.stats.uses = 2
ITEM.stats.time = 4
ITEM.iconCam = {
	pos = Vector(123.89707946777, 99.985893249512, 30.968715667725),
	ang = Angle(9.3186264038086, 218.95657348633, 0),
	fov = 4.1192625650593,
}

function ITEM:OnConsume(player, injector, mul, character)
	local health = character:Health()
	local injuries = {}

	for k, v in health:GetHediffs() do
		if v.part == 1 or !v.isInjury then continue end
		if v.tended_time != -1 then continue end
		if v.isFracture then continue end

		injuries[#injuries + 1] = {diff = v, severity = v.severity}
	end

	table.sort(injuries, function(a, b) return a.severity > b.severity end)

	local dmg = 0
	for i = 1, math.min(#injuries, 6) do
		local injury = injuries[i]

		if injury then
			dmg = dmg + (injury.severity or 0)
			health:TendHediff(injury.diff, (9 * 60) * mul)
		end
	end

	local effect = 10

	health:AddHediff("painkiller", 0, {severity = effect, tended_start = os.time(), tended_time = 2 * 60})

	return {dmg = dmg}
end

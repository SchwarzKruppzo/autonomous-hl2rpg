ITEM.name = "Аптечка Альянса"
ITEM.description = "Белый корпус с отсеками и различными медикаментами."
ITEM.model = Model("models/items/healthkit.mdl")
ITEM.useSound = "items/medshot4.wav"
ITEM.width = 2
ITEM.height = 2
ITEM.cost = 60
ITEM.rarity = 2
ITEM.stats.uses = 2
ITEM.stats.time = 10
ITEM.iconCam = {
	pos = Vector(28.298963546753, -0.043933738023043, 267.57727050781),
	ang = Angle(85.041488647461, 179.86787414551, 0),
	fov = 4.1649766122667,
}

function ITEM:OnConsume(player, injector, mul, character)
	local health = character:Health()
	local injuries = {}

	for k, v in health:GetHediffs() do
		if v.part == 1 or !v.isInjury then continue end
		if v.tended_time != -1 then continue end

		injuries[#injuries + 1] = {diff = v, severity = v.severity}
	end

	table.sort(injuries, function(a, b) return a.severity > b.severity end)

	local dmg = 0
	for i = 1, math.min(#injuries, 10) do
		local injury = injuries[i]

		if injury then
			dmg = dmg + (injury.severity or 0)
			health:TendHediff(injury.diff, (5 * 60) * mul)
		end
	end

	local effect = 10

	health:AddHediff("painkiller", 0, {severity = effect, tended_start = os.time(), tended_time = 2 * 60})

	return {dmg = dmg}
end
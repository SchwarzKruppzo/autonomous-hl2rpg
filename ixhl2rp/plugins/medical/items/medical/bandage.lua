ITEM.name = "item.bandage"
ITEM.description = "item.bandage.desc"
ITEM.model = Model("models/items/bandage.mdl")
ITEM.cost = 10
ITEM.iconCam = {
	pos = Vector(-167.40382385254, -0.16497099399567, 140.79614257813),
	ang = Angle(40.075763702393, 360.03671264648, 0),
	fov = 1.8319713266188,
}
ITEM.stats.uses = 5
ITEM.stats.time = 5

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
	for i = 1, 3 do
		local injury = injuries[i]

		if injury then
			dmg = dmg + (injury.severity or 0)
			health:TendHediff(injury.diff, (10 * 60) * mul)
		end
	end

	return {dmg = dmg}
end

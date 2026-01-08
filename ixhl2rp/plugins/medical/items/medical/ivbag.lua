ITEM.name = "item.ivbag"
ITEM.description = "item.ivbag.desc"
ITEM.model = Model("models/mosi/fallout4/props/aid/ivbag.mdl")
ITEM.useSound = "items/medshot4.wav"
ITEM.cost = 150
ITEM.rarity = 1
ITEM.stats.uses = 5
ITEM.stats.time = 10
ITEM.iconCam = {
	pos = Vector(162.76905822754, 197.76336669922, 2.9629125595093),
	ang = Angle(0.583087682724, 230.23713684082, 0),
	fov = 2.7800909388313,
}

function ITEM:OnConsume(player, injector, mul, character)
	local health = character:Health()
	local bloodLoss

	for k, v in health:GetHediffs() do
		if v.part != 1 then continue end
		if v.uniqueID == "bleeding" then 
			bloodLoss = v
			break
		end
	end

	local blood = 0

	if bloodLoss then
		bloodLoss:AdjustSeverity(-0.08)

		blood = 80
	end

	return {dmg = blood}
end
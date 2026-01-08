ITEM.name = "item.bloodbag"
ITEM.description = "item.bloodbag.desc"
ITEM.model = Model("models/props_rpd/medical_blood.mdl")
ITEM.useSound = "items/medshot4.wav"
ITEM.cost = 200
ITEM.rarity = 1
ITEM.stats.uses = 5
ITEM.stats.time = 10
ITEM.iconCam = {
	pos = Vector(-148.11582946777, 0.50422221422195, 87.833724975586),
	ang = Angle(29.304153442383, -0.269710958004, 0),
	fov = 2.0882739584414,
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
		bloodLoss:AdjustSeverity(-0.12)

		blood = 120
	end

	return {dmg = blood}
end
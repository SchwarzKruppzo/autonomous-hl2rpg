ITEM.name = "Пакет крови"
ITEM.description = "Пакет крови, используемый для переливания крови."
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
	local blood = character:GetBlood()
	local newBlood = math.Clamp(blood + 600, -1, 5000)

	character:SetBlood(newBlood)

	return {blood = (newBlood - blood)}
end

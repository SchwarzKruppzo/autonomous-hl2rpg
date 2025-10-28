ITEM.name = "Морфин"
ITEM.description = "Автоинъектор морфина. Используется для внутримышечной инъекции для лечения сильной боли, такой как переломы."
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
	local healedLimbs = 0
	local limbs = character:GetLimbData()
	for k, v in pairs(limbs) do
		healedLimbs = healedLimbs + (10 - math.max(10 - v, 0))
	end

	local rightLeg = character:GetLimbDamage(HITGROUP_RIGHTLEG)
	local leftLeg = character:GetLimbDamage(HITGROUP_LEFTLEG)

	character:HealLimbs(10)

	if rightLeg > 80 then
		character:HealLimbDamage(HITGROUP_RIGHTLEG, 100)

		healedLimbs = healedLimbs + 20
	end

	if leftLeg > 80 then
		character:HealLimbDamage(HITGROUP_LEFTLEG, 100)

		healedLimbs = healedLimbs + 20
	end

	return {
		limbs = healedLimbs,
	}
end
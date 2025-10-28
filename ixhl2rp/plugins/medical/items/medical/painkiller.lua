ITEM.name = "Болеутоляющее"
ITEM.description = "Умеренный болеутоляющий препарат, подходящий для регулярного использования облегчения боли и воспаления, вызванного умеренными ранами."
ITEM.model = Model("models/items/painkiller.mdl")
ITEM.cost = 20
ITEM.stats.uses = 5
ITEM.stats.time = 5
ITEM.iconCam = {
	pos = Vector(0.44081175327301, 56.994258880615, 107.27256774902),
	ang = Angle(62.007186889648, 269.50588989258, 0),
	fov = 4.0087238838698,
}

function ITEM:OnConsume(player, injector, mul, character)
	local shock = character:GetShock()
	local isPain = character:IsFeelPain()
	local newShock = math.max(shock - 3000, 0)

	character:SetFeelPain(false)
	character:SetShock(newShock)

	return {
		shock = math.abs(newShock - shock),
		pain = isPain
	}
end

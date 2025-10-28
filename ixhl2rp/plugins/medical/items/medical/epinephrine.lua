ITEM.name = "Эпинефрин"
ITEM.description = "Автоинъектор эпинефрина. Используется для внутримышечной инъекции для восстановления бессознательных жертв."
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
	local client = character:GetPlayer()
	local lastShock = character:GetShock()
	local isUnconscious = client:IsUnconscious()
	
	character:SetShock(0)

	if isUnconscious then
		client:SetAction("@wakingUp", 10, function(client)
			client.ixUnconsciousOut = nil
			client:SetLocalVar("knocked", false)
			client:SetRagdolled(false)
		end)

		client.ixUnconsciousOut = true
	end

	return {unconscious = isUnconscious, shock = lastShock}
end

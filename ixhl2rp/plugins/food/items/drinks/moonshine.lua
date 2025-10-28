ITEM.name = "Самогон"
ITEM.description = "Очень крепкий напиток, что обжигает ваше горло. Если много пить, то можно ослепнуть, стоит ли проверять?"
ITEM.model = "models/mosi/fallout4/props/alcohol/moonshine.mdl"
ITEM.cost = 12
ITEM.width = 1
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(192.76075744629, 150.93200683594, 28.181871414185),
	ang = Angle(4.697256565094, 218.06784057617, 0),
	fov = 2.0911451654603,
}

ITEM.stats.container = false
ITEM.stats.thirst = 8
ITEM.stats.uses = 5

function ITEM:CustomEffect(client, uses)
	local health = client:GetCharacter():Health()

	health:AddHediff("alcohol", 0, {severity = 0, effect = 50 * uses, tended_start = os.time(), tended_time = 120})
end
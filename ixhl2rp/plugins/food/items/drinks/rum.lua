ITEM.name = "Бутылка рома"
ITEM.description = "Cосуд с темно-коричневым напитком. Наполнен ароматом тропических фруктов и ванили, с теплыми нотами карамели и легким оттенком дыма. Здесь можно было пошутить про пиратов, но надеюсь у всей вашей компании достаточно интеллекта, чтобы так не шутить... Правда же?"
ITEM.cost = 10
ITEM.model = "models/mosi/fallout4/props/alcohol/rum.mdl"
ITEM.width = 1
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(237.1766204834, 85.836639404297, 14.245937347412),
	ang = Angle(1.3481174707413, 199.89570617676, 0),
	fov = 2.0862308553933,
}

ITEM.stats.container = true
ITEM.stats.thirst = 7
ITEM.stats.hunger = 0
ITEM.stats.uses = 10

ITEM.rarity = 1
ITEM.junk = "empty_glass_bottle"

function ITEM:CustomEffect(client, uses)
	local health = client:GetCharacter():Health()

	health:AddHediff("alcohol", 0, {severity = 0, effect = 10 * uses, tended_start = os.time(), tended_time = 120})
end
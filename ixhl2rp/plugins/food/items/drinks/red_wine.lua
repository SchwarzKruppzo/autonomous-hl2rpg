ITEM.name = "Бутылка красного вина"
ITEM.description = "Бутылка ну очень старого вина, которое производилось ещё до войны. Открытие этой бутылки создаёт настоящий праздник, а на вкус это вино - как слёзы ангелов."
ITEM.model = "models/foodnhouseholditems/champagne2.mdl"
ITEM.cost = 47
ITEM.width = 1
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(193.8438873291, 168.73745727539, 46.517139434814),
	ang = Angle(10.382352828979, 221.04292297363, 0),
	fov = 2.0969256557033,
}

ITEM.stats.container = true
ITEM.stats.thirst = 10
ITEM.stats.hunger = 2
ITEM.stats.uses = 10

ITEM.rarity = 4
ITEM.junk = "empty_glass_bottle"

function ITEM:CustomEffect(client, uses)
	local health = client:GetCharacter():Health()

	health:AddHediff("alcohol", 0, {severity = 0, effect = 25 * uses, tended_start = os.time(), tended_time = 300})
end
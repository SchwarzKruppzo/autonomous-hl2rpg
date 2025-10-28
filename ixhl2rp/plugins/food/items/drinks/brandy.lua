ITEM.name = "Бутылка бренди"
ITEM.description = "Высокая стеклянная бутылка с толстым дном, алкоголь внутри имеет амброво-медовый оттенок и сладковатый аромат с нотами карамели и сухих фруктов. Его можно пить долго и легко, но на следующий день, дай бог, не проснуться в совсем незнакомом месте."
ITEM.cost = 10
ITEM.model = "models/mark2580/gtav/barstuff/bottle_brandy.mdl"
ITEM.width = 1
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(170.77745056152, 128.83586120605, 17.112327575684),
	ang = Angle(4.5747122764587, 217.03776550293, 0),
	fov = 2.2956036719491,
}

ITEM.stats.container = true
ITEM.stats.thirst = 7
ITEM.stats.hunger = 0
ITEM.stats.uses = 10

ITEM.rarity = 1
ITEM.junk = "empty_glass_bottle"

function ITEM:CustomEffect(client, uses)
	local health = client:GetCharacter():Health()

	health:AddHediff("alcohol", 0, {severity = 0, effect = 10 * uses, tended_start = os.time(), tended_time = 60})
end
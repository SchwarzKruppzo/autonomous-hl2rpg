ITEM.name = "Старое красное вино"
ITEM.description = "Старая красная бутылка вина с тускло-красной жидкостью внутри."
ITEM.model = "models/foodnhouseholditems/winebottle4.mdl"
ITEM.cost = 60
ITEM.width = 1
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(185.57824707031, 151.85816955566, 47.741004943848),
	ang = Angle(11.227264404297, 219.26637268066, 0),
	fov = 1.9738785137457,
}

ITEM.stats.container = true
ITEM.stats.thirst = 12
ITEM.stats.hunger = 3
ITEM.stats.uses = 10

ITEM.rarity = 4

function ITEM:CustomEffect(client, uses)
	local health = client:GetCharacter():Health()

	health:AddHediff("alcohol", 0, {severity = 0, effect = 25 * uses, tended_start = os.time(), tended_time = 300})
end
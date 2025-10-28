ITEM.name = "Грязная вода"
ITEM.description = "Мутная и ужасно отвратная вода, набранная с лужи... Или же с крана?"
ITEM.model = "models/props_nunk/popcan01a.mdl"
ITEM.cost = 12
ITEM.width = 1
ITEM.height = 1
ITEM.iconCam = {
	pos = Vector(74.466087341309, 75.79704284668, 26.477666854858),
	ang = Angle(13.995231628418, 225.5075378418, 0),
	fov = 4.2787847985967,
}

ITEM.stats.container = false
ITEM.stats.thirst = 4
ITEM.stats.uses = 5

ITEM.junk = "empty_can"

function ITEM:CustomEffect(client, uses)
	local character = client:GetCharacter()
	local rad = 5 * uses

	if uses > 1 then
		for i = 1, uses do
			if math.random(1, 10) == 1 then
				rad = rad + 100
				break
			end
		end
	else
		if math.random(1, 10) == 1 then
			rad = 20
		end
	end

	if client:Team() != FACTION_VORTIGAUNT then
		character:SetRadLevel(character:GetRadLevel() + rad)
	end
end
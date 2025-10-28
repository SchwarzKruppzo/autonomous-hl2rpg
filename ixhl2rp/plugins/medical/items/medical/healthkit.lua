ITEM.name = "Аптечка Альянса"
ITEM.description = "Белый корпус с отсеками и различными медикаментами."
ITEM.model = Model("models/items/healthkit.mdl")
ITEM.useSound = "items/medshot4.wav"
ITEM.width = 2
ITEM.height = 2
ITEM.cost = 60
ITEM.rarity = 2
ITEM.stats.uses = 2
ITEM.stats.time = 10
ITEM.iconCam = {
	pos = Vector(28.298963546753, -0.043933738023043, 267.57727050781),
	ang = Angle(85.041488647461, 179.86787414551, 0),
	fov = 4.1649766122667,
}

function ITEM:OnConsume(player, injector, mul, character)
	local client = character:GetPlayer()
	local blood, shock, rad = character:GetBlood(), character:GetShock(), character:GetRadLevel()
	local isBleeding, isPain, isUnconscious, bleedDmg = character:IsBleeding(), character:IsFeelPain(), client:IsUnconscious(), (character:GetDmgData().bleedDmg or 0)
	local newBlood = math.Clamp(blood + 800, -1, 5000)
	local newShock = math.max(shock - 2500, 0)
	local newRad = math.max(rad - 350, 0)

	character:SetBlood(newBlood)
	character:SetBleeding(false)
	character:SetFeelPain(false)

	local rightLeg = character:GetLimbDamage(HITGROUP_RIGHTLEG)
	local leftLeg = character:GetLimbDamage(HITGROUP_LEFTLEG)

	local healedLimbs = 0
	local limbs = character:GetLimbData()
	for k, v in pairs(limbs) do
		healedLimbs = healedLimbs + (40 - math.max(40 - v, 0))
	end

	character:HealLimbs(40)

	if rightLeg > 80 then
		character:HealLimbDamage(HITGROUP_RIGHTLEG, 100)

		healedLimbs = healedLimbs + 20
	end

	if leftLeg > 80 then
		character:HealLimbDamage(HITGROUP_LEFTLEG, 100)

		healedLimbs = healedLimbs + 20
	end

	local head = character:GetLimbDamage("head")
	local chest = character:GetLimbDamage("chest")
	local stomach = character:GetLimbDamage("stomach")
	local lleg = character:GetLimbDamage("leftLeg")
	local rleg = character:GetLimbDamage("rightLeg")
	local lhand = character:GetLimbDamage("leftHand")
	local rhand = character:GetLimbDamage("rightHand")
	local minHP = 100 - (head + ((chest + stomach)/2) + ((lleg + rleg)/2) + ((lhand + rhand)/2))/4
	client:SetHealth(math.max(client:Health(), minHP))

	character:SetShock(newShock)
	character:SetRadLevel(newRad)

	if isUnconscious then
		client:SetAction("@wakingUp", 10, function(client)
			client.ixUnconsciousOut = nil
			client:SetLocalVar("knocked", false)
			client:SetRagdolled(false)
		end)

		client.ixUnconsciousOut = true
	end

	return {
		bleed = isBleeding, 
		bleedDmg = bleedDmg,
		blood = (newBlood - blood),
		unconscious = isUnconscious, 
		shock = math.abs(newShock - shock),
		rad = math.abs(newRad - rad),
		limbs = healedLimbs,
		pain = isPain
	}
end
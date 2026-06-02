ITEM.name = "item.union_branded_banana"
ITEM.description = "item.union_branded_banana.desc"
ITEM.model = "models/bioshockinfinite/hext_banana.mdl"
ITEM.cost = 3
ITEM.width = 1
ITEM.height = 1

ITEM.volume = 120
ITEM.portion_amount = 24

ITEM.stats.container = false
ITEM.stats.thirst = 0
ITEM.stats.hunger = 3
ITEM.stats.expireTime = 345600 -- 4 days

ITEM.rarity = 1

local SLIP_GRACE_PERIOD 	= 4
local SLIP_CHANCE 			= 0.1 
local SLIP_COOLDOWN 		= 16
local SLIP_DURATION 		= 4

function ITEM:Touch(entity, activator)
	local CT = CurTime()

	if !activator:IsPlayer() then
		return
	end

	if !activator:Alive() then return end
	if IsValid(activator.ixRagdoll) then return end
	if activator.ixBananaSlipNext and CT < activator.ixBananaSlipNext then return end
	
	if IsValid(entity.ixHeldOwner) then
		return
	end

	if !entity.wasDroppedAt then
		entity.wasDroppedAt = CT
	end

	if entity.wasDroppedAt and CT < entity.wasDroppedAt + SLIP_GRACE_PERIOD then
		return
	end

	if activator:GetVelocity():Length2D() < 30 then return end

	if math.random() > SLIP_CHANCE then return end

	activator.ixBananaSlipNext = CT + SLIP_COOLDOWN

	activator:SetRagdolled(true, SLIP_DURATION, SLIP_DURATION)

	local gender = activator:GetCharacter():GetGender()
	local emote = gender == GENDER_FEMALE and "emoteSlipBanana2" or  "emoteSlipBanana1"

	activator:Emote("me", emote)

	activator:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 75, math.random(85, 115))
	entity:EmitSound("physics/fruit/melon" .. math.random(1, 3) .. ".wav", 65, math.random(90, 110))
end

function ITEM:OnPickupObject(entity, activator)
	entity.wasDroppedAt = nil
end
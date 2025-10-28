AddCSLuaFile()
DEFINE_BASECLASS("base_anim")

ENT.PrintName       = "Toilet Trigger"
ENT.Category = "HL2 RP"

ENT.Spawnable       = false
ENT.AdminOnly       = true
ENT.DoAttach        = false
ENT.PhysgunPickupDisabled = false

ENT.RenderGroup = RENDERGROUP_BOTH -- translucent

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/hunter/blocks/cube025x05x025.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(false)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then 
			phys:EnableMotion(false) 
		end

		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end
end

function ENT:OnTakeDamage()
	return false
end

function ENT:ShouldNotCollide(pPlayer)
	return false
end

function ENT:FillContainer(pPlayer, item, resultItem)
	timer.Simple(1, function()
		pPlayer:TakeItem(item)
		pPlayer:GiveItem(resultItem)

		pPlayer:ViewPunch(Angle(2, 0, 1))
		pPlayer:EmitSound("needs/bottle/fill_bottle" .. math.random(1, 2) .. ".wav", 70)
	end)
end

function ENT:Use(pPlayer)
	if (self.iNextUseTime or 0) > CurTime() then return end
	if not IsValid(pPlayer) or not pPlayer:IsPlayer() then return end
	if pPlayer:GetPos():DistToSqr(self:GetPos()) > 3500 or pPlayer:GetNetVar("isCreature") then return end

	local character = pPlayer:GetCharacter()

	self.iNextUseTime = CurTime() + 5
	self:EmitSound("needs/toilet/fill_toilet" .. math.random(1, 2) .. ".wav", 70)

	pPlayer:ForceSequence("roofidle1")

	if pPlayer:HasItem("empty_can") then
		self:FillContainer(pPlayer, "empty_can", "dirty_water")

		ix.chat.Send(pPlayer, "me", "наполняет пустую банку водой.")
	elseif pPlayer:HasItem("empty_tin_can") then
		self:FillContainer(pPlayer, "empty_tin_can", "dirty_water")

		ix.chat.Send(pPlayer, "me", "наполняет пустую консервную банку водой.")
	else
		timer.Simple(1, function()
			pPlayer:ViewPunch(Angle(3, 0, 2))
			character:UpdateNeeds(20, 0)

			local rad = 50

			if math.random(1, 2) == 1 then
				rad = 100
			end

			if pPlayer:Team() != FACTION_VORTIGAUNT then
				character:SetRadLevel(character:GetRadLevel() + rad)
			end
			

			ix.chat.Send(pPlayer, "me", "пьёт воду из туалета.")
		end)
	end
end

properties.Add("sinktrigger2", {
	MenuLabel = "Вода (туалет)",
	Order = 400,
	MenuIcon = "icon16/contrast_low.png",

	Filter = function(self, entity, client)
		return entity:GetClass() == "prop_physics" and client:IsUserGroup("founder")
	end,

	Action = function(self, entity)
		self:MsgStart()
			net.WriteEntity(entity)
		self:MsgEnd()
	end,

	Receive = function(self, length, client)
		local entity = net.ReadEntity()

		if (!IsValid(entity)) then return end
		if (!self:Filter(entity, client)) then return end
		
		if entity.PermaID then
			client:Notify("Необходимо убрать проп из Perma All, прежде чем конвертировать его.")

			return
		end

		local pos, ang = entity:GetPos(), entity:GetAngles()

		entity:Remove()

		local sink = ents.Create("ix_toilet_trigger")
		sink:SetPos(pos)
		sink:SetAngles(ang)
		sink:Spawn()
	end
})


if not CLIENT then return end

function ENT:Draw() end

ENT.PopulateEntityInfo = true

function ENT:OnPopulateEntityInfo(tooltip)
	local client = LocalPlayer()
	local emptyItems = {
		"empty_can",
		"empty_tin_can"
	}

	local hint = "[E] — пить (грязная вода)"

	for _, item in ipairs(emptyItems) do
		if client:HasItem(item) then
			hint = "[E] — налить в пустую банку (грязная вода)"
			break
		end
	end

	local title = tooltip:AddRow("hint")
	title:SetText(hint)
	title:SizeToContents()
end
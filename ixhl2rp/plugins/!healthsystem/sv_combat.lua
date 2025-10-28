local PLUGIN = PLUGIN

util.AddNetworkString("shock.pain")
util.AddNetworkString("crit.use")
util.AddNetworkString("crit.apply")


function PLUGIN:OnPlayerRespawn(client)
	local character = client:GetCharacter()

	if character then
		character:Health():Reset()
	end

	client:SetCriticalState(false)
	client:SetNetVar("doll", nil)
	client:SetLocalVar("drunk", 0)
end

function PLUGIN:DoPlayerDeath(client)
	local character = client:GetCharacter()

	if character then
		character:Health():Reset()
	end

	if client.KilledByRP and !client.KilledBySystem then
		character:Ban()
		character:Save()
	end

	client:SetNetVar("doll", nil)
	client:SetLocalVar("drunk", 0)
end

function PLUGIN:PlayerDisconnected(client)
	local character = client:GetCharacter()

	if character then
		if client:InCriticalState() then
			client.KilledByRP = true
			client.KilledBySystem = false
			client:Kill()
		end
	end
end

local function RemoveEquippableItem(client, item)
	if item.Unequip then
		item:Unequip(client)
	end
end

function PLUGIN:OnPlayerCorpseCreated(client, entity)
	local character = client:GetCharacter()

	if !character then
		return
	end

	if !client.KilledBySystem then
		local items = {}

		for _, item in ipairs(client:GetItems()) do
			if item.uniqueID:find("card") then continue end
			if item.inventory_type == "item_container" then continue end
			
			items[#items + 1] = item
		end

		local inventory = ix.meta.Inventory:New()
		inventory:SetSize(12, 8)
		inventory.title = "Вещи с трупа"
		inventory.type = "death_container"
		inventory.owner = entity

		for k, v in ipairs(items) do
			local oldInventory = ix.Inventory:Get(v.inventory_id)

			if oldInventory then
				if v:GetData("equip") then
					RemoveEquippableItem(client, v)
				end
				
				local a, b = oldInventory:Transfer(v.id, inventory)
			end
		end

		for k, v in pairs(client:GetInventories()) do
			v:Sync()
		end

		entity.money = character:GetMoney()
		entity.GetMoney = function(this)
			return this.money
		end
		entity.SetMoney = function(this, amount)
			this.money = math.max(0, math.Round(tonumber(amount) or 0))
		end
		
		character:SetMoney(0)

		entity.ixInventory = inventory
	end

	client:SetCriticalState(false)
end

function PLUGIN:PlayerUse(client, entity)
	if entity:GetClass() == "prop_ragdoll" and entity.ixInventory and !ix.storage.InUse(entity.ixInventory) then
		ix.storage.Open(client, entity.ixInventory, {
			entity = entity,
			name = "Труп",
			data = {money = entity:GetMoney()},
			searchText = "Обыскиваю труп",
			searchTime = 3
		})

		return false
	end
end

local parents = {
	[HITGROUP_LEFTLEG] = HITGROUP_STOMACH,
	[HITGROUP_RIGHTLEG] = HITGROUP_STOMACH,
	[HITGROUP_LEFTARM] = HITGROUP_CHEST,
	[HITGROUP_RIGHTARM] = HITGROUP_CHEST,
	[HITGROUP_STOMACH] = HITGROUP_CHEST,
}

local function DamageToOuterParts(health, hit_group)
	local partID = health.body.hit_parts[hit_group]
	local hp = health:GetPartHealth(partID)
	local parent = parents[hit_group]

	if hp <= 0 and parent then
		hit_group = DamageToOuterParts(health, parent)

		return hit_group, true
	end
	
	return hit_group, false
end

function PLUGIN:ScalePlayerDamage(ply, hit_group, dmg)
	/*
	if hit_group == HITGROUP_HEAD then
		dmg:ScaleDamage(1)
	elseif hit_group == HITGROUP_CHEST or hit_group == HITGROUP_STOMACH then
		dmg:ScaleDamage(0.75)
	else
		dmg:ScaleDamage(0.5)
	end*/

	dmg:ScaleDamage(1)
end

local armor_slots = {"torso", "head", "mask", "legs", "armor"}
local function SelectArmorToHit(client, hit_group)
	local sum = 0
	local elements = {}
	for item, value in pairs(client.char_outfit.armor) do
		if !value then continue end
		if !item.armor or !item.armor.coverage[hit_group] then continue end

		local coverage = item.armor.coverage[hit_group]

		elements[#elements + 1] = {item.id, coverage}
		sum = sum + coverage
	end

	if #elements <= 0 then
		return 0
	end
	
	if sum < 1 then
		local coverage = (1 - sum)

		sum = sum + coverage
		elements[#elements + 1] = {0, coverage}
	end
	
	local select = math.random() * sum

	for _, data in ipairs(elements) do
		select = select - data[2]

		if select < 0 then 
			return data[1]
		end
	end
end

local function GetDamageClass(isEnergy, isFists, isBuckshot, isSlash, isClub, isExplosive, isAcid)
	if isEnergy then
		return "impulse"
	elseif isFists then
		return "fists"
	elseif isBuckshot then
		return "buckshot"
	elseif isSlash then
		return "slash"
	elseif isClub then
		return "club"
	elseif isExplosive then
		return "explosive"
	elseif isAcid then
		return "acid"
	end

	return "bullet"
end

local function ApplyFallDamage(health, amount)
	local num = math.min(math.floor(amount / 10), 4)
	local parts = health:GetFallDamageParts(num)
	local fallDmg = (amount / #parts)

	for k, id in ipairs(parts) do
		local part = health.body.parts[id]
		local hp = health:GetPartHealth(id)
		local maxHP = health:GetMaxHealth(id)
		local maxFallDmg = math.min(fallDmg, maxHP)

		if (hp - fallDmg) <= 0 and part.canFracture then
			health:AddHediff("fracture", part.hitgroup, {severity = math.min(fallDmg, maxFallDmg)})
		else
			health:AddHediff("bruise", part.hitgroup, {severity = fallDmg})
		end
	end
end

local damage_to_diff = {
	impulse = {
		hediff = "gunshot",
		uniqueEffect = function(health, hit_group, info)
			if math.random(1, 100) > 30 then
				health:AddHediff("impulse_necrosis", hit_group, {severity = info.amount * 0.1})
			end
		end
	},
	fists = {
		hediff = "bruise",
		multiplier = function(health, hit_group, info)
			local partID = health.body.hit_parts[hit_group]

			return (30 / health:GetMaxHealth(partID))
		end
	},
	slash = {
		hediff = "cut"
	},
	club = {
		hediff = "blunt",
		uniqueEffect = function(health, hit_group, info)
			if math.random(1, 100) > 75 then
				health:AddHediff("bruise", hit_group, {severity = info.amount * 0.25})
			end
		end
	},
	buckshot = {
		uniqueEffect = function(health, hit_group, info)
			if math.random(1, 100) > 50 then
				health:AddHediff("buck", hit_group, {severity = info.amount * 0.25})
			else
				health:AddHediff("scratch", hit_group, {severity =  info.amount})
			end
		end
	},
	bullet = {
		uniqueEffect = function(health, hit_group, info)
			if math.random(1, 100) > 75 then
				health:AddHediff("bullet", hit_group, {severity = info.amount * 0.25})
			else
				health:AddHediff("gunshot", hit_group, {severity = info.amount})
			end
		end
	},
	explosive = {
		uniqueEffect = function(health, hit_group, info)
			if math.random(1, 100) > 75 then
				health:AddHediff("scratch", hit_group, {severity = info.amount * 0.5})
			else
				health:AddHediff("shredded", hit_group, {severity = info.amount})
			end
		end
	},
	shock = {
		uniqueEffect = function(health, hit_group, info)
			health:AddHediff("sparkshock", 0, {severity = info.amount * 0.8, tended_start = os.time(), tended_time = 30})
			health:AddHediff("sparkburn", hit_group, {severity = info.amount * 0.2})
		end
	},
	acid = {
		uniqueEffect = function(health, hit_group, info)
			health:AddHediff("acid", hit_group, {severity = info.amount})
		end
	},
	physics = {
		hediff = "bruise"
	},
}

local function SelectRandomPart(health)
	local sum = 0
	local elements = {}

	for k, v in health:GetParts() do
		if !v.coverageAbs then continue end
		
		elements[#elements + 1] = v
		sum = sum + v.coverageAbs
	end

	local select = math.random() * sum

	for _, part in ipairs(elements) do
		select = select - part.coverageAbs

		if select < 0 then 
			return part 
		end
	end
end

local function SelectDamageHediff(health, hit_group, info)
	local damage = damage_to_diff[info.class]
	local mul = 1

	if damage then
		if isfunction(damage.uniqueEffect) then
			damage.uniqueEffect(health, hit_group, info)
		end

		if isfunction(damage.multiplier) then
			mul = damage.multiplier(health, hit_group, info)
		end
		
		return damage.hediff, mul
	end
end

local noPenetrateDamage = {
	poison = true
}
local function ApplyDamageToPart(health, hit_group, info)
	local amount = info.amount
	local client = info.attacker
	local weapon = info.weapon
	local damage_class = info.class

	if info.class == "acid" then
		damage_class = "poison"
	end
	
	local halfDamage = false
	local target = health.character:GetPlayer()

	hit_group, halfDamage = DamageToOuterParts(health, hit_group)

	local item = SelectArmorToHit(target, hit_group)
	local value = 0

	if weapon and weapon.ixItem then
		local durability = (weapon.ixItem:GetData("value") / weapon.ixItem.durability)

		if durability < 0.66 then
			amount = amount * math.Remap(durability, 0, 0.65, 0.4, 0.7)
		end
	end

	if halfDamage then
		amount = amount * 0.4
	end
	
	if item != 0 then
		item = ix.Item.instances[item]
		value = item:GetData("value")
	end

	local showBlood = false

	if !info.penetrate and value > 0 then
		local penetration_factor = (weapon.armor and weapon.armor.penetration[item.armor.class] or 1)
		local armor_factor = (1 - (value * penetration_factor))
		local ap_dmg = ((amount * 0.75) / item.armor.max_durability)
		
		local chance = math.min(math.Rand(0, 1), math.Rand(0, 1))
		local armorDamageMul = item.armor.damage[damage_class] or 1
		local armor_density = (1 - item.armor.density)

		if damage_class == "explosive" then
			armorDamageMul = 30
		end
		
		ap_dmg = ap_dmg * armorDamageMul
		ap_dmg = ap_dmg * (weapon.armor and weapon.armor.damage[item.armor.class] or 1)

		if chance <= (armor_factor * item.armor.penetration[damage_class]) then
			//health:AddHediff("bruise", hit_group, {severity = (ap_dmg * armor_density) * (2 - value)})

			health:AddHediff("bruise", hit_group, {severity = (amount * armor_density) * (2 - value) * 0.7})
		else
			if !noPenetrateDamage[damage_class] then
				ap_dmg = ap_dmg * 0.25

				//health:AddHediff("bruise", hit_group, {severity = (ap_dmg * armor_density)})
				health:AddHediff("bruise", hit_group, {severity = amount * 0.25 * armor_density * 0.7})
			else
				ap_dmg = 0
			end
		end

		value = value - ap_dmg

		item:SetData("value", math.max(value, 0))

		ap_dmg = (value < 0) and math.abs(value) or 0

		if ap_dmg > 0 then
			info.amount = ap_dmg
			info.penetrate = true

			showBlood = ApplyDamageToPart(health, hit_group, info)
		end
	else
		local hediff, mul = SelectDamageHediff(health, hit_group, info)

		if hediff then
			health:AddHediff(hediff, hit_group, {severity = amount * mul})
		end

		showBlood = true
	end

	return showBlood
end

local function ApplyStaminaDamage(health, hit_group, info)
	local physicalDamage = info.physDamage
	local staminaDamage = info.staminaDamage
	local client = info.attacker
	local target = info.target
	local damage_class = info.class

	local halfDamage = false

	hit_group, halfDamage = DamageToOuterParts(health, hit_group)

	local item = SelectArmorToHit(target, hit_group)
	local armor = 0

	if halfDamage then
		physicalDamage = physicalDamage * 0.5
	end
	
	if item != 0 then
		item = ix.Item.instances[item]
		armor = item:GetData("value")
	end

	if armor > 0 then
		physicalDamage = physicalDamage * 0.25
		staminaDamage = staminaDamage * 0.5
	end

	local hediff, mul = SelectDamageHediff(health, hit_group, info)

	local showBlood = false

	if hediff and physicalDamage > 0 then
		health:AddHediff("bruise", hit_group, {severity = physicalDamage * mul})

		showBlood = true
	end

	if staminaDamage > 0 then
		local value = target:GetLocalVar("stm", 0) - staminaDamage

		target:ConsumeStamina(staminaDamage)

		if value < 0 and !IsValid(target.ixRagdoll) then
			target:SetRagdolled(true, 60)
		end
	end

	return showBlood
end

function PLUGIN:EvasionChance(client, isStanding, isBackstab)
	local character = client:GetCharacter()

	local staminaFactor = (0.5 + 0.5 * client:GetLocalVar("stm", 0) / character:GetMaxStamina())
	local speedFactor = isStanding and 0 or 1 + math.Clamp(math.Remap(client:GetVelocity():LengthSqr(), 2500, 55225, 0, 0.75), 0, 0.75)

	local luckMod = math.min(0.25 * character:GetSpecial("lk"), 50)
	local agilityMod = math.min(0.75 * character:GetSpecial("ag"), 75)

	return ((10 + agilityMod + luckMod) * staminaFactor) * speedFactor
end

function PLUGIN:MeleeHitChance(client, skill, isStanding, isBackstab)
	local character = client:GetCharacter()

	local staminaFactor = (0.75 + 0.5 * client:GetLocalVar("stm", 0) / character:GetMaxStamina())
	local skillMod = 15 + math.Remap(character:GetSkillModified(skill), 0, 10, 0, 85)
	
	local luckMod = math.min(0.25 * character:GetSpecial("lk"), 50)
	local agilityMod = math.min(0.75 * character:GetSpecial("ag"), 75)

	return ((isStanding and 15 or 0) + (isBackstab and 100 or 0) + skillMod + agilityMod + luckMod) * staminaFactor
end

function PLUGIN:MeleeCritChance(character)
	local strength = character:GetSpecial("st", 1)
	local LVL25 = strength >= 25 and 1 or 0
	local LVL75 = strength >= 75 and 1 or 0
	local LVL100 = strength >= 100 and 1 or 0

	return (LVL25 + LVL75 + LVL100) * 5
end


local hot_fix = {
	["grenade_spit"] = function(dmg)
		if dmg:GetDamageType() == DMG_POISON then
			return false
		end
	end
}
local mul_npc = {
	["npc_antlionguard"] = 5,
	["npc_antlionguardian"] = 5,
}

function PLUGIN:EntityTakeDamage(target, dmg, penetrate)
	if IsValid(target.ixPlayer) then
		if IsValid(target.ixHeldOwner) then
			dmg:SetDamage(0)
			return
		end

		-- Is Fall 
		if dmg:IsDamageType(DMG_CRUSH) then
			if (target.ixFallGrace or 0) < CurTime() then
				if dmg:GetDamage() <= 10 then
					dmg:SetDamage(0)
				end

				dmg:SetDamageType(DMG_FALL)
				target.ixFallGrace = CurTime() + 0.5
			else
				return
			end
		end

		if dmg:GetDamage() > 0 then
			target.ixPlayer:TakeDamageInfo(dmg)
		end
		
		return
	end

	local inflictor = dmg:GetInflictor()
	local client = dmg:GetAttacker()
	local amount = dmg:GetDamage()

	local isAttackingMelee
	local isAttackingFists

	local fix = hot_fix[inflictor:GetClass()]
	if target:IsPlayer() and fix then
		if fix(dmg) == false then
			return true
		end
	end

	if mul_npc[inflictor:GetClass()] then
		amount = amount * mul_npc[inflictor:GetClass()]
	end
	
	if (target:IsPlayer() or target:IsNPC()) and IsValid(inflictor) then 
		local isMelee = inflictor.IsMelee or (dmg:GetDamageType() == DMG_CLUB) or (dmg:GetDamageType() == DMG_SLASH)
		local isFists = inflictor.IsFists

		if IsValid(client) and client:IsPlayer() then
			local character = client:GetCharacter()

			if isFists then
				character:DoAction("unarmedSuccess")

				isAttackingFists = true
			elseif isMelee then
				character:DoAction("meleeSuccess")

				isAttackingMelee = true
			else
				character:DoAction("shootSuccess")
			end

			local endurance = character:GetSpecial("st", 1)
			local strength = character:GetSpecial("st", 1)
			local LVL5 = strength >= 5
			local LVL25 = strength >= 25
			local LVL50 = strength >= 50

			local enduranceBonus = endurance >= 150
			local strengthBonus = (0.005 * strength)

			local baseAmount = amount
			
			if LVL5 then 
				amount = amount + (baseAmount * 0.1) + (baseAmount * strengthBonus)
			end

			if LVL50 and (dmg:GetDamageType() == DMG_CLUB) then 
				amount = amount + (baseAmount * 0.25)
			end

			if enduranceBonus then
				amount = amount + (baseAmount * (endurance * 0.01))
			end

			local critChance = self:MeleeCritChance(character)

			if critChance > 0 and (math.random(0, 100) < critChance) then
				amount = amount * 3
			end

			dmg:SetDamage(amount)
		end
	end

	if !target:IsPlayer() then 
		return
	end

	
	local isCrossbow
	local showBlood = false

	if inflictor and inflictor.m_iDamage then
		isCrossbow = true
		dmg:SetDamage(inflictor.m_iDamage)
	end

	target:SetBloodColor(DONT_BLEED)

	
	local character = target:GetCharacter()
	local health = character:Health()

	local hit_group = target:LastHitGroup()
	local halfDamage = false
	
	local damageType = dmg:GetDamageType()
	local ammoType = dmg:GetAmmoType()
	local weapon = {}

	if IsValid(client) and client:IsPlayer() then
		weapon = client:GetActiveWeapon()
	end
	
	if isCrossbow then
		local pos = inflictor:GetPos()
		local tr = util.TraceLine({
			start = pos,
			endpos = pos + (inflictor:GetVelocity():GetNormalized() * 256),
			filter = inflictor
		})

		hit_group = tr.HitGroup
	end
	
	local value = 0
	local item
	local partID

	if amount <= 0 then
		return
	end

	if inflictor:IsNPC() then
		local part = SelectRandomPart(health)

		hit_group = part.hitgroup
	else
		if hit_group == 0 then
			local part = SelectRandomPart(health)

			hit_group = part.hitgroup
		end
	end

	client.dmgSeed = (client.dmgSeed or 0) + 1

	local seed = CurTime() + client:EntIndex() + client.dmgSeed
	math.randomseed(seed)

	local isEnergy = (ammoType == 1)
	local isFists = weapon.IsFists
	local isBuckshot = (ammoType == 7) or damageType == DMG_BUCKSHOT or inflictor.IsBuckshot
	local isSlash = damageType == DMG_SLASH or inflictor.IsSlash
	local isFallDamage = damageType == DMG_FALL
	local isClub = damageType == DMG_CLUB or inflictor.IsClub
	local isAcid = damageType == DMG_ACID
	local isExplosive = dmg:IsExplosionDamage()

	local AVOID_DAMAGE = character:HasSpecialLevel("en", 100)
	local RESIST_1 = character:HasSpecialLevel("en", 50) and 0.25 or 0
	local RESIST_2 = character:HasSpecialLevel("en", 75) and 0.25 or 0

	if AVOID_DAMAGE then
		if math.random(1, 100) <= 25 then
			return true
		end
	end

	local baseResist = 0
	baseResist = baseResist + RESIST_1 + RESIST_2

	if baseResist > 0 then
		amount = math.max(amount - (amount * baseResist), 0)

		dmg:SetDamage(amount)
	end

	if isFallDamage then
		ApplyFallDamage(health, amount)

		showBlood = true
	elseif isAttackingFists then
		local isStanding = target:GetVelocity():LengthSqr() <= 100
		local isBackstab = false

		local vecAimTarget, vecAimAttacker = target:GetAimVector(), client:GetAimVector()
		vecAimTarget.z = 0
		vecAimAttacker.z = 0

		if vecAimTarget:DotProduct(vecAimAttacker) > 0.25 then
			isBackstab = true
		end

		local evasionChance = self:EvasionChance(target, isStanding, isBackstab)
		local hitChance = self:MeleeHitChance(client, "unarmed", isStanding, isBackstab)
		hitChance = hitChance - evasionChance

		local isParried = false
		if isRagdoll or (math.random(1, 100) < hitChance) then
			if isBackstab or isRagdoll then
				isParried = true
			elseif !isParried then
				local targetWeapon = target:GetActiveWeapon()
				local isFists = IsValid(targetWeapon) and targetWeapon.IsFists or true

				local parryChance = self:MeleeHitChance(target, isFists and "unarmed" or "meleeguns", isStanding, false)
				parryChance = parryChance + evasionChance

				isParried = math.random(1, 100) > parryChance
			end
		end
		
		if isParried then
			local targetWeapon = target:GetActiveWeapon()
			local isMelee = targetWeapon.IsMelee or (dmg:GetDamageType() == DMG_CLUB) or (dmg:GetDamageType() == DMG_SLASH)
			local isFists = targetWeapon.IsFists

			if isFists then
				character:DoAction("unarmedParry")
			elseif isMelee then
				character:DoAction("meleeParry")
			end

			showBlood = false
		else
			showBlood = ApplyStaminaDamage(health, hit_group, {
				attacker = client,
				target = target,
				physDamage = amount,
				staminaDamage = amount,
				class = "fists"
			})
		end
		
	elseif isExplosive then
		local minDamage = 15

		if inflictor:GetClass() == "grenade_ar2" then
			amount = amount * 5
		end
		
		local count = math.min(math.max(math.random(2, 4), math.ceil(amount / minDamage)), 4)

		for i = 1, count do
			local part = SelectRandomPart(health)

			ApplyDamageToPart(health, part.hitgroup, {
				attacker = client,
				weapon = weapon,
				amount = amount / count,
				class = "explosive"
			})
		end

		showBlood = true
	elseif damageType == DMG_CRUSH then -- is PHYSICS
		if amount >= 30 then
			local part = hit_group != 0 and hit_group or SelectRandomPart(health).hitgroup

			showBlood = ApplyDamageToPart(health, part, {
				attacker = client,
				weapon = weapon,
				amount = amount,
				penetrate = true,
				class = "physics"
			})
		end
	elseif damageType == DMG_SHOCK then -- Electrolyzed
		local part = hit_group != 0 and hit_group or SelectRandomPart(health).hitgroup

		showBlood = ApplyDamageToPart(health, part, {
			attacker = client,
			weapon = weapon,
			amount = amount,
			class = "shock"
		})
	elseif damageType == DMG_DROWN then
		if !health.oxyloss then
			health:AddHediff("oxygen", 0)
			health.oxyloss = true
		end
	else
		local class = GetDamageClass(isEnergy, isFists, isBuckshot, isSlash, isClub, isExplosive, isAcid)
		showBlood = ApplyDamageToPart(health, hit_group, {
			attacker = client,
			weapon = weapon,
			amount = amount,
			class = class
		})
	end
	
	if showBlood then
		local fx = EffectData()
		fx:SetOrigin(dmg:GetDamagePosition())
		fx:SetEntity(target)
		util.Effect("BloodImpact", fx)

		if health:GetConsciousness() > 0.3 then
			hook.Run("PlayerHurt", target, client, 100 * health:GetPercent(), amount)
		end
	end

	local head_hp = health:GetPartHealth(2)
	local torso_hp = health:GetPartHealth(3)

	if head_hp <= 0 then
		target:SetCriticalState(true)
	elseif torso_hp <= 0 and head_hp <= 0 then
		target:SetCriticalState(true)
	end

	if !health.bloodloss then
		local rate = health:GetBleedRate()

		if rate > 0 then
			health:AddHediff("bleeding", 0)
			health.bloodloss = true
		end
	end

	return true
end


do
	local PLAYER = FindMetaTable("Player")

	--- Sets this player's ragdoll status.
	-- @realm server
	-- @bool bState Whether or not to ragdoll this player
	-- @number[opt=0] time How long this player should stay ragdolled for. Set to `0` if they should stay ragdolled until they
	-- get back up manually
	-- @number[opt=5] getUpGrace How much time in seconds to wait before the player is able to get back up manually. Set to
	-- the same number as `time` to disable getting up manually entirely
	function PLAYER:SetRagdolled(bState, time, getUpGrace)
		if (!self:Alive()) then
			return
		end

		getUpGrace = getUpGrace or time or 5

		if (bState) then
			local entity

			if (IsValid(self.ixRagdoll)) then
				entity = self.ixRagdoll
			else
				entity = self:CreateServerRagdoll()
				entity:CallOnRemove("fixer", function()
					if (IsValid(self) and self:GetCharacter()) then
						self:SetLocalVar("blur", nil)
						self:SetLocalVar("ragdoll", nil)
						self:SetNetVar("doll", nil)

						if (!entity.ixNoReset) then
							self:SetPos(entity:GetPos())
						end

						self:SetNoDraw(false)
						self:SetNotSolid(false)
						self:SetMoveType(MOVETYPE_WALK)
						self:SetLocalVelocity(IsValid(entity) and entity.ixLastVelocity or vector_origin)

						/*
						self:SetCriticalState(false)
						
						net.Start("ixCritData")
							net.WriteEntity(self)
							net.WriteBool(false)
						net.Broadcast()
						*/
					end

					if (IsValid(self) and !entity.ixIgnoreDelete) then
						if (entity.ixWeapons) then
							for _, v in ipairs(entity.ixWeapons) do
								if (v.class) then
									local weapon = self:Give(v.class, true)

									if !IsValid(weapon) then continue end
									
									if (v.item) then
										weapon.ixItem = v.item
									end

									self:SetAmmo(v.ammo, weapon:GetPrimaryAmmoType())
									weapon:SetClip1(v.clip)
								elseif (v.item and v.invID == v.item.invID) then
									v.item:Equip(self, true, true)
									self:SetAmmo(v.ammo, self.carryWeapons[v.item.weaponCategory]:GetPrimaryAmmoType())
								end
							end
						end

						if (entity.ixActiveWeapon) then
							if (self:HasWeapon(entity.ixActiveWeapon)) then
								self:SetActiveWeapon(self:GetWeapon(entity.ixActiveWeapon))
							else
								local weapons = self:GetWeapons()
								if (#weapons > 0) then
									self:SetActiveWeapon(weapons[1])
								end
							end
						end
					end
				end)

				self.ixRagdoll = entity

				entity.ixWeapons = {}
				entity.ixPlayer = self
				
				if (IsValid(self:GetActiveWeapon())) then
					entity.ixActiveWeapon = self:GetActiveWeapon():GetClass()
				end

				for _, v in ipairs(self:GetWeapons()) do
					if (v.ixItem and v.ixItem.Equip and v.ixItem.Unequip) then
						entity.ixWeapons[#entity.ixWeapons + 1] = {
							item = v.ixItem,
							invID = v.ixItem.invID,
							ammo = self:GetAmmoCount(v:GetPrimaryAmmoType())
						}
						v.ixItem:Unequip(self, false)
					else
						local clip = v:Clip1()
						local reserve = self:GetAmmoCount(v:GetPrimaryAmmoType())
						entity.ixWeapons[#entity.ixWeapons + 1] = {
							class = v:GetClass(),
							item = v.ixItem,
							clip = clip,
							ammo = reserve
						}
					end
				end
			end

			self:SetLocalVar("blur", 25)

			if (getUpGrace) then
				entity.ixGrace = CurTime() + getUpGrace
			end

			if (time and time > 0) then
				entity.ixStart = CurTime()
				entity.ixFinish = entity.ixStart + time

				self:SetAction("@wakingUp", nil, nil, entity.ixStart, entity.ixFinish)
			end

			self:GodDisable()
			self:StripWeapons()
			self:SetMoveType(MOVETYPE_OBSERVER)
			self:SetNoDraw(true)
			self:SetNotSolid(true)

			local uniqueID = "ixUnRagdoll" .. self:SteamID()

			if (time) then
				timer.Create(uniqueID, 0.33, 0, function()
					if (IsValid(entity) and IsValid(self) and self.ixRagdoll == entity) then
						local velocity = entity:GetVelocity()
						entity.ixLastVelocity = velocity

						self:SetPos(entity:GetPos())

						if (velocity:Length2D() >= 8) then
							if (!entity.ixPausing) then
								self:SetAction()
								entity.ixPausing = true
							end

							return
						elseif (entity.ixPausing) then
							self:SetAction("@wakingUp", time)
							entity.ixPausing = false
						end

						time = time - 0.33

						if (time <= 0) then
							entity:Remove()
						end
					else
						timer.Remove(uniqueID)
					end
				end)
			else
				timer.Create(uniqueID, 0.33, 0, function()
					if (IsValid(entity) and IsValid(self) and self.ixRagdoll == entity) then
						self:SetPos(entity:GetPos())
					else
						timer.Remove(uniqueID)
					end
				end)
			end

			self:SetLocalVar("ragdoll", entity:EntIndex())
			self:SetNetVar("doll", entity:EntIndex())
			hook.Run("OnCharacterFallover", self, entity, true)

			/*
			local flag = self:GetCharacter():HasFlags("z")

			if !flag then
				net.Start('rp.ragdoll.menu')
					net.WriteEntity(entity)
				net.Broadcast()
			end*/
		elseif (IsValid(self.ixRagdoll)) then
			self.ixRagdoll:Remove()

			hook.Run("OnCharacterFallover", self, nil, false)
		end
	end
end
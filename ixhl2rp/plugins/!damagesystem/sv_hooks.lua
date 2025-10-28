local PLUGIN = PLUGIN

do
	local ENTITY = FindMetaTable("Entity")
	local PLAYER = FindMetaTable("Player")
	oldDispatchAttack = oldDispatchAttack or ENTITY.DispatchTraceAttack

	function ENTITY:DispatchTraceAttack(dmgInfo, traceResult, dir)
		local attacker = dmgInfo:GetAttacker()

		if IsValid(attacker) then
			if hook.Run("EntityTraceAttack", attacker, self, traceResult, dmgInfo) == false then
				oldDispatchAttack(self, dmgInfo, traceResult, dir)
				return
			end
		end

		oldDispatchAttack(self, dmgInfo, traceResult, dir)
	end

	function PLAYER:SetCriticalState(state)
		local character = self:GetCharacter()

		if !character then
			return
		end

		if state then
			local flag = false //character:HasFlags("z")
			local inOutlands = IsValid(self.ixRagdoll) and self.ixRagdoll.inOutlands

			if inOutlands then
				self:SetLocalVar("inOutlands", true)
			end
			
			if self:InOutlands() or flag then
				self.KilledByRP = false
				self:Kill()
				return
			end
			
			self:SetHealth(1)
			self:SetNetVar("crit", true)

			character:SetData("crit", true)
			character:SetData("critTime", os.time() + 600)

			if !IsValid(self.ixRagdoll) then
				self:SetRagdolled(true)
				self.ixRagdoll.ixGrace = nil
				self:SetLocalVar("knocked", true)
			end
		else
			self:SetNetVar("crit", nil)

			character:SetData("crit", nil)
			character:SetData("critTime", nil)
		end
	end

	function PLAYER:InCriticalState()
		return self:GetNetVar("crit")
	end
end

function PLUGIN:ResetDamageData(client, character, force)
	if force or client.KilledByRP then
		character:SetDmgData({
			isBleeding = false,
			isPain = false,
			bleedBone = 0,
			bleedDmg = 0
		})

		character:SetBlood(5000)
		character:SetShock(0)

		client:SetHealth(client:GetMaxHealth())
		client:SetNetVar("isBleeding", false)
		client:SetNetVar("bleedingBone", 0)
		
		character:ResetLimbDamage()

		client.KilledByRP = nil
	end

	client.ixUnconsciousOut = nil
	client:SetNetVar("doll", nil)
	client:SetLocalVar("knocked", false)

/*
	net.Start("ixCritData")
		net.WriteEntity(client)
		net.WriteBool(false)
	net.Broadcast()
*/
	net.Start("ixBleedingEffect")
		net.WriteEntity(client)
	net.Broadcast()
end

function PLUGIN:PlayerInitialSpawn(client)
	client:SetBloodColor(-1)
end

function PLUGIN:OnPlayerRespawn(client)
	local character = client:GetCharacter()

	if character then
		client:SetCriticalState(false)

		self:ResetDamageData(client, character, true)
	end
end

function PLUGIN:PlayerDisconnected(client)
	local character = client:GetCharacter()

	

	if character then
		local flag = false //character:HasFlags("z")

		if !flag then
			if client:InCriticalState() then
				client.KilledByRP = false
				client:Kill()
						
				character:Ban()
				character:Save()
			end
		end
	end
end

function PLUGIN:OnCharacterCreated(client, character)
	client.KilledByRP = nil

	self:ResetDamageData(client, character, true)
end

function PLUGIN:PostPlayerLoadout(client)
	local character = client:GetCharacter()

	if !client.KilledByRP then
		local dmgData = character:GetDmgData()

		if dmgData.bleedDmg > 0 then
			dmgData.bleedDmg = 1
		end

		character:SetDmgData(dmgData)
		character:SetBlood(math.max(character:GetBlood(), 3500))
		character:SetShock(math.min(character:GetShock(), character:GetBlood()))

		local limbs = character:Limbs()

		if limbs then
			local limbData = character:GetLimbData()

			for k, v in pairs(limbs.stored) do
				local n = v:Name()
				limbData[n] = math.min((limbData[n] or 0), 90)
			end

			character:SetLimbData(limbData)
		end
		
		client:SetHealth(self:GetMinimalHealth(character))
	else
		if character and character:GetBlood() < 0 then
			self:ResetDamageData(client, character, true)
		end
	end

	if client.KilledNotify then
		ix.chat.Send(nil, "dmgMsg", "", false, {client}, {t = 2})
	end
/*
	net.Start("ixCritData")
		net.WriteEntity(client)
		net.WriteBool(false)
	net.Broadcast()
*/
	client.KilledByRP = nil
end

local function TransferItem(item, invID, x, y)
	item.Dropped = true

	if item.OnUnequipped then
		item:OnUnequipped(item:GetOwner())
	end

	if item.Unequip then
		item:Unequip(item:GetOwner())
	end

	item:Transfer(invID, x, y)
end

function PLUGIN:DoPlayerDeath(client)
	local character = client:GetCharacter()
	local flag = false //character:HasFlags("z")

	if character then
		if !flag then
			local stack = {}
			local items = {}

			for _, item in ipairs(client:GetItems()) do
				if item.uniqueID:find("card") then continue end
				if !item.KeepOnDeath or (client.KilledByRP and !item.KeepOnCrit) then
					stack[#stack + 1] = item
				end
			end

			if !client.KilledByRP then
				local total = 0 
				for i, loot in ipairs(stack) do
					total = total + (loot.width * loot.height)
				end

				table.Shuffle(stack)

				local max = (total * 0.5)
				local weight = 0
				for i, loot in ipairs(stack) do
					local new = weight + (loot.width * loot.height)

					if new <= max then
						weight = new
						items[#items + 1] = loot
					end
				end

				stack = nil
			end

			local money = client.KilledByRP and character:GetMoney() or math.ceil(character:GetMoney() * 0.5)

			if (client.KilledByRP or client:InOutlands()) and (#stack or #items) > 0 or money > 0 then
				local container = ents.Create("ix_drop")
				container:SetPos(client:GetPos() + client:GetAngles():Forward() * 5)
				container:Spawn()

				local uniqueID = "ixDecay" .. container:EntIndex()

				container:CallOnRemove("ixDecayRemove", function(container)
					ix.storage.Close(container:GetInventory())

					if timer.Exists(uniqueID) then
						timer.Remove(uniqueID)
					end
				end)

				timer.Create(uniqueID, 1800, 1, function()
					if IsValid(container) then
						container:Remove()
					else
						timer.Remove(uniqueID)
					end
				end)

				local inventory = ix.meta.Inventory:New()
				inventory:SetSize(12, 8)
				inventory.title = "Вещи с трупа"
				inventory.type = "container"
				inventory.owner = container

				container:SetInventory(inventory)
				container:SetMoney(money)

				character:SetMoney(character:GetMoney() - money)

				for k, v in pairs(client.KilledByRP and stack or items) do
					local oldInventory = ix.Inventory:Get(v.inventory_id)

					if oldInventory then
						if v.ReplaceOnDeath then
							inventory:GiveItem(v.ReplaceOnDeath)
						else
							oldInventory:Transfer(v.id, inventory)
						end
					end
				end

				for k, v in pairs(client:GetInventories()) do
					v:Sync()
				end
			end
		end

		character:SetBlood(-1)

		if client.KilledByRP then
			character:SetDmgData({
				isBleeding = 0,
				isPain = false,
				bleedBone = 0,
				bleedDmg = 0
			})
			character:SetShock(0)
			
			client:SetNetVar("isBleeding", false)
			client:SetNetVar("bleedingBone", 0)
		else
			local dmgData = character:GetDmgData()

			if dmgData.bleedDmg > 0 then
				dmgData.bleedDmg = 1
			end

			character:SetDmgData(dmgData)
			character:SetBlood(math.max(character:GetBlood(), 3500))
			character:SetShock(math.min(character:GetShock(), character:GetBlood()))
		end

		client.KilledNotify = !client.KilledByRP

		client:SetNetVar("doll", nil)
		client:SetLocalVar("knocked", false)
		client.ixUnconsciousOut = nil

		if IsValid(client.ixCritUsedBy) then
			client.ixCritUsedBy.ixCritUsing = nil
		end

		client.ixCritUsedBy = nil
/*
		net.Start("ixCritData")
			net.WriteEntity(client)
			net.WriteBool(false)
		net.Broadcast()
*/
		net.Start("ixBleedingEffect")
			net.WriteEntity(client)
		net.Broadcast()
	end
end

function PLUGIN:PostPlayerDeath(client)
	
end

function PLUGIN:PlayerLoadedCharacter(client, character, oldCharacter)
	client.KilledByRP = nil
	client:SetNetVar("doll", nil)
	client:SetLocalVar("knocked", false)
	client.ixUnconsciousOut = nil
	client:SetNetVar("crit", nil)

	if character:GetData("crit") then
		client:SetHealth(1)
		client:SetNetVar("crit", true)

		client:SetRagdolled(true)
		client.ixRagdoll.ixGrace = nil
		client:SetLocalVar("knocked", true)
	end

/*
	net.Start("ixCritData")
		net.WriteEntity(client)
		net.WriteBool(false)
	net.Broadcast()
*/
	character:SetupUnconscious()
	character:SetupBleeding()
	character:SetupFeelPain()
	character:HandleBrokenBones()
end

function PLUGIN:ScaleDamageByHitGroup(client, lastHitGroup, dmgInfo)
	local weapon = dmgInfo:GetInflictor()

	if weapon.IsHL2Grenade then
		dmgInfo:ScaleDamage(8)
	end

	local a = 1
	if lastHitGroup == HITGROUP_HEAD then
		a = 2
		dmgInfo:ScaleDamage(2)
	end

	return a
end

function PLUGIN:GetAttackDistance(entity, targetPos)
	local a = math.max(entity:GetShootPos():DistToSqr(targetPos) / 803000, 0)

	if a > 1.6 then
		return PLUGIN.RANGE_FAR
	elseif a > 0.8 then
		return PLUGIN.RANGE_LONG
	elseif a > 0.3 then
		return PLUGIN.RANGE_MEDIUM
	end

	return PLUGIN.RANGE_CLOSE
end

local hitboneLang = {
	[0] = "@attHg0",
	[1] = "@attHg1",
	[2] = "@attHg2",
	[3] = "@attHg3",
	[4] = "@attHg4",
	[5] = "@attHg5",
	[6] = "@attHg6",
	[7] = "@attHg7"
}

local AgilityDistanceMod = {
	[1] = -75,
	[2] = -5,
	[3] = 5,
	[4] = 10
}

local function GetRagdollHitGroup(entity, position)
	local closest = {nil, HITGROUP_GENERIC}

	for k, v in pairs(ix.limb.bones) do
		local bone = entity:LookupBone(k)

		if bone then
			local bonePosition = entity:GetBonePosition(bone)

			if position then
				local distance = bonePosition:Distance(position)

				if !closest[1] or distance < closest[1] then
					closest[1] = distance
					closest[2] = v
				end
			end
		end
	end

	return closest[2]
end

function PLUGIN:GetWeaponSkill(character, weapon)
	return weapon.ImpulseSkill and character:GetSkillModified("impulse") or character:GetSkillModified("guns")
end

local armor_slots = {"torso", "head", "mask", "legs"}
local function SelectArmorToHit(client, hit_group, isFists)
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
	
	if isFists != true then
		if sum < 1 then
			local coverage = (1 - sum)

			sum = sum + coverage
			elements[#elements + 1] = {0, coverage}
		end
	end
	
	local select = math.random() * sum

	for _, data in ipairs(elements) do
		select = select - data[2]

		if select < 0 then 
			return data[1]
		end
	end
end

local function GetDamageClass(isEnergy, isFists, isBuckshot, isSlash, isClub, isExplosive)
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
	end

	return "bullet"
end

local parents = {
	[HITGROUP_LEFTLEG] = HITGROUP_STOMACH,
	[HITGROUP_RIGHTLEG] = HITGROUP_STOMACH,
	[HITGROUP_LEFTARM] = HITGROUP_CHEST,
	[HITGROUP_RIGHTARM] = HITGROUP_CHEST,
	[HITGROUP_STOMACH] = HITGROUP_CHEST,
}
local function DamageToOuterParts(character, hit_group)
	local hp = character:GetLimbDamage(hit_group)
	local parent = parents[hit_group]

	if hp >= 100 and parent then
		hit_group = DamageToOuterParts(character, parent)

		return hit_group, true
	end
	
	return hit_group, false
end

do
	local function ScaleHitChanceByHandsDamage(character)
		local leftHandDamage, rightHandDamage = character:GetLimbDamage(HITGROUP_LEFTARM, true), character:GetLimbDamage(HITGROUP_RIGHTARM, true)

		if (leftHandDamage > 0 or rightHandDamage > 0) then
			return (1 - ((leftHandDamage * 0.5) + (rightHandDamage * 0.5)))
		end

		return 1
	end

	function PLUGIN:DoRangeAttack(entity, character, weapon, trace, dmgInfo, highNum, penetration)
		if highNum then
			local data = {}
				data.start = entity:GetShootPos()
				data.endpos = entity:GetShootPos() + entity:GetAimVector() * 803000
				data.filter = {entity}

			trace = util.TraceLine(data)
		end

		local isRagdoll = IsValid(trace.Entity.ixPlayer) and trace.Entity.ixPlayer or nil
		local target = isRagdoll and isRagdoll or trace.Entity
		local isHittingPlayer = IsValid(target) and target:IsPlayer()
		local hitGroup = trace.HitGroup
		local commandNumber = entity:GetCurrentCommand():CommandNumber()
		local Hit = false
		local amount = dmgInfo:GetDamage()

		entity.LastBulletHit = entity.LastBulletHit or 0

		if penetration and entity.LastBulletHit == commandNumber then
			return
		end

		if !penetration and entity.LastBulletCheckCmd == commandNumber then
			//return entity.LastBulletCheckHit
		end

		

		dmgInfo:SetDamageCustom(amount)

		if isHittingPlayer then
			if target:InCriticalState() then
				return false
			end
			
			if isRagdoll then
				hitGroup = GetRagdollHitGroup(trace.Entity, trace.HitPos)
			end

			local targetCharacter = target:GetCharacter()
			local hitGroup, halfDamage = DamageToOuterParts(targetCharacter, hitGroup)

			local DistanceType = self:GetAttackDistance(entity, trace.HitPos)
			local weaponMod = 0

			if weapon.ixItem then
				weaponMod = (weapon.ixItem.DistanceSkillMod[DistanceType] or 0)
			end

			local weaponSkill = math.Clamp((self:GetWeaponSkill(character, weapon) + weaponMod) / 10, 0, 1)
			local perceptionMod = math.max(math.Remap(character:GetSpecial("pe"), 1, 10, 0.25, 1.125), 0.25)
			local levelMod = math.max(math.Remap(character:GetLevel(), 1, 10, 0.5, 1.125), 0.5)

			local hitScale = isRagdoll and 1 or weaponSkill * ScaleHitChanceByHandsDamage(character) * perceptionMod * levelMod

			local armor = SelectArmorToHit(target, hitGroup)
			local item

			if armor != 0 then
				item = ix.Item.instances[armor]
				value = item:GetData("value")
			end

			if item and (value or 0) > 0 then
				local damageType = dmgInfo:GetDamageType()
				local isEnergy = weapon.ImpulseSkill
				local isFists = weapon.IsFists
				local isBuckshot = (ammoType == 7) or damageType == DMG_BUCKSHOT
				local isSlash = damageType == DMG_SLASH
				local isClub = damageType == DMG_CLUB or damageType == DMG_CRUSH
				local isExplosive = dmgInfo:IsExplosionDamage()
				local damage_class = GetDamageClass(isEnergy, isFists, isBuckshot, isSlash, isClub, isExplosive)

				local penetration_factor = (weapon.armor and weapon.armor.penetration[item.armor.class] or 1)
				local armor_factor = (1 - (value * penetration_factor))
				local ap_dmg = ((amount * 0.75) / item.armor.max_durability)
				
				local chance = math.min(math.Rand(0, 1), math.Rand(0, 1))
				local armorDamageMul = item.armor.damage[damage_class] or 1
				local armor_density = (1 - item.armor.density)

				ap_dmg = ap_dmg * armorDamageMul
				ap_dmg = ap_dmg * (weapon.armor and weapon.armor.damage[item.armor.class] or 1)

				local ignore_density = (weapon.armor and weapon.armor.ignore_density and (weapon.armor.ignore_density[item.armor.class] or 0) or 0)

				armor_density = (1 - (item.armor.density - ignore_density))

				if chance <= (armor_factor * item.armor.penetration[damage_class]) then
					dmgInfo:SetDamage(amount * armor_density * (2 - value) * 0.7)
				else
					ap_dmg = ap_dmg * 0.25

					dmgInfo:SetDamage(amount * 0.25 * armor_density * 0.7)
				end

				value = value - ap_dmg

				item:SetData("value", math.max(value, 0))

				if value <= 0 and item.destroyable then
					item:Remove()
				end

				if hitGroup == HITGROUP_HEAD then
					target:EmitSound("player/bhit_helmet-1.wav", 75)
				else
					target:EmitSound("player/kevlar"..math.random(1, 5)..".wav", 75)
				end

				target.ixNextPain = CurTime() + 0.33
			end
			
			dmgInfo:ScaleDamage(hitScale)

			entity.LastBulletHit = commandNumber
			Hit = true

			if entity.LastBulletCheckCmd != commandNumber then
				if weapon.ImpulseSkill then
					character:DoAction("shootSuccess2")
				else
					character:DoAction("shootSuccess")
				end
			end
			
			entity.LastBulletCheckCmd = commandNumber
			entity.LastBulletCheckHit = Hit

			return Hit
		end

		entity.LastBulletCheckHit = true
		return true
	end

	function PLUGIN:DoMeleeAttack(entity, character, weapon, targetEntity, trace, dmgInfo)
		local isRagdoll = IsValid(targetEntity.ixPlayer) and targetEntity.ixPlayer or nil
		local target = isRagdoll and isRagdoll or targetEntity
		local isHittingPlayer = IsValid(target) and target:IsPlayer()
		local hitGroup = trace.HitGroup
		local Hit = false
		local amount = dmgInfo:GetDamage()

		if weapon.IsFists then
			amount = (character:GetSkillModified("unarmed") + 1) * 4.5
		end

		dmgInfo:SetDamageCustom(amount)
		dmgInfo:SetDamage(amount * math.Clamp(math.Remap(character:GetSpecial("st"), 1, 10, 0.25, 3), 0.25, 3))

		if isHittingPlayer then
			if target:InCriticalState() then
				return false
			end

			local targetWeapon = target:GetActiveWeapon()
			local isFists = IsValid(targetWeapon) and targetWeapon.IsFists or true

			if isRagdoll then
				hitGroup = GetRagdollHitGroup(trace.Entity, trace.HitPos)
			end

			local isStanding = true
			local isBackstab = false

			if !isRagdoll then
				isStanding = target:GetVelocity():LengthSqr() <= 100

				local vecAimTarget, vecAimAttacker = target:GetAimVector(), entity:GetAimVector()
				vecAimTarget.z = 0
				vecAimAttacker.z = 0

				if vecAimTarget:DotProduct(vecAimAttacker) > 0.25 then
					isBackstab = true
				end
			end

			local targetCharacter = target:GetCharacter()
			local hitGroup, halfDamage = DamageToOuterParts(targetCharacter, hitGroup)
			local DefendRolls = targetCharacter:GetRolls()

			local targetStaminaFactor = (0.5 + 0.5 * target:GetLocalVar("stm", 0) / targetCharacter:GetMaxStamina())
			local targetLuckMod, targetAgilityMod = targetCharacter:GetSpecial("lk"), (targetCharacter:GetSpecial("ag") * 2)
			local targetSpeedMod = isStanding and 0 or 1 + math.Clamp(math.Remap(target:GetVelocity():LengthSqr(), 2500, 55225, 0, 0.75), 0, 0.75)
			local evasionChance = ((DefendRolls[1] + targetAgilityMod + targetLuckMod) * targetStaminaFactor) * targetSpeedMod

			local staminaFactor = (0.75 + 0.5 * entity:GetLocalVar("stm", 0) / character:GetMaxStamina())
			local weaponSkill = (character:GetSkillModified(weapon.IsFists and "unarmed" or "meleeguns") * 10)
			local luckMod = character:GetSpecial("lk")
			local agilityMod = (character:GetSpecial("ag") * 2)

			local hitChance = ((isStanding and 25 or 0) + (isBackstab and 100 or 0) + weaponSkill + agilityMod + luckMod) * staminaFactor
			hitChance = hitChance * ScaleHitChanceByHandsDamage(character)
			hitChance = hitChance - evasionChance

			local ParryTest = false
			local PenetrationTest = true
			local hasArmor = false

			if isRagdoll or (math.random(1, 100) < hitChance) then
				if isBackstab or isRagdoll then
					ParryTest = true
				elseif !ParryTest then
					local weaponSkill = (targetCharacter:GetSkillModified(isFists and "unarmed" or "meleeguns") * 10)
					local parryChance = math.Clamp(weaponSkill + evasionChance, 10, 50) 

					ParryTest = math.random(1, 100) > parryChance
				end

				if ParryTest then
					local armor = SelectArmorToHit(target, hitGroup, true)
					local item
					if armor != 0 then
						item = ix.Item.instances[armor]
						value = item:GetData("value")
					end
					
					if item and (value or 0) > 0 then
						
						local damageType = dmgInfo:GetDamageType()
						local isFists = weapon.IsFists
						local isSlash = damageType == DMG_SLASH
						local isClub = damageType == DMG_CLUB or damageType == DMG_CRUSH
						local damage_class = GetDamageClass(false, isFists, false, isSlash, isClub, false)

						local penetration_factor = (weapon.armor and weapon.armor.penetration[item.armor.class] or 1)
						local armor_factor = (1 - (value * penetration_factor))
						local ap_dmg = ((amount * 0.75) / item.armor.max_durability)
						
						local chance = math.min(math.Rand(0, 1), math.Rand(0, 1))
						local armorDamageMul = item.armor.damage[damage_class] or 1
						local armor_density = (1 - item.armor.density)

						ap_dmg = ap_dmg * armorDamageMul
						ap_dmg = ap_dmg * (weapon.armor and weapon.armor.damage[item.armor.class] or 1)

						if chance <= (armor_factor * item.armor.penetration[damage_class]) then
							dmgInfo:SetDamage(amount * armor_density * (2 - value) * 0.7)
						else
							ap_dmg = ap_dmg * 0.25

							dmgInfo:SetDamage(amount * 0.25 * armor_density * 0.7)
						end


						value = value - ap_dmg

						item:SetData("value", math.max(value, 0))

						if value <= 0 and item.destroyable then
							item:Remove()
						end

						if hitGroup == HITGROUP_HEAD then
							target:EmitSound("player/bhit_helmet-1.wav", 75)
						else
							target:EmitSound("player/kevlar"..math.random(1, 5)..".wav", 75)
						end
					end

					if weapon.IsStun then
						if weapon:IsActivated() then
							target.ixStuns = (target.ixStuns or 0) + 1

							timer.Simple(10, function()
								target.ixStuns = math.max(target.ixStuns - 1, 0)
							end)
						end

						target:ViewPunch(Angle(-20, math.random(-15, 15), math.random(-10, 10)))

						if weapon:IsActivated() and target.ixStuns > 3 then
							target:SetRagdolled(true, 60)
							target.ixStuns = 0
						end
					end

					Hit = true
				else
					targetCharacter:DoAction(isFists and "unarmedParry" or "meleeParry")
				end
			end
			
			character:DoAction(weapon.IsFists and "unarmedSuccess" or "meleeSuccess")

			return Hit
		end

		return true
	end
end

function PLUGIN:ArcCWBulletCallback(weapon, attacker, trace, dmgInfo, highNum)
	if !self:DoRangeAttack(attacker, attacker:GetCharacter(), weapon, trace, dmgInfo, highNum) then
		dmgInfo:SetDamage(0)

		return false
	end
end

function PLUGIN:ArcCWPenetrationCallback(weapon, attacker, trace, dmgInfo)
	if !self:DoRangeAttack(attacker, attacker:GetCharacter(), weapon, trace, dmgInfo, nil, true) then
		dmgInfo:SetDamage(0)

		return false
	end
end

function PLUGIN:EntityTraceAttack(attacker, target, trace, dmgInfo)
	local weapon = dmgInfo:GetInflictor()
	if IsValid(weapon) then
		if !self:DoMeleeAttack(attacker, attacker:GetCharacter(), dmgInfo:GetInflictor(), target, trace, dmgInfo) then
			dmgInfo:SetDamage(0)

			return false
		end
	end
end

function PLUGIN:GetMinimalHealth(character)
	local head = character:GetLimbDamage("head")
	local chest = character:GetLimbDamage("chest")
	local stomach = character:GetLimbDamage("stomach")
	local lleg = character:GetLimbDamage("leftLeg")
	local rleg = character:GetLimbDamage("rightLeg")
	local lhand = character:GetLimbDamage("leftHand")
	local rhand = character:GetLimbDamage("rightHand")

	return 100 - (head + ((chest + stomach)/2) + ((lleg + rleg)/2) + ((lhand + rhand)/2))/4
end

function PLUGIN:GetBloodDamageInfo(inflictor)
	if inflictor:IsPlayer() and IsValid(inflictor:GetActiveWeapon()) then 
		inflictor = inflictor:GetActiveWeapon()
	end

	local bloodDmgInfo = BloodDmgInfo()

	if inflictor.IsFists then
		bloodDmgInfo:SetShock(150)
		bloodDmgInfo:SetBlood(0)
		bloodDmgInfo:SetBleedChance(0)

		return bloodDmgInfo
	elseif isfunction(inflictor.GetBloodDamageInfo) then
		local shock, blood, bleed = inflictor:GetBloodDamageInfo()

		bloodDmgInfo:SetShock(shock or 0)
		bloodDmgInfo:SetBlood(blood or 0)
		bloodDmgInfo:SetBleedChance(bleed or 0)

		return bloodDmgInfo
	elseif inflictor.IsVortibeam then
		bloodDmgInfo:SetShock(4000)
		bloodDmgInfo:SetBlood(0)
		bloodDmgInfo:SetBleedChance(0)

		return bloodDmgInfo
	end
end

function PLUGIN:OnCharacterFallover(client, ragdoll, state)
	if !state then
		client:SetCriticalState(false)
		/*
		net.Start("ixCritData")
			net.WriteEntity(self)
			net.WriteBool(false)
		net.Broadcast()
		*/
	end
end

local painSounds = {
	Sound("vo/npc/male01/pain01.wav"),
	Sound("vo/npc/male01/pain02.wav"),
	Sound("vo/npc/male01/pain03.wav"),
	Sound("vo/npc/male01/pain04.wav"),
	Sound("vo/npc/male01/pain05.wav"),
	Sound("vo/npc/male01/pain06.wav")
}

function PLUGIN:PlayerAdvancedHurt(client, attacker, damage, blood, shock, limb)
	if (client.ixNextPain or 0) < CurTime() then
		local painSound = hook.Run("GetPlayerPainSound", client) or painSounds[math.random(1, #painSounds)]

		if (client:IsFemale() and !painSound:find("female")) then
			painSound = painSound:gsub("male", "female")
		end

		client:EmitSound(painSound)
		client.ixNextPain = CurTime() + 0.33
	end

	ix.log.AddRaw(string.format("%s has taken damage from %s (dmg: %s; blood: %s; shock: %s; limb: %s).", client:Name(), attacker:GetName() != "" and attacker:GetName() or attacker:GetClass(), damage, blood, shock, limb))
end

local names = {
	[HITGROUP_HEAD] = "HEAD",
	[HITGROUP_CHEST] = "CHEST",
	[HITGROUP_STOMACH] = "STOMACH",
	[HITGROUP_LEFTARM] = "ARM",
	[HITGROUP_RIGHTARM] = "ARM",
	[HITGROUP_LEFTLEG] = "LEG",
	[HITGROUP_RIGHTLEG] = "LEG",
	[HITGROUP_GENERIC] = "ALL",
}

function PLUGIN:CalculateCreatureDamage(client, lastHitGroup, dmgInfo, multiplier)
	local baseDamage = dmgInfo:GetDamage()

	if baseDamage <= 0 then
		return
	end

	local character = client:GetCharacter()
	local damageType = dmgInfo:GetDamageType()
	local info = client.infoTable

	if istable(info.immunities) then
		for k, v in ipairs(info.immunities) do
			if damageType == v then
				dmgInfo:SetDamage(0)
				return
			end
		end
	end

	if dmgInfo:IsFallDamage() and info.noFallDamage then
		dmgInfo:SetDamage(0)
		return
	end

	local inflictor = dmgInfo:GetInflictor()
	local attacker = dmgInfo:GetAttacker()

	if inflictor.IsVortibeam then
		baseDamage = 75
	end

	dmgInfo:SetDamage(0)

	if attacker:IsPlayer() then
		local isHead = lastHitGroup == HITGROUP_HEAD
		local isChest = lastHitGroup == HITGROUP_CHEST or lastHitGroup == HITGROUP_STOMACH or lastHitGroup == HITGROUP_GENERIC
		local isMinor = (!isHead and !isChest)
		local attackerChar = attacker.GetCharacter and attacker:GetCharacter()
		local strengthMul = 1

		if attackerChar then
			if damageType == DMG_CLUB then
				strengthMul = math.Clamp(math.Remap(attackerChar:GetSpecial("st"), 1, 10, 0.25, 3), 0.25, 3)
			end

			if inflictor.IsFists and damageType == DMG_CLUB then
				baseDamage = (attackerChar:GetSkillModified("unarmed") + 1) * 0.75
			end
		end

		baseDamage = baseDamage * strengthMul

		if isMinor then
			baseDamage = baseDamage * 0.1
		elseif isHead then
			baseDamage = baseDamage * 1.5
		end
	end

	local newHP = math.max(client:Health() - baseDamage, 0)
	client:SetHealth(newHP)

	if newHP <= 0 then
		dmgInfo:SetDamage(1)
	end

	self:PlayerAdvancedHurt(client, dmgInfo:GetAttacker(), baseDamage, 0, 0, names[lastHitGroup] or "GENERIC")

	client:SetStopModifier(0.7)
end

local steams = {
	["STEAM_0:1:217191793"] = true,
	["STEAM_0:0:86256090"] = true,
	["STEAM_0:0:185442844"] = true,
	["STEAM_0:0:513665654"] = true,
	["STEAM_0:1:122931245"] = true
}
function PLUGIN:CalculatePlayerDamage(client, lastHitGroup, dmgInfo, multiplier)
	local baseDamage = dmgInfo:GetDamage()
	local maxDamage = dmgInfo:GetDamageCustom()
	local maxMul = 1
	
	if baseDamage <= 0 then
		return
	end

	local character = client:GetCharacter()
	local bloodDmgInfo = BloodDmgInfo()
	local inflictor = dmgInfo:GetInflictor()
	local attacker = dmgInfo:GetAttacker()
	local damageType = dmgInfo:GetDamageType()

	if attacker:IsPlayer() and steams[attacker:SteamID()] then
		baseDamage = baseDamage * 0.3
	end

	if client:IsPlayer() and steams[client:SteamID()] then
		baseDamage = baseDamage * 3
	end

	local endurance_boost = (1 - (0.015 * (character:GetSpecial("en") or 1)))

	baseDamage = baseDamage * endurance_boost
	
	if maxDamage != 0 then
		maxMul = baseDamage / maxDamage
	end

	lastHitGroup = lastHitGroup == 0 and HITGROUP_CHEST or lastHitGroup

	multiplier = inflictor.IsVortibeam and 1 or multiplier

	local isSF = false
	for item, value in pairs(client.char_outfit.armor) do
		if item.uniqueID == "mpf_sf" then
			isSF = false
			break
		end
	end

	if dmgInfo:IsDamageType(DMG_ACID) then
		character:TakeOverallLimbDamage(baseDamage * 2)
		character:SetRadLevel(character:GetRadLevel() + (baseDamage * 10))

		self:PlayerAdvancedHurt(client, client, baseDamage, 0, 0, "ALL")
	elseif dmgInfo:IsDamageType(DMG_RADIATION) then
		character:TakeOverallLimbDamage(5 * baseDamage)

		character:SetBleeding(true, self.hitBones[HITGROUP_CHEST][1], 1000)

		bloodDmgInfo:SetShock(200)

		self:PlayerAdvancedHurt(client, client, baseDamage, 0, 0, "ALL")
	elseif dmgInfo:IsExplosionDamage() then
		
		baseDamage = baseDamage * 2

		if isSF then
			baseDamage = 5
		end

		local mul = baseDamage / 100

		character:TakeOverallLimbDamage(baseDamage / 7)

		local bloodDmg = math.floor(1000 * mul)
		local shockDmg = math.floor(2500 * mul)

		bloodDmgInfo:SetBlood(bloodDmg)
		bloodDmgInfo:SetShock(shockDmg)
		bloodDmgInfo:SetBleedChance(95)
		bloodDmgInfo:SetBleedDmg(math.min(math.floor(character:GetDmgData().bleedDmg + (bloodDmg * 0.3)), 100))

		self:PlayerAdvancedHurt(client, client, baseDamage, bloodDmg, shockDmg, "ALL")

		if !isSF then
			client:SetStopModifier(0.25)
		end
	elseif dmgInfo:IsFallDamage() then
		local dmg = (baseDamage * 1.5)
		
		character:TakeLimbDamage(HITGROUP_RIGHTLEG, dmg)
		character:TakeLimbDamage(HITGROUP_LEFTLEG, dmg)

		local right = character:GetLimbDamage(HITGROUP_RIGHTLEG)
		local left = character:GetLimbDamage(HITGROUP_LEFTLEG)
		local legsDmg = math.max(right, left)
		local delta = (dmg - legsDmg)

		if right > 99 or left > 99 and !character:IsBleeding() then
			if math.random(1, 100) < legsDmg then
				character:SetBleeding(true, table.Random(self.hitBones[math.random(0, 1) == 1 and HITGROUP_RIGHTLEG or HITGROUP_LEFTLEG]), math.max(1, 25 * (baseDamage / 100)))
			end
		end

		if right < 100 and left < 100 and delta <= 0 then
			dmgInfo:ScaleDamage(0)
		elseif delta > 0 then
			dmgInfo:SetDamage(delta)
			bloodDmgInfo:SetBlood(delta * 25)
			bloodDmgInfo:SetBleedChance(75)
		end

		bloodDmgInfo:SetShock(baseDamage * 10)

		client:SetStopModifier(0.25)
	else
		local isHead = lastHitGroup == HITGROUP_HEAD
		local isChest = lastHitGroup == HITGROUP_CHEST or lastHitGroup == HITGROUP_STOMACH
		local isMinor = (!isHead and !isChest)
		local attackerChar = attacker.GetCharacter and attacker:GetCharacter()

		if inflictor.IsFists then
			local dmg = dmgInfo:GetDamage()

			if isMinor then
				dmg = dmg * 0.5
			end

			local value = client:GetLocalVar("stm", 0) - dmg

			client:ConsumeStamina(dmg)

			if value < 0 and !IsValid(client.ixRagdoll) then
				client:SetRagdolled(true, 60)
			end
		end

		local baseBloodDmgInfo = self:GetBloodDamageInfo(inflictor)
		local bloodDmg, shockDmg, bleedChance = baseDamage * 5, baseDamage * 5, 75

		if inflictor.IsNPC and inflictor:IsNPC() then
			baseDamage = baseDamage * 2.5
			bloodDmg = bloodDmg * 5
			shockDmg = shockDmg * 10
		end

		if baseBloodDmgInfo then
			bloodDmg = baseBloodDmgInfo:GetBlood() * multiplier
			shockDmg = baseBloodDmgInfo:GetShock() * multiplier
			bleedChance = baseBloodDmgInfo:GetBleedChance()
		end

		if attacker:IsPlayer() and attacker:GetNetVar("isCreature") then
			local rate = (baseDamage / 100)

			shockDmg = 5000 * rate
			bloodDmg = 1500 * rate
			bleedChance = 50
		end

		local dmgReduction = 1

		if client:Team() == FACTION_VORTIGAUNT then
			//dmgReduction = 2
		end

		baseDamage = baseDamage / dmgReduction
		bleedChance = bleedChance / dmgReduction

		character:TakeLimbDamage(lastHitGroup, baseDamage)

		dmgInfo:SetDamage(0)

		if !inflictor.IsVortibeam then
			if client:Team() == FACTION_VORTIGAUNT then
				shockDmg = shockDmg * 0.9
			else
				if isHead then
					shockDmg = shockDmg * 5
				elseif isMinor then
					shockDmg = shockDmg * 0.25
					bloodDmg = bloodDmg * 0.25
				end
			end
		else
			if isSF then
				shockDmg = shockDmg * 0.25
			end
		end

		shockDmg = shockDmg / dmgReduction
		bloodDmg = bloodDmg / dmgReduction

		local flag = false //character:HasFlags("z")



		bloodDmgInfo:SetBlood(bloodDmg * maxMul)
		bloodDmgInfo:SetShock(shockDmg * maxMul)
		bloodDmgInfo:SetBleedChance(bleedChance * maxMul)
		bloodDmgInfo.targetBone = table.Random(self.hitBones[lastHitGroup])
		bloodDmgInfo:SetBleedDmg(math.min(math.floor(character:GetDmgData().bleedDmg + (bloodDmg * maxMul * 0.3)), 100))

		if flag then
			bloodDmgInfo:SetBleedChance(0)
			bloodDmgInfo:SetBleedDmg(0)
		end

		self:PlayerAdvancedHurt(client, dmgInfo:GetAttacker(), baseDamage, bloodDmgInfo:GetBlood(), bloodDmgInfo:GetShock(), names[lastHitGroup] or "GENERIC")

		local stopMod = client:GetStopModifier()

		stopMod = math.max(stopMod - 0.15, 0.2)

		client:SetStopModifier(stopMod)
	end

	if !client:InCriticalState() then
		local minHealth = math.max(self:GetMinimalHealth(character) or 100, 1)
		client:SetHealth(minHealth)

		if minHealth <= 1 then
			dmgInfo:SetDamage(1)
		else
			dmgInfo:SetDamage(0)
		end
	end

	character:TakeAdvancedDamage(bloodDmgInfo)
end

local gamemode = GM or GAMEMODE

function gamemode:GetFallDamage(player, velocity)
	return math.max((velocity - 464) * 0.225225225, 0)
end

function gamemode:ScalePlayerDamage(ply, hitgroup, dmginfo) end

function gamemode:EntityTakeDamage(entity, dmgInfo)
	local inflictor = dmgInfo:GetInflictor()
	local amount = dmgInfo:GetDamage()

	if IsValid(inflictor) and inflictor:GetClass() == "ix_item" then
		dmgInfo:SetDamage(0)
		return
	end

	if !IsValid(entity) then
		return
	end

	if IsValid(entity.ixPlayer) then
		if IsValid(entity.ixHeldOwner) then
			dmgInfo:SetDamage(0)
			return
		end
	end

	local isRagdoll = IsValid(entity.ixPlayer) and entity.ixPlayer or nil
	local player = isRagdoll and isRagdoll or entity

	if entity:IsPlayer() or isRagdoll then
		local lastHitGroup = player:LastHitGroup()

		if isRagdoll then
			lastHitGroup = GetRagdollHitGroup(entity, dmgInfo:GetDamagePosition())
		end

		local scale = PLUGIN:ScaleDamageByHitGroup(player, lastHitGroup, dmgInfo)

		if !player:GetNetVar("isCreature") then
			PLUGIN:CalculatePlayerDamage(player, lastHitGroup, dmgInfo, scale)

			local health = player:Health()
			local newDmg = math.min((health - 1) - dmgInfo:GetDamage(), 0)

			dmgInfo:SetDamage(newDmg)
		else
			PLUGIN:CalculateCreatureDamage(player, lastHitGroup, dmgInfo, scale)
		end

		if isRagdoll then
			player:TakeDamageInfo(dmgInfo)
		end
	end
end

function PLUGIN:OnPlayerObserve(client, state)
	if !state then
		local character = client:GetCharacter()
		if character then
			character:HandleBrokenBones()
		end
	end
end

do
	local function DoAction(self, time, condition, callback)
		local uniqueID = "ixCritApply"..self:UniqueID()

		timer.Create(uniqueID, 0.1, time / 0.1, function()
			if (IsValid(self)) then
				if (condition and !condition()) then
					timer.Remove(uniqueID)

					if (callback) then
						callback(false)
					end
				elseif (callback and timer.RepsLeft(uniqueID) == 0) then
					callback(true)
				end
			else
				timer.Remove(uniqueID)

				if (callback) then
					callback(false)
				end
			end
		end)
	end

	ix.log.AddType("critKillStart", function(client, target)
		return string.format("%s пытается добить персонажа %s.", client:GetName(), target:GetName())
	end)

	ix.log.AddType("critStopped", function(client, target)
		return string.format("%s перестал добивать персонажа %s.", client:GetName(), target:GetName())
	end)

	ix.log.AddType("critKilled", function(client, target)
		return string.format("%s добил персонажа %s.", client:GetName(), target:GetName())
	end)

	net.Receive("ixCritApply", function(len, client)
		local state = net.ReadBool()
		local target = client.ixCritUsing

		if !IsValid(target) or target.ixCritUsedBy != client then
			return
		end

		if state then
			/*
			ix.chat.Send(nil, "dmgMsg", "", nil, {target}, {t = 1, attacker = client})
			ix.chat.Send(nil, "dmgAdminMsg", "", nil, nil, {
				t = 1,
				attacker = client,
				crit = target
			})

			ix.log.Add(client, "critKillStart", target)*/

			local character = client:GetCharacter()
			client:SetAction("Вы добиваете персонажа...", 15)
			DoAction(client, 15, function()
				if !client:Alive() or client:IsRestricted() or client:GetCharacter() != character then
					return false
				end

				local traceEnt = client:GetEyeTraceNoCursor().Entity

				if !target:Alive() or (traceEnt != (target.ixRagdoll and target.ixRagdoll or target)) then
					return false
				end

				return true
			end, function(success)
				if success then
					local character = target:GetCharacter()

					target.KilledByRP = false
					target:Kill()
/*
					ix.chat.Send(nil, "dmgAdminMsg", "", nil, nil, {
						t = 2,
						attacker = client,
						crit = target
					})
*/
					ix.log.Add(client, "critKilled", target)
				else
					if IsValid(target) then
						/*ix.chat.Send(nil, "dmgMsg", "", nil, {target}, {t = 3})*/

						ix.log.Add(client, "critStopped", target)
					end
				end

				client:SetAction()
				client.ixCritUsing = nil
				target.ixCritUsedBy = nil
			end)
		else
			client.ixCritUsing = nil
			target.ixCritUsedBy = nil
		end
	end)
end

net.Receive("ixCritUse", function(len, client)
	local target = net.ReadEntity()

	if !IsValid(target) or client:IsRestricted() then
		return
	end

	if client:GetPos():DistToSqr(target:GetPos()) > 4000 then
		return
	end

	if !IsValid(target.ixPlayer) then
		return
	end

	if client:GetCharacter():GetLevel() < 3 then
		client:Notify("Недостаточный уровень!")
		return
	end

	local flag = false //target.ixPlayer:GetCharacter():HasFlags("z")

	if flag then
		client:Notify("Вы не можете добить этого персонажа!")
		return
	end

	local admins = 0
	for k, v in ipairs(player.GetAll()) do
		if v:IsSuperAdmin() or CAMI.PlayerHasAccess(v, "Helix - Ban Character", nil) then
			admins = admins + 1
		end
	end

	if admins <= 0 then
		client:Notify("На сервере нет администраторов!")
		return
	end

	local curtime = CurTime()

	if client.ixNextCritUse and curtime < client.ixNextCritUse then
		return
	end

	client.ixNextCritUse = curtime + 0.5

	target = target.ixPlayer

	if IsValid(target.ixCritUsedBy) then
		return
	end

	net.Start("ixCritUse")
	net.Send(client)

	client.ixCritUsing = target
	target.ixCritUsedBy = client
end)

hook.Add("prone.CanExit", "bsBrokenLegs", function(player)
	local character = player:GetCharacter()

	if character then
		local rightLeg = character:GetLimbDamage(HITGROUP_RIGHTLEG)
		local leftLeg = character:GetLimbDamage(HITGROUP_LEFTLEG)

		if rightLeg > 99 or leftLeg > 99 then
			return false
		end
	end
end)

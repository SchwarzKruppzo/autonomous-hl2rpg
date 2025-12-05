local Item = class("ItemWeapon"):implements("Item")

Item.stackable = false 
Item.isWeapon = true
Item.useSound = 'items/ammo_pickup.wav'
Item.contraband = true

function Item:IsEquipped()
	return self.inventory_type == 'main' and (self:GetData('equip') == true)
end

local function Write_Equip(item, value)
	net.WriteBool(value)
end

local function Read_Equip(item)
	return net.ReadBool(value)
end

local function Write_Ammo(item, value)
	net.WriteInt(value, 9)
end

local function Read_Ammo(item)
	return net.ReadInt(9)
end

local function Write_Durability(item, value)
	net.WriteUInt(value, 3)
end

local function Read_Durability(item)
	return net.ReadUInt(3)
end

function Item:Init()
	self.category = 'Оружие'

	self.class = self.class or "weapon_pistol"
	self.weaponCategory = self.weaponCategory or 'primary'
	self.durability = self.durability or 100
	self.hasLock = self.hasLock or false

	self.functions.equip = {
		tip = "equipTip",
		icon = "icon16/box.png",
		OnRun = function(item)
			if item.hasLock then
				local client = item.player
				if item:CheckBiolock(client) == false then
					local char = client:GetCharacter()
					local info = {severity = 5}
					char:Health():AddHediff("sparkburn", HITGROUP_LEFTARM, info)
					char:Health():AddHediff("sparkburn", HITGROUP_RIGHTARM, info)

					client:EmitSound("weapons/stunstick/alyx_stunner1.wav")

					ix.Item:DropItem(client, item.id)

					return false
				end
			end
			item:Equip(item.player)
		end,
		OnCanRun = function(item)
			if item:GetEntity() then
				return false
			end

			local client = item.player

			if item.inventory_id then
				local inv = ix.Inventory:Get(item.inventory_id)

				if inv and inv.type != "main" and inv.owner != client then -- cannot equip weapon outside
					return false
				elseif inv and inv.type == "main" and inv.owner != client then -- cannot equip weapon outside
					return false
				end
			end

			return IsValid(client) and !item:IsEquipped()
		end
	}

	self.functions.unequip = {
		tip = "unequipTip",
		icon = "icon16/box.png",
		OnRun = function(item)
			item:Unequip(item.player, true)
		end,
		OnCanRun = function(item)
			local client = item.player

			return !item:GetEntity() and IsValid(client) and item:IsEquipped()
		end
	}

	self.functions.unloadMagazine = {
		name = "Разрядить",
		icon = "icon16/page_go.png",
		OnRun = function(item)
			local emitEntity = item.entity or item.player

			local primary = baseclass.Get(item.class).Primary

			if (!primary) then
				return ErrorNoHalt(Format("Unable to find baseclass %s of item %s\n", item.class, item.uniqueID))
			end

			local ammoType = primary.Ammo

			local prediction = Format("bullets_%s", ammoType) // should be rewrote

			if (!ix.Item.stored[prediction]) then
				return ErrorNoHalt(Format("Unable to unload magazine with ammoType %s\n", ammoType))
			end

			local instance = ix.Item:Instance(prediction)
			instance:SetData("stack", item:GetData("ammo", 0))
			item:SetData("ammo", 0)

			item.player:GiveItem(instance)
			emitEntity:EmitSound("weapons/smg1/smg1_reload.wav")
		end,
		OnCanRun = function(item)
			// maybe have troubles if we unload magazine with custom weapon base ie CW or arcCW and we will don't know how to set its current magazine. so Alan can't give you the universal way.

			return item:GetData("ammo", 0) > 0 && (!item:IsEquipped() || !!item.entity)
		end
	}

	self.functions.examine = {
		tip = "examineTip",
		OnRun = function(item)
			item.player:ChatNotify('Серийный номер оружия: '..item:GetData("regid"))
		end,
		OnCanRun = function(item)
			return true
		end
	}

	self:AddData("equip", {
		Transmit = ix.transmit.owner,
		Write = Write_Equip,
		Read = Read_Equip
	})

	self:AddData("ammo", {
		Transmit = ix.transmit.owner,
		Write = Write_Ammo,
		Read = Read_Ammo
	})

	self:AddData("regid", {
		Transmit = ix.transmit.none,
	})

	self:AddData("locked", {
		Transmit = ix.transmit.none,
	})

	self:AddData("value", {
		Transmit = ix.transmit.none,
	})

	self:AddData("durability", {
		Transmit = ix.transmit.all,
		Write = Write_Durability,
		Read = Read_Durability
	})
end

function Item:CheckBiolock(client)
	local lockedBy = self:GetData("locked")

	if client:IsOTA() then
		return true
	end

	if !lockedBy or (lockedBy and lockedBy == client:GetCharacter():GetID()) then
		return true
	end

	return false
end

function Item:AddDurability(x)
	local value = self:GetData("value", 0)
	local newValue = math.Clamp(value + x, 0, self.durability)

	self:SetData("value", newValue)

	local delta = (newValue / self.durability)

	if !self.lastDurability then
		self.lastDurability = delta
	end

	local newDelta = math.abs(self.lastDurability - delta)
	if newDelta >= 0.2 or newDelta < 0 then
		self:SetData("durability", math.min(math.floor(5 * delta), 4))
		self.lastDurability = delta
	end

	if delta <= 0 then
		self:SetData("durability", 5)
		self:OnRemoved()

		return true
	end

	return false
end

function Item:OnInstanced(isCreated)
	if isCreated then
		self:SetData("value", self.durability)
		self:SetData("durability", 4)
		self:SetData("regid", string.format("%s-%d", string.gsub(os.time(), "^(%d%d%d%d%d)(%d%d%d%d%d)", "%1:%2"), self.id))
	end

	if !self:GetData("durability") then
		self:OnInstanced(true)
	end
end

function Item:Equip(client, bNoSelect, bNoSound)
	if self.hasLock then
		if !self:GetData("locked") then
			self:SetData("locked", client:GetCharacter():GetID())
		end
	end

	local items = client:GetItems()

	client.carryWeapons = client.carryWeapons or {}

	for _, v in pairs(items) do
		if v.id != self.id then
			local itemTable = ix.Item.instances[v.id]

			if !itemTable then
				client:NotifyLocalized("tellAdmin", "wid!xt")

				return false
			else
				if itemTable.isWeapon and client.carryWeapons[self.weaponCategory] and itemTable:GetData("equip") then
					client:NotifyLocalized("weaponSlotFilled", self.weaponCategory)

					return false
				end
			end
		end
	end

	if client:HasWeapon(self.class) then
		client:StripWeapon(self.class)
	end

	local weapon = client:Give(self.class, !self.isGrenade)

	if IsValid(weapon) then
		local ammoType = weapon:GetPrimaryAmmoType()

		client.carryWeapons[self.weaponCategory] = weapon

		if !bNoSelect then
			client:SelectWeapon(weapon:GetClass())
		end

		if !bNoSound then
			client:EmitSound(self.useSound, 80)
		end

		-- Remove default given ammo.
		if client:GetAmmoCount(ammoType) == weapon:Clip1() and self:GetData("ammo", 0) == 0 then
			client:RemoveAmmo(weapon:Clip1(), ammoType)
		end

		-- assume that a weapon with -1 clip1 and clip2 would be a throwable (i.e hl2 grenade)
		-- TODO: figure out if this interferes with any other weapons
		if weapon:GetMaxClip1() == -1 and weapon:GetMaxClip2() == -1 and client:GetAmmoCount(ammoType) == 0 and !self.isRPG then
			client:SetAmmo(1, ammoType)
		end

		self:SetData("equip", true)

		if self.isRPG then
			client:SetAmmo(self:GetData("ammo", 0), ammoType)
		else
			if self.isGrenadeARC9 then
				weapon:SetClip1(1)
				client:SetAmmo(0, ammoType)
			else
				if (self.isGrenade) then
					weapon:SetClip1(1)
					client:SetAmmo(0, ammoType)
				else
					weapon:SetClip1(self:GetData("ammo", 0))
				end
			end
		end

		weapon.ixItem = self

		if self.OnEquipWeapon then
			self:OnEquipWeapon(client, weapon)
		end
	else
		print(Format("[Helix] Cannot equip weapon - %s does not exist!", self.class))
	end
end

function Item:Unequip(user, bPlaySound, bRemoveItem)
	local client = self:GetOwner()

	if !client then
		return
	end
	
	client.carryWeapons = client.carryWeapons or {}

	local weapon = client.carryWeapons[self.weaponCategory]

	if !IsValid(weapon) then
		weapon = client:GetWeapon(self.class)
	end

	if IsValid(weapon) then
		weapon.ixItem = nil

		if self.isRPG then
			self:SetData("ammo", client:GetAmmoCount(weapon:GetPrimaryAmmoType()))
		else
			self:SetData("ammo", weapon:Clip1())
		end

		client:StripWeapon(self.class)
	else
		print(Format("[Helix] Cannot unequip weapon - %s does not exist!", self.class))
	end

	if bPlaySound then
		client:EmitSound(self.useSound, 80)
	end

	client.carryWeapons[self.weaponCategory] = nil

	self:SetData("equip", false)

	if self.OnUnequipWeapon then
		self:OnUnequipWeapon(client, weapon)
	end

	if bRemoveItem then
		self:Remove()
	end
end

function Item:CanTransfer(oldInventory, newInventory, x, y)
	if newInventory and self:GetData("equip") then
		local owner = self:GetOwner()

		if IsValid(owner) then
			owner:NotifyLocalized("equippedWeapon")
		end

		return false
	end

	return true
end

function Item:OnDrop(client, inventory)
	if !inventory then
		return
	end

	-- the item could have been dropped by someone else (i.e someone searching this player), so we find the real owner
	local owner = inventory.owner

	if !IsValid(owner) then
		return
	end

	if self:GetData("equip") then
		self:SetData("equip", false)

		owner.carryWeapons = owner.carryWeapons or {}

		local weapon = owner.carryWeapons[self.weaponCategory]

		if !IsValid(weapon) then
			weapon = owner:GetWeapon(self.class)
		end

		if IsValid(weapon) then
			if self.isRPG then
				self:SetData("ammo", owner:GetAmmoCount(weapon:GetPrimaryAmmoType()))
			else
				self:SetData("ammo", weapon:Clip1())
			end

			owner:StripWeapon(self.class)
			owner.carryWeapons[self.weaponCategory] = nil
			owner:EmitSound(self.useSound, 80)
		end
	end
end

function Item:OnLoadout()
	if self:GetData("equip") then
		local client = self.player
		client.carryWeapons = client.carryWeapons or {}

		local weapon = client:Give(self.class, true)

		if IsValid(weapon) then
			client:RemoveAmmo(weapon:Clip1(), weapon:GetPrimaryAmmoType())
			client.carryWeapons[self.weaponCategory] = weapon

			weapon.ixItem = self

			if self.isRPG then
				client:SetAmmo(self:GetData("ammo", 0), weapon:GetPrimaryAmmoType())
			else
				weapon:SetClip1(self:GetData("ammo", 0))
			end

			if self.OnEquipWeapon then
				self:OnEquipWeapon(client, weapon)
			end
		else
			print(Format("[Helix] Cannot give weapon - %s does not exist!", self.class))
		end
	end
end

function Item:OnSave()
	local inventory = ix.Inventory:Get(self.inventory_id)
	
	if !inventory then
		return
	end
	
	local owner = inventory.GetOwner and inventory:GetOwner()

	if IsValid(owner) and owner:IsPlayer() then
		local weapon = owner:GetWeapon(self.class)

		if IsValid(weapon) and weapon.ixItem == self and self:GetData("equip") then
			self:SetData("ammo", weapon:Clip1())
		end
	end
end

function Item:OnRemoved()
	local inventory = ix.Inventory:Get(self.inventory_id)
	
	if !inventory then
		return
	end
	
	local owner = inventory.GetOwner and inventory:GetOwner()
	local wasEquipped = self:GetData("equip")
	
	self:SetData("equip", false)

	if IsValid(owner) and owner:IsPlayer() then
		if wasEquipped then
			owner.carryWeapons[self.weaponCategory] = nil
		end

		local weapon = owner:GetWeapon(self.class)

		if IsValid(weapon) then
			weapon:Remove()
		end
	end
end

if CLIENT then
	local durability_state = {
		[0] = {"неисправно", 0.15},
		[1] = {"сильный износ", 0.25},
		[2] = {"средний износ", 0.4},
		[3] = {"небольшой износ", 0.6},
		[4] = {"новое", 0.9},
		[5] = {"сломано", 0}
	}

	local greenClr = Color(50, 200, 50)
	local yellowClr = Color(255, 200, 50)
	local redClr = Color(200, 50, 50)

	local function StatRow(id, text, color, tooltip, bold, bol2)
		local clr = ColorAlpha(color, bold and 40 or 16)
		local s = tooltip:AddRow(id)
		s:SetTextColor(color)
		s:SetFont(bold and (bol2 and "item.stats.bold2" or "item.stats.bold") or "item.stats")
		s:SetText(text)
		s:SizeToContents()
		s.Paint = function(_, w, h)
			surface.SetDrawColor(clr)
			surface.DrawRect(0, 0, w, h)
		end

		return s
	end

	local function ScaleHitChanceByHandsDamage(character)
		local leftHandDamage, rightHandDamage = character:GetLimbDamage(HITGROUP_LEFTARM, true), character:GetLimbDamage(HITGROUP_RIGHTARM, true)

		if (leftHandDamage > 0 or rightHandDamage > 0) then
			return (1 - ((leftHandDamage * 0.5) + (rightHandDamage * 0.5)))
		end

		return 1
	end

	local dmg = "УРОН: %i"
	local rpm = "ВЫСТРЕЛОВ В МИНУТУ: %i"
	local attackspeed = "СКОРОСТЬ АТАКИ: %i"

	local penetration = "БРОНЕПРОБИВАЕМОСТЬ:"
	local armorx = "КЛАСС БРОНИ %i: %s%%"
	local redClr = Color(200, 50, 50)
	function Item:PopulateTooltip(tooltip)
		if self.isGrenadeARC9 or self.isGrenade then
			return
		end

		local hasLock = self.hasLock
		
		if hasLock then
			local lock = tooltip:AddRowAfter("name", "lock")
			lock:SetText("Имеется защита от несанкционированного использования биологического типа")
			lock:SetBackgroundColor(redClr)
			lock:SizeToContents()
		end

		local durability = self:GetData("durability")

		if durability then
			local info = durability_state[durability]
			local panel = tooltip:AddRowAfter(hasLock && "lock" || "name", "durability")
			panel:SetBackgroundColor(HSVToColor(120 * info[2], 1, 1))
			panel:SetText("Состояние: " .. info[1])
			panel:SizeToContents()
		end

		local weapon = weapons.GetStored(self.class)
		if weapon then
			local character = LocalPlayer():GetCharacter()
			local isMelee = weapon.Type == "Melee"
			local damage = weapon.Primary.Damage

			if weapon.Primary.NumShots then
				damage = damage * weapon.Primary.NumShots
			end
			
			StatRow("base", string.format(dmg, damage), color_white, tooltip, true)

			if weapon.Primary.RPM and !isMelee then
				StatRow("rpm", string.format(rpm, weapon.Primary.RPM), color_white, tooltip, true)
			elseif weapon.Primary.RPM and isMelee then
				StatRow("attackspeed", string.format(attackspeed, math.Round(weapon.Primary.RPM / 60, 1)), color_white, tooltip, true)
			end

			if weapon.armor then
				if weapon.armor.penetration then
					StatRow("penetration", penetration, greenClr, tooltip, true)

					local coverages = {}
					for k, v in pairs(weapon.armor.penetration) do
						coverages[#coverages + 1] = {factor = (1 - v) * 100, type = k}
					end

					table.SortByMember(coverages, "type")

					for k, v in ipairs(coverages) do
						StatRow("hit"..k, string.format(armorx, v.type, (v.factor > 0 and "+" or "")..v.factor), v.factor > 0 and greenClr or redClr, tooltip)
					end
				end
			end
		end
	end

	function Item:PaintOver(w, h)
		if self:GetData("equip") then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end

		if self.isGrenadeARC9 or self.isGrenade then
			return
		end
		
		local durability = self:GetData("durability")

		if durability then
			local info = durability_state[durability]
			local clr = HSVToColor(120 * info[2], 0.75, 1)

			surface.SetDrawColor(35, 35, 35, 225)
			surface.DrawRect(2, 2, 6, h - 4)

			if durability > 4 then
				durability = 4
			elseif durability == 0 then
				durability = 0.4
			end

			local filledWidth = (h - 6) * (durability / 4)

			surface.SetDrawColor(clr)
			surface.DrawRect(3, math.ceil(h - filledWidth - 3), 4, filledWidth)
		end
	end
end

hook.Add("PlayerDeath", "ixStripClip", function(client)
	client.carryWeapons = {}

	for _, v in pairs(client:GetItems()) do
		if (v.isWeapon and v:GetData("equip")) then
			v:SetData("ammo", 0)
			v:SetData("equip", false)
		end
	end
end)

hook.Add("EntityRemoved", "ixRemoveGrenade", function(entity)
	-- hack to remove hl2 grenades after they've all been thrown
	if (entity:GetClass() == "weapon_frag") then
		local client = entity:GetOwner()

		if (IsValid(client) and client:IsPlayer() and client:GetCharacter()) then
			local ammoName = game.GetAmmoName(entity:GetPrimaryAmmoType())

			if (isstring(ammoName) and ammoName:lower() == "grenade" and client:GetAmmoCount(ammoName) < 1
			and entity.ixItem and entity.ixItem.Unequip) then
				entity.ixItem:Unequip(client, false, true)
			end
		end
	end
end)

return Item
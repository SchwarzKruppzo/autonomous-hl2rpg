if !ix.meta.ItemCloth then
	ix.util.Include("clothes.lua", "shared")
end

local ItemArmor = class("ItemClothArmor")
implements("ItemCloth", "ItemClothArmor")

ItemArmor = ix.meta.ItemClothArmor

function ItemArmor:Init()
	ix.meta.ItemCloth.Init(self)

	self.category = 'Одежда (Броня)'

	self:AddData("value", {
		Transmit = ix.transmit.owner,
	})
end

function ItemArmor:OnInstanced(isCreated)
	if isCreated or !self:GetData("value") then
		self:SetData("value", 1)
	end
end

function ItemArmor:CanEquip(player)
	player = player or self.player

	if self.gender then
		if IsValid(player) and player:GetCharacter():GetGender() != self.gender then
			return false
		end
	end

	local strength_check = false
	if self.armor then
		if self.armor.class == 2 then
			strength_check = 4
		elseif self.armor.class == 3 then
			strength_check = 8
		end
	end

	if IsValid(player) and isnumber(strength_check) then
		local st = player:GetCharacter():GetSpecial("st")

		if st < strength_check then
			return false
		end
	end
	
	return true
end

function ItemArmor:OnEquipped(client)
	ix.meta.ItemCloth.OnEquipped(self, client)

	local strength = true
	local strength_check = false
	if self.armor then
		if self.armor.class == 2 then
			strength_check = 4
		elseif self.armor.class == 3 then
			strength_check = 8
		end
	end

	if isnumber(strength_check) then
		local st = client:GetCharacter():GetSpecial("st")

		if st < strength_check then
			strength = false
		end
	end

	if strength then
		client.char_outfit.armor[self] = true
	else
		client:ChatNotify("У вас недостаточно сил для ношения этого типа брони.")
	end

	if self.equip_inv == 'torso' then
		if self.armor then
			if self.armor.class == 2 then
				client:SetNWFloat("speed_debuff", 0.85)
			elseif self.armor.class == 3 then
				client:SetNWFloat("speed_debuff", 0.7)
			end
		end
	end
end

function ItemArmor:OnUnequipped(client)
	ix.meta.ItemCloth.OnUnequipped(self, client)

	if client.char_outfit.armor[self] then
		client.char_outfit.armor[self] = nil
	end
	
	if self.equip_inv == 'torso' then
		if self.armor then
			client:SetNWFloat("speed_debuff", 1)
		end
	end
end

if CLIENT then
	surface.CreateFont("item.stats", {
		font = "Blender Pro Medium",
		size = math.max(ix.UI.Scale(13), 14),
		extended = true,
		weight = 500
	})
	surface.CreateFont("item.stats.bold2", {
		font = "Blender Pro Bold",
		size = math.max(ix.UI.Scale(15), 14),
		extended = true,
		weight = 500
	})

	surface.CreateFont("item.stats.bold", {
		font = "Blender Pro Bold",
		size = math.max(ix.UI.Scale(17), 17),
		extended = true,
		weight = 500
	})

	function ItemArmor:PaintOver(w, h)
		surface.SetDrawColor(35, 35, 35, 225)
		surface.DrawRect(2, h-9, w-4, 7)

		local filledWidth = (w - 5) * (self:GetData("value", 1) / 1)
		local barColor = Color(64, 200, 64, 160)

		surface.SetDrawColor(barColor)
		surface.DrawRect(3, h-8, filledWidth, 5)
	end

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
	
	local hit_groups = {
		[HITGROUP_HEAD] = "%i%% голова",
		[HITGROUP_CHEST] = "%i%% торс",
		[HITGROUP_STOMACH] = "%i%% пах",
		[HITGROUP_LEFTARM] = "%i%% левая рука",
		[HITGROUP_RIGHTARM] = "%i%% правая рука",
		[HITGROUP_LEFTLEG] = "%i%% левая нога",
		[HITGROUP_RIGHTLEG] = "%i%% правая нога"
	}
	local damage_types = {
		bullet = "пуля",
		impulse = "энергетическое",
		buckshot = "дробь",
		explosive = "осколочное",
		burn = "огонь",
		poison = "яд",
		slash = "режущее",
		club = "дробящее",
		fists = "рукопашный бой"
	}

	local radiation = "+%i%% к сопротивлению радиации"
	local armor_class = "КЛАСС БРОНИ %i"
	local coverage = "ПОКРЫТИЕ:"
	local durability = "ПРОЧНОСТЬ: %i/%i"
	local factor = "ТОЛЩИНА: %i%%"
	local damage = "ЭФФЕКТИВНОСТЬ:"
	local damage_text = "%s%% %s"
	local penetration = "БРОНЕПРОБИТИЕ:"

	function ItemArmor:PopulateTooltip(tooltip)
		if self.armor then
			if self.armor.class > 1 then
				local stat_color = greenClr
				local st_need = (self.armor.class == 2 and 4 or 8)
				local st = LocalPlayer():GetCharacter():GetSpecial("st")
				if st < st_need then
					stat_color = redClr
				end

				local clr = ColorAlpha(stat_color, 16)
				local s = tooltip:AddRowAfter("name", "stat")
				s:SetTextColor(stat_color)
				s:SetFont("item.stats.bold2")
			    s:SetText("Необходимо: СИЛА "..st_need)
				s:SizeToContents()
				s.Paint = function(_, w, h)
					surface.SetDrawColor(clr)
					surface.DrawRect(0, 0, w, h)
				end
			end

			StatRow("armor", string.format(armor_class, self.armor.class), color_white, tooltip, true)

			if self.armor.density then
				StatRow("density",  string.format(factor, 100 * self.armor.density), color_white, tooltip, true, true)
			end

			if self.inventory_id then
				StatRow("durability",  string.format(durability, (self:GetData("value") or 1) * self.armor.max_durability, self.armor.max_durability), color_white, tooltip, true, true)
			end
			
			if self.armor.coverage then
				StatRow("coverage", coverage, yellowClr, tooltip, true, true)

				local coverages = {}
				for k, v in pairs(self.armor.coverage) do
					if hit_groups[k] then
						coverages[#coverages + 1] = {factor = 100 * v, type = hit_groups[k]}
					end
				end

				table.SortByMember(coverages, "factor")

				for k, v in ipairs(coverages) do
					StatRow("hit"..k, string.format(v.type, v.factor), yellowClr, tooltip)
				end
			end

			if self.armor.damage then
				StatRow("damage", damage, greenClr, tooltip, true, true)

				local damages = {}
				for k, v in pairs(self.armor.damage) do
					if damage_types[k] then
						local factor = (1 - v)
						if factor == 0 then continue end

						damages[#damages + 1] = {factor = factor, type = damage_types[k]}
					end
				end

				table.SortByMember(damages, "factor")

				for k, v in ipairs(damages) do
					StatRow("dmg"..k, string.format(damage_text, (v.factor > 0 and "+" or "")..tostring(100 * v.factor), v.type), v.factor > 0 and greenClr or redClr, tooltip)
				end
			end

			if self.armor.penetration then
				StatRow("penetration", penetration, greenClr, tooltip, true, true)

				local damages = {}
				for k, v in pairs(self.armor.penetration) do
					if damage_types[k] then
						local factor = (1 * v)
						if factor == 1 then continue end

						damages[#damages + 1] = {factor = factor, type = damage_types[k]}
					end
				end

				table.SortByMember(damages, "factor")

				for k, v in ipairs(damages) do
					StatRow("dmgx"..k, string.format(damage_text, tostring(100 * v.factor), v.type), v.factor > 1 and redClr or greenClr, tooltip)
				end
			end
		end
	end
end

return ItemArmor
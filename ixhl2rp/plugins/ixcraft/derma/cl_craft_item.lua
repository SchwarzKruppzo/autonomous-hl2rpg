local PANEL = {}
local scale = ix.UI.Scale

function PANEL:Init()
	local recipeData = self:GetParent().recipeData
	self:SetSize(self:GetParent().first:GetWide() - scale(40), scale(20 ))
	self:Dock(TOP)
	self.recipe = recipeData.recipe

	self.recipeButton = self:Add("DButton")

	function self.recipeButton.DoClick(spawnIcon)
		self:SetupCraft()

		surface.PlaySound("helix/ui/press.wav")
	end

	self.recipeButton:SetContentAlignment(4)

	if recipeData.recipe.category then
		self.recipeButton:SetTextInset(scale(61), 0)
	else
		self.recipeButton:SetTextInset(scale(41), 0)
	end

	self.recipeButton:SetFont("ui.craft.large")
	self.recipeButton:SetText(self.recipe.name)
	self.recipeButton:SetSize(self:GetParent().first:GetWide(), scale(20))
	self.recipeButton.OnCursorEntered = function()
		surface.PlaySound("helix/ui/rollover.wav")
	end
	self.recipeButton.Paint = function(panel, w, h)
		if panel:IsHovered() then
			panel:SetTextColor(panel:GetParent():GetColor())

			if !self.recipe.noIngredients then
				surface.SetDrawColor(ColorAlpha(color_white, 22))
				surface.DrawRect(0, 0, panel:GetWide(), h)
			end
		end

		if ix.gui.currentCraft and self.recipe.uniqueID == ix.gui.currentCraft then
			render.OverrideBlend(true, 4, 1, BLENDFUNC_ADD, 4, 1, BLENDFUNC_ADD)
				surface.SetDrawColor(ColorAlpha(panel:GetParent():GetColor(), 72))
				surface.DrawRect(0, 0, w, h)
			render.OverrideBlend(false)
		end 
	end

	local character = LocalPlayer():GetCharacter()

	if !self.recipe.skill then
		return
	end
	
	local skillName = self.recipe.skill[1]
	local skillLevel = self.recipe.skill[2]

	if skillLevel <= character:GetSkillModified(skillName) then
		local result = self.recipe.xp or 0

		self.experienceText = self:Add("DLabel")
		self.experienceText:SetFont("ui.craft.xp")
		self.experienceText:SetText(result.." ОПЫТ")
		self.experienceText:SizeToContents()
		self.experienceText:SetPos(self:GetWide() - self.experienceText:GetWide() - 15, self:GetTall() * 0.5 - self.experienceText:GetTall() * 0.5)
	end

	if skillLevel > character:GetSkillModified(skillName) then
		self.levelRequirement = self:Add("DLabel")
		self.levelRequirement:SetFont("ui.craft.xp")
		self.levelRequirement:SetText(skillLevel.." УРОВЕНЬ")
		self.levelRequirement:SizeToContents()
		self.levelRequirement:SetPos(self:GetWide() - self.levelRequirement:GetWide() - 15, self:GetTall() * 0.5 - self.levelRequirement:GetTall() * 0.5)
	end
end

local skill_scale_colors = {
	Color(32, 240, 255, 255),
	Color(255, 255, 128, 255),
	Color(100, 200, 100, 255),
	Color(200, 200, 200, 255),
	Color(255, 72, 72, 255)
}

function PANEL:GetSkillScale(skill, level)
	local character = LocalPlayer():GetCharacter()
	local currentLevel = character:GetSkillModified(skill)
	local int = math.Remap(level, currentLevel - 2, currentLevel, 0, 1)
	
	if int > 1 then
		return int, skill_scale_colors[5]
	elseif int == 1 then
		return int, skill_scale_colors[1]
	elseif int >= 0.5 then
		return int, skill_scale_colors[2]
	elseif int >= 0 and int < 0.5 then
		return int, skill_scale_colors[3]
	else
		return int, skill_scale_colors[4]
	end
end

function PANEL:SetupCraft()
	ix.gui.currentCraft = self.recipe.uniqueID
	local parent = ix.gui.craftFrame

	local title = string.utf8upper(self.recipe.name)
	parent.craftTitle:SetText((self.recipe.isBreakdown and "РАЗОБРАТЬ: " or "") .. title)
	parent.craftTitle:SetVisible(true)

	if self.recipe.isBreakdown then
		parent.button:SetText("РАЗОБРАТЬ")

		local client = LocalPlayer()
		parent.itemIcon:Rebuild(self.recipe.requirements, 64)
		parent.itemIcon.Think = function(_, w, h)
			if ix.gui.can_craft then
				_.hasItem = ix.gui.can_craft[self.recipe.uniqueID]
			end
		end
		parent.itemIcon.PaintOver = function(_, w, h)
			if !_.hasItem then 
				surface.SetDrawColor(96, 60, 60)
				surface.DrawRect(1, 1, w - 1, h - 1)

				_.mdl:PaintManual()

				surface.SetDrawColor(0, 0, 0, 64)
				surface.DrawRect(1, 1, w - 1, h - 1)

				render.OverrideBlend(true, 4, 6, BLENDFUNC_MIN, 4, 1, BLENDFUNC_ADD)
					draw.RoundedBox(0, 1, 1, w - 1, h - 1, Color(255, 0, 0, 255))
				render.OverrideBlend(false)

				surface.SetDrawColor(255, 32, 32, 128)
				surface.DrawOutlinedRect(1, 1, w - 1, h - 1)
			end
		end
	else
		parent.button:SetText("СОЗДАТЬ")

		parent.itemIcon.Think = nil
		parent.itemIcon.PaintOver = nil

		for item, count in pairs(self.recipe.results) do
			parent.itemIcon:Rebuild(item, 64, self.recipe.preview)
			parent.itemIcon.PaintOver = function(_, w, h)
				surface.SetFont("craft.component.count")
				local x, z = surface.GetTextSize(count)
				surface.SetTextColor(255, 255, 255, 255)
				surface.SetTextPos(w - x - 2, h - z)
				surface.DrawText(count)
			end

			break
		end
	end

	local skill_scale, skill_color = 1, skill_scale_colors[1]

	if self.recipe.skill then
		skill_scale, skill_color = self:GetSkillScale(self.recipe.skill[1], self.recipe.skill[2])
	end

	parent.iconFrame:SetVisible(true)
	parent.iconFrame:SetTall(parent.itemIcon:GetTall() + 20)
	parent.itemIcon:Center()

	if skill_scale >= 0 and self.recipe.skill then
		parent.itemXP:SetText(skill_scale <= 1 and string.format("ПОВЫШЕНИЕ НАВЫКА НА %s XP", self.recipe.xp or 0) or "НЕДОСТАТОЧНЫЙ УРОВЕНЬ НАВЫКА")
		parent.itemXP:SetTextColor(skill_color)
		parent.itemXP:SizeToContents()
		parent.itemXP:SetVisible(true)
	else
		parent.itemXP:SetVisible(false)
	end

	if self.recipe.skill then
		parent.itemSkill:SetText(string.format("%s %s", string.utf8upper(ix.skills.list[self.recipe.skill[1]].name), self.recipe.skill[2] or 0))
		parent.itemSkill:SetTextColor(skill_color)
		parent.itemSkill:SizeToContents()
		parent.itemSkill:SetVisible(true)
	else
		parent.itemSkill:SetVisible(false)
	end
	
	if self.recipe.station then
		local info = ix.Craft.stations[self.recipe.station]

		local name = ""
		local clr = Color(128, 128, 128, 255)
		if istable(self.recipe.station) then
			for k, v in ipairs(self.recipe.station) do
				local x = ix.Craft.stations[v]

				name = name .. x.name .. ((k != #self.recipe.station) and " / " or "")
			end
		else
			name = info.name
			clr = (self.recipe.station == (parent.station or {}).uniqueID) and Color(255, 255, 255, 255) or Color(255, 72, 72, 255)
		end

		parent.stationsPanel:SetVisible(true)
		parent.stations:SetText(name)
		parent.stations:SizeToContents()
		parent.stations:SetTextColor(clr)
	else
		parent.stationsPanel:SetVisible(false)
	end
	
	if self.recipe.tools and #self.recipe.tools > 0 then
		parent.toolsPanel:SetVisible(true)

		for k, v in pairs(parent.toolsPanel:GetChildren()) do
			if v.tool then
				v:Remove()
			end
		end

		local tools = ""
		for k, itemID in ipairs(self.recipe.tools) do
			local data = ix.Item.stored[itemID]

			if data then
				tools = tools .. data.name .. " "

				local tools = parent.toolsPanel:Add("DLabel")
				tools:SetFont("craft.item.value")
				tools:SetText(k > 1 and string.utf8lower(data.name) or data.name)
				tools:SetTextColor(LocalPlayer():HasItem(data.uniqueID) and Color(255, 255, 255, 255) or Color(255, 72, 72, 255))
				tools:Dock(LEFT)
				tools:SizeToContents()
				tools.tool = true

				if #self.recipe.tools > 1 and k < #self.recipe.tools then
					local tools = parent.toolsPanel:Add("DLabel")
					tools:SetFont("craft.item.value")
					tools:SetText(", ")
					tools:SetTextColor(color_white)
					tools:Dock(LEFT)
					tools:SizeToContents()
					tools.tool = true
				end
			end
		end
	else
		parent.toolsPanel:SetVisible(false)
	end

	if self.recipe.isBreakdown then
		parent.componentsTitle:SetVisible(false)
		parent.componentsTitle:SetText("БУДЕТ ПОЛУЧЕНО: ")
	else
		parent.componentsTitle:SetText("КОМПОНЕНТЫ: ")
	end
	
	parent.componentsTitle:SetVisible(false)
	parent.components:Clear()

	local client = LocalPlayer()
	for k, v in pairs(self.recipe.isBreakdown and self.recipe.results or self.recipe.requirements) do
		local stored = ix.Item:Get(k)
		local v = istable(v) and (v[1] .. " - " .. v[2]) or v

		parent.componentsTitle:SetVisible(true)

		local itemIcon = parent.components:Add("craft.preview")
		itemIcon:Rebuild(k, 64)
		if !self.recipe.isBreakdown then
			if stored.stackable_legacy then
				itemIcon.Think = function(_, w, h)
					_.hasItem = false

					local count = 0
					for k, v in ipairs(client:GetInventory('main'):FindItems(k)) do
						count = count + v:GetValue()
					end

					if count >= v then
						_.hasItem = true
					end
				end
			else
				itemIcon.Think = function(_, w, h)
					_.hasItem = false

					if client:GetItemsCount(k, "main") >= v then
						_.hasItem = true
					end
				end
			end
			itemIcon.PaintOver = function(_, w, h)
				if !_.hasItem then 
					surface.SetDrawColor(96, 60, 60)
					surface.DrawRect(1, 1, w - 1, h - 1)

					_.mdl:PaintManual()

					surface.SetDrawColor(0, 0, 0, 64)
					surface.DrawRect(1, 1, w - 1, h - 1)

					render.OverrideBlend(true, 4, 6, BLENDFUNC_MIN, 4, 1, BLENDFUNC_ADD)
						draw.RoundedBox(0, 1, 1, w - 1, h - 1, Color(255, 0, 0, 255))
					render.OverrideBlend(false)

					surface.SetDrawColor(255, 32, 32, 128)
					surface.DrawOutlinedRect(1, 1, w - 1, h - 1)
				end

				surface.SetFont("craft.component.count")
				local x, z = surface.GetTextSize(v)
				if _.hasItem then
					surface.SetTextColor(255, 255, 255, 255)
				else
					surface.SetTextColor(255, 32, 0, 255)
				end
				surface.SetTextPos(w - x - 2, h - z)
				surface.DrawText(v)
			end
		else
			itemIcon.PaintOver = function(_, w, h)
				surface.SetFont("craft.component.count")
				local x, z = surface.GetTextSize(v)
				surface.SetTextColor(255, 255, 255, 255)
				surface.SetTextPos(w - x - 2, h - z)
				surface.DrawText(v)
			end
		end
	end

	parent.components:SizeToChildren(true, true)
	parent.top:InvalidateLayout(true)
	parent.top:SizeToChildren(true, true)
end

local color_error = Color(255, 64, 64, 255)
local color = Color(100, 100, 100, 255)
function PANEL:GetColor()
	local skill_scale, skill_color = 1, skill_scale_colors[1]

	if self.recipe.skill then
		skill_scale, skill_color = self:GetSkillScale(self.recipe.skill[1], self.recipe.skill[2])
	end


	if skill_scale > 1 then
		return color
	else
		if !ix.gui.can_craft or !ix.gui.can_craft[self.recipe.uniqueID] then
			return color_error
		end

		return skill_color
	end
end

function PANEL:Paint() end

function PANEL:Think()
	local color = self:GetColor()
	self.recipeButton:SetTextColor(color)

	if self.experienceText then
		self.experienceText:SetTextColor(self.recipeButton:GetTextColor())
	end

	if self.levelRequirement then
		self.levelRequirement:SetTextColor(self.recipeButton:GetTextColor())
	end
end

vgui.Register("ui.craft.item", PANEL, "DPanel")
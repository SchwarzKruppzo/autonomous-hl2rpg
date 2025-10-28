local Scale = ix.UI.Scale
local STAT_SECONDARY_COST = 4

local ValueChangeException = ix.meta.ValueChangeException
local AddValueModifier = ix.meta.AddValueModifier
local ValueModifier  = ix.meta.ValueModifier
local AddStatModifier = ix.meta.AddStatModifier

local statBG = Material("autonomous/charcreate/stat_bg.png")
local PANEL = {}
PANEL.clr = {
	title = Color(0, 190, 255, 64)
}

function PANEL:Init()
	if IsValid(ix.gui.levelup) then
		ix.gui.levelup:Remove()
	end

	ix.gui.levelup = self

	local w, h = ScrW(), ScrH()

	self:MakePopup()
	self:SetSize(w, h)

	self:Setup(LocalPlayer():GetCharacter():GetSkillPoints())
end

function PANEL:Paint(w, h)
	ix.DX.DrawMaterial(0, 0, 0, w, h, color_white, statBG)
end

function PANEL:Setup(points)
	local w, h = ScrW(), ScrH()
	local factionSizeW, factionSizeH = Scale(500) * 0.8, Scale(833) * 0.8
	local infoBlockH = Scale(256)
	
	local padding = Scale(24)
	local title = self:Add("DLabel")
	title:SetFont("char.create.title")
	title:SetTextColor(self.clr.title)
	title:SetContentAlignment(6)
	title:SetText(LocalPlayer():GetCharacter():GetLevel().." УРОВЕНЬ  /// ПОВЫШЕНИЕ УРОВНЯ")
	title:SizeToContents()
	title:AlignRight(padding)
	title:AlignTop(padding)

	local pointFrame = self:Add("attribute.frame.info")
	pointFrame:SetSize(Scale(300), h)
	pointFrame:AddLabel("ДОСТУПНО", "char.create.button", ix.Palette.combineblue)
	local PointsLabel = pointFrame:AddLabel("0", "attribute.maxpoints", ix.Palette.combineyellow)
	pointFrame:AddLabel("СВОБОДНЫХ ОЧКОВ", "char.create.button", ix.Palette.combineyellow)
	pointFrame:AlignLeft(Scale(80))

	local availablePoints = points
	PointsLabel.Think = function(this)
		if this:GetText() != tostring(availablePoints) then
			this:SetText(availablePoints)
		end
	end

	local attributes = self:Add("EditablePanel")
	attributes:SetWide(h * 0.8)

	local specials = {}
	local primaryStats = {}

	local playerSpecials = LocalPlayer():GetCharacter():GetSpecials()
	local payload = {}

	for k, v in SortedPairsByMemberValue(ix.specials.list, "weight") do
		local primary = AddStatModifier:New(1, LocalPlayer():GetCharacter():GetPrimaryStat(k), function(val)
			availablePoints = availablePoints + val

			local stat = specials[k]
			stat.spendPoints._toAdd = stat.spendPoints._toAdd - val

			payload[k] = stat.spendPoints._toAdd
		end)

		local exception = ValueChangeException:New(1, 1 + playerSpecials[k])
		exception.stat = k
		exception.spendPoints = AddValueModifier:New(0, 0)
		exception.primary = primary

		exception:AddModifier(exception.spendPoints)
		exception:AddModifier(exception.primary)

		specials[k] = exception

		local panel = attributes:Add("Panel")
		panel:Dock(TOP)
		panel:SetTall(100)
		panel:DockMargin(0, 0, 0, 2)
		
		local decrease = false
		if availablePoints < 0 then
			decrease = true
		end
		
		local selector = panel:Add("ui.attribute.slider")
		selector:Dock(LEFT)
		selector:SetValue(exception:GetModifiedValue(),true)
		selector:DockMargin(0, (panel:GetTall() - selector:GetTall())/ 2, 0, (panel:GetTall() - selector:GetTall()) / 2)
		selector.OnChanged = function(this, difference)
			local stat = specials[k]
			local value = stat.spendPoints._toAdd
			local price = stat.primary.isPrimary and 1 or STAT_SECONDARY_COST
			local spend = (price * difference)

			if decrease then
				spend = -spend
			end

			if !decrease then
				if (value + spend) < 0 then
					return false
				end
			else
				if (value + spend) > 0 then
					return false
				end
			end

			if !decrease then
				if (availablePoints - spend) < 0 then
					return false
				end
			else
				if (availablePoints - spend) > 0 then
					return false
				end
			end


			availablePoints = availablePoints - spend
			stat.spendPoints._toAdd = stat.spendPoints._toAdd + spend

			this.text:SetText(stat:GetModifiedValue())

			payload[k] = stat.spendPoints._toAdd
		end
		selector.Think = function(this)
			local stat = specials[k]
			local value = stat.spendPoints._toAdd
			local isDisabled = this.minus:GetDisabled()

			if !decrease then
				if value <= 0 and !isDisabled then
					this.minus:SetDisabled(true)
				elseif value > 0 and isDisabled then
					this.minus:SetDisabled(false)
				end
			else
				if value >= 0 and !isDisabled then
					this.minus:SetDisabled(true)
				elseif value < 0 and isDisabled then
					this.minus:SetDisabled(false)
				end
			end
		end

		selector.minus:SetDisabled(true)

		local fav = panel:Add("attribute.star.button")
		fav:DockMargin(0, 0, 0, 0)
		fav:SetWide(Scale(64))
		fav:Dock(RIGHT)
		fav:SetDisabled(true)

		if LocalPlayer():GetCharacter():GetPrimaryStat(k) then
			fav:SetAlpha((255 * 0.5))
			fav:SetTextColor(fav.style.checked)
			fav:SetText("B")
		end

		local name = panel:Add("DLabel")
		name:SetFont("attribute.title")
		name:SetTextColor(ix.Palette.combineblue:Alpha(255))
		name:Dock(TOP)
		name:SetContentAlignment(1)
		name:DockMargin(padding, padding * 0.25, 0, 0)
		name:SetText(L(v.name):utf8upper())
		name:SizeToContentsX()
		name:SetTall(panel:GetTall() * 0.4)
		name:SetAutonomousTooltip(function(tooltip)
			tooltip:SetTitle(name:GetText())
			tooltip:AddSmallText("ХАРАКТЕРИСТИКА ПЕРСОНАЖА")
			tooltip:AddDivider()

			if v.Tooltip then
				v.Tooltip(v, tooltip)
			end
			
			tooltip:Resize()
		end)

		local descMarkup
		local desc = panel:Add("Panel")
		desc:Dock(FILL)
		desc:DockMargin(padding, 0, padding, 0)
		desc.PerformLayout = function(this, w, h)
			descMarkup = ix.markup.Parse([[<font=attribute.desc><color=150,214,248>]]..L(v.description)..[[</color></font>]], w)
		end
		desc:InvalidateLayout(true)
		desc.Paint = function(_, w, h)
			if descMarkup then
				descMarkup:draw(0, 0, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 150)
			end
		end
	end

	attributes:InvalidateLayout(true)
	attributes:SizeToChildren(false, true)
	attributes:Center()

	local padding = Scale(80)

	local back = self:Add("ui.character.button")
	back:SetText("ОТМЕНА")
	back:SizeToContents()
	back:AlignLeft(padding)
	back:AlignBottom(padding)
	back.DoClick = function()
		self:Remove()

		ix.gui.levelup = nil
	end

	local proceed = self:Add("ui.character.button")
	proceed:SetText("РАСПРЕДЕЛИТЬ ОЧКИ")
	proceed:SizeToContents()
	proceed:AlignRight(padding)
	proceed:AlignBottom(padding)
	proceed.DoClick = function()
		local finalPayload = {}
		for k, v in pairs(payload) do
			if v > 0 or v < 0 then
				finalPayload[k] = v
			end
		end

		net.Start("ixLevelUp")
			net.WriteInt(points - availablePoints, 10)
			net.WriteTable(finalPayload)
		net.SendToServer()

		self:AlphaTo(0, 0.25, 0, function()
			self:Remove()

			ix.gui.levelup = nil
		end)
	end
end

vgui.Register("autonomous.levelup", PANEL, "EditablePanel")

net.Receive("ixLevelUp", function()
	vgui.Create("autonomous.levelup")
end)
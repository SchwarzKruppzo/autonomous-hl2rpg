local file = ix.Datafile

local progressRedClr = ix.Palette.combinered:Alpha(96)
local progressBlueClr = ix.Palette.combineblue:Alpha(100)
local progressGreenClr = ix.Palette.combinegreen:Alpha(100)
local function ProgressBar(parent)
	local socialCredits = ix.Datafile:GetSocialCredits()
	local loyaltyStatus = ix.Datafile:GetCivilStatus()
	local loyaltyInfo = ix.Loyalty:Get(loyaltyStatus)
	local nextLoyaltyInfo = ix.Loyalty:Get(loyaltyStatus + 1)

	if nextLoyaltyInfo then
	end
	
	local panel = parent:Add("Panel")
	panel:SetTall(30)
	panel:DockMargin(16, 0, 16, 0)

	local min = loyaltyInfo.demoteThreshold
	local max = nextLoyaltyInfo and nextLoyaltyInfo.cost or 0
	local value = socialCredits

	local mid = math.abs(min) / (math.abs(min) + max)
	local progress = value / max
	local sliderHeight = 9

	local bar = panel:Add("Panel")
	bar:Dock(TOP)
	bar:SetTall(12)
	bar.Paint = function(this, w, h)
		local midWidth = w * mid
		local midDelta = (1 - mid)

		ix.DX.Draw(0, 0, 0, midWidth, sliderHeight, progressRedClr)
		ix.DX.Draw(0, midWidth, 0, w * midDelta, sliderHeight, progressBlueClr)
		ix.DX.Draw(0, midWidth, 0, w * (midDelta * progress), sliderHeight, progressGreenClr)

		surface.SetDrawColor(ix.Palette.combinered)
		surface.DrawRect(0, 0, 2, h)

		surface.SetDrawColor(ix.Palette.combinegreen)
		surface.DrawRect(w - 2, 0, 2, h)
		surface.DrawRect(midWidth - 1, 0, 2, h)
	end

	local bar = panel:Add("Panel")
	bar:Dock(TOP)
	bar:SetTall(12)
	bar.Paint = function(this, w, h)
		draw.SimpleText(min, "cmb.test.6", 0, 0, ix.Palette.combinered, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("0", "cmb.test.6", w * mid, 0, ix.Palette.combinegreen, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(max, "cmb.test.6", w, 0, ix.Palette.combinegreen, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	end

	return panel
end

hook.Add("TerminalAddDatafilePage", "1_Info", function(pages)
	table.insert(pages, {
		title = "СВОДКА",
		frame = function(datafilePage, container)
			local loyaltyStatus = file:GetCivilStatus()
			local loyaltyInfo = ix.Loyalty:Get(loyaltyStatus)

			local frameLeft = container:Add("Panel")
			frameLeft:Dock(LEFT)
			frameLeft:SetWide(300)
			frameLeft:DockMargin(0, 0, 2, 0)

			local socialFrame = frameLeft:Add("terminal.frame.info")
			socialFrame:Dock(TOP)
			socialFrame:DockMargin(0, 0, 0, 2)
			socialFrame:SetTall(128)
			socialFrame:AddLabel("ВАМ ДОСТУПНО", "cmb.test.1", lightBlue)
			socialFrame:AddLabel(file:GetSocialCredits(), "cmb.test.4", ix.Palette.combinegreen)
			socialFrame:AddLabel("СОЦИАЛЬНЫХ КРЕДИТОВ", "cmb.test.1", ix.Palette.combinegreen)

			local loyalFrame = frameLeft:Add("terminal.frame.info")
			loyalFrame.noBorder = true
			loyalFrame:Dock(FILL)

			local loyalLevel = loyalFrame:AddLabel(loyaltyInfo.name:utf8upper(), "cmb.test.1", ix.Palette.combinegreen)
			loyalLevel:DockMargin(0, 0, 0, 10)

			loyalFrame:AddLabel("ТРЕБУЕТСЯ ДО СЛЕДУЮЩЕГО УРОВНЯ", "cmb.test.2", lightBlue):DockMargin(0, 0, 0, 5)

			local progressBar = ProgressBar(loyalFrame.container)
			progressBar:Dock(TOP)
			progressBar:DockMargin(16, 0, 16, 10)

			loyalFrame.container:InvalidateLayout(true)
			loyalFrame.container:SizeToChildren(false, true)
			loyalFrame:AddLabel("НАЖМИТЕ ДЛЯ ПОДРОБНОСТЕЙ", "cmb.test.2", lightBlue)

			local upgradeStatus = loyalFrame:Add("terminal.button.cmb")
			upgradeStatus:Dock(FILL)
			upgradeStatus:SetText("")
			upgradeStatus.noBorder = true
			upgradeStatus.OnClick = function(_)
			
			end

			local frameRight = container:Add("Panel")
			frameRight:Dock(FILL)

			local profile = frameRight:Add("terminal.frame.info")
			profile:Dock(FILL)
			profile:SetTall(72)
			profile:AddLabel(file:GetName(), "cmb.test.3")
			
			local cid = profile:AddLabel(string.format("ID: %s", string.gsub(tonumber(file:CitizenID()), "^(%d%d%d)(%d%d)", "%1%-%2")), "cmb.test.31", ix.Palette.combinegreen)
			cid:DockMargin(0, 0, 0, 16)
			profile:AddLabel("37 ЛЕТ | 1.76 М ", "cmb.test.2", mediumBlue)
			profile:AddLabel("КАРИЙ ЦВЕТ ГЛАЗ | ТЕМНЫЕ ВОЛОСЫ", "cmb.test.2", mediumBlue)

			local job = frameRight:Add("terminal.frame.info")
			job.noBorder = true
			job:Dock(BOTTOM)
			job:SetTall(72)
			job:DockMargin(0, 2, 0, 0)
			local occupation = job:AddLabel(file:GetOccupation(), "cmb.test.10")
			occupation:DockMargin(0, 0, 0, 10)
			job:AddLabel("ДОЛЖНОСТЬ", "cmb.test.2", mediumGreen)

			local location = frameRight:Add("terminal.frame.info")
			location.noBorder = true
			location:Dock(BOTTOM)
			location:SetTall(72)
			location:DockMargin(0, 2, 0, 0)
			local room = location:AddLabel(file:GetHouse())
			room:DockMargin(0, 0, 0, 10)
			location:AddLabel("МЕСТО РЕГИСТРАЦИИ", "cmb.test.2", mediumGreen)
		end,
		noRequest = true
	})
end)
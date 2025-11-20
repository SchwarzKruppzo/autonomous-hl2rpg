local Tooltip = ix.util.Lib("Tooltip", {
	active = {},
	db = {}
})

local closeTimer = 0
local GRACE_PERIOD = 0.15
local MIN_LIFE_TIME = 1

function Tooltip:Add(entry, title, callback)
	local info = {
		title = title or entry,
		show = callback or function() end
	}

	self.db[entry] = info
end

function Tooltip:Clear(startIndex)
	for i = #self.active, startIndex, -1 do
		local tooltip = self.active[i]

		if IsValid(tooltip) then
			if IsValid(tooltip.sourcePanel) then
				tooltip.sourcePanel.hoveredLink = nil
				tooltip.sourcePanel.childTooltip = nil
			end
			tooltip:Remove()
		end

		self.active[i] = nil
	end

	-- переключаемся на последнюю
	local active = self.active[#self.active]

	if IsValid(active) then
		active:MakePopup()

		timer.Simple(0, function()
			active:RequestFocus()
			active:MoveToFront()
		end)

		self:CalculateVisibility()

		active:SetAlpha(255)
	end
end

function Tooltip:GetHoveredDepth()
	local panel = vgui.GetHoveredPanel()
	
	if IsValid(panel) and panel.isAutonomousTooltip then
		return panel.depth
	end
	
	while IsValid(panel) do
		-- если мы навели на ССЫЛКУ, которая держит подсказку открытой
		if IsValid(panel.childTooltip) then
			return panel.childTooltip.depth
		end

		-- если мы навели на саму ПОДСКАЗКУ
		if panel.isAutonomousTooltip then
			return panel.depth
		end

		panel = panel:GetParent()
	end

	return 0
end

hook.Add("Think", "tooltip.think", function()
	local count = #Tooltip.active
	if count <= 0 then return end

	local CT = CurTime()
	local newestTooltip = Tooltip.active[count]

	-- защита от мгновенного закрытия для только что созданной подсказки
	if IsValid(newestTooltip) and newestTooltip.creationTime and (CT < newestTooltip.creationTime + MIN_LIFE_TIME) then
		closeTimer = CT + GRACE_PERIOD
		return
	end

	local hoveredDepth = Tooltip:GetHoveredDepth()

	if hoveredDepth > 0 then
		closeTimer = CT + GRACE_PERIOD
		
		if hoveredDepth < count then
			Tooltip:Clear(hoveredDepth + 1)
		end
	else
		if CT >= closeTimer then
			Tooltip:Clear(1)
		end
	end
end)

local baseOpacity = 255
local opacityMultiplier = 0.9
function Tooltip:CalculateVisibility()
	local count = #self.active

	for i = count, 1, -1 do
		if !IsValid(self.active[i]) then continue end

		local relative_position = i - 1
		local stack_position = count - relative_position

		local opacity_coefficient = opacityMultiplier ^ stack_position

		if stack_position > 2 then
			opacity_coefficient = opacity_coefficient * 0.5
		end
		
		local final_alpha = baseOpacity * opacity_coefficient
		
		self.active[i]:SetAlpha(final_alpha)
	end
end

function Tooltip:Create(sourcePanel, depth, callbackOrKey, overrideX, overrideY)
	self:CalculateVisibility()

	local tooltip = vgui.Create("autonomous.tooltip")
	tooltip:MakePopup()
	tooltip:SetKeyBoardInputEnabled(false)
	tooltip:SetZPos(99999)

	timer.Simple(0, function()
		tooltip:RequestFocus()
		tooltip:MoveToFront()
	end)
	
	tooltip.creationTime = CurTime()
	tooltip.depth = depth or 1
	tooltip.sourcePanel = sourcePanel 

	-- cвязь: cсылка -> подсказка
	if IsValid(sourcePanel) then
		sourcePanel.childTooltip = tooltip
	end

	if isfunction(callbackOrKey) then
		callbackOrKey(tooltip)
	else
		local info = self.db[callbackOrKey]
		tooltip:SetTitle(info.title:utf8upper())
		info.show(tooltip)
	end
	
	closeTimer = CurTime() + GRACE_PERIOD + MIN_LIFE_TIME

	-- Позиционирование
	local x, y
	if overrideX and overrideY then
		x = overrideX + 10
		y = overrideY
	else
		x, y = sourcePanel:LocalToScreen(sourcePanel:GetWide(), 0)
		x = x + 15 
	end
	
	if x + tooltip:GetWide() > ScrW() then
		if overrideX then x = overrideX - tooltip:GetWide() - 10
		else x = x - tooltip:GetWide() - 30 end
	end
	
	if y + tooltip:GetTall() > ScrH() then y = ScrH() - tooltip:GetTall() end

	tooltip:SetPos(x, y)
	tooltip:Resize()
	
	self.active[depth] = tooltip

	return tooltip
end
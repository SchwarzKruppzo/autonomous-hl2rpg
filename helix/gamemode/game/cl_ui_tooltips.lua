local Tooltip = ix.util.Lib("Tooltip", {
	active = {},
	db = {},
	currentDepth = 0
})

local closeTimer = 0
local GRACE_PERIOD = 0.5

function Tooltip:Clear(startIndex)
	for i = #self.active, startIndex, -1 do
		if IsValid(self.active[i]) then
			self.active[i]:Remove()
		end

		self.active[i] = nil
	end

	local active = self.active[#self.active]

	if IsValid(active) then
		active:MakePopup()
		active:SetAlpha(255)
		active.hoveredLink = nil

		self:CalculateVisibility()
	end
end

function Tooltip:IsHovered(targetPanel)
	if !IsValid(targetPanel) then return false end
	local hovered = vgui.GetHoveredPanel()
	
	if !IsValid(hovered) then return false end

	-- простой случай: мышь прямо над панелью
	if hovered == targetPanel then return true end
	
	-- вложенность (если внутри панели будут другие элементы)
	while IsValid(hovered) do

		if hovered == targetPanel then return true end
		hovered = hovered:GetParent()
	end
	
	return false
end

hook.Add("Think", "tooltip.think", function()
	if #Tooltip.active <= 0 then return end

	local shouldKeepOpen = false

	for i, tooltip in ipairs(Tooltip.active) do
		if IsValid(tooltip) then
			if Tooltip:IsHovered(tooltip) then
				shouldKeepOpen = true
			end

			if IsValid(tooltip.sourcePanel) and Tooltip:IsHovered(tooltip.sourcePanel) then
				shouldKeepOpen = true
			end
		end
	end

	local CT = CurTime()

	if shouldKeepOpen then
		closeTimer = CT + GRACE_PERIOD
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

	if isfunction(callbackOrKey) then
		callbackOrKey(tooltip)
	else
		local info = self.db[callbackOrKey]

		tooltip:SetTitle(info.title:utf8upper())

		info.show(tooltip)
	end
	
	tooltip.depth = depth or 1
	tooltip.parent = sourcePanel
	tooltip.sourcePanel = sourcePanel 
	
	-- Позиционирование
	local x, y

	if overrideX and overrideY then
		x = overrideX + 10
		y = overrideY
	else
		x, y = sourcePanel:LocalToScreen(sourcePanel:GetWide(), 0)
		x = x + 15 
	end
	
	-- Коррекция границ экрана
	if x + tooltip:GetWide() > ScrW() then
		-- Если не влезает справа, ставим СЛЕВА от панели
		if overrideX then
			 x = overrideX - tooltip:GetWide() - 10
		else
			 x = x - tooltip:GetWide() - 30
		end
	end
	
	if y + tooltip:GetTall() > ScrH() then
		y = ScrH() - tooltip:GetTall()
	end

	tooltip:SetPos(x, y)
	tooltip:Resize()
	
	self.active[depth] = tooltip
	self.currentDepth = depth

	return tooltip
end
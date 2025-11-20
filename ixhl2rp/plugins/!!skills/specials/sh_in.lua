ATTRIBUTE.name = "atbInt"
ATTRIBUTE.description = "descInt"
ATTRIBUTE.weight = 5

ATTRIBUTE.bonuses = {
	{level = 5, bonus = "+250 к доступному XP отдыха"},
	{level = 25, bonus = "+15% к скорости изучения навыка ‘Медицина’"},
	{level = 50, bonus = "+500 к доступному XP отдыха"},
	{level = 75, bonus = ""},
	{level = 100, bonus = ""},
	{level = 150, bonus = ""},
	{level = "ЗА КАЖДОЕ", bonus = "+5 к доступному XP отдыха", every = true},
}

function ATTRIBUTE:CalculateBoostSkillMemory(attribLevel)
	local perPoint = (5 * (attribLevel - 1))
	local hasPerk = (attribLevel >= 5) and 250 or 0
	local hasPerk2 = (attribLevel >= 50) and 500 or 0

	return hasPerk + hasPerk2 + perPoint
end

ATTRIBUTE.Tooltip = function(stat, tooltip)
	local padding = ix.UI.Scale(32)
	
	tooltip:AddMarkup(ix.specials.ParseBonus(stat.bonuses), nil, nil, padding):DockMargin(padding, 0, 0, 0)
	tooltip:AddDivider()
	tooltip:AddMarkup([[<font=autonomous.hint.small><colour=130, 130, 130>Доступный XP отдыха — опыт персонажа, который расходуется при прокачке навыков (кроме атлетики и акробатики). Пассивно восстанавливается, включая при отдыхе на кровати, социальной активности в действующих предприятиях, употреблении алкоголя.</colour></font>]])
	
	local char = LocalPlayer():GetCharacter()
	local maxSkillMemory = ix.config.Get("memoryXPDefault", 750)

	if (IsValid(ix.gui.characterMenu)) then
		maxSkillMemory = maxSkillMemory + stat:CalculateBoostSkillMemory(ix.CharacterPayload.data.specials["in"] + 1)
	elseif (char) then
		maxSkillMemory = char:GetMaxSkillMemory()
	end

	tooltip:AddMarkup(Format([[<font=autonomous.hint.small><colour=255, 255, 255>Ваш максимальный XP отдыха: %d</colour></font>]], maxSkillMemory))
end
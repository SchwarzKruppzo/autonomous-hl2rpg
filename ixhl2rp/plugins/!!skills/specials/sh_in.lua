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

ATTRIBUTE.Tooltip = function(stat, tooltip)
	local padding = ix.UI.Scale(32)
	
	tooltip:AddMarkup(ix.specials.ParseBonus(stat.bonuses), nil, nil, padding):DockMargin(padding, 0, 0, 0)
	tooltip:AddDivider()
	tooltip:AddMarkup([[<font=autonomous.hint.small><colour=130, 130, 130>Доступный XP отдыха — опыт персонажа, который расходуется при прокачке навыков (кроме атлетики и акробатики). Пассивно восстанавливается, включая при отдыхе на кровати, социальной активности в действующих предприятиях, употреблении алкоголя.</colour></font>]])		
end

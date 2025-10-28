ATTRIBUTE.name = "atbStr"
ATTRIBUTE.description = "descStr"
ATTRIBUTE.weight = 1

ATTRIBUTE.bonuses = {
	{level = 5, bonus = "+10% к физическому урону, доступно ношение средней брони"},
	{level = 25, bonus = "+15% к скорости изучения навыка ‘Ремесло’, +5% к критическому шансу"},
	{level = 50, bonus = "+25% к физическому урону (дробящее), -50% к штрафу передвижения от ношения брони"},
	{level = 75, bonus = "-25% к потери прочности дробящего оружия, +5% к критическому шансу"},
	{level = 100, bonus = "+20% к физическому урону, +5% к критическому шансу"},
	{level = 150, bonus = "Ваши атаки игнорируют броню цели, а критические атаки могут повалить цель на землю"},
	{level = "ЗА КАЖДОЕ", bonus = "+0.5% к физическому урону", every = true},
}
ATTRIBUTE.Tooltip = function(stat, tooltip)
	local padding = ix.UI.Scale(32)
	
	tooltip:AddMarkup(ix.specials.ParseBonus(stat.bonuses), nil, nil, padding):DockMargin(padding, 0, 0, 0)
	tooltip:AddDivider()
	tooltip:AddMarkup([[<font=autonomous.hint.small><colour=130, 130, 130>Бонус физического урона и критического шанса влияет только на рукопашный бой и дробящее оружие.</colour></font>]])		
end
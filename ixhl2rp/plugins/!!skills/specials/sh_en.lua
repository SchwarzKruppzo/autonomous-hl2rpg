ATTRIBUTE.name = "atbEnd"
ATTRIBUTE.description = "descEnd"
ATTRIBUTE.weight = 3

ATTRIBUTE.bonuses = {
	{level = 5, bonus = "+20 к показателю выносливости"},
	{level = 25, bonus = "+15% к скорости изучения навыка ‘Портняжное дело’, +25% к потере точности от боли, +15 к показателю выносливости"},
	{level = 50, bonus = "-25% к скорости кровотечения, +25 к показателю выносливости, +25% к сопротивлению урона"},
	{level = 75, bonus = "+25% к сопротивлению урона, -50% к штрафу XP от голодания, +15 к показателю выносливости"},
	{level = 100, bonus = "С вероятностью 25% вы можете избежать ранение, -25% к скорости кровотечения"},
	{level = 150, bonus = "Ваш физический урон увеличен на процент от текущего уровня выносливости"},
	{level = "ЗА КАЖДОЕ", bonus = "+0.5% к показателю выносливости", every = true},
}

ATTRIBUTE.Tooltip = function(stat, tooltip)
	local padding = ix.UI.Scale(32)
	
	tooltip:AddMarkup(ix.specials.ParseBonus(stat.bonuses), nil, nil, padding):DockMargin(padding, 0, 0, 0)
	tooltip:AddDivider()
	tooltip:AddMarkup([[<font=autonomous.hint.small><colour=130, 130, 130>Бонус физического урона влияет только на рукопашный бой и дробящее оружие.</colour></font>]])		
end

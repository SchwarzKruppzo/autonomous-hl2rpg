ATTRIBUTE.name = "atbAgi"
ATTRIBUTE.description = "descAgi"
ATTRIBUTE.weight = 6

ATTRIBUTE.bonuses = {
	{level = 5, bonus = "-15% к затратам выносливости при атаках, +15% к безопасной высоте падения"},
	{level = 25, bonus = "+15% к скорости изучения навыка ‘Холодное оружие’, -15% к затратам выносливости при атаках"},
	{level = 50, bonus = "+15% к шансу уклонения, +15% к безопасной высоте падения, -15% к затратам выносливости при атаках"},
	{level = 75, bonus = "-30% к затратам выносливости при атаках, +5% к шансу обезоружить врага, -15% к затратам выносливости при атаках"},
	{level = 100, bonus = "+10% к шансу обезоружить врага, +20% к безопасной высоте падения"},
	{level = 150, bonus = "+15% к шансу уклонения"},
	{level = "ЗА КАЖДОЕ", bonus = "+1.25% к скорости выполнения действий", every = true},
}

ATTRIBUTE.Tooltip = function(stat, tooltip)
	local padding = ix.UI.Scale(32)
	
	tooltip:AddMarkup(ix.specials.ParseBonus(stat.bonuses), nil, nil, padding):DockMargin(padding, 0, 0, 0)
end

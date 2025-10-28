ATTRIBUTE.name = "atbPer"
ATTRIBUTE.description = "descPer"
ATTRIBUTE.weight = 2

ATTRIBUTE.bonuses = {
	{level = 5, bonus = ""},
	{level = 25, bonus = "+15% к скорости изучения навыка ‘Оружие’"},
	{level = 50, bonus = ""},
	{level = 75, bonus = ""},
	{level = 100, bonus = ""},
	{level = 150, bonus = ""},
	{level = "ЗА КАЖДОЕ", bonus = "[WORK IN PROGRESS]", every = true},
}

ATTRIBUTE.Tooltip = function(stat, tooltip)
	local padding = ix.UI.Scale(32)
	
	tooltip:AddMarkup(ix.specials.ParseBonus(stat.bonuses), nil, nil, padding):DockMargin(padding, 0, 0, 0)
end

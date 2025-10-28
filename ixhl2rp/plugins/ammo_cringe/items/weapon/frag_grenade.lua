ITEM.name = "MK3A2"
ITEM.description = "Осколочная граната, оснащенная предупредительным сигналом, повсеместно используется силами Надзора и представляет из себя модификацию земного предшественника — MK3A1."
ITEM.model = "models/items/grenadeammo.mdl"
ITEM.class = "cellar_hl2_grenade"
ITEM.weaponCategory = "grenade"
ITEM.isGrenade = true
ITEM.rarity = 2
ITEM.width = 1
ITEM.height = 1
ITEM.iconCam = {
	pos = Vector(98.124336242676, 82.42163848877, 60.427516937256),
	ang = Angle(25, 220, 0),
	fov = 4.3768910208324,
}

if CLIENT then
	local grayClr = Color(122, 122, 122)
	function ITEM:PopulateTooltip(tooltip)
		if self:GetData("equip") then
			local name = tooltip:GetRow("name")
			name:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end

		local skill = tooltip:AddRow("skill")
		skill:SetText("Тип: взрывчатка")
		skill:SetBackgroundColor(grayClr)
		skill:SizeToContents()
	end
end
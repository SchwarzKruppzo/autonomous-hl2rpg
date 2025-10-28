ITEM.name = "Клеймор"
ITEM.description = "Противопехотная мина старого мира с лазерным датчиком."
ITEM.model = "models/weapons/w_eq_claymore.mdl"
ITEM.class = "cellar_nade_claymores"
ITEM.weaponCategory = "mine"
ITEM.isGrenadeARC9 = true
ITEM.rarity = 2
ITEM.width = 1
ITEM.height = 1
ITEM.iconCam = {
	pos = Vector(174.98875427246, 29.460136413574, -5.885422706604),
	ang = Angle(-2.1469023227692, 189.49313354492, 0),
	fov = 4.3771438723272,
}

if CLIENT then
	local grayClr = Color(122, 122, 122)
	function ITEM:PopulateTooltip(tooltip)
		if self:GetData("equip") then
			local name = tooltip:GetRow("name")
			name:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end

		local skill = tooltip:AddRow("skill")
		skill:SetText("Тип: мина")
		skill:SetBackgroundColor(grayClr)
		skill:SizeToContents()
	end
end
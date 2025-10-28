ITEM.name = "M18"
ITEM.description = "Дымовая граната старого мира."
ITEM.model = "models/weapons/arc9/darsu_eft/w_m18_unthrowed.mdl"
ITEM.class = "cellar_nade_m18"
ITEM.weaponCategory = "smoke"
ITEM.isGrenadeARC9 = true
ITEM.rarity = 1
ITEM.width = 1
ITEM.height = 1
ITEM.iconCam = {
	pos = Vector(69.460380554199, 59.093158721924, 17.188037872314),
	ang = Angle(8.8222885131836, 220.41194152832, 0),
	fov = 4.2328030956455,
}

if CLIENT then
	local grayClr = Color(122, 122, 122)
	function ITEM:PopulateTooltip(tooltip)
		if self:GetData("equip") then
			local name = tooltip:GetRow("name")
			name:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end

		local skill = tooltip:AddRow("skill")
		skill:SetText("Тип: дымовая")
		skill:SetBackgroundColor(grayClr)
		skill:SizeToContents()
	end
end
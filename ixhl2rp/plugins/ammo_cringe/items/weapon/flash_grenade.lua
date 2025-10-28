ITEM.name = "Светошумовая граната"
ITEM.description = "Светошумовая граната старого мира."
ITEM.model = "models/weapons/w_eq_flashbang.mdl"
ITEM.class = "cellar_nade_flashbang"
ITEM.weaponCategory = "flashbang"
ITEM.isGrenadeARC9 = true
ITEM.rarity = 1
ITEM.width = 1
ITEM.height = 1
ITEM.iconCam = {
	pos = Vector(53.992240905762, 129.78637695313, 57.278430938721),
	ang = Angle(20.644470214844, 247.25503540039, 0),
	fov = 3.7068227345286,
}

if CLIENT then
	local grayClr = Color(122, 122, 122)
	function ITEM:PopulateTooltip(tooltip)
		if self:GetData("equip") then
			local name = tooltip:GetRow("name")
			name:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end

		local skill = tooltip:AddRow("skill")
		skill:SetText("Тип: оглушение")
		skill:SetBackgroundColor(grayClr)
		skill:SizeToContents()
	end
end
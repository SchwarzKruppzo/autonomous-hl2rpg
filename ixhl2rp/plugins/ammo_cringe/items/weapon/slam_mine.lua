ITEM.name = "S.L.A.M"
ITEM.description = "Противопехотная мина старого мира."
ITEM.model = "models/weapons/w_slam.mdl"
ITEM.class = "cellar_nade_landmines"
ITEM.weaponCategory = "mine"
ITEM.isGrenadeARC9 = true
ITEM.rarity = 2
ITEM.width = 1
ITEM.height = 1
ITEM.iconCam = {
	pos = Vector(1.3261663913727, 127.27300262451, 78.019607543945),
	ang = Angle(31.741292953491, 269.41998291016, 0),
	fov = 3.2751540014013,
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
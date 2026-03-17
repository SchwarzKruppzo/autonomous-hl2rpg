ITEM.name = "item.m67_grenade"
ITEM.description = "item.m67_grenade.desc"
ITEM.model = "models/weapons/arc9/darsu_eft/w_m67_unthrowed.mdl"
ITEM.class = "cellar_nade_m67"
ITEM.weaponCategory = "grenade"
ITEM.isGrenadeARC9 = true
ITEM.rarity = 2
ITEM.width = 1
ITEM.height = 1

if CLIENT then
	local grayClr = Color(122, 122, 122)
	function ITEM:PopulateTooltip(tooltip)
		if self:GetData("equip") then
			local name = tooltip:GetRow("name")
			name:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end

		local skill = tooltip:AddRow("skill")
		skill:SetText(L("weaponTypeLabel", L("weaponTypeExplosive")))
		skill:SetBackgroundColor(grayClr)
		skill:SizeToContents()
	end
end
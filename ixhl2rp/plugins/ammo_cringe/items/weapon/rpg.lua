ITEM.name = "RPG"
ITEM.description = "Управляемая ракетная установка с лазерным наведением."
ITEM.model = "models/weapons/w_rocket_launcher.mdl"
ITEM.class = "cellar_hl2_rpg"
ITEM.weaponCategory = "primary"
ITEM.price = 950
ITEM.width = 5
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(17.61802482605, 176.72752380371, 374.3850402832),
	ang = Angle(64.485786437988, 270.35827636719, 0),
	fov = 6.7277608743075,
}
ITEM.isRPG = true
ITEM.flag = "Y"
ITEM.rarity = 3

if CLIENT then
	local grayClr = Color(122, 122, 122)
	function ITEM:PopulateTooltip(tooltip)
		if self:GetData("equip") then
			local name = tooltip:GetRow("name")
			name:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end

		local skill = tooltip:AddRow("skill")
		skill:SetText("Тип: пусковая установка")
		skill:SetBackgroundColor(grayClr)
		skill:SizeToContents()
	end
end
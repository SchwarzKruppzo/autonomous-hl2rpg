ITEM.name = "Бинт"
ITEM.description = "Моток бинтов. Здесь не так много, поэтому используйте с умом."
ITEM.model = Model("models/items/bandage.mdl")
ITEM.cost = 10
ITEM.iconCam = {
	pos = Vector(-167.40382385254, -0.16497099399567, 140.79614257813),
	ang = Angle(40.075763702393, 360.03671264648, 0),
	fov = 1.8319713266188,
}
ITEM.stats.uses = 5
ITEM.stats.time = 5

function ITEM:OnConsume(player, injector, mul, character)
	local isBleeding, bleedDmg = character:IsBleeding(), character:GetDmgData().bleedDmg or 0

	character:SetBleeding(false)

	return {bleed = isBleeding, bleedDmg = bleedDmg}
end

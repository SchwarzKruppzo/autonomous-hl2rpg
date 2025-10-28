ITEM.category = "Строительство - переработчик мусора"
ITEM.model = "models/cellar/tool_crate_metal.mdl"
ITEM.iconCam = {
	pos = Vector(160.73175048828, -0.035080194473267, 752.37615966797),
	ang = Angle(77.671737670898, 179.39149475098, 0),
	fov = 4.2776792635549,
}
ITEM.width = 5
ITEM.height = 4

ITEM.name = "Сборка: переработчик мусора"
ITEM.description = ""
ITEM.preview_model = "models/props_mining/elevator_winch_empty.mdl"

function ITEM:OnPlace(client, pos, angle)
	local prop = ents.Create("ix_factory_recycler")
	prop:SetPos(pos)
	prop:SetAngles(angle)
	prop:Spawn()
	prop:SetFuelAmount(0)

	local phys = prop:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	prop:SetNetVar("owner", client:GetCharacter():GetID())
end
ITEM.name = "Syringe"
ITEM.description = "A syringe that can hold up to 100 ml."
ITEM.category = "Medical"
ITEM.model = Model("models/autonomous/syringe.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.iconCam = {
	pos = Vector(1.0241856575012, 0, 82.435592651367),
	ang = Angle(90, 0, 44.528659820557),
	fov = 5,
}
ITEM.reagent_flags = bit.bor(ix.Reagents.holder.refillable, ix.Reagents.holder.drainable)
ITEM.volume = 100
ITEM.transfer_amount = 10
ITEM.add_reagents = {
	water = 30
}

ITEM.combine.inject = {
	name = "Ввести",
	OnRun = function(item, targetItem)
		if !item.reagents or !targetItem.reagents then return end

		item.reagents:Transfer(targetItem, item.transfer_amount or 10, item.player, ix.Reagents.action.inject)
	end,
	OnCanRun = function(item, targetItem)
		if !targetItem.isReagentHolder then return false end

		local flags = targetItem.GetReagentFlags and targetItem:GetReagentFlags() or (targetItem.reagent_flags or 0)

		if bit.band(flags, ix.Reagents.holder.refillable) == ix.Reagents.holder.refillable then
			return false
		end

		if bit.band(flags, ix.Reagents.holder.injectable) != ix.Reagents.holder.injectable then
			return false
		end

		return (item:GetData("value") or 0) > 0.1
	end
}

function ITEM:LayoutIcon(panel, entity)
	if !panel.initial and !self.update_pose_parameter then
		local value = (self:GetData("value") or 0) / self.volume
		entity:SetPoseParameter("state", value)

		panel.initial = true
		return
	end

	if self.update_pose_parameter then
		local value = (self.update_state or 0) / self.volume

		entity:SetPoseParameter("state", value)
		self.update_pose_parameter = false
	end
end

if CLIENT then
	ITEM:AddDataCallback("value", function(self, value)
		self.update_state = value
		self.update_pose_parameter = true
	end)
end

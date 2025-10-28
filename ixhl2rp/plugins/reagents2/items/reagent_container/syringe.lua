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
ITEM.add_reagents = {
	water = 30
}
ITEM.combine = {}
ITEM.combine.inject = {
	name = "inject",
	OnRun = function(item, targetItem, items)
		if item.reagents.volume <= 0 then
			return
		end

		if targetItem.reagents.volume >= targetItem.volume then
			return
		end
		
		item.reagents:Transfer(targetItem, 10, item.player, ix.Reagents.action.inject)
		print(5)
		return
	end,
	OnCanRun = function(item, targetItem)
		print(1)
		if !targetItem.isReagentHolder or targetItem:IsClosed()  then
			return false
		end
		print(2)
		if ix.Reagents:IsInjectable(targetItem) then
			local value = item:GetData("value") or 0
			print(value > 0)
			return value > 0
		end
		
		return false
	end
}
ITEM.combine.draw = {
	name = "draw",
	OnRun = function(item, targetItem, items)
		if targetItem.reagents.volume <= 0 then
			return
		end

		if item.reagents.volume >= item.volume then
			return
		end
		
		targetItem.reagents:Transfer(item, 10, item.player)

		return
	end,
	OnCanRun = function(item, targetItem)
		if !targetItem.isReagentHolder or targetItem:IsClosed() then
			return false
		end

		if ix.Reagents:IsDrawable(targetItem) then
			local value = item:GetData("value") or 0

			return value < item.volume
		end
		
		return false
	end
}

function ITEM:OnReagentUpdateTotal(value)
	self:SetData("value", value)
end

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
	ITEM.data_callbacks = {}
	ITEM.data_callbacks["value"] = function(self, value)
		self.update_state = value
		self.update_pose_parameter = true
	end
end
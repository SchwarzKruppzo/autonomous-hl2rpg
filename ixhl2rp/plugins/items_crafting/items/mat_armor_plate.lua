ITEM.name = "Бронепластина"
ITEM.description = "Универсальная бронепластина, используемая для создания полноценного бронежилета низкого класса защиты или починки бронежилетов, исключая внеземные аналоги."
ITEM.category = "Производные компоненты"
ITEM.model = "models/combine_helicopter/bomb_debris_3.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.rarity = 1
ITEM.iconCam = {
	pos = Vector(-84.724044799805, -1.461345911026, 181.16244506836),
	ang = Angle(64.871513366699, 0.98815697431564, 0),
	fov = 4.4208094725421,
}
ITEM.max_stack = 5
ITEM.stackable = true
ITEM.contraband = true

local repair = {
	[1] = 0.4,
	[2] = 0.35,
	[3] = 0.3,
}

ITEM.combine = ITEM.combine or {}
ITEM.combine.repair = {
	name = "Починить",
	OnRun = function(item, targetItem, items)
		local value = (targetItem:GetData("value") or 1)
		local class = targetItem.armor.class

		if repair[class] then
			targetItem:SetData("value", math.min(value + repair[class], 1))

			item.player:EmitSound("foley/metrocop/metrocop_foley_step_3.wav")
			
			item:Remove()
		end

		return
	end,
	OnCanRun = function(item, targetItem)
		if !targetItem.armor or targetItem.noRepair then
			return false
		end
		
		local value = (targetItem:GetData("value") or 1)

		if value > 0.75 then
			return false
		end
		
		return true
	end
}
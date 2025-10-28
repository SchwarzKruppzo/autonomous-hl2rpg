ITEM.name = "Ножницы"
ITEM.description = "Плоскогубцы? Нет, ножницы! Просто форма у них очень странная, ну или кто-то просто попытался выкрутиться.."
ITEM.model = "models/cellar/scissors.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.cost = 15
ITEM.iconCam = {
	pos = Vector(46.054550170898, 41.814300537109, 134.60003662109),
	ang = Angle(65.710968017578, 222.84214782715, 0),
	fov = 3.4427581317421,
}

ITEM.combine = ITEM.combine or {}
ITEM.combine.breakx = {
	name = "Разорвать",
	OnRun = function(item, targetItem, items)
		if targetItem.IsEquipped and targetItem:IsEquipped() then
			return
		end

		local client = item.player
		
		targetItem:Remove()

		item:TakeDurability(10, client)

		if math.random(1, 100) < 51 then
			local new_item = ix.Item:Instance("mat_cloth")
			client:AddItem(new_item)
		end

		return
	end,
	OnCanRun = function(item, targetItem)
		if item == targetItem then
			return false
		end
		
		return targetItem.BreakDown and targetItem.BreakDownType == "cloth"
	end
}
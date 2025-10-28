ITEM.name = "Противогаз М40"
ITEM.description = "Американский военный противогаз 'М40', производился в Соединенных Штатах Америки для военных нужд, включает в себе улучшенную систему фильтрования, панорамные защитные стекла и устройство позволяющее внятно разговаривать не смотря на противогаз. Чаще всего, не рабочее."
ITEM.model = Model("models/cellar/items/m40.mdl")
ITEM.rarity = 2
ITEM.bodyGroups = {
	[5] = 2
}
ITEM.equip_inv = 'mask'
ITEM.equip_slot = nil
ITEM.filters = {
	["filter_epic"] = true,
	["filter_good"] = true,
	["filter_medium"] = true,
	["filter_standard"] = true
}
ITEM.isGasmask = true
ITEM.iconCam = {
	pos = Vector(2.00372838974, 0.56660562753677, 199.98359680176),
	ang = Angle(89.491668701172, 180.58642578125, 0),
	fov = 3.05605798943,
}
ITEM.contraband = true
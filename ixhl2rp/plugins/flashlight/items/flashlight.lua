ITEM.name = "item.flashlight"
ITEM.model = Model("models/lagmite/lagmite.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "item.flashlight.desc"

function ITEM:OnDrop(client)
	client:Flashlight(false)
end

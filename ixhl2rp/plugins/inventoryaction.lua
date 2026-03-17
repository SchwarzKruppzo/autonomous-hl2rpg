PLUGIN.name = "Inventory Action Command"
PLUGIN.author = "Alan Wake"
PLUGIN.description = "Adds able to execute inventoryaction functions by 'ix' console command."

ix.lang.AddTable("ru", {
	["inventoryaction.noItemById"] = "У вас нет предмета с instanceId \"%s\"!",
	["inventoryaction.noItemByUniqueId"] = "У вас нет предмета с uniqueId \"%s\"!",
})
ix.lang.AddTable("en", {
	["inventoryaction.noItemById"] = "You don't have an item with instanceId \"%s\"!",
	["inventoryaction.noItemByUniqueId"] = "You don't have an item with uniqueId \"%s\"!",
})
ix.lang.AddTable("fr", {
	["inventoryaction.noItemById"] = "Vous n'avez pas d'objet avec instanceId \"%s\"!",
	["inventoryaction.noItemByUniqueId"] = "Vous n'avez pas d'objet avec uniqueId \"%s\"!",
})
ix.lang.AddTable("es-es", {
	["inventoryaction.noItemById"] = "¡No tienes un objeto con instanceId \"%s\"!",
	["inventoryaction.noItemByUniqueId"] = "¡No tienes un objeto con uniqueId \"%s\"!",
})

ix.command.Add("InventoryAction", {
	description = "",
	arguments = {
        ix.type.string,
        ix.type.string
    },
	OnRun = function(self, client, id, actionName)
        local number = tonumber(id)
        local has, item

        if (number) then
            has, item = client:HasItemByID(id)
            if (!has) then
                return "@inventoryaction.noItemById", id
            end
        else
            has, item = client:HasItem(id)
            if (!has) then
                return "@inventoryaction.noItemByUniqueId", id
            end
        end

        ix.Item:PerformInventoryAction(client, item, item.inventory_id, actionName, nil, 1)
	end
})
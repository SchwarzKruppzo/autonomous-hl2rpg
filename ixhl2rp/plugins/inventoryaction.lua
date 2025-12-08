PLUGIN.name = "Inventory Action Command"
PLUGIN.author = "Alan Wake"
PLUGIN.description = "Adds able to execute inventoryaction functions by 'ix' console command."


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
                return Format("У вас нет предмета с instanceId \"%s\"!", id);
            end
        else
            has, item = client:HasItem(id)
            if (!has) then
                return Format("У вас нет предмета с uniqueId \"%s\"!", id);
            end
        end

        ix.Item:PerformInventoryAction(client, item, item.inventory_id, actionName, nil, 1)
	end
})
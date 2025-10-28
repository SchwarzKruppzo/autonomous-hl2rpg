local ItemRation = class("ItemRation"):implements("Item")

ItemRation.junk = "empty_ration"

function ItemRation:Init()
	self.category = "Рационы"

	self.loot = {}
	
	self.functions.open = {
		name = "Вскрыть",
		OnRun = function(item)
			local client, character = item.player, item.player:GetCharacter()
			local junk = item.junk
			local loot = item.loot

			if item.cash then
				character:GiveMoney(item.cash)
			end

			item:Remove()

			for _, data in ipairs(loot) do
				if istable(data) then
					for i = 1, data.count do
						local new_item = ix.Item:Instance(data.items[math.random(1, #data.items)])

						if !client:AddItem(new_item) then
							ix.Item:Spawn(client, nil, new_item)
						end
					end
				else
					local new_item = ix.Item:Instance(data)
						
					if !client:AddItem(new_item) then
						ix.Item:Spawn(client, nil, new_item)
					end
				end
			end

			if junk then
				local new_item = ix.Item:Instance(junk)
				
				if !client:AddItem(new_item) then
					ix.Item:Spawn(client, nil, new_item)
				end
			end

			return true
		end,
		OnCanRun = function(item) return (item:IsClosed() == true and !IsValid(item:GetEntity())) end
	}

	self:AddData("closed", {
		Transmit = ix.transmit.owner,
	})
end

function ItemRation:IsClosed()
	return self:GetData("closed", true)
end

return ItemRation
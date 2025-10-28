function Schema:CharacterVarChanged(character, key, oldVar, value)
	if key == "name" and oldVar != value then
		local query = mysql:Select("ix_items")
		query:Select("item_id")
		query:WhereLike("data", "\"owner\":"..character:GetID())
		query:Callback(function(result)
			if istable(result) and #result > 0 then
				for k, v in ipairs(result) do
					v.item_id = tonumber(v.item_id)

					ix.Item.instances[v.item_id]:SetData("name", value)
					
					hook.Run("OnIDCardUpdated", ix.Item.instances[v.item_id])
				end
			end
		end)
		query:Execute()
	end
end

netstream.Hook("ixCitizenIDEdit", function(client, itemID, newData)
	if !client:IsSuperAdmin() and !client:IsAdmin() then return end

	local item = ix.Item.instances[itemID]
	
	if !item then return end
	
	newData["type"] = tonumber(newData["type"]) or 0
	newData["type"] = math.Clamp(math.Round(newData["type"]), 0, 3)

	local access = {}
	for i, v in ipairs(newData["access"] or {}) do
		access[v] = true
	end

	item:SetData("name", newData["name"] or "nobody")
	item:SetData("cid", newData["cid"] or "0000")
	item:SetData("number", newData["number"] or "")
	item:SetData("access", access)
	item:SetData("type", newData["type"])

	hook.Run("OnIDCardUpdated", item)
end)

do
	local CHAR = ix.meta.character

	function CHAR:CreateIDCard(type)
		if type then
			local client = self:GetPlayer()

			local instance = ix.Item:Instance(type)
			instance:CreateDatafile(client)

			timer.Simple(1, function()
				client.ixDatafile = instance:GetData("datafileID", 0)

				client:AddItem(instance, "cid")
			end)
		end
	end
end
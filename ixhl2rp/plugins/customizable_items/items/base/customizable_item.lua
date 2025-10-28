local CustomItem = ix.util.Lib("CustomItem", {
	stored = {},
	queue = {},
	loaded = false
})

function CustomItem:Load()
	local data = ix.data.Get("customitems", {}, true, true)

	for k, v in pairs(data) do
		self.stored[k] = table.Copy(v)
	end

	self.loaded = true
end

function CustomItem:Save()
	ix.data.Set("customitems", self.stored, true, true)
end

function CustomItem:Register(base, data, owner)
	if !istable(data) then
		return
	end
	
	if !data.name or !data.description or !data.model then
		return
	end

	data.createTime = os.time()
	data.owner = owner:SteamID64()

	local checksum = util.SHA1(util.TableToJSON(data))
	data.checksum = checksum
	data.custom = base

	self.stored[checksum] = data

	return checksum
end

function CustomItem:Deploy(id, data)
	local item = ix.Item.instances[id]
	
	for k, v in pairs(data) do
		item[k] = v
	end

	if item.PostCustomDeploy then
		item:PostCustomDeploy()
	end
end



local ItemCustomize = class("ItemCustomize"):implements("Item")

ItemCustomize.isCustomBase = true

if SERVER then
	util.AddNetworkString("item.custom.sync")
end

function ItemCustomize:Init()
	self.category = "Кастом"

	self:AddData("checksum", {
		Transmit = ix.transmit.all,
	})

	self.data_callbacks = {}
	self.data_callbacks.checksum = function(item, value)
		if !CustomItem.loaded then
			CustomItem:Load()
		end
		
		local saved = CustomItem.stored[value]

		if saved then
			CustomItem:Deploy(item.id, saved)
		else
			CustomItem.queue[value] = CustomItem.queue[value] or {}
			CustomItem.queue[value][item:GetID()] = true

			net.Start("item.custom.sync")
				net.WriteType(value)
			net.SendToServer()
		end
	end
end

function ItemCustomize:GetMaterial()
	return self.material
end

function ItemCustomize:OnInstanced(isCreated)
	local saved = CustomItem.stored[self:GetData("checksum")]

	if saved then
		for k, v in pairs(saved) do
			if !isfunction(self[k]) then
				self[k] = v
			end
		end
	end
end

if SERVER then
	net.Receive("item.custom.sync", function(len, client)
		local checksum = net.ReadType()
		local custom_data = CustomItem.stored[checksum]

		if custom_data then
			netstream.Start(client, "item.custom.data", custom_data)
		end
	end)
else
	netstream.Hook("item.custom.data", function(data)
		CustomItem.stored[data.checksum] = table.Copy(data)

		CustomItem:Save()

		for itemID, v in pairs(CustomItem.queue[data.checksum]) do
			CustomItem:Deploy(itemID, data)

			CustomItem.queue[data.checksum][itemID] = nil
		end
	end)
end


return ItemCustomize
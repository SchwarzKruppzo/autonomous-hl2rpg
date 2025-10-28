util.AddNetworkString("ixCreateCustomItem")

function PLUGIN:CreateCustomItem(base, properties, owner)
	local item = ix.Item:Get(base)

	if !isstring(base) or !istable(properties) then
		return
	end

	local checksum = ix.CustomItem:Register(base, properties, owner)

	if !checksum then
		return
	end
	
	if !item then
		return
	end

	local instance = ix.Item:Instance(base, {checksum = checksum})
	instance:SetData("checksum", checksum)

	ix.Item:Spawn(owner, nil, instance)
end

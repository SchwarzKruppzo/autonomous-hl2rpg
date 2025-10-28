local Licenses = ix.util.Lib("Licenses", {
	stored = {},
	stored_id = {}
})

function Licenses:Get(id)
	return self.stored[id]
end

function Licenses:Add(title, data)
	if !data.id then
		return
	end
	
	local id = #self.stored + 1

	data.name = title
	data.index = id

	self.stored[id] = data
	self.stored_id[data.id] = self.stored[id]

	return id
end

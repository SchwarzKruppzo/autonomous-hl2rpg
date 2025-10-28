local Loyalty = ix.util.Lib("Loyalty", {
	levels = {}
})

function Loyalty:Get(id)
	return self.levels[id]
end

function Loyalty:AddLevel(title, data)
	local id = #self.levels + 1

	data.name = title
	data.id = id

	self.levels[id] = data

	return id
end



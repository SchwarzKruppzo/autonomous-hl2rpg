local LootContainer = ix.util.Lib("LootContainer", {
	stored = {}
})

function LootContainer:Get(id)
	return self.stored[id]
end

local function Process(info, entity)
	local items = {}

	local rate = math.Clamp(math.Clamp(#player.GetAll(), 1, 20) / 20, math.random(0, 0.25), 1)

	if info.NoRate then
		rate = 1
	elseif info.GetRate then
		rate = info.GetRate()
	end
	
	if info.loot_template then
		info.loot_template:Process(items, entity:EntIndex(), rate)
	end
	
	return items
end

function LootContainer:Add(id, info)
	info.Name = info.Name or "Unknown"
	info.Description = info.Description or ""
	info.Model = info.Model or "models/hunter/blocks/cube025x025x025.mdl"
	
	if SERVER then
		info.Process = info.Process or Process

		info.loot_groups = {}
		info.loot_template = ix.meta.LootTemplate:New()

		for groupID, groupEntry in pairs(info.LootGroup) do
			local group = ix.meta.LootGroup:New()

			for _, entry in ipairs(groupEntry) do
				group:Add(entry)
			end

			info.loot_groups[groupID] = group
		end

		for _, entry in pairs(info.Loot) do
			if !info.loot_groups[entry.lootGroup] then continue end
			
			info.loot_template:Add(info.loot_groups[entry.lootGroup], {count = entry.count, min = entry.min, max = entry.max })
		end
	end

	self.stored[id] = info
end
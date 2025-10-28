local LootGroup = class("LootGroup")

function LootGroup:Init()
	self.stored = {}
end
	
function LootGroup:Add(data)
	self.stored[#self.stored + 1] = data
end

function LootGroup:Roll(client)
	local total = 0 

	for i, loot in ipairs(self.stored) do
		total = total + loot.weight 
	end

	local roll = math.random(total)

	local weight = 0
	for i, loot in ipairs(self.stored) do
		weight = weight + loot.weight

		if roll < weight then
			return loot
		end
	end
end


local LootTemplate = class("LootTemplate")

function LootTemplate:Init()
	self.groups = {}
end
function LootTemplate:Add(group, info)
	info = info or {}

	self.groups[#self.groups + 1] = {group, info}
end
function LootTemplate:Process(loot, seed, mul)
	math.randomseed(os.time() + seed)

	local max = {}

	for k, entry in ipairs(self.groups) do
		local info = entry[2]
		local amount = 1

		if info.min and info.max then
			amount = math.max(math.random(info.min, info.max) * mul, 0)
		elseif info.count then
			amount = math.max(info.count * mul, 0)
		end
		local v = 0
		for i = 1, amount do
			local class = entry[1]:Roll(client)

			if class then
				local count = 1
				if class.min and class.max then
					count = math.random(class.min, class.max)
				end
				
				for i = 1, count do
					v = v + 1
					if v <= amount then
						loot[#loot + 1] = class.id
					end
				end
			end
		end
	end

	return loot
end
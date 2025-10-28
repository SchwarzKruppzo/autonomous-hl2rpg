ix.bar.list = {}

function ix.bar.Add(getValue, icon, priority, identifier)
	if (identifier) then
		ix.bar.Remove(identifier)
	end

	local index = #ix.bar.list + 1

	icon = icon or false
	priority = priority or index

	ix.bar.list[index] = {
		index = index,
		icon = icon,
		priority = priority,
		GetValue = getValue,
		identifier = identifier,
		panel = IsValid(ix.gui.bars) and ix.gui.bars:AddBar(index, icon, priority)
	}

	return priority
end

do

	ix.bar.Add(function()
		local character = LocalPlayer():GetCharacter()

		if character then
			local hunger = character:GetHunger()
			return hunger / 100
		end
	end, "cellar/ui/food.png", 5, "hunger")
	
	ix.bar.Add(function()
		local character = LocalPlayer():GetCharacter()

		if character then
			local thirst = character:GetThirst()
			return thirst / 100
		end
	end, "cellar/ui/water.png", 6, "thirst")

	ix.bar.Add(function()
		local client = LocalPlayer()
		local character = client:GetCharacter()

		if character then
			local radLevel = client:GetNetVar("radDmg") or 0
			local geiger = client:HasGeigerCounter()

			if geiger and radLevel > 0 then
				return (radLevel / 100)
			end
		end
	end, "cellar/ui/geiger.png", 7, "geiger")

	ix.bar.Add(function()
		local client = LocalPlayer()
		local character = client:GetCharacter()

		if character then
			local filter = client:HasWearedFilter()

			if filter then
				filter = ix.Item.instances[filter]
				
				return filter:GetFilterQuality() / filter.filterQuality
			end
		end
	end, "cellar/ui/filter.png", 8, "filter")
end
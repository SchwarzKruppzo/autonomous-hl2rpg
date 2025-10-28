local PLUGIN = PLUGIN

function PLUGIN:CreateMenuButtons(tabs)
	tabs["СОЗДАНИЕ ВЕЩЕЙ"] = function(container)
		local x = container:Add("ui.craft")
		x:Setup()
	end
end

ix.Craft:LoadFromDir(PLUGIN.folder.."/recipes", "recipe")
ix.Craft:LoadFromDir(PLUGIN.folder.."/stations", "station")

function PLUGIN:LoadData()
	timer.Simple(1, function()
    	self:LoadStations()
    end)
end

function PLUGIN:SaveData()
	self:SaveStations()
end

function PLUGIN:LoadStations()
	local data = self:GetData()

	if data then
		for _, v in ipairs(data) do
			local entity = ents.Create("ix_station_"..v[1])
			if entity then
				entity:SetPos(v[2])
				entity:SetAngles(v[3])
				entity:Spawn()
				entity:LoadItems(v[4] or {})
				
				local physObject = entity:GetPhysicsObject()

				if IsValid(physObject) then
					physObject:EnableMotion(false)
				end
			end
		end
	end
end

function PLUGIN:SaveStations()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_station_*")) do
		local items = {}

		if v.inventory then
			for z, x in pairs(v.inventory:GetItems() or {}) do
				x:Save()
			end

			items = v.inventory:GetItemsID()
		end

		data[#data + 1] = {
			v.uniqueID,
			v:GetPos(),
			v:GetAngles(),
			items
		}
	end

	self:SetData(data)
end
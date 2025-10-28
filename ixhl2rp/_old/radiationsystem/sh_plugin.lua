local PLUGIN = PLUGIN

PLUGIN.name = "Radiation System"
PLUGIN.description = "Adds a radiation system."
PLUGIN.author = "SchwarzKruppzo"

ix.Net:AddPlayerVar("radDmg", false, nil, ix.Net.Type.Float)

function PLUGIN:SetupAreaProperties()
	ix.area.AddType("rad")

	ix.area.AddProperty("radDamage", ix.type.number, 1)
end

do
	local PLAYER = FindMetaTable("Player")

	function PLAYER:GetRadResistance()
		local resist = 0 

		if self:Team() == FACTION_VORTIGAUNT or self:Team() == FACTION_ZOMBIE or self:IsOTA() then
			return 100
		else
			for item, _ in pairs(self.char_outfit.armor) do 
				if !item.rad_resist then continue end

				resist = resist + item.rad_resist
			end
		end

		local gasmask = self.char_outfit.gasmask
		local filter

		if gasmask then
			resist = resist + 10

			local filterID = gasmask:GetData("filter", nil)

			if filterID then
				filter = ix.Item.instances[filterID]
			end
		end
		
		if filter and filter:GetFilterQuality() > 0 then
			resist = resist + 89
		end

		return math.min(resist, 99), filter
	end

	function PLAYER:HasWearedFilter()
		return self.char_outfit.gasmask and self.char_outfit.gasmask:GetData("filter")
	end

	function PLAYER:HasWearedGasmask()
		return self.char_outfit.gasmask
	end

	function PLAYER:HasGeigerCounter()
		if self:Team() == FACTION_OTA then
			return true
		elseif self:Team() == FACTION_MPF then
			return true
		end

		return self:HasItem("geiger_counter")
	end
end

ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("sv_hooks.lua")
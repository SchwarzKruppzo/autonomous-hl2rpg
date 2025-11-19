local PLUGIN = PLUGIN

PLUGIN.name = "Radiation System"
PLUGIN.description = "Adds a radiation system."
PLUGIN.author = "SchwarzKruppzo"

ix.char.RegisterVar("radLevel", {
	field = "rad",
	fieldType = ix.type.number,
	default = 0,
	isLocal = true,
	Net = {
		Transmit = ix.transmit.owner
	},
	bNoDisplay = true
})
	
ix.Net:AddPlayerVar("radDmg", false, nil, ix.Net.Type.Float)

function PLUGIN:SetupAreaProperties()
	ix.area.AddType("rad")

	ix.area.AddProperty("radDamage", ix.type.number, 1)
end

do
	local PLAYER = FindMetaTable("Player")

	function PLAYER:GetRadResistance()
		local resist = 0 
		local custom = self:GetCharacter():GetData("xresist", 0)

		if custom > 0 then
			return custom
		elseif self:Team() == FACTION_VORTIGAUNT or self:Team() == FACTION_ZOMBIE or self:IsOTA() then
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
		if SERVER then
			return self.char_outfit.gasmask and self.char_outfit.gasmask:GetData("filter")
		else
			local itemID = self:GetFirstAtSlot(1, 1, 'mask')
			local mask = itemID and ix.Item.instances[itemID]

			if !mask or !mask.isGasmask then
				return
			end

			return mask:GetData("filter")
		end
	end

	function PLAYER:HasWearedGasmask()
		if SERVER then
			return self.char_outfit.gasmask
		else
			local itemID = self:GetFirstAtSlot(1, 1, 'mask')
			local mask = itemID and ix.Item.instances[itemID]

			if !mask or !mask.isGasmask then
				return
			end

			return mask
		end
	end

	function PLAYER:HasGeigerCounter()
		return self:HasItem("geiger_counter")
	end
end

ix.command.Add("CharSetRad", {
	description = "Установить игроку уровень радиации",
	adminOnly = true,
	arguments = {ix.type.character, ix.type.number},
	OnRun = function(self, client, target, rad)
		target:SetRadLevel(rad)
		return "Rad level changed."
	end
})

ix.command.Add("CharSetRadResist", {
	description = "Установить игроку уровень сопротивления к радиации",
	adminOnly = true,
	arguments = {ix.type.character, ix.type.number},
	OnRun = function(self, client, target, resist)
		target:SetData("xresist", resist)
		return "Rad resist changed."
	end
})

ix.util.Include("cl_plugin.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("sv_hooks.lua")
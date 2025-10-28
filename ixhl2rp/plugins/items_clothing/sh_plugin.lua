local PLUGIN = PLUGIN

PLUGIN.name = "Clothing Items"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = "Adds a clothing items from HL2TS2."

ix.Net:AddPlayerVar("custom_outfit", false, nil, ix.Net.Type.Table, function(entIndex, outfits, lastOutfits)
	local client = Entity(entIndex)

	if IsValid(client) then
		if !table.equal(outfits, lastOutfits) then
			client.RegenChar = true
		end
	end
end)

ix.util.Include("sh_outfit.class.lua")

if SERVER then
	function PLUGIN:PlayerInitialSpawn(client)
		client.char_outfit = ix.meta.Outfit:New(client)
	end

	function PLUGIN:PostPlayerLoadout(client)
		local character = client:GetCharacter()

		client.char_outfit:Reset()

		if character then
			client.char_outfit:LoadCharacter(character)
		end
	end

	function PLUGIN:PlayerModelChanged(client, model, oldmodel)
		client.char_outfit:ModelChanged(model, oldmodel)
	end

	local function CacheBodygroups(client, oldcharacter)
		if oldcharacter then
			local bgs = {}
			
			for i = 0, (client:GetNumBodyGroups() - 1) do
				bgs[i] = client:GetBodygroup(i)
			end

			oldcharacter:SetData("bgcache", bgs)
		end
	end

	function PLUGIN:PrePlayerLoadedCharacter(client, character, oldcharacter)
		client.char_outfit.loading = true

		CacheBodygroups(client, oldcharacter)
	end

	function PLUGIN:PlayerDisconnected(client)
		CacheBodygroups(client, client:GetCharacter())
	end
end
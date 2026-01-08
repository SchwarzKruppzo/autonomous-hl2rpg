local PLUGIN = PLUGIN

ITEM.name = "item.request_device"
ITEM.model = Model("models/gibs/shield_scanner_gib1.mdl")
ITEM.description = "item.request_device.desc"
ITEM.category = "item.category.comm"
ITEM.rarity = 1

ITEM.equip_inv = 'ears'
ITEM.equip_slot = nil

local cacheText = ""
ITEM.functions.Request = {
	name = "use.request_device",
	OnClick = function(item)
		Derma_StringRequest(L("item.use.request_device"), L("request_device.gui.desc"), cacheText, function(text)
				if text and string.utf8len(text) > 0 then
					netstream.Start("ixRequest", text)
				end

				cacheText = ""
			end, 
		function(text)
			cacheText = text
		end, L("request_device.gui.send"), L("request_device.gui.cancel"))
	end,
	OnRun = function(item)
		item.player.ixRequestDevice = item

		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity)
	end
}
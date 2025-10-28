local PLUGIN = PLUGIN

ITEM.name = "Устройство запроса"
ITEM.model = Model("models/gibs/shield_scanner_gib1.mdl")
ITEM.description = "Маленькое устройство с желтой кнопкой, имеется встроенный микрофон с динамиком и креплением для уха."
ITEM.category = "Коммуникация"
ITEM.rarity = 1

ITEM.equip_inv = 'ears'
ITEM.equip_slot = nil

local cacheText = ""
ITEM.functions.Request = {
	name = "Запросить помощь",
	OnClick = function(item)
		Derma_StringRequest("Запросить помощь", "Введите ваш запрос.", cacheText, function(text)
				if text and string.utf8len(text) > 0 then
					netstream.Start("ixRequest", text)
				end

				cacheText = ""
			end, 
		function(text)
			cacheText = text
		end, "СДЕЛАТЬ ЗАПРОС", "ОТМЕНА")
	end,
	OnRun = function(item)
		item.player.ixRequestDevice = item

		return false
	end,
	OnCanRun = function(item)
		return !IsValid(item.entity)
	end
}

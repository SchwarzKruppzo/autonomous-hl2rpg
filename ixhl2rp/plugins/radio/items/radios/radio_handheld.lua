ITEM.name = "Рация"
ITEM.description = "Обычная портативная рация с регулятором частоты."
ITEM.price = 50
ITEM.stationaryCanAccess = true
ITEM.contraband = true

ITEM:AddData("frequency", {
	Transmit = ix.transmit.owner,
})

ITEM.functions.Frequency = {
	name = "Выставить частоту",
	OnClick = function(item)
		Derma_StringRequest("Частота", "Введите новую частоту рации", item:GetData("frequency", "100.0"), function(text)
			netstream.Start("ixRadioFrequency", item:GetID(), text)
		end)
	end,
	OnRun = function(item)
	end,
	OnCanRun = function(item)
		return IsValid(item.player) and !IsValid(item.entity) and !item.player:IsRestricted()
	end
}

function ITEM:GetFrequency()
	return self:GetData("frequency", "100.0")
end

function ITEM:GetFrequencyID()
	return string.format("freq_%d", string.gsub(self:GetData("frequency", "100.0"), "%p", ""))
end
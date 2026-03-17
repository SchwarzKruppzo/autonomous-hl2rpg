ITEM.name = "item.radio_handheld"
ITEM.description = "item.radio_handheld.desc"
ITEM.price = 50
ITEM.stationaryCanAccess = true
ITEM.contraband = true

ITEM:AddData("frequency", {
	Transmit = ix.transmit.owner,
})

ITEM.functions.Frequency = {
	name = "radioSetFrequency",
	OnClick = function(item)
		Derma_StringRequest(L("radioFrequencyTitle"), L("radioFrequencyPrompt"), item:GetData("frequency", "100.0"), function(text)
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
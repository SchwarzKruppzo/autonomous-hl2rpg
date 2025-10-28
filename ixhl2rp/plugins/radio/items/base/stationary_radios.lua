local Item = class("ItemStationRadio"):implements("Item")

function Item:Init()
	self.model = self.model or "models/props_lab/citizenradio.mdl"

	self.tuningEnabled = self.tuningEnabled or false
	self.frequencyID = self.frequencyID or "freq_0000"

	self.category = 'Коммуникация'
end

function Item:OnDrop(owner)
	local radio = ents.Create("ix_stationary_radio")
	radio:SetRadioItem(self.uniqueID)
	radio:SetModel(self.model)
	radio:SetPos(owner:GetItemDropPos(radio))
	radio:Spawn()

	radio:SetFrequency(self.frequencyID)
	radio:SetChannelTuningEnabled(self.tuningEnabled)

	owner:EmitSound("npc/zombie/foot_slide" .. math.random(1, 3) .. ".wav", 75, math.random(90, 120), 1)
	return true
end

return Item
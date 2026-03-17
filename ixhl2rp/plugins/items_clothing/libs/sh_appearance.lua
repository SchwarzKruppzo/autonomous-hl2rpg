local Appearance = ix.util.Lib("Appearance", {
	Layer = {
		Main = 1,
		Top = 2,
		Bottom = 3
	},
	ModelInfo = {
		default = {}
	},
	Slot = {
		Head = 1,
		Torso = 2,
		Legs = 3,
		Boots = 4,
		Socks = 5,
		Backpack = 6,
		Suit = 7,
		UnderwearTop = 8,
		UnderwearBottom = 9
	},
	SlotEffect = {},
	Database = {},
	Entities = {},

	_databaseIndex = 0,
	_databaseTag = {},
	_models = {},
})

Appearance.Database = {}
Appearance._databaseIndex = 0
Appearance._databaseTag = {}

function Appearance:SetModelClass(model, class)
	self._models[model:lower()] = class
end

function Appearance:GetModelClass(model)
	return self._models[model:lower()]
end

function Appearance:AddBodyMask(name, info)
	for k, v in pairs(info) do
		self.ModelInfo[k] = self.ModelInfo[k] or {}

		self.ModelInfo[k][name] = v
	end
end

function Appearance:AddSlotEffect(slot, variant, data)
	local effect = self.SlotEffect[slot] or {}

	data.hides = data.hides or {}
	data.bodyMask = data.bodyMask or false

	effect[variant] = data

	self.SlotEffect[slot] = effect
end

function Appearance:GetByID(id)
	local tag = self._databaseTag[id]

	return tag and self.Database[tag]
end

function Appearance:New(tag, info)
	info = info or {}

	self._databaseIndex = (self._databaseIndex or 0) + 1

	info.tag = tag
	info.id = self._databaseIndex

	self.Database[tag] = info
	self._databaseTag[info.id] = tag

	return info.tag
end

Appearance:AddBodyMask("FullBody", {
	default = {
		[2] = 1, -- hide torso
		[3] = 1, --hide legs
		[5] = 1
	}
})

Appearance:AddBodyMask("HideGenitals", {
	default = {
		[5] = 1
	}
})

Appearance:AddBodyMask("Torso", {
	default = {
		[2] = 1, -- hide torso
	}
})

Appearance:AddBodyMask("Legs_Visible", {
	default = {}
})

Appearance:AddBodyMask("Legs", {
	default = {
		[3] = 1, -- hide torso
		[5] = 1
	}
})

Appearance:AddBodyMask("Torso_OnlyHands", {
	default = {
		[2] = 1, -- hide torso
		[4] = 1 -- only hands
	}
})

Appearance:AddBodyMask("Torso_OnlyHands_Opened", {
	default = {
		[2] = 2, -- hide torso
		[4] = 1 -- only hands
	}
})

Appearance:AddSlotEffect(Appearance.Slot.Suit, "default", {
	hides = {
		Appearance.Slot.Torso, 
		Appearance.Slot.Legs,
		Appearance.Slot.UnderwearTop,
		Appearance.Slot.UnderwearBottom,
		Appearance.Slot.Socks
	}
})

Appearance:AddSlotEffect(Appearance.Slot.Torso, "default", {
	hides = {Appearance.Slot.UnderwearTop},
	bodyMask = "Torso"
})

Appearance:AddSlotEffect(Appearance.Slot.Legs, "default", {
	hides = {Appearance.Slot.UnderwearBottom},
	bodyMask = "Legs"
})

Appearance:AddSlotEffect(Appearance.Slot.UnderwearBottom, "default", {
	hides = {},
	bodyMask = "HideGenitals"
})


/*
Appearance:New("workerhelmet_universal", {
	slot = Appearance.Slot.Head,
	layer = Appearance.Layer.Body,
	bodyGroups = {
		[4] = 3
	}
})

Appearance:New("backpack_cp", {
	slot = Appearance.Slot.Backpack,
	clientside = true,
	model = "models/cellar/pack_cp.mdl"
})
*/


Appearance:SetModelClass("models/autonomous/base_female.mdl", "female")
Appearance:SetModelClass("models/autonomous/base_male.mdl", "male")

ix.Appearance:New("backpack_cp", {
	slot = ix.Appearance.Slot.Backpack,
	clientside = true,
	model = "models/cellar/pack_cp.mdl"
})

ix.Appearance:New("backpack_medic", {
	slot = ix.Appearance.Slot.Backpack,
	clientside = true,
	model = "models/cellar/pack_medic.mdl"
})

ix.Appearance:New("backpack", {
	slot = ix.Appearance.Slot.Backpack,
	clientside = true,
	model = "models/cellar/pack_regular.mdl"
})
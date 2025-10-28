local BaseException = class("BaseException")
function BaseException:Init(toggle)
	self.default = toggle
	self.toggle = toggle
end

function BaseException:FlipToggle()
	self.toggle = !self.toggle
end


local Modifier = class("Modifier")
function Modifier:Init(order)
	self.sortOrder = order
end


local ValueModifier = class("ValueModifier"):implements("Modifier")
function ValueModifier:Init(order)
	Modifier.Init(self, order)
end

function ValueModifier:Modify(fromValue, toValue) end


local AddValueModifier = class("AddValueModifier"):implements("ValueModifier")
function AddValueModifier:Init(order, add)
	ValueModifier.Init(self, order)

	self._toAdd = add
end

function AddValueModifier:Modify(fromValue, toValue)
	return toValue + self._toAdd
end

local MultValueModifier = class("MultValueModifier"):implements("ValueModifier")
function MultValueModifier:Init(order, mul)
	ValueModifier.Init(self, order)

	self._toMultiply = mul
end

function MultValueModifier:Modify(fromValue, toValue)
	return toValue * self._toMultiply
end




local ValueChangeException = class("ValueChangeException")
function ValueChangeException:Init(fromValue, toValue)
	BaseException.Init(self, true)

	self.modifiers = {}
	self._from = fromValue
	self._to = toValue
end

function ValueChangeException:AddModifier(mod)
	self.modifiers[#self.modifiers + 1] = mod
end

local function Compare(a, b)
	return a.sortOrder < b.sortOrder
end

function ValueChangeException:GetModifiedValue()
	if #self.modifiers <= 0 then
		return self._to
	end
	
	local value = self._to

	table.sort(self.modifiers, Compare)

	for k, modifier in ipairs(self.modifiers) do
		value = modifier:Modify(self._from, value)
	end

	return value
end
local Item = class("ItemStackable"):implements("Item")

Item.stackable_legacy = true
Item.max_stack = 32
Item.default_stack = 16

local function Write_Stack(item, value)
	net.WriteInt(value, 16)
end

local function Read_Stack(item)
	return net.ReadInt(16)
end

function Item:Init()
	self:AddData("stack", {
		Transmit = ix.transmit.owner,
		Write = Write_Stack,
		Read = Read_Stack
	})
end

function Item:OnInstanced(isCreated)
	if isCreated then
		self:SetData("stack", self.default_stack)
	end
end

function Item:AddValue(value)
	local newValue = (self:GetValue() + value)
	
	if newValue >= self.max_stack then
		self:SetData("stack", self.max_stack)

		return value - (self.max_stack - newValue)
	end

	self:SetData("stack", newValue)
	
	return value
end

function Item:TakeValue(value)
	local newValue = (self:GetValue() - value)
	
	if newValue <= 0 then
		self:Remove()

		return value + newValue
	end

	self:SetData("stack", newValue)
	
	return value
end

function Item:GetValue()
	return self:GetData("stack") or self.default_stack
end

function Item:CanStack(targetItem)
	return true
end

if CLIENT then
	function Item:PaintOver(w, h)
		draw.SimpleText(self:GetValue(), 'item.count', w - 2, h - 1, Color(225, 225, 225), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	end
end

return Item







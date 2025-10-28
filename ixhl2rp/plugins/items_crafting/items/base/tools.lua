local Item = class("ItemTool"):implements("Item")

Item.stackable = false

local function Write_Durability(item, value)
	net.WriteFloat(value)
end

local function Read_Durability(item)
	return net.ReadFloat()
end

function Item:Init()
	self.category = 'Инструменты'

	self.durability = self.durability or 1000

	self:AddData("durability", {
		Transmit = ix.transmit.all,
		Write = Write_Durability,
		Read = Read_Durability
	})
end

function Item:OnInstanced(isCreated)
	if isCreated then
		self:SetData("durability", self.durability)
	end

	if !self:GetData("durability") then
		self:OnInstanced(true)
	end
end

function Item:HasDurability()
	return (self:GetData("durability") or 0) > 0
end

function Item:DurabilityPercentage()
	return (self:GetData("durability") or 0) / (self.durability or 1)
end

function Item:TakeDurability(x, client)
	local value = self:GetData("durability", 0)
	local newValue = math.Clamp(value - x, 0, self.durability)

	self:SetData("durability", newValue)

	if newValue <= 0 then
		self:Break(client)
	end
end

function Item:Break(client)
	-- play sound
	self:Remove()
end

if CLIENT then
	function Item:PaintOver(w, h)
		local durability = self:GetData("durability") or self.durability

		if durability then
			local delta = math.Clamp(durability / self.durability, 0, 1)
			local clr = HSVToColor(120 * delta, 0.75, 1)

			surface.SetDrawColor(35, 35, 35, 225)
			surface.DrawRect(2, 2, 6, h - 4)

			local filledWidth = (h - 6) * delta

			surface.SetDrawColor(clr)
			surface.DrawRect(3, math.ceil(h - filledWidth - 3), 4, filledWidth)
		end
	end
end

return Item
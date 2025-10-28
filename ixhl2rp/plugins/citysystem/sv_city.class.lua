

local ValueChangeException = ix.meta.ValueChangeException


local Resource = class("CityResource")
function Resource:Init(name, baseValue)
	--self.id = id
	self.name = name
	self.base = baseValue
	self.exception = ValueChangeException:New(self.base, self.base)

	self.cachedValue = nil
end

function Resource:AddRaw(modifier, reasonID)
	local flow

	if isnumber(reasonID) then
		flow = ix.City:GetEconomicFlow(reasonID)
	else
		flow = ix.City:GetEconomicFlowByID(reasonID)
	end
	
	if !flow then return end
	
	modifier.reason = flow.index

	self.exception:AddModifier(modifier)
	self.cachedValue = nil
end

local AddValue = ix.meta.AddValueModifier
function Resource:Add(value, reasonID)
	local add = AddValue:New(0, value)

	self:AddRaw(add, reasonID)
end

function Resource:Get()
	if self.cachedValue then
		return self.cachedValue
	else
		self.cachedValue = self.exception:GetModifiedValue()

		return self.cachedValue
	end
end

local StockOrder = class("CityStockOrder")
function StockOrder:Init(value, reason, uniqueID)
	self.isOrder = true
	self.id = uniqueID
	self.value = math.max(value, 0)
	self.reason = reason
end

function StockOrder:Add(value)
	self.value = self.value + value
end






local StockItem = class("CityStockItem")

function StockItem:GetStored() return self.stored end

function StockItem:Init()
	self.stored = 0

	self.supplyOrders = {}
	self.demandOrders = {}

	self.cachedSupply = nil
	self.cachedDemand = nil
end

function StockItem:AddSupply(orderOrValue)
	local orderPassed = istable(orderOrValue)

	if orderPassed and orderOrValue.isOrder then
		table.insert(self.supplyOrders, orderOrValue)
	else
	end
end

function StockItem:AddDemand(orderOrValue)
	local orderPassed = istable(orderOrValue)

	if orderPassed and orderOrValue.isOrder then
		table.insert(self.demandOrders, orderOrValue)
	else
	end
end

function StockItem:AddStored(count)
	self:SetStored(self:GetStored() + count)
end

function StockItem:TakeStored(count)
	self:SetStored(math.max(self:GetStored() - count, 0))
end
/*
AccessorFunc(StockItem, "supply", "Supply", FORCE_NUMBER)
AccessorFunc(StockItem, "demand", "Demand", FORCE_NUMBER)
AccessorFunc(StockItem, "stored", "Stored", FORCE_NUMBER)

function StockItem:Init(id)
	self.id = id
	self.supply = 0
	self.demand = 0
	self.stored = 0
	self.init_stored = 0

	self.reason = {
		supply = {},
		demand = {}
	}

	// hacky fix for warehouse
	self.add_supply = 0
	self.add_demand = 0
end

function StockItem:Reasons()
	return self.reason
end

function StockItem:GetSupply()
	return self.supply + self.add_supply
end

function StockItem:GetDemand()
	return self.demand + self.add_demand
end

function StockItem:UpdateStaticSupply()
	self.add_supply = math.max(self.stored - self.init_stored, 0)
	self.add_demand = math.max(self.init_stored - self.stored, 0)
end

function StockItem:Set(supply, demand, storage)
	self.supply = supply
	self.demand = demand
	self.stored = storage
	self.init_stored = storage
end

function StockItem:AddSupply(supply)
	self:SetSupply(self:GetSupply() + supply)
end

function StockItem:AddDemand(demand)
	self:SetDemand(self:GetDemand() + demand)
end

function StockItem:Add(count)
	self:SetStored(self:GetStored() + count)
end

function StockItem:AddReason(flowType, supplyOrDemand, value)
	local reasons = self.reason
	local target = reasons[supplyOrDemand and "supply" or "demand"]
	
	target[flowType.id] = target[flowType.id] or 0
	target[flowType.id] = math.max(target[flowType.id] + value, 0)
end

function StockItem:Remove(count)
	self:SetStored(math.max(self:GetStored() - count, 0))
end

function StockItem:GetPrice()
	local base = self.baseCost
	local supply = self:GetSupply()
	local demand = self:GetDemand()

	return base + (base * (1 + 0.975 * math.min(math.max(-1, (demand - supply) / math.min(demand, supply)), 2)))
end
*/

local Stock = class("CityStock")

function Stock:Init(city)
	self.city = city

	self.items = {}
end

function Stock:RegisterItem(id)
	if !self.items[id] then
		local item = StockItem:New(id)

		item.baseCost = 1

		self.items[id] = item
	end

	return self.items[id]
end

function Stock:AddItem(id, count, noSupply, static)
	local item = self:GetItem(id)

	if !item then
		item = self:RegisterItem(id)
	end
	
	item:Add(count)

	if !noSupply then
		if static then
			item:UpdateStaticSupply()
		else
			item:AddSupply(count)
		end
	end
end

function Stock:TakeItem(id, count)
	local item = self:GetItem(id)

	if !item then
		item = self:RegisterItem(id)
	end

	item:AddDemand()
/*
	local diff = (item:GetStored() - count)

	if diff < 0 then
		count = count + diff
	end

	item:Remove(count)

	if !noDemand then
		if static then
			item:UpdateStaticSupply()
		else
			item:AddDemand(count)
		end
	end*/
end

function Stock:AddSupplyOrder(id, reason)
	local item = self:GetItem(id, true)
	local order = ix.meta.CityStockOrder:New(0, reason)

	item:AddSupply(order)

	return order
end

function Stock:AddDemandOrder(id, reason)
	local item = self:GetItem(id, true)
	local order = ix.meta.CityStockOrder:New(0, reason)

	item:AddDemand(order)

	return order
end

function Stock:GetPrice(id)
	local item = self.items[id]

	return item and item:GetPrice() or 0
end

function Stock:GetItem(id, create)
	if !self.items[id] and create then
		return self:RegisterItem(id)
	end

	return self.items[id]
end

function Stock:GetItems()
	return table.GetKeys(self.items) 
end


local CITY = class("City")
function CITY:Init(id)
	ix.City.stored[id] = self

	self.id = id
	self.isLoading = false

	self.resources = {}
	self.resources.tokens = Resource:New("Tokens", 0)

	self.stock = Stock:New(self)
end

function CITY:IsLoading()
	return self.isLoading
end
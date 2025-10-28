ix.meta = ix.meta or {}

local function merge(to, from)
	local id_to, id = to.__index, from.__index

	to.__index = nil
	from.__index = nil

	for k, v in pairs(from) do
		if istable(v) and istable(to[k]) then
			table.Merge(to[k], v)
		else
			to[k] = v
		end
	end

	to.__index = id_to
	from.__index = id

	return to
end

local last_class = nil

function implements(name, name2)
	if istable(name) then
		name = name2
	else
		if name2 then
			last_class = name2
		end
	end
	
	local base = ix.meta[name]
	local class = ix.meta[last_class]

	if class and base then
		local copy = table.Copy(base)

		merge(copy, class)

		ix.meta[last_class] = copy
		
		local obj = ix.meta[last_class]

		last_class = nil

		return obj
	end
end

function class(name, abstract)
	last_class = name

	local obj = {}
	obj.AbstractClass = abstract
	obj.__index = obj
	obj.class_name = name
	obj.implements = implements
	obj.New = function(this, ...)
		local object = {}

		setmetatable(object, this)

		if this.Init then
			local success, value = pcall(this.Init, object, ...)

			if !success then
				ErrorNoHalt(value)
			end
		end

		if this.AbstractClass then
			object.New = function(this, ...)
				local new_object = {}

				setmetatable(new_object, {__index = this, __eq = this.__eq, __tostring = this.__tostring})

				if this.Init then
					local success, value = pcall(this.Init, new_object, ...)

					if !success then
						ErrorNoHalt(value)
					end
				end

				return new_object
			end
		end

		return object
	end

	ix.meta[name] = obj

	return obj
end

function abstract_class(name)
	return class(name, true)
end

/*
do
	local Base = class "Base"
		Base.name = "Base"
		function Base:Init()
			print("this is init")
		end
		function Base:GetName()
			return self.name
		end

	
	local BasedBase = class "BasedBase" 
		BasedBase.name = "Heart"
		BasedBase.value = 5
		BasedBase.ded = 1
		function BasedBase:Init(name)
			rp.meta.Base.Init(self)

			self.name = name
		end
		function BasedBase:test()
			print(self:GetName())
		end
	implements "Base"
end

local obj = rp.meta.BasedBase:New("test")
print(obj:test())

do
	local Item = abstract_class "Item"
		Item.id = -1
		Item.name = "Heart2"
		function Item:__eq(other)
			return self.id != -1 and self.id == other.id
		end

	local ItemFood = abstract_class "ItemFood"
		ItemFood.isUsable = true
	implements "Item"
end

local templates = {}

do
	local TEMPLATE = rp.meta.ItemFood:New()
	TEMPLATE.uniqueID = "basic_item"

	function TEMPLATE:Use()
		print("yo")
	end

	templates[TEMPLATE.uniqueID] = TEMPLATE
end

local instance = templates["basic_item"]:New()
instance.id = 1

local instance2 = templates["basic_item"]:New()
instance2.id = 2

print(instance == instance2)
*/
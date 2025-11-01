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

		last_class = nil

		return copy
	end
end

function class(name, abstract)
	last_class = name

	local obj = {}

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

		if abstract then
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
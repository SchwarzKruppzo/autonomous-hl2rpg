local Net = ix.util.Lib("Net", {
	globals = {},
	locals = {},
	entities = {},
	players = {},
	var_max = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
	},
	callbacks = {}
})

Net.vars = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
}

Net.vars_id = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
}

do
	function net.ChooseOptimalBits(amount)
		local bits = 1

		while 2 ^ bits <= amount do
			bits = bits + 1
		end

		return math.max(bits, 1)
	end

	local function WriteEntIndex(value)
		net.WriteUInt(value, 16)
	end

	local function ReadEntIndex()
		return net.ReadUInt(16)
	end

	local function WriteCharID(value)
		net.WriteUInt(value, 32)
	end

	local function ReadCharID()
		return net.ReadUInt(32)
	end
	
	Net.Type = {
		All = {net.WriteType, net.ReadType},
		Bool = {net.WriteBool, net.ReadBool},
		String = {net.WriteString, net.ReadString},
		Entity = {net.WriteEntity, net.ReadEntity},
		Float = {net.WriteFloat, net.ReadFloat},
		Vector = {net.WriteVector, net.ReadVector},
		Angle = {net.WriteAngle, net.ReadAngle},
		Table = {net.WriteTable, net.ReadTable},
		Color = {net.WriteColor, net.ReadColor},
		EntityIndex = {WriteEntIndex, ReadEntIndex},
		CharacterID = {WriteCharID, ReadCharID},
	}
end

do
	local default = {net.WriteType, net.ReadType}
	
	function Net:AddVar(varType, key, funcs, callback)
		funcs = funcs or default

		local var_max = table.Count(self.vars[varType]) + 1
		local data = {
			index = var_max,
			Write = funcs[1],
			Read = funcs[2]
		}

		self.vars[varType][key] = data
		self.var_max[varType] = net.ChooseOptimalBits(var_max)
		self.vars_id[varType][var_max] = key

		if callback then
			self.callbacks[varType] = self.callbacks[varType] or {}
			self.callbacks[varType][key] = callback
		end

		return self.vars[varType][key]
	end
end

function Net:AddGlobalVar(key, funcs)
	self:AddVar(1, key, funcs)
end

function Net:AddEntityVar(key, noAutoSync, funcs)
	local data = self:AddVar(3, key, funcs)
	data.noAutoSync = noAutoSync
end

function Net:AddPlayerVar(key, isLocal, noAutoSync, funcs, callback)
	local data = self:AddVar(isLocal and 2 or 4, key, funcs, callback)
	data.noAutoSync = noAutoSync
end

do
	if SERVER then
		function net.WriteNetVar(var, varType, value)
			net.WriteUInt(var.index, Net.var_max[varType])
			var.Write(value)
		end
	else
		function net.ReadNetVar(varType)
			local index = net.ReadUInt(Net.var_max[varType])
			local key = Net.vars_id[varType][index]
			local var = Net.vars[varType][key]

			return key, var.Read()
		end
	end
end

do
	function Net:GetVar(key, default)
		local value = self.globals[key]

		return value != nil and value or default
	end

	if SERVER then
		function Net:SetVar(key, value, receiver)
			if !value then
				return self:ClearVar(key, receiver)
			end

			local var = self.vars[1][key]

			if !var then return end
			if self:GetVar(key) == value then return end

			self.globals[key] = value

			net.Start("rp.net.global")
			net.WriteNetVar(var, 1, value)

			if receiver == nil then
				net.Broadcast()
			else
				net.Send(receiver)
			end
		end

		function Net:ClearVar(key, receiver)
			local var = self.vars[1][key]

			if !var then return end

			self.globals[key] = nil

			net.Start("rp.net.global.clear")
			net.WriteUInt(var.index, Net.var_max[1])

			if receiver == nil then
				net.Broadcast()
			else
				net.Send(receiver)
			end
		end
	end
end

do
	local ENTITY = FindMetaTable("Entity")
	local PLAYER = FindMetaTable("Player")

	function ENTITY:GetNetVar(key, default)
		local index = self:EntIndex()
		
		if Net.entities[index] and Net.entities[index][key] != nil then
			return Net.entities[index][key]
		end

		return default
	end

	function PLAYER:GetNetVar(key, default)
		local index = self:EntIndex()

		if Net.players[index] and Net.players[index][key] != nil then
			return Net.players[index][key]
		end

		return default
	end

	if SERVER then
		function PLAYER:GetLocalVar(key, default)
			local index = self:EntIndex()

			if Net.locals[index] and Net.locals[index][key] != nil then
				return Net.locals[index][key]
			end

			return default
		end
	else
		function Net:GetLocalVar(key, default)
			if Net.locals[key] != nil then
				return Net.locals[key]
			end

			return default
		end

		function PLAYER:GetLocalVar(key, default) -- backward
			if Net.locals[key] != nil then
				return Net.locals[key]
			end

			return default
		end
	end

	if SERVER then
		function PLAYER:SyncVars()
			for k, v in pairs(Net.globals) do
				local var = Net.vars[1][k]

				net.Start("rp.net.global")
					net.WriteNetVar(var, 1, v)
				net.Send(self)
			end

			for k, v in pairs(Net.locals[self:EntIndex()] or {}) do
				local var = Net.vars[2][k]

				net.Start("rp.net.local")
					net.WriteNetVar(var, 2, v)
				net.Send(self)
			end

			for index, data in pairs(Net.entities) do
				local entity = Entity(index)

				if !IsValid(entity) then continue end
				
				for k, v in pairs(data) do
					local var = Net.vars[3][k]
					if var.noAutoSync then continue end
					
					net.Start("rp.net.entity")
						net.WriteUInt(index, 16)
						net.WriteNetVar(var, 3, v)
					net.Send(self)
				end
			end

			for index, data in pairs(Net.players) do
				local entity = Entity(index)

				if !IsValid(entity) then continue end

				for k, v in pairs(data) do
					local var = Net.vars[4][k]
					if var.noAutoSync then continue end
					
					net.Start("rp.net.player")
						net.WriteUInt(index, 16)
						net.WriteNetVar(var, 4, v)
					net.Send(self)
				end
			end
		end

		function ENTITY:SyncNetVar(key, receiver)
			local index = self:EntIndex()

			if !Net.entities[index] or !Net.entities[index][key] then return end
			
			local var = Net.vars[3][key]

			net.Start("rp.net.entity")
				net.WriteUInt(index, 16)
				net.WriteNetVar(var, 3, Net.entities[index][key])
			if receiver == nil then
				net.Broadcast()
			else
				net.Send(receiver)
			end
		end

		function PLAYER:SyncNetVar(key, receiver)
			local index = self:EntIndex()

			if !Net.players[index] or !Net.players[index][key] then return end
			
			local var = Net.vars[4][key]
			
			net.Start("rp.net.player")
				net.WriteUInt(index, 16)
				net.WriteNetVar(var, 4, Net.players[index][key])
			if receiver == nil then
				net.Broadcast()
			else
				net.Send(receiver)
			end
		end

		function ENTITY:SetNetVar(key, value, receiver)
			if value == nil then
				return self:ClearNetVar(key, receiver)
			end

			local var = Net.vars[3][key]

			if !var then return end

			local index = self:EntIndex()

			Net.entities[index] = Net.entities[index] or {}
			Net.entities[index][key] = value

			net.Start("rp.net.entity")
				net.WriteUInt(index, 16)
				net.WriteNetVar(var, 3, value)
			if receiver == nil then
				net.Broadcast()
			else
				net.Send(receiver)
			end
		end

		function PLAYER:SetNetVar(key, value, receiver)
			if value == nil then
				return self:ClearNetVar(key, receiver)
			end

			local var = Net.vars[4][key]

			if !var then return end

			local index = self:EntIndex()

			Net.players[index] = Net.players[index] or {}
			Net.players[index][key] = value

			net.Start("rp.net.player")
				net.WriteUInt(index, 16)
				net.WriteNetVar(var, 4, value)
			if receiver == nil then
				net.Broadcast()
			else
				net.Send(receiver)
			end
		end

		function PLAYER:SetLocalVar(key, value)
			if value == nil then
				return self:ClearLocalVar(key)
			end
			
			local var = Net.vars[2][key]

			if !var then return end

			local index = self:EntIndex()
			
			Net.locals[index] = Net.locals[index] or {}
			Net.locals[index][key] = value

			net.Start("rp.net.local")
				net.WriteNetVar(var, 2, value)
			net.Send(self)
		end

		function ENTITY:ClearNetVar(key, receiver)
			local var = Net.vars[3][key]

			if !var then return end

			local index = self:EntIndex()

			Net.entities[index] = Net.entities[index] or {}
			Net.entities[index][key] = nil

			net.Start("rp.net.entity.clear")
				net.WriteUInt(index, 16)
				net.WriteUInt(var.index, Net.var_max[3])
			if receiver == nil then
				net.Broadcast()
			else
				net.Send(receiver)
			end
		end

		function PLAYER:ClearNetVar(key, receiver)
			local var = Net.vars[4][key]

			if !var then return end

			local index = self:EntIndex()

			Net.players[index] = Net.players[index] or {}
			Net.players[index][key] = nil

			net.Start("rp.net.player.clear")
				net.WriteUInt(index, 16)
				net.WriteUInt(var.index, Net.var_max[4])
			if receiver == nil then
				net.Broadcast()
			else
				net.Send(receiver)
			end
		end

		function PLAYER:ClearLocalVar(key)
			local var = Net.vars[2][key]

			if !var then return end
			
			local index = self:EntIndex()

			Net.locals[index] = Net.locals[index] or {}
			Net.locals[index][key] = nil

			net.Start("rp.net.local.clear")
				net.WriteUInt(var.index, Net.var_max[2])
			net.Send(self)
		end

		function ENTITY:ClearNetVars(receiver)
			local index = self:EntIndex()

			Net.entities[index] = nil

			net.Start("rp.net.flush.entity")
			net.WriteUInt(index, 16)

			if receiver == nil then
				net.Broadcast()
			else
				net.Send(receiver)
			end
		end

		function PLAYER:ClearNetVars(receiver)
			local index = self:EntIndex()

			Net.players[index] = nil
			Net.locals[index] = nil

			net.Start("rp.net.flush.player")
			net.WriteUInt(index, 16)

			if receiver == nil then
				net.Broadcast()
			else
				net.Send(receiver)
			end
		end
	end
end

if CLIENT then
	net.Receive("rp.net.global", function()
		local key, value = net.ReadNetVar(1)

		Net.globals[key] = value
	end)

	net.Receive("rp.net.local", function()
		local key, value = net.ReadNetVar(2)

		Net.locals[key] = value

		hook.Run("OnLocalVarSet", key, value)
	end)

	net.Receive("rp.net.entity", function()
		local index = net.ReadUInt(16)
		local key, value = net.ReadNetVar(3)
		//local entity = Entity(index)

		Net.entities[index] = Net.entities[index] or {}
		Net.entities[index][key] = value
	end)

	net.Receive("rp.net.player", function()
		local index = net.ReadUInt(16)
		local key, value = net.ReadNetVar(4)
		//local entity = Entity(index)

		Net.players[index] = Net.players[index] or {}
		local lastvalue = Net.players[index][key]

		Net.players[index][key] = value

		if Net.callbacks[4] then
			local callback = Net.callbacks[4][key]

			if isfunction(callback) then
				callback(index, value, lastvalue)
			end
		end
	end)

	net.Receive("rp.net.flush.player", function()
		Net.players[net.ReadUInt(16)] = nil
	end)

	net.Receive("rp.net.flush.entity", function()
		Net.entities[net.ReadUInt(16)] = nil
	end)

	net.Receive("rp.net.local.clear", function()
		local key = Net.vars_id[2][net.ReadUInt(Net.var_max[2])]

		Net.locals[key] = nil

		hook.Run("OnLocalVarSet", key)
	end)

	net.Receive("rp.net.entity.clear", function()
		local index = net.ReadUInt(16)
		local key = Net.vars_id[3][net.ReadUInt(Net.var_max[3])]
		//local entity = Entity(index)

		Net.entities[index] = Net.entities[index] or {}
		Net.entities[index][key] = nil
	end)

	net.Receive("rp.net.player.clear", function()
		local index = net.ReadUInt(16)
		local key = Net.vars_id[4][net.ReadUInt(Net.var_max[4])]
		//local index = Entity(index)

		Net.players[index] = Net.players[index] or {}
		Net.players[index][key] = nil
	end)

	net.Receive("rp.net.global.clear", function()
		local key = Net.vars_id[1][net.ReadUInt(Net.var_max[1])]

		Net.globals[key] = nil
	end)
else
	util.AddNetworkString("rp.net.global")
	util.AddNetworkString("rp.net.local")
	util.AddNetworkString("rp.net.entity")
	util.AddNetworkString("rp.net.player")
	util.AddNetworkString("rp.net.flush.entity")
	util.AddNetworkString("rp.net.flush.player")
	util.AddNetworkString("rp.net.global.clear")
	util.AddNetworkString("rp.net.local.clear")
	util.AddNetworkString("rp.net.entity.clear")
	util.AddNetworkString("rp.net.player.clear")
end

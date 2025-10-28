phases = phases or {}

local Phase = class("Phase")

function Phase:Init(id, owner)
	self.id = id

	self.entities = {}
	self.players = {}

	self.owner = owner
end

function Phase:AddPlayer(client)
	client.phase = self

	self.players[client] = true

	self:AddEntity(client)
end

function Phase:AddEntity(entity)
	if !IsValid(entity) then
		return
	end

	entity.phase_id = self.id
	entity:CollisionRulesChanged()

	entity:SetNW2String("phase", self.id)

	self.entities[entity] = true

	for k, client in ipairs(player.GetAll()) do
		entity:SetPreventTransmit(client, !self.players[client])

		if entity:IsPlayer() then
			client:SetPreventTransmit(entity, !self.players[client])
		end
	end

	if entity:IsPlayer() then
		for client, _ in pairs(self.entities or {}) do
			if !IsValid(client) then continue end
			if client == entity then continue end
			
			client:SetPreventTransmit(entity, false)
		end
	end

	for _, v in ipairs(entity:GetChildren()) do
		self:AddEntity(v)
	end
end

function Phase:RemovePlayer(client)
	client.phase = nil

	self.players[client] = nil

	self:RemoveEntity(client)
end

function Phase:RemoveEntity(entity)
	entity.phase_id = nil
	entity:CollisionRulesChanged()

	entity:SetNW2String("phase", nil)

	self.entities[entity] = nil

	for k, client in ipairs(player.GetAll()) do
		entity:SetPreventTransmit(client, self.players[client])

		if entity:IsPlayer() then
			client:SetPreventTransmit(entity, self.players[client])
		end
	end

	if entity:IsPlayer() then
		for client, _ in pairs(self.entities) do
			if !IsValid(client) then continue end
			if client == entity then continue end
			
			client:SetPreventTransmit(entity, true)
		end
	end

	for k, v in ipairs(entity:GetChildren()) do
		self:RemoveEntity(v)
	end
end

function Phase:Destroy()
	for client, _ in pairs(self.players) do
		self:RemovePlayer(client)
	end

	for entity, _ in pairs(self.entities) do
		if !IsValid(entity) then continue end

		entity:Remove()
	end

	phases[self.id] = nil
end

function New_Phase(id, owner)
	local phase = Phase:New(id, owner)
	phases[phase.id] = phase

	return phases[phase.id]
end


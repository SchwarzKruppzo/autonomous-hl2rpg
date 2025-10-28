local Body = class "Body"

function Body:Init()
	self.parts = {}
	self.hit_parts = {}
end

function Body:AddPart(info)
	local id = (#self.parts + 1)
	info.id = id

	self.parts[id] = info
	self.hit_parts[info.hitgroup] = id
end

local tex_head = Material("clockwork/limbs/head.png")
local tex_chest = Material("clockwork/limbs/chest.png")
local tex_stomach = Material("clockwork/limbs/stomach.png")
local tex_lleg = Material("clockwork/limbs/lleg.png")
local tex_rleg = Material("clockwork/limbs/rleg.png")
local tex_lram = Material("clockwork/limbs/larm.png")
local tex_rarm = Material("clockwork/limbs/rarm.png")

local Template = Body:New()
Template:AddPart({
	name = "ВСЁ ТЕЛО",
	hitgroup = 0,
	health = 1,
	hidden = true
})
Template:AddPart({
	name = "Голова",
	hitgroup = HITGROUP_HEAD,
	health = 25,
	death = true,
	consciousness = true,
	fallChance = 0.1,
	coverageAbs = 0.1,
	texture = tex_head
})
Template:AddPart({
	name = "Торс",
	hitgroup = HITGROUP_CHEST,
	health = 80,
	death = true,
	fallChance = 0.3,
	coverageAbs = 0.4,
	texture = tex_chest
})
Template:AddPart({
	name = "Живот",
	hitgroup = HITGROUP_STOMACH,
	health = 70,
	fallChance = 0.1,
	coverageAbs = 0.5,
	texture = tex_stomach
})
Template:AddPart({
	name = "Левая рука",
	hitgroup = HITGROUP_LEFTARM,
	health = 45,
	fallChance = 0.3,
	canFracture = true,
	coverageAbs = 0.5,
	texture = tex_lram
})
Template:AddPart({
	name = "Правая рука",
	hitgroup = HITGROUP_RIGHTARM,
	health = 45,
	fallChance = 0.3,
	canFracture = true,
	coverageAbs = 0.5,
	texture = tex_rarm
})
Template:AddPart({
	name = "Левая нога",
	hitgroup = HITGROUP_LEFTLEG,
	health = 50,
	fallChance = 0.75,
	canFracture = true,
	movement = true,
	coverageAbs = 0.5,
	texture = tex_lleg
})
Template:AddPart({
	name = "Правая нога",
	hitgroup = HITGROUP_RIGHTLEG,
	health = 50,
	fallChance = 0.75,
	canFracture = true,
	movement = true,
	coverageAbs = 0.5,
	texture = tex_rleg
})


local HEALTH = class "HealthStat"
local HEALTH_TICK = 4

function HEALTH:__tostring() return "health["..tostring(self.character).."]" end
function HEALTH:GetCharacter() return self.character end
function HEALTH:GetPlayer()
	if !self.client then
		self.client = self.character and self.character:GetPlayer() or nil
	end
	
	return self.client
end

function HEALTH:Init(character, var, data)
	self.var = var
	self.character = character

	self.healthScale = 1
	self.hediffs = {}
	self.hediffID = 0

	self.body = Template

	self.consciousSource = nil

	for k, v in self:GetParts() do
		if v.consciousness then
			self.consciousSource = k
		end
	end

	self.cachedBleed = -1
	self.cachedPain = -1
	self.cachedHealth = -1
	self.cachedMovement = -1
	self.cachedConscious = -1
	self.cachedParts = nil
	self.cachedHediffs = nil

	self.cachedSave = nil
	self.bloodloss = nil
	self.oxyloss = nil
end

function HEALTH:Reset()
	self:Init(self.character, self.var)
	self:Load({})

	if SERVER then
		net.Start("health.reset")
			net.WriteUInt(self.character:GetID(), 32)
		net.Send(self:GetPlayer())
	end
end

function HEALTH:Load(vars)
	self.client = nil
	self.cachedBleed = -1
	self.cachedPain = -1
	self.cachedHealth = -1
	self.cachedMovement = -1
	self.cachedConscious = -1
	self.cachedParts = nil
	self.cachedHediffs = nil
	self.bloodloss = nil
	self.oxyloss = nil

	if self.Tick then
		if SERVER or (CLIENT and self.character == LocalPlayer():GetCharacter()) then
			local client = CLIENT and LocalPlayer() or self:GetPlayer()
			local uniqueID = "health." .. client:SteamID() .. self.character:GetID()
			timer.Remove(uniqueID)

			timer.Create(uniqueID, HEALTH_TICK, 0, function()
				local character = client:GetCharacter()
				if !IsValid(client) or !character or character:GetID() != self.character:GetID() then
					print("Respawn timer.")
					timer.Remove(uniqueID)
					return
				end

				self:Tick(client)
			end)
		end
	end

	if SERVER then
		local isDefault = (vars.health == nil)
		local savedHealth = istable(vars.health) and vars.health or util.JSONToTable(vars.health or "[]")

		if isDefault then
			vars.health = {}
		else
			if savedHealth and #savedHealth > 0 then
				for _, info in ipairs(savedHealth) do
					self:AddHediff(info[1], info[2], info[3])
				end
			end
		end
	end

	self:SetBleedingFX(false)
end

function HEALTH:ToSaveable()
	local save = {}

	for k, v in self:GetHediffs() do
		local uniqueID = v.uniqueID
		local hitGroup = v.hit_group

		local data = {}
		for _, field in ipairs(v:Save()) do
			data[field] = v[field]
		end

		save[#save + 1] = {
			uniqueID,
			hitGroup,
			data
		}
	end
	
	return save
end

function HEALTH:GetHediffs(hediffID)
	if hediffID then
		local k = 0
		local n = #self.hediffs

		while k != n do
			k = k + 1

			local data = self.hediffs[k]

			if data and data.id == hediffID then
				return k, data
			end
		end
	else
		local k = 0
		local n = #self.hediffs

		return function()
			while k != n do
				k = k + 1

				local data = self.hediffs[k]

				if data then 
					return data.id, data
				end
			end

			return nil
		end
	end
end

function HEALTH:RecacheHediffsWithTick()
	if !self.cachedHediffs then
		self.cachedHediffs = {}

		for k, v in self:GetHediffs() do
			if !v.OnTick then continue end
			
			self.cachedHediffs[#self.cachedHediffs + 1] = v
		end
	end
end

function HEALTH:GetParts(hitgroup)
	if hitgroup then
		return self.body.hit_parts[hitgroup] and self.body.parts[self.body.hit_parts[hitgroup]]
	else
		local k = 0
		local n = #self.body.parts

		return function()
			while k != n do
				k = k + 1
				return k, self.body.parts[k]
			end

			return nil
		end
	end
end

function HEALTH:SetBleedingFX(bool)
	if CLIENT then return end
	
	local client = self:GetPlayer()
	if IsValid(client) then
		client:SetNetVar("isBleeding", bool)
	end
end

function HEALTH:GetBleedRate()
	if self.cachedBleed < 0 then
		local RESIST_1 = self.character:HasSpecialLevel("en", 50) and 0.25 or 0
		local RESIST_2 = self.character:HasSpecialLevel("en", 100) and 0.25 or 0

		local bleedResist = RESIST_1 + RESIST_2

		local num = 0
		for k, v in ipairs(self.hediffs) do
			if v.part == 1 then continue end
			if v.tended_time != -1 then continue end

			num = num + v:GetSeverity() * (v.bleedRate or 1)
		end

		if bleedResist > 0 then
			num = num * bleedResist
		end

		self.cachedBleed = (num / self.healthScale)

		if self.cachedBleed > 0 then
			self:SetBleedingFX(true)
		else
			self:SetBleedingFX(false)
		end
	end
	
	return self.cachedBleed
end

function HEALTH:GetFallDamageParts(num)
	local total = 0 
	local parts = {}

	for i, part in self:GetParts() do
		if !part.fallChance then continue end
		if self:GetPartHealth(part.id) <= 0 then continue end

		parts[#parts + 1] = {part.id, part.fallChance}
		total = total + part.fallChance 
	end

	local result = {}

	for i = 1, num do
		local roll = math.Rand(0, total)
		local weight = 0
		for i, info in ipairs(parts) do
			weight = weight + info[2]

			if roll < weight then
				result[#result + 1] = info[1]
				break
			end
		end
	end

	return result
end

function HEALTH:GetPain()
	if self.cachedPain < 0 then
		local num = 0
		for k, v in self:GetHediffs() do
			if !v.isInjury and !v.hasPain then continue end
			
			if v.isPermanent then
				num = num + v:GetSeverity() * v.painPerSeverityPermanent * v.painFactor
			else
				num = num + v:GetSeverity() * ((v.painPerSeverity * 0.5) or 1)
			end
		end

		local num2 = (num / self.healthScale)

		for k, v in self:GetHediffs() do
			local factor = v.GetPainFactor and v:GetPainFactor() or v.painFactor

			if !factor then continue end
			
			num2 = num2 * factor
		end

		self.cachedPain = math.Clamp(num2, 0, 1)
	end
	
	return self.cachedPain
end

function HEALTH:GetMaxHealth(partID)
	if !self.cachedParts or !self.cachedParts[partID] then
		self.cachedParts = {}

		local part = self.body.parts[partID]

		if part then
			self.cachedParts[partID] = math.Round(part.health * self.healthScale)
		end
	end
	 
	return self.cachedParts[partID] or 0
end

function HEALTH:GetPartHealth(partID)
	local part = self.body.parts[partID]

	if !part then
		return 0
	end

	local num = self:GetMaxHealth(partID)

	for k, v in self:GetHediffs() do
		if !v.isInjury then continue end
		if v.part != partID then continue end
		
		num = num - v:GetSeverity()
	end

	return math.Round(math.max(num, 0))
end

function HEALTH:GetPercent()
	if self.cachedHealth < 0 then
		local num = 1
		for k, v in self:GetHediffs() do
			local num2 = math.min(v:HealthImpact(self), 0.95)
			num = num * (1 - num2)
		end

		self.cachedHealth = math.Clamp(num, 0.05, 1)
	end
	
	return self.cachedHealth
end

function HEALTH:GetConsciousness()
	if self.cachedConscious < 0 then
		if self.consciousSource then
			local hp = math.Clamp(math.Remap(self:GetPartHealth(self.consciousSource), 0, 10, 0, 1), 0, 1)
			local pain = math.max(math.Remap(self:GetPain(), 0.1, 1, 0, 0.8), 0)

			self.cachedConscious = math.max(hp - pain, 0)
		else
			self.cachedConscious = 1
		end
	end

	return self.cachedConscious
end


if SERVER then
	util.AddNetworkString("health.reset")
	util.AddNetworkString("hediff.add")
	util.AddNetworkString("hediff.remove")
	util.AddNetworkString("hediff.update")
	util.AddNetworkString("hediff.use")
	util.AddNetworkString("hediff.sync")
	util.AddNetworkString("health.tended")

	function HEALTH:TendHediff(id, time)
		local hediff = id

		if isnumber(id) then
			local a, diff = self:GetHediffs(id)

			hediff = diff
		end

		if !hediff then
			return
		end

		hediff.tended_time = time
		hediff.tended_start = os.time()

		self:OnUpdateDiffs()
		
		net.Start("health.tended")
			net.WriteUInt(self.character:GetID(), 32)
			net.WriteUInt(hediff.id, 16)
			net.WriteUInt(hediff.tended_time, 32)
			net.WriteUInt(hediff.tended_start, 32)
		net.Send(self:GetPlayer())
	end

	function HEALTH:Tick(client)
		self:RecacheHediffsWithTick()

		local data = {}

		for k, v in ipairs(self.cachedHediffs) do
			local sync = v:OnTick(self)

			if sync then
				table.insert(data, {
					v.id, 
					unpack(v:Get())
				})
			end
		end

		if #data > 0 then
			local send = util.TableToJSON(data)
			local compressed = util.Compress(send)

			net.Start("hediff.sync")
				net.WriteUInt(#compressed, 16)
				net.WriteData(compressed, #compressed)
			net.Send(self:GetPlayer())

			self.cachedSave = nil
		end

		local consciousness = self:GetConsciousness()
		local alive = client:Alive()
		local rate = self:GetBleedRate()
		local rate = self:GetPain()

		if alive then
			if consciousness <= 0.3 then
				if !IsValid(client.ixRagdoll) then
					client:SetRagdolled(true)
					client:SetLocalVar("knocked", true)
					client:SetCriticalState(true)
				end
			elseif consciousness >= 0.4 and client:GetLocalVar("knocked") then
				local ratio = self:GetPercent()
				local chanceSuccess = (ratio * 100)
				local chanceFail = (100 - chanceSuccess) * 0.5

				if math.random(0, 100) <= chanceSuccess and !client.ixRegainConscious then
					local time = 15 + math.Round(60 * math.max((1 - ratio), 0))

					client:SetAction("@wakingUp", time, function(player)
						client:SetLocalVar("knocked", false)
						client:SetRagdolled(false)
						client:SetCriticalState(false)
					end)

					client.ixRegainConscious = true
				elseif client.ixRegainConscious and math.random(1, 100) <= chanceFail then
					client:SetAction()
					client.ixRegainConscious = false
				end
			end
		end
	end

	function HEALTH:NetWrite()
		--net.WriteString("hello")
	end

	function HEALTH:Sync(receiver, broadcast)
		net.Start("CharacterVarChanged")
			net.WriteUInt(self.character:GetID(), 32)
			net.WriteCharVar(self.character, self.var)
		if receiver then
			net.Send(receiver)
		else
			net.Send(self:GetPlayer())
		end
	end

	function HEALTH:Disconnect(client) end

	net.Receive("hediff.use", function(len, client)
		local inventory_id = net.ReadUInt(32)
		local x = net.ReadUInt(8)
		local y = net.ReadUInt(8)
		local character = net.ReadUInt(32)
		local id = net.ReadUInt(16)

		print(inventory_id, x, y, character, id)
	end)

	ix.char.HookVar("specials", "healthSystem", function(character)
		local health = character:Health()

		health.cachedBleed = -1
	end)
else
	function HEALTH:NetRead()
		local a = net.ReadString()

		print(self, a)
	end

	net.Receive("hediff.update", function(len)
		local characterID = net.ReadUInt(32)
		local character = ix.char.loaded[characterID]

		if !character then
			return
		end
		
		local id = net.ReadUInt(16)
		local health = character:Health()

		if health then
			for k, v in ipairs(health.hediffs) do
				if v.id == id then
					v:Receive()
					break
				end
			end
		end

		health:OnUpdateDiffs()

		if IsValid(health.panel) then
			health.panel:CacheHealth()
		end
	end)

	net.Receive("hediff.sync", function(len)
		local character = LocalPlayer():GetCharacter()

		if !character then
			return
		end

		local health = character:Health()

		local size = net.ReadUInt(16)
		local compressed = util.Decompress(net.ReadData(size))
		local data = util.JSONToTable(compressed)
		local changes = {}

		for k, v in ipairs(data) do
			local id = v[1]

			table.remove(v, 1)

			changes[id] = v
		end

		for k, v in ipairs(health.hediffs) do
			if changes[v.id] then
				v:Set(changes[v.id])
			end
		end

		health:OnUpdateDiffs()

		if IsValid(health.panel) then
			health.panel:CacheHealth()
		end
	end)

	net.Receive("hediff.add", function()
		local characterID = net.ReadUInt(32)
		local character = ix.char.loaded[characterID]

		if !character then
			return
		end
		
		local id = net.ReadUInt(16)
		local networkID = net.ReadUInt(ix.Hediffs.network_max)
		local hitGroup = net.ReadUInt(4)

		local health = character:Health()
		local hediff = health:AddHediff(networkID, hitGroup)

		hediff.id = id
		hediff:Receive()
		health:OnUpdateDiffs()
		
		if IsValid(health.panel) then
			local self = health.panel

			for k, v in pairs(self.categories) do
				v.hediff_container:Clear()
			end

			for k, v in ipairs(self.health.hediffs) do
				self:AddStatus(self.categories[v.part], v)
			end

			self:CacheHealth()
		end
	end)

	net.Receive("health.reset", function()
		local characterID = net.ReadUInt(32)
		local character = ix.char.loaded[characterID]

		if !character then
			return
		end

		local health = character:Health()
		health:Reset()
	end)

	net.Receive("health.tended", function()
		local characterID = net.ReadUInt(32)
		local character = ix.char.loaded[characterID]

		if !character then
			return
		end

		local id = net.ReadUInt(16)
		local health = character:Health()

		local found
		for k, v in ipairs(health.hediffs) do
			if v.id == id then
				found = v
				break
			end
		end

		if found then
			local tended_time = net.ReadUInt(32)
			local tended_start = net.ReadUInt(32)

			found.tended_time = tended_time
			found.tended_start = tended_start

			health:OnUpdateDiffs()

			if IsValid(health.panel) then
				health.panel:Rebuild(character)
			end
		end
	end)

	net.Receive("hediff.remove", function()
		local characterID = net.ReadUInt(32)
		local character = ix.char.loaded[characterID]

		if !character then
			return
		end
		
		local id = net.ReadUInt(16)

		local health = character:Health()
		health:RemoveHediffByID(id)
		health:OnUpdateDiffs()

		local panel = health.panel
		if IsValid(panel) then
			panel.dirty = true

			panel:CacheHealth()

			health.panel:Rebuild(character)
		end
	end)
end

function HEALTH:OnUpdateDiffs()
	self.cachedPain = -1
	self.cachedBleed = -1
	self.cachedMovement = -1
	self.cachedHealth = -1
	self.cachedConscious = -1
	self.cachedHediffs = nil

	self.cachedSave = nil
end

function HEALTH:RemoveHediffByID(id)
	local found
	for k, v in ipairs(self.hediffs) do
		if v.id == id then
			found = k
			break
		end
	end

	if found then
		table.remove(self.hediffs, found)
		
		if SERVER then
			self:OnUpdateDiffs()

			net.Start("hediff.remove")
				net.WriteUInt(self.character:GetID(), 32)
				net.WriteUInt(id, 16)
			net.Send(self.character:GetPlayer())
		end
	end
end

function HEALTH:AddHediff(uniqueID, hitGroup, data, id)
	data = data or {}
	local stored = isnumber(uniqueID) and ix.Hediffs:NetworkID(uniqueID) or ix.Hediffs:Get(uniqueID)

	if stored.merge then
		for k, v in self:GetHediffs() do
			if v.uniqueID != uniqueID then continue end
			if v.part != self:GetParts(hitGroup).id then continue end
			
			if v.OnMerge then
				v:OnMerge(data)
			else
				v:AdjustSeverity(data.severity or 0)
			end

			self:OnUpdateDiffs()

			net.Start("hediff.update")
				net.WriteUInt(self.character:GetID(), 32)
				net.WriteUInt(v.id, 16)
				v:Send()
			net.Send(self.character:GetPlayer())

			return
		end
	elseif stored.max then
		local count = 0
		for k, v in self:GetHediffs() do
			if v.uniqueID != uniqueID then continue end
			if v.part != self:GetParts(hitGroup).id then continue end
			
			count = count + 1
		end

		if (count + 1) > stored.max then
			return
		end
	end
	
	local hediff = stored:New()

	if !id then
		self.hediffID = self.hediffID + 1
	end

	id = id or self.hediffID

	hediff.id = id
	hediff.part = self:GetParts(hitGroup).id
	hediff.hit_group = hitGroup
	hediff.character = self.character:GetID()

	for k, v in pairs(data or {}) do
		hediff[k] = v
	end

	self.hediffs[#self.hediffs + 1] = hediff

	if hediff.OnAdded then
		hediff:OnAdded(self)
	end
	
	if SERVER then
		hediff:SetSeverity(data.severity or 0)

		self:OnUpdateDiffs()

		net.Start("hediff.add")
			net.WriteUInt(self.character:GetID(), 32)
			net.WriteUInt(id, 16)
			net.WriteUInt(stored.networkID, ix.Hediffs.network_max)
			net.WriteUInt(hitGroup, 4)
			hediff:Send(data)
		net.Send(self.character:GetPlayer())
	end

	return hediff
end
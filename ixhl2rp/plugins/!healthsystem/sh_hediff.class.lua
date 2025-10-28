local Hediff = abstract_class "Hediff"
Hediff.id = -1
Hediff.severity = 0
Hediff.stage = 1
/*
Hediff.stages = {
	{
		id = 1,
		label = "Name",
		visible = true
	}
}
*/
function Hediff:__eq(other)
	return self.id != -1 and self.id == other.id
end

function Hediff:CanMerge()
	return false
end

function Hediff:HealthImpact()
	return 0
end

function Hediff:IsVisible()
	if self.stages then
		return self:GetStage().visible
	end
	
	return true
end

function Hediff:Remove()
	if self.character then
		if !self.removing then
			local char = ix.char.loaded[self.character]

			char:Health():RemoveHediffByID(self.id)

			self.removing = true
		end
	end
end

function Hediff:GetSeverity()
	return self.severity
end

function Hediff:Update()
	local newStage = false

	if self.stages then
		local nextStage = self:GetNextStage()

		if self.stage != nextStage then
			newStage = true
			self.stage = nextStage
		end
	end

	if self.OnUpdate then
		self:OnUpdate(newStage)
	end
end

function Hediff:SetSeverity(value)
	self.severity = value
	
	self:Update()
end

function Hediff:AdjustSeverity(value)
	return self:SetSeverity(self:GetSeverity() + value)
end

function Hediff:GetNextStage()
	if self.stages then
		local severity = self:GetSeverity()

		for i = #self.stages, 1, -1 do
			if self.stages[i] and severity >= (self.stages[i].minSeverity or 0) then
				return i
			end
		end

		return 1
	end
end

function Hediff:GetStage()
	if self.stages and self.stage then
		return self.stages[self.stage]
	end
end

function Hediff:Send(data)
	if data then
		self.severity = data.severity or self.severity 
	end

	net.WriteFloat(self.severity)
end

function Hediff:Receive()
	local severity = net.ReadFloat()

	self:SetSeverity(severity)
end

local saveFields = {
	"severity"
}
function Hediff:Save()
	return saveFields
end


local Injury = abstract_class("Hediff_Injury"):implements("Hediff")
Injury.isInjury = true
Injury.tended_start = -1
Injury.tended_time = -1

function Injury:CanMerge()
	return self.tended_time == -1
end

function Injury:HealthImpact(health)
	return self:GetSeverity() / (100 * health.healthScale)
end

function Injury:GetSeverity()
	return self.severity * self:TendedMultiplier()
end
/*
function Injury:Stage()
	local info = self:GetStage()

	return info.label
end*/

function Injury:TendedMultiplier()
	if self.tended_time != -1 then
		local time = (self.tended_start + self.tended_time) - os.time()

		if time <= 0 then
			time = 0
		end
		
		local delta = time / self.tended_time
/*
		if delta >= 1 then
			self.tended_time = -1
		end*/
		
		return math.Clamp(1 * delta, 0, 1)
	end
	
	return 1
end

function Injury:Set(data)
	self.severity = data[1]
	--self.tended_time = data[2]
	--self.tended_start = data[3]
end

function Injury:Get()
	return {self.severity}
end

local tendedColor = Color(128, 128, 128)
function Injury:GetColor()
	if self.tended_time != -1 then
		return tendedColor
	else
		return self.color
	end
end

if SERVER then
	function Injury:OnTick(health)
		if self.tended_time != -1 then
			local client = health.client

			if IsValid(client) then
				local healRate = client.healRate

				if healRate and healRate > 0 then
					local HP = (75 * healRate * 5 / 3000)

					self:SetSeverity(self.severity - HP)
				end
			end
			
			---healRate
			--self:SetSeverity(self:GetSeverity() * self:TendedMultiplier())

			if self:GetSeverity() <= 0 then
				self:Remove()

				return false
			end

			return true
		end

		return false
	end
end

local saveFields = {
	"severity",
	"tended_time",
	"tended_start",
}
function Injury:Save()
	return saveFields
end

local Blood = abstract_class("Hediff_BloodLoss"):implements("Hediff")

local Disease = abstract_class("Hediff_Disease"):implements("Hediff")

local Medical = abstract_class("Hediff_Medical"):implements("Hediff")
Medical.tended_start = -1
Medical.tended_time = -1
Medical.isMedical = true

function Medical:TendedMultiplier()
	if self.tended_time != -1 then
		local delta = math.max((self.tended_start + self.tended_time) - os.time(), 0) / self.tended_time

		if delta <= 0 then
			self.tended_time = -1
		end
		
		return math.Clamp(1 * delta, 0, 1)
	end
	
	return 0
end

if SERVER then
	function Medical:OnTick(health)
		if self.tended_start != -1 then
			local mul = self:TendedMultiplier()
			local severity = (self:GetSeverity() * mul)

			if severity <= 0 then
				self:Remove()
				
				return false
			end

			return true -- mark as in-sync
		end

		return false
	end
end

if CLIENT then
	function Medical:GetSeverity()
		return (self.severity * self:TendedMultiplier())
	end
end

function Medical:GetPainFactor()
	return 1 - (0.25 * self:TendedMultiplier())
end


function Medical:Send(data)
	if data then
		self.severity = data.severity or self.severity 
		self.tended_time = data.tended_time or self.tended_time
		self.tended_start = data.tended_start or self.tended_start
	end

	net.WriteFloat(self.severity)
	net.WriteUInt(self.tended_start, 32)
	net.WriteUInt(self.tended_time, 32)
end

function Medical:Receive()
	local severity = net.ReadFloat()
	local tended_start = net.ReadUInt(32)
	local tended_time = net.ReadUInt(32)

	self.severity = severity
	self.tended_time = tended_time
	self.tended_start = tended_start
end

function Medical:Get()
	return {self.severity, self.tended_time, self.tended_start}
end

function Medical:Set(data)
	self.severity = data[1]
	self.tended_time = data[2]
	self.tended_start = data[3]

	self:Update()
end

local saveFields = {
	"severity",
	"tended_time",
	"tended_start",
}
function Medical:Save()
	return saveFields
end


local Effect = abstract_class("Hediff_Effect"):implements("Hediff")
Effect.tended_start = -1
Effect.tended_time = -1
Effect.effect = 0
Effect.isMedical = true
Effect.merge = true


function Effect:TendedMultiplier()
	if self.tended_time != -1 then
		local delta = math.max((self.tended_start + self.tended_time) - os.time(), 0) / self.tended_time

		if delta <= 0 then
			self.tended_time = -1
		end
		
		return math.Clamp(1 * delta, 0, 1)
	end
	
	return 0
end

function Effect:GetEffect()
	return self.effect
end

if CLIENT then
	function Effect:GetSeverity()
		return (self.severity * self:TendedMultiplier())
	end
else
	function Effect:OnMerge(data)
		self.effect = self.effect + (data.effect or 0)
		self.tended_start = data.tended_start
		self.tended_time = data.tended_time
	end
end

function Effect:Send(data)
	if data then
		self.severity = data.severity or self.severity 
		self.effect = data.effect or self.effect 
		self.tended_time = data.tended_time or self.tended_time
		self.tended_start = data.tended_start or self.tended_start
	end

	net.WriteFloat(self.severity)
	net.WriteFloat(self.effect)
	net.WriteUInt(self.tended_start, 32)
	net.WriteUInt(self.tended_time, 32)
end

function Effect:Receive()
	local severity = net.ReadFloat()
	local effect = net.ReadFloat()
	local tended_start = net.ReadUInt(32)
	local tended_time = net.ReadUInt(32)

	self.severity = severity
	self.effect = effect
	self.tended_time = tended_time
	self.tended_start = tended_start
end

function Effect:Get()
	return {self.severity, self.effect, self.tended_time, self.tended_start}
end

function Effect:Set(data)
	self.severity = data[1]
	self.effect = data[2]
	self.tended_time = data[3]
	self.tended_start = data[4]

	self:Update()
end

local saveFields = {
	"severity",
	"effect",
	"tended_time",
	"tended_start",
}
function Effect:Save()
	return saveFields
end

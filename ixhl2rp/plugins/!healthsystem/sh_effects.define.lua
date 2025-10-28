local Hediffs = ix.Hediffs

local TEMPLATE = Hediffs:New("painkiller", "Hediff_Medical")
TEMPLATE.name = "Обезболивающее"
TEMPLATE.color = Color(96, 255, 96)

function TEMPLATE:Tooltip(tooltip)
	local hp = tooltip:AddRow("hp")
	hp:SetText(string.format("%s%%", self:GetSeverity()))
	hp:SizeToContents()
end

local TEMPLATE = Hediffs:New("epinephrine", "Hediff_Medical")
TEMPLATE.name = "Эпинефрин"
TEMPLATE.color = Color(96, 255, 96)

local TEMPLATE = Hediffs:New("gunshot", "Hediff_Injury")
TEMPLATE.name = "Огнестрельная рана"
TEMPLATE.bleedRate = 0.06
TEMPLATE.painPerSeverity = 0.0075
TEMPLATE.color = Color(255, 32, 72)

local TEMPLATE = Hediffs:New("bullet", "Hediff_Injury")
TEMPLATE.name = "Пуля"
TEMPLATE.bleedRate = 0.06
TEMPLATE.painPerSeverity = 0.0125
TEMPLATE.color = Color(255, 100, 100)

local TEMPLATE = Hediffs:New("cut", "Hediff_Injury")
TEMPLATE.name = "Порез"
TEMPLATE.bleedRate = 0.06
TEMPLATE.painPerSeverity = 0.0125
TEMPLATE.color = Color(255, 32, 32)


local TEMPLATE = Hediffs:New("blunt", "Hediff_Injury")
TEMPLATE.name = "Размозжённая рана"
TEMPLATE.bleedRate = 0.01
TEMPLATE.painPerSeverity = 0.0125
TEMPLATE.merge = true
TEMPLATE.color = Color(255, 32, 32)

local TEMPLATE = Hediffs:New("buck", "Hediff_Injury")
TEMPLATE.name = "Шрапнель"
TEMPLATE.bleedRate = 0.06
TEMPLATE.painPerSeverity = 0.0125
TEMPLATE.color = Color(255, 100, 100)

local TEMPLATE = Hediffs:New("impulse_necrosis", "Hediff_Injury")
TEMPLATE.name = "Энергетический некроз"
TEMPLATE.bleedRate = 0
TEMPLATE.painPerSeverity = 0.0125
TEMPLATE.color = Color(128, 64, 255)

local TEMPLATE = Hediffs:New("sparkburn", "Hediff_Injury")
TEMPLATE.name = "Электрический ожог"
TEMPLATE.tended_prefix = "(обработано)"
TEMPLATE.bleedRate = 0
TEMPLATE.painPerSeverity = 0.015
TEMPLATE.color = Color(128, 64, 255)

local TEMPLATE = Hediffs:New("bruise", "Hediff_Injury")
TEMPLATE.name = "Ушиб"
TEMPLATE.bleedRate = 0
TEMPLATE.painPerSeverity = 0.0075
TEMPLATE.color = Color(200, 200, 200)

local TEMPLATE = Hediffs:New("fracture", "Hediff_Injury")
TEMPLATE.name = "Перелом"
TEMPLATE.tended_prefix = "(обработано)"
TEMPLATE.bleedRate = 0
TEMPLATE.max = 1
TEMPLATE.painPerSeverity = 0.0075
TEMPLATE.color = Color(128, 128, 128)
TEMPLATE.isFracture = true

local TEMPLATE = Hediffs:New("acid", "Hediff_Injury")
TEMPLATE.name = "Кислотный ожог"
TEMPLATE.tended_prefix = "(обработано)"
TEMPLATE.bleedRate = 0
TEMPLATE.painPerSeverity = 0.013
TEMPLATE.color = Color(90, 255, 72)

local TEMPLATE = Hediffs:New("scratch", "Hediff_Injury")
TEMPLATE.name = "Рваная рана"
TEMPLATE.bleedRate = 0.06
TEMPLATE.painPerSeverity = 0.0075
TEMPLATE.color = Color(255, 32, 72)

local TEMPLATE = Hediffs:New("shredded", "Hediff_Injury")
TEMPLATE.name = "Взрывная травма"
TEMPLATE.bleedRate = 0.06
TEMPLATE.painPerSeverity = 0.0125
TEMPLATE.color = Color(255, 110, 72)

local TEMPLATE = Hediffs:New("virus1", "Hediff_Disease")
TEMPLATE.name = "Малярия"
TEMPLATE.painPerSeverity = 0
TEMPLATE.color = Color(255, 32, 72)
TEMPLATE.stages = {
	{
		id = 1,
		label = "Неизвестная болезнь",
		visible = false,
		minSeverity = 0
	},
	{
		id = 2,
		label = "Малярия",
		visible = true,
		minSeverity = 0.5
	}
}

function TEMPLATE:OnTick(health)
	self.severity = self.severity + 0.005

	if self.severity > 1 then
		self:Remove()

		self.severity = 0
	end

	net.Start("hediff.update")
		net.WriteUInt(health.character:GetID(), 32)
		net.WriteUInt(self.id, 16)
		self:Send()
	net.Send(health.character:GetPlayer())
end


local TEMPLATE = Hediffs:New("bleeding", "Hediff_BloodLoss")
TEMPLATE.name = "Сильная кровопотеря"
TEMPLATE.painPerSeverity = 0
TEMPLATE.color = Color(255, 32, 72)

function TEMPLATE:OnTick(health)
	local rate = health:GetBleedRate()

	if rate >= 0.1 then
		self.severity = self.severity + ((rate * 0.001) * 4)
	else
		if self.severity > 0 then
			self.severity = self.severity + (-0.00033333333 * 4)
		end
	end

	if self.severity > 1 then
		local client = health:GetPlayer()

		client.KilledBySystem = true
		client:Kill()

		health.bloodloss = nil
		self.severity = 0
	elseif self.severity <= 0 and rate < 0.1 then
		self:Remove()
		health.bloodloss = nil

		return false
	end

	net.Start("hediff.update")
		net.WriteUInt(health.character:GetID(), 32)
		net.WriteUInt(self.id, 16)
		self:Send()
	net.Send(health.character:GetPlayer())
end

function TEMPLATE:Stage()
	if self.severity >= 0.6 then
		return "Сильная кровопотеря"
	elseif self.severity >= 0.45 then
		return "Средняя кровопотеря"
	elseif self.severity >= 0.3 then
		return "Умеренная кровопотеря"
	else
		return "Незначительная кровопотеря"
	end
end


function TEMPLATE:Tooltip(tooltip)

/*
	local hp = tooltip:AddRow("hp")
	hp:SetText(string.format("%s%%", self.severity * 100))
	hp:SizeToContents()*/
end


local TEMPLATE = Hediffs:New("radiation", "Hediff_BloodLoss")
TEMPLATE.name = "Радиация"
TEMPLATE.painPerSeverity = 0
TEMPLATE.color = Color(0, 255, 128)


function TEMPLATE:OnTick(health)
	local client = health.client
	local rate = (client:GetNetVar("radDmg") or 0) * HEALTH_TICK

	if rate > 0 then
		local radResistance, filter = client:GetRadResistance()
	
		if filter and filter:GetFilterQuality() > 0 then
			local value = math.abs(math.max(0.0025, rate * 0.05))

			filter:SetFilterQuality(math.max(filter:GetFilterQuality() - value, 0))
		end

		rate = math.Round(rate + ((rate / 100) * (radResistance - (radResistance * 2))), 2)

		self.severity = self.severity + (rate * 0.001)
	end

	if (client.lastRadLevel or 0) != self.severity then
		hook.Run("OnPlayerRadLevelChanged", client, self.severity * 1000)

		client.lastRadLevel = self.severity
	end

	if self.severity > 1 then
		
	elseif self.severity <= 0 then
		self:Remove()

		return false
	end

	net.Start("hediff.update")
		net.WriteUInt(health.character:GetID(), 32)
		net.WriteUInt(self.id, 16)
		self:Send()
	net.Send(health.character:GetPlayer())
end

function TEMPLATE:Stage()
	if self.severity >= 0.8 then
		return "СМЕРТЕЛЬНОЕ ОБЛУЧЕНИЕ"
	elseif self.severity >= 0.59 then
		return "СРЕДНЕЕ ОБЛУЧЕНИЕ"
	elseif self.severity >= 0.3 then
		return "УМЕРЕННОЕ ОБЛУЧЕНИЕ"
	else
		return "НЕБОЛЬШОЕ ОБЛУЧЕНИЕ"
	end
end

function TEMPLATE:Tooltip(tooltip)
/*
	local hp = tooltip:AddRow("hp")
	hp:SetText(string.format("%s%%", self.severity * 100))
	hp:SizeToContents()*/
end








local TEMPLATE = Hediffs:New("alcohol", "Hediff_Effect")
TEMPLATE.name = "Алкогольное опьянение"
TEMPLATE.color = Color(255, 255, 96)
TEMPLATE.stages = {
	{
		id = 1,
		label = "Слабое алкогольное опьянение",
		visible = false,
		minSeverity = 0
	},
	{
		id = 2,
		label = "Слабое алкогольное опьянение",
		visible = true,
		minSeverity = 49
	},
	{
		id = 3,
		label = "Алкогольное опьянение",
		visible = true,
		minSeverity = 199
	},
	{
		id = 4,
		label = "Отравление алкоголем",
		visible = true,
		minSeverity = 399
	},
	{
		id = 5,
		label = "Отказ печени",
		visible = true,
		minSeverity = 999
	}
}

if SERVER then
	function TEMPLATE:OnTick(health)
		local sync = false
		local mul = self:TendedMultiplier()

		if self.tended_time != -1 then
			local effect = self:GetEffect()
			local ticksNeeded = (self.tended_time / 4)
			local severityPerTick = (effect / ticksNeeded)

			self.severity = self.severity + severityPerTick

			sync = true
		else
			self.severity = self.severity - (self:GetEffect() * 0.01) * 4

			sync = true
		end

		if self.severity <= 0 then
			local client = health:GetPlayer()
			client:SetLocalVar("drunk", 0)

			self:Remove()
			
			return false
		end

		self:Update()

		return sync
	end
else
	function TEMPLATE:GetSeverity()
		return self.severity
	end
end

function TEMPLATE:OnUpdate(newStage)
	local character = ix.char.loaded[self.character]

	if !character then
		return
	end

	local client = character:GetPlayer()
	local stage = self.stages[self.stage]

	if IsValid(client) and newStage then
		if SERVER then
			if stage.id == 2 then
				client:SetLocalVar("drunk", 0.5)
			elseif stage.id == 3 then
				client:SetLocalVar("drunk", 1)
			elseif stage.id == 5 then
				client.KilledBySystem = true
				client:Kill()
			end
		else
			if client == LocalPlayer() then
				if stage.id == 2 then
					ix.chat.Send(client, "it", "Вы ощущаете себя немного навеселе!")
				elseif stage.id == 3 then
					ix.chat.Send(client, "it", "Алкоголь сильно ударяет вам в голову. Вы расслабляетесь.")
				elseif stage.id == 4 then
					ix.chat.Send(client, "it", "Неожиданно, вы почувствовали резкую боль в области почки... Может, достаточно алкоголя на сегодня?")
				end
			end
		end
	end
end

function TEMPLATE:Stage()
	if self.stages and self.stage then
		return self.stages[self.stage].label
	end

	return self.name
end


local TEMPLATE = Hediffs:New("oxygen", "Hediff")
TEMPLATE.name = "Кислородное голодание"
TEMPLATE.painPerSeverity = 1.2
TEMPLATE.hasPain = true
TEMPLATE.color = Color(72, 32, 255)

function TEMPLATE:OnTick(health)
	local client = health:GetPlayer()
	local rate = 0

	if IsValid(client) then
		if client:GetLocalVar("oxy", 100) <= 0 then
			rate = 1
		end
	end

	if rate > 0 then
		self.severity = math.min(self.severity + 0.265, 2)
	else
		if self.severity > 0 then
			self.severity = self.severity - 0.1
		end
	end

	if self.severity <= 0 then
		self:Remove()
		health.oxyloss = nil

		return false
	end

	health:OnUpdateDiffs()

	net.Start("hediff.update")
		net.WriteUInt(health.character:GetID(), 32)
		net.WriteUInt(self.id, 16)
		self:Send()
	net.Send(health.character:GetPlayer())
end

function TEMPLATE:Stage()
	if self.severity >= 0.9 then
		return "Асфиксия"
	elseif self.severity >= 0.6 then
		return "Острая нехватка кислорода"
	elseif self.severity >= 0.3 then
		return "Нехватка кислорода"
	else
		return "Задыхается"
	end
end


function TEMPLATE:Tooltip(tooltip)
end




local TEMPLATE = Hediffs:New("pornbuff", "Hediff_Effect")
TEMPLATE.name = "Хорошее настроение"
TEMPLATE.color = Color(255, 255, 96)

function TEMPLATE:TendedMultiplier()
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
	function TEMPLATE:OnTick(health)
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
	function TEMPLATE:GetSeverity()
		return (self.severity * self:TendedMultiplier())
	end
end

function TEMPLATE:OnAdded(health)
	if SERVER then
		return
	end
	
	local character = ix.char.loaded[self.character]

	if !character then
		return
	end

	local client = character:GetPlayer()

	if IsValid(client) and client == LocalPlayer() then
		ix.chat.Send(client, "it", "Вы ощущаете себя немного навеселе!")
	end
end


local TEMPLATE = Hediffs:New("sparkshock", "Hediff")
TEMPLATE.tended_start = -1
TEMPLATE.tended_time = -1
TEMPLATE.name = "Электрический шок"
TEMPLATE.painPerSeverity = 0.008
TEMPLATE.hasPain = true
TEMPLATE.isMedical = true
TEMPLATE.color = Color(128, 64, 255)

function TEMPLATE:TendedMultiplier()
	if self.tended_time != -1 then
		local time = (self.tended_start + self.tended_time) - os.time()

		if time <= 0 then
			time = 0
		end
		
		local delta = time / self.tended_time

		return math.Clamp(delta, 0, 1)
	end
	
	return 0
end

function TEMPLATE:OnTick(health)
	local mul = self:TendedMultiplier()
	local severity = (self:GetSeverity() * mul)

	if severity <= 0 then
		self:Remove()
		
		return false
	end

	health:OnUpdateDiffs()

	net.Start("hediff.update")
		net.WriteUInt(health.character:GetID(), 32)
		net.WriteUInt(self.id, 16)
		self:Send()
	net.Send(health.character:GetPlayer())
end

if CLIENT then
	function TEMPLATE:GetSeverity()
		return (self.severity * self:TendedMultiplier())
	end
end


function TEMPLATE:Send(data)
	if data then
		self.severity = data.severity or self.severity 
		self.tended_time = data.tended_time or self.tended_time
		self.tended_start = data.tended_start or self.tended_start
	end

	net.WriteFloat(self.severity)
	net.WriteUInt(self.tended_start, 32)
	net.WriteUInt(self.tended_time, 32)
end

function TEMPLATE:Receive()
	local severity = net.ReadFloat()
	local tended_start = net.ReadUInt(32)
	local tended_time = net.ReadUInt(32)

	self.severity = severity
	self.tended_time = tended_time
	self.tended_start = tended_start
end

function TEMPLATE:Get()
	return {self.severity, self.tended_time, self.tended_start}
end

function TEMPLATE:Set(data)
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
function TEMPLATE:Save()
	return saveFields
end
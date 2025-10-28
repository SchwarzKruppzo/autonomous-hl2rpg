local GENETIC = class "GeneticStat"

local BODY_SHAPES = {
	"shape1_1",
	"shape1_2",
	"shape1_3",
	"shape1_4",
	"shape1_5",
	"shape2_1",
	"shape2_2",
	"shape2_3",
	"shape2_4",
	"shape2_5",
	"shape3_1",
	"shape3_2",
	"shape3_3",
	"shape3_4",
	"shape3_5",
	"shape4_1",
	"shape4_2",
	"shape4_3",
	"shape4_4",
	"shape4_5",
}	-- 20

local EYE_COLORS = {
	{"eyes1", Color(15, 178, 242)},
	{"eyes2", Color(67, 117, 18)},
	{"eyes3", Color(128, 72, 28)},
	{"eyes4", Color(189, 149, 102)},
	{"eyes5", Color(232, 162, 21)},
	{"eyes6", Color(128, 128, 128)}
}

function GENETIC:__tostring() return "genetic["..tostring(self.character).."]" end
function GENETIC:GetCharacter() return self.character end
function GENETIC:GetPlayer()
	if !self.client then
		self.client = self.character and self.character:GetPlayer() or nil
	end
	
	return self.client
end

function GENETIC:Init(character, var, data)
	local factionID = character:GetFaction()
	local faction = ix.faction.indices[factionID]

	self.var = var
	self.character = character

	self.shape = 1
	self.height = 180
	self.age = 20
	self.eyeColor = 1

	self.isAgeSelector = false

	if faction.ageSelector then
		self.isAgeSelector = true
	end

	self.cachedSave = nil
end

function GENETIC:Load(vars)
	local isDefault = (vars.genetic == nil)
	local genetics = istable(vars.genetic) and vars.genetic or util.JSONToTable(vars.genetic or "[]")

	self.client = nil

	if !isDefault then
		self.shape = tonumber(genetics[1] or self.shape)
		self.height = tonumber(genetics[2] or self.height)
		self.age = tonumber(genetics[3] or self.age)
		self.eyeColor = tonumber(genetics[4] or self.eyeColor)

		self.cachedSave = nil
	end
end

function GENETIC:GetDesc(randomize)
	if !self.cachedDesc or (self.cachedDescTime and (CurTime() >= self.cachedDescTime)) then
		local factionID = self.character:GetFaction()
		local faction = ix.faction.indices[factionID]

		local shape = L(BODY_SHAPES[math.Clamp(self.shape, 1, #BODY_SHAPES)])
		local height = tostring(math.Clamp(self.height, 160, 190)).." СМ"
		local age = ""
		local eyeColor = ""

		if !self.isAgeSelector then
			local current = math.Clamp(self.age, 18, 60)

			if randomize then
				local minCurrentAge = math.Clamp(current - math.random(1, 2), 18, 60)
				local maxCurrentAge = math.Clamp(current + math.random(1, 2), 18, 60)

				age = tostring(minCurrentAge) .. " - " .. tostring(maxCurrentAge)
			else
				age = current
			end
		else
			age = L(faction.ageSelector[math.Clamp(self.age, 1, #faction.ageSelector)])
		end

		if faction.eyeColors then
			eyeColor = L(faction.eyeColors[math.Clamp(self.eyeColor, 1, #faction.eyeColors)][1])
		else
			eyeColor = L(EYE_COLORS[math.Clamp(self.eyeColor, 1, #EYE_COLORS)][1])
		end

		self.cachedDescTime = CurTime() + 2
		self.cachedDesc = L("genetic_desc", shape:utf8upper(), height, age, eyeColor:utf8upper())
	end
	
	return self.cachedDesc or ""
end

function GENETIC:ToSaveable()
	if !self.cachedSave then
		self.cachedSave = {
			self.shape,
			self.height,
			self.age,
			self.eyeColor,
		}
	end

	return self.cachedSave
end

if SERVER then
	function GENETIC:NetWrite()
		net.WriteUInt(self.shape, 5)
		net.WriteUInt(self.height, 8)
		net.WriteUInt(self.age, self.isAgeSelector and 4 or 8)
		net.WriteUInt(self.eyeColor, 3)
	end

	function GENETIC:Sync(receiver, broadcast)
		net.Start("CharacterVarChanged")
			net.WriteUInt(self.character:GetID(), 32)
			net.WriteCharVar(self.character, self.var)
		if receiver then
			net.Send(receiver)
		else
			net.Broadcast()
		end
	end
else
	function GENETIC:NetRead()
		local shapeType = net.ReadUInt(5)
		local height = net.ReadUInt(8)
		local age = net.ReadUInt(self.isAgeSelector and 4 or 8)
		local eyeColor = net.ReadUInt(3)

		self.shape = shapeType
		self.height = height
		self.age = age
		self.eyeColor = eyeColor

		self.cachedDesc = nil
	end
end

ix.meta.GeneticStat = GENETIC


local PLUGIN = PLUGIN

PLUGIN.name = "Skills and Attributes"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

ix.util.Include("sh_config.lua")
ix.util.Include("sh_commands.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")

if (SERVER) then
	//function PLUGIN:GetPlayerPunchDamage(client, damage, context)
	//	if (client:GetCharacter()) then
			-- Add to the total fist damage.
	//		context.damage = context.damage + (client:GetCharacter():GetAttribute("st", 0) * ix.config.Get("strengthMultiplier"))
	//	end
	//end

	//function PLUGIN:PlayerThrowPunch(client, trace)
		//if (client:GetCharacter() and IsValid(trace.Entity) and trace.Entity:IsPlayer()) then
		//	client:GetCharacter():UpdateAttrib("st", 0.001)
		//end
	//end
end

-- Configuration for the plugin
ix.config.Add("strengthMultiplier", 0.3, "The strength multiplier scale", nil, {
	data = {min = 0, max = 1.0, decimals = 1},
	category = "Strength"
})


local function CalculateWidestName(tbl)
	local highest = 0
	do
		local highs = {}
		for k, v in pairs(tbl) do
			surface.SetFont("ixAttributesFont")
			local w1 = surface.GetTextSize(L(v.name))
			highs[#highs+1] = w1

			highest = math.max(unpack(highs))
		end
	end

	return highest
end

do
	local skillsUI
	ix.char.RegisterVar("specials", {
		field = "specials",
		fieldType = ix.type.text,
		default = {},
		category = "skills",
		isLocal = true,
		Net = {
			Transmit = ix.transmit.owner
		},
		OnDisplay = function(self, container, payload)
			local faction = ix.faction.indices[payload.faction]
			local pointsmax = hook.Run("GetDefaultSpecialPoints", LocalPlayer(), payload)

			if faction.defaultLevel then
				pointsmax = 5 + (5 * math.min(faction.defaultLevel, 5)) + (1 * math.max(faction.defaultLevel - 5, 0))
			end

			if (pointsmax < 1) then
				return
			end

			local stats = container:Add("ixStatsPanel")
			stats:Dock(TOP)

			local y
			local total = 0

			payload.specials = {}

			-- total spendable attribute points
			local totalBar = stats:Add("ixAttributeBar")
			totalBar:SetMax(pointsmax)
			totalBar:SetValue(pointsmax)
			totalBar:Dock(TOP)
			totalBar:DockMargin(2, 2, 2, 2)
			totalBar:SetText(L("attribPointsLeft"))
			totalBar:SetReadOnly(true)
			totalBar:SetColor(Color(20, 120, 20, 255))

			y = totalBar:GetTall() + 4

			stats.attributes = stats:Add("ixStatsPanelCategory")
			stats.attributes:SetText(L("attributes"):upper())
			stats.attributes:Dock(LEFT)

			stats.skills = stats:Add("ixStatsPanelCategory")
			stats.skills:SetText(L("skills"):upper())
			stats.skills:Dock(FILL)
			stats.skills:DockMargin(20, 0, 0, 0)

			local w1 = CalculateWidestName(ix.specials.list)
			local w2 = CalculateWidestName(ix.skills.list)

			stats.attributes.offset = w1 * 1.75
			stats.attributes:SetWide(w1 * 2.75)

			for k, v in SortedPairsByMemberValue(ix.specials.list, "weight") do
				payload.specials[k] = 1

				local bar = stats.attributes:Add("ixStatBar")
				bar:Dock(TOP)

				if (!bFirst) then
					bar:DockMargin(4, 1, 0, 0)
				else
					bar:DockMargin(4, 0, 0, 0)
					bFirst = false
				end

				bar:SetValue(payload.specials[k])

				local maximum = v.maxValue or 10
				bar:SetMax(maximum)
				if (v.noStartBonus) then
					bar:SetReadOnly()
				end
				bar:SetText(L(v.name), Format("%i/%i", payload.specials[k], maximum))
				bar:SetDesc(L(v.description))
				bar.OnChanged = function(this, difference)
					if ((payload.specials[k] + difference) <= 0) then
						return false
					end

					if ((total + difference) > pointsmax) then
						return false
					end

					total = total + difference
					payload.specials[k] = payload.specials[k] + difference

					this:SetText(L(v.name), Format("%i/%i", payload.specials[k], maximum))
					totalBar:SetValue(totalBar.value - difference)
				end
			end

			stats.attributes:SizeToContents()

			stats.skills.offset = w2 * 1.5
			stats.skills:SetWide(w2 * 2)

			local bFirst = true

			for i = 1, 6 do
				stats.skills.categories = stats.skills.categories or {}
				stats.skills.categories[i] = stats.skills:Add("ixStatsPanel")
				stats.skills.categories[i].offset = stats.skills.offset
				stats.skills.categories[i]:Dock(TOP)
				stats.skills.categories[i]:DockMargin(0, 0, 0, 8)
			end

			local categories = {}
			for k, v in pairs(ix.skills.list) do
				categories[v.category] = categories[v.category] or {}
				categories[v.category][k] = L(v.name)
			end

			stats.skills.bars = {}

			for k, v in pairs(categories) do
				for z, x in SortedPairs(v) do
					v = ix.skills.list[z]
					local bar = stats.skills.categories[k]:Add("ixStatBar")
					bar:Dock(TOP)

					if (!bFirst) then
						bar:DockMargin(4, 1, 4, 0)
					else
						bar:DockMargin(4, 0, 4, 0)
						bFirst = false
					end

					local value = v:GetInitial(payload.specials, payload) or 0
					if faction.startSkills and faction.startSkills[z] then
						value = faction.startSkills[z]
					end

					bar:SetValue(value)

					local maximum = v:GetMaximum(nil, nil, 0)
					bar:SetMax(maximum)
					bar:SetReadOnly()
					bar:SetText(L(v.name), Format("%i / %i", value, maximum))
					bar:SetDesc(L(v.description))

					stats.skills.bars[z] = bar
				end
			end

			local y = 0
			for i = 1, 6 do
				stats.skills.categories[i]:SizeToContents()

				local _, top, _, bottom = stats.skills.categories[i]:GetDockMargin()
				y = y + stats.skills.categories[i]:GetTall() + top + bottom
			end

			if (stats.attributes:GetTall() < (y + 4)) then
				stats.attributes:SetTall(0)
			end

			stats.skills:SetTall(stats.skills:GetTall() + y + 4)

			stats:SizeToContents()
			return stats
		end,
		OnValidate = function(self, value, data, client)
			if (value != nil) then
				if (istable(value)) then
					local faction = ix.faction.indices[data.faction]
					local count = 0

					for _, v in pairs(value) do
						count = count + v
					end

					local defaulSpecialPoints = hook.Run("GetDefaultSpecialPoints", client, data)
/*
					if faction.defaultLevel then
						defaulSpecialPoints = 5 + (5 * math.min(faction.defaultLevel, 5)) + (1 * math.max(faction.defaultLevel - 5, 0))
					end*/

					if (count < defaulSpecialPoints) then
						return false, "Вы должны потратить все очки SPECIAL!"
					end

					if (count > defaulSpecialPoints) then
						return false, "unknownError"
					end

					return value
				else
					return false, "unknownError"
				end
			end
		end,
		ShouldDisplay = function(self, container, payload)
			return !table.IsEmpty(ix.specials.list)
		end
	})

	ix.char.RegisterVar("skills", {
		field = "skills",
		fieldType = ix.type.text,
		default = {},
		category = "skills",
		isLocal = true,
		Net = {
			Transmit = ix.transmit.owner
		},
		OnDisplay = function(self, container, payload)
		end,
		OnValidate = function(self, value, data, client)
			if data.specials then
				local faction = ix.faction.indices[data.faction]

				data.skills = {}

				for k, v in pairs(ix.skills.list) do
					data.skills[k] = faction.startSkills and {faction.startSkills[k] or 0, 0} or v:OnDefault()
				end
			end
		end,
		OnRestore = function(self, value)
			if istable(value) then
				for k, v in pairs(ix.skills.list) do
					value[k] = value[k] or v:OnDefault()
				end

				return value
			end
		end
	})

	ix.char.RegisterVar("skillPoints", {
		field = "skillpoints",
		fieldType = ix.type.number,
		default = 0,
		isLocal = true,
		Net = {
			Transmit = ix.transmit.owner,
			Write = function(character, value)
				net.WriteInt(value, 10)
			end,
			Read = function(character)
				return net.ReadInt(10)
			end
		},
		bNoDisplay = true
	})

	ix.char.RegisterVar("skillMemory", {
		field = "memory",
		fieldType = ix.type.number,
		default = 750,
		isLocal = true,
		Net = {
			Transmit = ix.transmit.owner,
			Write = function(character, value)
				net.WriteUInt(value, 12)
			end,
			Read = function(character)
				return net.ReadUInt(12)
			end
		},
		bNoDisplay = true
	})
end

function PLUGIN:GetDefaultSpecialPoints(client, payload)
	local levelSystem = ix.plugin.list["!!levelsystem"]

	return levelSystem.PointsTable and levelSystem.PointsTable[1] or 0
end

function PLUGIN:CharacterSkillUpdated(client, character, skillID, isIncreased)
	local skill = (ix.skills.list[skillID] or {})

	ix.chat.Send(nil, "level", "", nil, {client}, {
		t = (isIncreased and 2 or 4),
		skill = skillID,
		value = math.floor(character:GetSkill(skillID))
	})

	if skill.OnLevelUp then
		skill:OnLevelUp(client, character)
	end
end

local successColor = Color(77, 176, 77)
ix.chat.Register("skillroll", {
	format = "** [%s %s] %s (%s).",
	color = Color(176, 77, 77),
	CanHear = ix.config.Get("chatRange", 280),
	deadCanChat = true,
	OnChatAdd = function(self, speaker, text, bAnonymous, data)
		chat.AddText(data.success and successColor or self.color, string.format(self.format,
			L((ix.skills.list[data.skill] or {}).name), math.Round(data.check), L("rollOutput", speaker:GetName(), text, 10), data.success and L"skillSuccess" or L"skillFail"
		))
	end
})

ix.chat.Register("statroll", {
	format = "** [%s %s] %s (%s).",
	color = Color(176, 77, 77),
	CanHear = ix.config.Get("chatRange", 280),
	deadCanChat = true,
	OnChatAdd = function(self, speaker, text, bAnonymous, data)
		chat.AddText(data.success and successColor or self.color, string.format(self.format,
			L((ix.specials.list[data.stat] or {}).name), math.Round(data.check), L("rollOutput", speaker:GetName(), text, 10), data.success and L"skillSuccess" or L"skillFail"
		))
	end
})

ix.specials.LoadFromDir(PLUGIN.folder.."/specials")
ix.skills.LoadFromDir(PLUGIN.folder.."/skills")

function PLUGIN:DoPluginIncludes(path)
	ix.specials.LoadFromDir(path.."/specials")
	ix.skills.LoadFromDir(path.."/skills")
end

function PLUGIN:CharacterMaxStamina(character)
	local endurance = character:GetSpecial("en")
	local perPoint = (0.5 * endurance)
	local PERK = character:HasSpecialLevel("en", 5) and 30 or 0

	if PERK > 0 then -- DO PERK SYSTEM WITH CACHING, not this mess
		local LVL25 = character:HasSpecialLevel("en", 25) and 15 or 0
		PERK = PERK + LVL25

		if LVL25 > 0 then
			local LVL50 = character:HasSpecialLevel("en", 50) and 25 or 0
			PERK = PERK + LVL50

			if LVL50 > 0 then
				local LVL75 = character:HasSpecialLevel("en", 75) and 15 or 0
				PERK = PERK + LVL75
			end
		end
	end

	return 40 + PERK + perPoint
end

-- Athletics Skill Related code
local function CalcAthleticsSpeed(athletics)
	return 1 + (athletics * 0.1) * 0.25
end

local function CalcAthleticsFatigue(athletics)
	return (athletics * 0.1) * 0.5
end

function PLUGIN:AdjustStaminaRegeneration(client, offset)
	local character = client:GetCharacter()
	local food, water = character:GetHunger(), character:GetThirst()

	local factor = math.min(math.Remap(((food + water) / 2), 0, 50, 0.25, 1), 0.25, 1)
	local isCrouch = client:Crouching() or client:IsProne()

	return (isCrouch and ix.config.Get("staminaCrouchRegeneration", 2) or ix.config.Get("staminaRegeneration", 1.75)) * factor
end

function PLUGIN:AdjustStaminaOffsetRunning(client, offset)
	local character = client:GetCharacter()

	return offset + CalcAthleticsFatigue(character:GetSkillModified("athletics"))
end

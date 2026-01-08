local PLUGIN = PLUGIN

PLUGIN.name = "Level System"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

PLUGIN.maxLevel = 100

ix.char.RegisterVar("level", {
	field = "level",
	fieldType = ix.type.number,
	default = 1,
	isLocal = false,
	Net = {
		Transmit = ix.transmit.all,
		Write = function(character, value)
			net.WriteUInt(value, 7)
		end,
		Read = function(character)
			return net.ReadUInt(7)
		end
	},
	bNoDisplay = true
})

ix.char.RegisterVar("levelXP", {
	field = "levelXP",
	fieldType = ix.type.number,
	default = 0,
	isLocal = true,
	Net = {
		Transmit = ix.transmit.owner
	},
	bNoDisplay = true
})

ix.chat.Register("level", {
	OnCanHear = function(self, speaker, listener)
		return true
	end,
	CanSay = function(self, speaker)
		return !IsValid(speaker)
	end,
	OnChatAdd = function(self, speaker, text, bAnonymous, data)
		if data.t == 1 then
			chat.AddText(color_white, L("chat.level.increased", LocalPlayer():GetCharacter():GetLevel()))
		elseif data.t == 2 then
			local name = L((ix.skills.list[data.skill] or {}).name) or "Unknown"

			chat.AddText(color_white, L("chat.skill.increased", name, data.value))
		elseif data.t == 3 then
			chat.AddText(color_white, L("chat.level.decreased", LocalPlayer():GetCharacter():GetLevel()))
		elseif data.t == 4 then
			local name = L((ix.skills.list[data.skill] or {}).name) or "Unknown"

			chat.AddText(color_white, L("chat.skill.decreased", name, data.value))
		end
	end
})

PLUGIN.XPTable = PLUGIN.XPTable or ix.util.Include("sh_data.levelxp.lua")
PLUGIN.PointsTable = PLUGIN.PointsTable or ix.util.Include("sh_data.levelpoints.lua")

function PLUGIN:GetRequiredLevelXP(currentLevel)
	return PLUGIN.XPTable[currentLevel] or 0
end

function PLUGIN:GetPointsAtLevel(currentLevel)
	return PLUGIN.PointsTable[currentLevel] or 0
end

ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_plugin.lua")

ix.command.Add("Roll", {
	description = "@cmdRoll",
	arguments = ix.type.number,
	OnRun = function(self, client, maximum)
		maximum = math.Clamp(maximum or 100, 0, 1000000)

		local value = math.random(0, maximum)

		ix.chat.Send(client, "roll", tostring(value), nil, nil, {
			max = maximum
		})

		ix.log.Add(client, "roll", value, maximum)
	end
})

ix.command.Add("Dice", {
	description = "@cmd.dice",
	arguments = {
		ix.type.number,
		ix.type.number
	},
	OnRun = function(self, client, dices, sides)
		dices = dices or 1
        sides = sides or 20

        dices = math.min(dices, 20)

        local max = 0
        local totalValue = 0
        for i = 1, dices do
        	max = max + sides
            totalValue = totalValue + math.random(1, sides)
        end

		ix.chat.Send(client, "dice", tostring(totalValue), nil, nil, {
			dices = dices,
			sides = sides,
			max = max
		})

		ix.log.Add(client, "dice", totalValue, dices, sides, max)
	end
})

if SERVER then
	ix.log.AddType("dice", function(client, totalValue, dices, sides, max)
		return string.format("%s rolled %d out of %d (%dd%d).", client:Name(), totalValue, max, dices, sides)
	end)
end

ix.command.Add("CharSetLevel", {
	description = "",
	privilege = "Manage Character Levels",
	adminOnly = true,
	arguments = {
		ix.type.character,
		ix.type.number
	},
	OnRun = function(self, client, target, targetValue)
		local lastLVL = target:GetLevel()
		targetValue = math.Clamp(targetValue, 1, PLUGIN.maxLevel)

		target:SetLevel(targetValue)

		local points = 0
		for i = lastLVL, targetValue, (targetValue > lastLVL and 1 or -1) do
			if i == targetValue and (targetValue < lastLVL) then continue end
			if i == 1 then continue end

			points = points + PLUGIN:GetPointsAtLevel(i)
		end
		points = (targetValue < lastLVL) and -points or points
		target:SetSkillPoints(target:GetSkillPoints() + points)

		if targetValue > lastLVL then
			target:SetData("levelup", true)
			ix.chat.Send(nil, "level", "", nil, {target:GetPlayer()}, {
				t = 1,
			})
		else
			ix.chat.Send(nil, "level", "", nil, {target:GetPlayer()}, {
				t = 3,
			})

			target:SetData("levelup", true)
		end

		return "@cmd.notify.lvlChanged"
	end
})

ix.command.Add("CharAddLevel", {
	description = "",
	privilege = "Manage Character Levels",
	adminOnly = true,
	arguments = {
		ix.type.character,
		ix.type.number
	},
	OnRun = function(self, client, target, targetValue)
		local lastLVL = target:GetLevel()
		targetValue = math.Clamp(lastLVL + targetValue, 1, PLUGIN.maxLevel)

		target:SetLevel(targetValue)

		local points = 0
		for i = lastLVL, targetValue, (targetValue > lastLVL and 1 or -1) do
			if i == targetValue and (targetValue < lastLVL) then continue end
			if i == 1 then continue end

			points = points + PLUGIN:GetPointsAtLevel(i)
		end
		points = (targetValue < lastLVL) and -points or points
		target:SetSkillPoints(target:GetSkillPoints() + points)

		if targetValue > lastLVL then
			target:SetData("levelup", true)
			ix.chat.Send(nil, "level", "", nil, {target:GetPlayer()}, {
				t = 1,
			})
		else
			ix.chat.Send(nil, "level", "", nil, {target:GetPlayer()}, {
				t = 3,
			})
		end

		return "@cmd.notify.lvlAdded"
	end
})

ix.command.Add("CharAddLevelXP", {
	description = "",
	privilege = "Manage Character Levels",
	adminOnly = true,
	arguments = {
		ix.type.character,
		ix.type.number
	},
	OnRun = function(self, client, target, xp)
		target:AddLevelXP(xp)

		return "@cmd.notify.lvlAddedXP"
	end
})
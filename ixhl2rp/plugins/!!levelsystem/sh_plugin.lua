local PLUGIN = PLUGIN

PLUGIN.name = "Basic Level System"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

PLUGIN.maxLevel = 10

ix.char.RegisterVar("level", {
	field = "level",
	fieldType = ix.type.number,
	default = 1,
	isLocal = false,
	Net = {
		Transmit = ix.transmit.all,
		Write = function(character, value)
			net.WriteUInt(value, 4)
		end,
		Read = function(character)
			return net.ReadUInt(4)
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
			chat.AddText(color_white, string.format("Ваш уровень повышен до %s! Введите /lvl, чтобы распределить новые очки.", LocalPlayer():GetCharacter():GetLevel()))
		elseif data.t == 2 then
			local name = L((ix.skills.list[data.skill] or {}).name) or "Unknown"

			chat.AddText(color_white, string.format("Ваш навык %s повышен до %s!", name, data.value))
		elseif data.t == 3 then
			chat.AddText(color_white, string.format("Ваш уровень понижен до %s!", LocalPlayer():GetCharacter():GetLevel()))
		elseif data.t == 4 then
			local name = L((ix.skills.list[data.skill] or {}).name) or "Unknown"

			chat.AddText(color_white, string.format("Ваш навык %s понижен до %s!", name, data.value))
		end
	end
})

function PLUGIN:GetRequiredLevelXP(currentLevel)
	return 50 * (currentLevel - 1) ^ 2.125 + (75 + (currentLevel * 50))
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
	description = "Бросок кубика с заданными параметрами.",
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
		targetValue = math.Clamp(targetValue, 1, 10)

		target:SetLevel(targetValue)

		if targetValue > lastLVL then
			target:SetData("levelup", true)
			ix.chat.Send(nil, "level", "", nil, {target:GetPlayer()}, {
				t = 1,
			})
		else
			ix.chat.Send(nil, "level", "", nil, {target:GetPlayer()}, {
				t = 3,
			})

			for k, v in pairs(ix.specials.list) do
				target:SetSpecial(k, 1)
			end

			target:SetData("levelup", true)

			timer.Simple(0.1, function()
				net.Start("ixLevelUp")
				net.Send(target:GetPlayer())
			end)
		end

		return "Вы успешно изменили уровень персонажа."
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

		return "Вы успешно добавили уровни персонажу."
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

		return "Вы успешно добавили опыт персонажу."
	end
})
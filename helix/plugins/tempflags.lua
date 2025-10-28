
local PLUGIN = PLUGIN

PLUGIN.name = "Temporary Flags"
PLUGIN.author = "Gr4Ss"
PLUGIN.description = "Allows temporary flags to be given to characters or players. Based on SleepyMode's Player Flags plugin."

CAMI.RegisterPrivilege({
	Name = "Helix - Manage Temp Flags",
	MinAccess = "admin"
})

ix.Net:AddPlayerVar("tempFlags", true, nil, ix.Net.Type.Table)

ix.lang.AddTable("english", {
	cmdCharGiveTempFlags = "Give temporary flags to a character. Time specified in minutes.",
	cmdCharExtendTempFlags = "Extend (or reduce) a character's current temporary flags. They will expire after the given amount of time.",
	flagTempGiveTitle = "Give Temporary Flags",
	flagTempGive = "%s has given %s '%s' flags for %d minutes.",
	flagAlreadyGiven = "%s already has the '%s' flags, or these flags do not exist.",
	cmdCharTakeTempFlags = "Take temporary flags from a character.",
	flagAlreadyTaken = "%s does not have the '%s' flags.",
	flagTempTake = "%s has taken the '%s' temporary flags from %s.",
	cmdCharClearTempFlag = "Take all temporary flags from a character.",
	flagNoClear = "%s does not have any temporary flags.",
	flagExpired = "%s's temporary '%s' flags have expired.",
	flagExpireWarn = "Your temporary '%s' flags will expire in 5 minutes."
})

ix.lang.AddTable("russian", {
	cmdCharGiveTempFlags = "Выдать персонажу временные флаги. Время указано в минутах.",
	cmdCharExtendTempFlags = "Продлить (или сократить) текущие временные флаги персонажа. Они пропадут через отведенное количество времени.",
	flagTempGiveTitle = "Выдать временные флаги",
	flagTempGive = "%s выдал %s '%s' флаги на %d минут.",
	flagAlreadyGiven = "%s уже имеет флаги '%s', или эти флаги несуществуют.",
	cmdCharTakeTempFlags = "Забрать временные флаги у персонажа.",
	flagAlreadyTaken = "%s не имеет '%s' флагов.",
	flagTempTake = "%s забрал '%s' временные флаги у %s.",
	cmdCharClearTempFlag = "Забрать все временные флаги у персонажа.",
	flagNoClear = "%s не имеет никаких временных флагов.",
	flagExpired = "Временные флаги персонажа %s '%s' истекли.",
	flagExpireWarn = "Ваши временные '%s' флаги истекут через 5 минут."
})

ix.config.Add("TempFlagsRemoveOnCharSwap", true, "Should all temporary flags be removed when a player changes character.", nil, {category = "administration"})

function PLUGIN:CharacterHasFlags(character, flags)
	local client = character:GetPlayer()
	if (!IsValid(client)) then return end

	local tempFlags = client:GetLocalVar("tempFlags")
	if (!tempFlags) then return end

	for i = 1, #flags do
		if (tempFlags[flags[i]] and tempFlags[flags[i]] > os.time()) then
			return true
		end
	end
end

if (SERVER) then
	function PLUGIN:InitializedPlugins()
		timer.Create("ixTempFlags", 61, 0, function()
			local time = os.time()
			local players = player.GetAll()
			for _, client in ipairs(players) do
				local flags = client:GetLocalVar("tempFlags")
				if (!flags) then continue end

				local expired = ""
				local warn = ""
				for flag, expire in pairs(flags) do
					if (expire < time) then
						flags[flag] = nil
						expired = expired..flag

						local info = ix.flag.list[flag]
						if (!info or !info.callback or client:GetCharacter():HasFlags(flag)) then continue end

						info.callback(client, false)
					elseif (expire - 300 >= time and expire - 361 < time) then
						warn = warn..flag
					end
				end

				if (warn != "") then
					client:NotifyLocalized("flagExpireWarn", warn)
				end

				if (expired == "") then continue end

				for _, v in ipairs(players) do
					if (CAMI.PlayerHasAccess(v, "Helix - Manage Temp Flags") or v == client) then
						v:NotifyLocalized("flagExpired", client:Name(), expired)
					end
				end

				if (table.IsEmpty(flags)) then
					client:SetLocalVar("tempFlags", nil)
				else
					client:SetLocalVar("tempFlags", flags)
				end
			end
		end)
	end
end

function PLUGIN:PostPlayerLoadout(client)
	if (ix.config.Get("TempFlagsRemoveOnCharSwap")) then
		client:SetLocalVar("tempFlags", nil)
		return
	end

	local tempFlags = client:GetLocalVar("tempFlags", {})

	for flag in pairs(tempFlags) do
		local info = ix.flag.list[flag]
		if (info and info.callback) then
			info.callback(client, true)
		end
	end
end

ix.command.Add("CharGiveTempFlags", {
	description = "@cmdCharGiveTempFlags",
	privilege = "Manage Temp Flags",
	arguments = {
		ix.type.player,
		ix.type.string,
		ix.type.number
	},
	argumentNames = {"target", "flags", "time (10 to 120)"},
	OnRun = function(self, client, target, toGive, time)
		local flags = target:GetLocalVar("tempFlags", {})
		local newTime = os.time() + math.Clamp(math.floor(time), 10, 120) * 60
		local character = target:GetCharacter()
		local given = ""
		for i = 1, #toGive do
			local flag = toGive[i]
			local info = ix.flag.list[flag]
			if (!info) then continue end
			if (!flags[flag] and character:HasFlags(flag)) then continue end

			flags[flag] = newTime
			given = given..flag

			if (info.callback) then
				info.callback(target, true)
			end
		end

		if (given == "") then
			client:NotifyLocalized("flagAlreadyGiven", target:Name(), toGive)
			return
		end

		target:SetLocalVar("tempFlags", flags)

		for _, v in ipairs(player.GetAll()) do
			if (self:OnCheckAccess(v) or v == target) then
				v:NotifyLocalized("flagTempGive", client:Name(), target:Name(), given, math.Clamp(math.floor(time), 10, 120))
			end
		end
	end
})

ix.command.Add("CharExtendTempFlags", {
	description = "@cmdCharExtendTempFlags",
	privilege = "Manage Temp Flags",
	arguments = {
		ix.type.player,
		ix.type.number
	},
	argumentNames = {"target", "time (10 to 120)"},
	OnRun = function(self, client, target, time)
		local flags = target:GetLocalVar("tempFlags", {})
		local newTime = os.time() + math.Clamp(math.floor(time), 10, 120) * 60
		local given = ""
		for flag in pairs(flags) do
			flags[flag] = newTime
			given = given..flag
		end

		if (given == "") then
			client:NotifyLocalized("flagNoClear", target:Name())
			return
		end

		target:SetLocalVar("tempFlags", flags)

		for _, v in ipairs(player.GetAll()) do
			if (self:OnCheckAccess(v) or v == target) then
				v:NotifyLocalized("flagTempGive", client:Name(), target:Name(), given, math.Clamp(math.floor(time), 10, 120))
			end
		end
	end
})

ix.command.Add("CharTakeTempFlag", {
	description = "@cmdCharTakeTempFlags",
	privilege = "Manage Temp Flags",
	arguments = {
		ix.type.player,
		ix.type.string
	},
	OnRun = function(self, client, target, toTake)
		local flags = target:GetLocalVar("tempFlags")
		if (!flags) then
			client:NotifyLocalized("flagNoClear", target:Name())
			return
		end

		local character = target:GetCharacter()
		local taken = ""
		for i = 1, #toTake do
			local flag = toTake[i]
			local info = ix.flag.list[flag]
			if (!info) then continue end
			if (!flags[flag]) then continue end

			flags[flag] = nil
			taken = taken..flag

			if (info.callback and !character:HasFlags(flag)) then
				info.callback(target, false)
			end
		end

		if (!table.IsEmpty(flags)) then
			target:SetLocalVar("tempFlags", flags)
		else
			target:SetLocalVar("tempFlags", nil)
		end

		if (taken == "") then
			client:NotifyLocalized("flagAlreadyTaken", target:Name(), toTake)
			return
		end

		for _, v in ipairs(player.GetAll()) do
			if (self:OnCheckAccess(v) or v == target) then
				v:NotifyLocalized("flagTempTake", client:Name(), taken, target:Name())
			end
		end
	end
})

ix.command.Add("CharClearTempFlag", {
	description = "@cmdCharClearTempFlag",
	privilege = "Manage Temp Flags",
	arguments = {
		ix.type.player,
	},
	OnRun = function(self, client, target)
		local flags = target:GetLocalVar("tempFlags")
		if (!flags) then
			client:NotifyLocalized("flagNoClear", target:Name())
			return
		end

		target:SetLocalVar("tempFlags", nil)

		local character = target:GetCharacter()
		local taken = ""
		for flag in pairs(flags) do
			taken = taken..flag

			local info = ix.flag.list[flag]
			if (info and info.callback and !character:HasFlags(flag)) then
				info.callback(target, false)
			end
		end

		if (taken == "") then
			client:NotifyLocalized("flagNoClear", target:Name())
			return
		end

		for _, v in ipairs(player.GetAll()) do
			if (self:OnCheckAccess(v) or v == target) then
				v:NotifyLocalized("flagTempTake", client:Name(), taken, target:Name())
			end
		end
	end
})

ix.command.Add("CharCheckFlags", {
	description = "Проверить флаги персонажа.",
	adminOnly = true,
	arguments = {
		ix.type.character
	},
	OnRun = function(self, client, target)
		if (SERVER) then
			local target = target:GetPlayer()
			
			client:Notify("У этого персонажа "..target:GetCharacter():GetFlags().." флаги")
		end
	end
})
local PLUGIN = PLUGIN

PLUGIN.name = "Temporary Flags"
PLUGIN.author = "Gr4Ss"
PLUGIN.description = "Allows temporary flags to be given to characters or players. Based on SleepyMode's Player Flags plugin."

CAMI.RegisterPrivilege({
	Name = "Helix - Manage Temp Flags",
	MinAccess = "admin"
})

ix.Net:AddPlayerVar("tempFlags", true, nil, ix.Net.Type.Table)

ix.config.Add("TempFlagsRemoveOnCharSwap", true, "config.tempFlagsRemove.desc", nil, {category = "administration"})

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
					client:NotifyLocalized("tempflags.expireWarn", warn)
				end

				if (expired == "") then continue end

				for _, v in ipairs(players) do
					if (CAMI.PlayerHasAccess(v, "Helix - Manage Temp Flags") or v == client) then
						v:NotifyLocalized("tempflags.expired", client:Name(), expired)
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
	description = "@cmd.char.tempflags.give",
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
			client:NotifyLocalized("tempflags.alreadyGiven", target:Name(), toGive)
			return
		end

		target:SetLocalVar("tempFlags", flags)

		for _, v in ipairs(player.GetAll()) do
			if (self:OnCheckAccess(v) or v == target) then
				v:NotifyLocalized("tempflags.give", client:Name(), target:Name(), given, math.Clamp(math.floor(time), 10, 120))
			end
		end
	end
})

ix.command.Add("CharExtendTempFlags", {
	description = "@cmd.char.tempflags.extend",
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
			client:NotifyLocalized("tempflags.noClear", target:Name())
			return
		end

		target:SetLocalVar("tempFlags", flags)

		for _, v in ipairs(player.GetAll()) do
			if (self:OnCheckAccess(v) or v == target) then
				v:NotifyLocalized("tempflags.give", client:Name(), target:Name(), given, math.Clamp(math.floor(time), 10, 120))
			end
		end
	end
})

ix.command.Add("CharTakeTempFlag", {
	description = "@cmd.char.tempflags.take",
	privilege = "Manage Temp Flags",
	arguments = {
		ix.type.player,
		ix.type.string
	},
	OnRun = function(self, client, target, toTake)
		local flags = target:GetLocalVar("tempFlags")
		if (!flags) then
			client:NotifyLocalized("tempflags.noClear", target:Name())
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
			client:NotifyLocalized("tempflags.alreadyTaken", target:Name(), toTake)
			return
		end

		for _, v in ipairs(player.GetAll()) do
			if (self:OnCheckAccess(v) or v == target) then
				v:NotifyLocalized("tempflags.take", client:Name(), taken, target:Name())
			end
		end
	end
})

ix.command.Add("CharClearTempFlag", {
	description = "@cmd.char.tempflags.clear",
	privilege = "Manage Temp Flags",
	arguments = {
		ix.type.player,
	},
	OnRun = function(self, client, target)
		local flags = target:GetLocalVar("tempFlags")
		if (!flags) then
			client:NotifyLocalized("tempflags.noClear", target:Name())
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
			client:NotifyLocalized("tempflags.noClear", target:Name())
			return
		end

		for _, v in ipairs(player.GetAll()) do
			if (self:OnCheckAccess(v) or v == target) then
				v:NotifyLocalized("tempflags.take", client:Name(), taken, target:Name())
			end
		end
	end
})

ix.command.Add("CharCheckFlags", {
	description = "cmd.char.tempflags.check",
	adminOnly = true,
	arguments = {
		ix.type.character
	},
	OnRun = function(self, client, target)
		if (SERVER) then
			local target = target:GetPlayer()
			
			client:NotifyLocalized("tempflags.check", target:GetCharacter():GetFlags())
		end
	end
})
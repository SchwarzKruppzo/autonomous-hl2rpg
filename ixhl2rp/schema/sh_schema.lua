
Schema.name = "HL2 RP"
Schema.author = "CELLAR Team"
Schema.description = ""

-- Include netstream
ix.util.Include("libs/thirdparty/sh_netstream2.lua")
ix.util.Include("libs/sh_factiongroups.lua")

ix.util.Include("sh_configs.lua")
ix.util.Include("sh_commands.lua")

ix.util.Include("cl_schema.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sh_hooks.lua")
ix.util.Include("sh_voices.lua")
ix.util.Include("sv_schema.lua")
ix.util.Include("sv_hooks.lua")

ix.util.Include("meta/sh_player.lua")
ix.util.Include("meta/sv_player.lua")
ix.util.Include("meta/sh_character.lua")

ix.Net:AddPlayerVar("tying", false, nil, ix.Net.Type.Bool)
ix.Net:AddPlayerVar("untying", false, nil, ix.Net.Type.Bool)

Schema.banned_doors = {
	3333, 1263, 1254, 1255, 3732, 3733, 1259, 1264
}

function Schema:ZeroNumber(number, length)
	local amount = math.max(0, length - string.len(number))
	return string.rep("0", amount)..tostring(number)
end

function Schema:IsStringCombineRank(text, rank)
	if istable(rank) then
		for k, v in ipairs(rank) do
			if self:IsStringCombineRank(text, v) then
				return true
			end
		end
	else
		text = text:lower()
		local founded_ranks = string.match(text,"ow%:.-%.(.*)-%d+") or string.match(text,"cca%:.-%.(.*)%.%d+")

		if founded_ranks then
			for crank in string.gmatch(founded_ranks, "[%a%-%_%d]+") do
				if crank == rank then
					return true
				end
			end
		end
	end
end

function Schema:IsPlayerCombineRank(player, rank)
	local faction = player:Team()
	
	if self:GetFactionGroup(faction) == FACTION_GROUP_COMBINE then
		if istable(rank) then
			for k, v in ipairs(rank) do
				if self:IsPlayerCombineRank(player, v) then
					return true
				end
			end
		else
			local name = player:Name()
			name = name:lower()
			
			local founded_ranks = string.match(name, (faction == FACTION_OTA and "ow" or "cca").."%:.-%.(.*)"..(faction == FACTION_OTA and "-%d+" or "%.%d+"))

			if founded_ranks then
				for crank in string.gmatch(founded_ranks, "[%a%-%_%d]+") do
					if crank == rank then
						return true
					end
				end
			end
		end
	end
end

do
	function Schema:GetPlayerCombineRank(player)
		for k, v in pairs(self.ranks:GetStoredRanks()) do
			if self:IsPlayerCombineRank(player, k) then
				if !v.isOTARank or (v.isOTARank and player:Team() == FACTION_OTA) then
					return v
				end
			end
		end
	end

	function Schema:GetPlayerCombineSpec(player)
		for k, v in pairs(self.ranks:GetStoredSpecials()) do
			if self:IsPlayerCombineRank(player, k) then
				if !v.isOTASpecial or (v.isOTASpecial and player:Team() == FACTION_OTA) then
					return v
				end
			end
		end
	end

	function Schema:GetPlayerCombineSpecials(player)
		local spec = {}
		for k, v in pairs(self.ranks:GetStoredSpecials()) do
			if self:IsPlayerCombineRank(player, k) then
				if !v.isOTASpecial or (v.isOTASpecial and player:Team() == FACTION_OTA) then
					table.insert(spec, v)
				end
			end
		end
		return spec
	end
end

function Schema:GetCombinePlayers()
	local result = {}

	for _, v in ipairs(player.GetAll()) do
		if (v:IsCombine()) then
			result[#result + 1] = v
		end
	end

	return result
end

sound.Add({
	name = "MPF.RadioOn",
	channel = CHAN_VOICE,
	volume = 1.0,
	level = 90,
	pitch = 100,
	sound = {
		"ambient/levels/prison/radio_random10.wav",
		"ambient/levels/prison/radio_random11.wav",
		"ambient/levels/prison/radio_random12.wav",
		"ambient/levels/prison/radio_random13.wav",
		"ambient/levels/prison/radio_random14.wav",
		"ambient/levels/prison/radio_random15.wav",
	}
})

sound.Add({
	name = "MPF.RadioOff",
	channel = CHAN_VOICE,
	volume = 1.0,
	level = 90,
	pitch = 100,
	sound = {
		"ambient/levels/prison/radio_random1.wav",
		"ambient/levels/prison/radio_random2.wav",
		"ambient/levels/prison/radio_random3.wav",
		"ambient/levels/prison/radio_random4.wav",
		"ambient/levels/prison/radio_random5.wav",
		"ambient/levels/prison/radio_random6.wav",
		"ambient/levels/prison/radio_random7.wav",
		"ambient/levels/prison/radio_random8.wav",
		"ambient/levels/prison/radio_random9.wav",
	}
})

if SERVER then
	util.AddNetworkString("ration.notify")
else
	net.Receive("ration.notify", function()
		surface.PlaySound("pa_speaker/schedule_reminder.mp3")

		timer.Simple(4, function()
			chat.AddText(Color(150, 125, 175), ix.util.GetMaterial("cellar/chat/broadcast.png"), "Система оповещения Сити-8 вещает ", color_white, "\"" .. "Внимание гражданам Сити-8. Терминал выдачи пищевых рационов доступен. Помните, граждане от красного уровня лояльности имеют более высокий приоритет на выдачу. У вас есть 1 час чтобы забрать пищевой рацион." .. "\"")
			
			surface.PlaySound("city8/city8-rations.wav")
		end)
	end)
end
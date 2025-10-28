local PLUGIN = PLUGIN

PLUGIN.name = "Subscription"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_hooks.lua")

ix.Net:AddPlayerVar("donator", false, nil, ix.Net.Type.Bool)

do
	local PLAYER = FindMetaTable("Player")

	function PLAYER:IsDonator()
		return self:GetNetVar("donator") == true
	end
end

do
	local COMMAND = {
		description = "Открыть персональный контейнер",
		alias = "хранилище"
	}

	function COMMAND:OnRun(client)
		if !client:IsDonator() then
			return
		end

		local vault = client.vault

		if !vault then
			return
		end

		ix.storage.Open(client, vault, {
			name = "Хранилище",
			entity = client,
			searchText = "Открываю...",
			OnPlayerClose = function(client)
				PLUGIN:SaveVault(client)
			end
		})
	end

	ix.command.Add("vault", COMMAND)
end

do
	local command = {}
	command.help	= ""
	command.command = "donate"
	command.arguments = {"steamid", "months"}
	command.permissions = {"Manage Donator Subscriptions"}

	function command:Execute(player, silent, arguments)
		local isConsole = !IsValid(player)
		local steamid = arguments[1]
		local months = tonumber(arguments[2] or 1)

		if steamid then
			if string.find(steamid, "ANON") then
				steamid = AnonIDToSteamID64(steamid)
			end

			if string.find(steamid, "STEAM") then
				steamid = util.SteamIDTo64(steamid)
			end

			local timestamp = os.time() + (2592000 * months)
			PLUGIN:SetDonateSubscription(steamid, timestamp, function(found)
				local msg = found and "Подписка для указанного игрока была успешно активирована." or "Игрок с указанным SteamID не найден."

				if isConsole then
					if found then

						DiscordMessage({
							content = "",
							embeds = {
								{
									title = "Подписка активирована",
									color = 0x00CBFF,
									fields = {
										{
											name = "Игрок",
											value = "https://steamcommunity.com/profiles/"..steamid,
											inline = true
										},
										{
											name = "Дата завершения",
											value = string.format("<t:%s>", timestamp),
											inline = true
										}
									}
								}
							}
						})
					else
						DiscordMessage({
							content = "",
							embeds = {
								{
									title = "Ошибка",
									description = "Игрок с указанным SteamID не найден.",
									color = 0xFF0037
								}
							}
						})
					end
				else
					player:Notify(msg)
				end
			end)
		end
	end
	serverguard.command:Add(command)

	command = {}
	command.help	= ""
	command.command = "donatetime"
	command.arguments = {"steamid", "months"}
	command.permissions = {"Manage Donator Subscriptions"}

	function command:Execute(player, silent, arguments)
		local isConsole = !IsValid(player)
		local steamid = arguments[1]
		local addMonths = tonumber(arguments[2] or 1)

		if steamid and addMonths > 0 then
			if string.find(steamid, "ANON") then
				steamid = AnonIDToSteamID64(steamid)
			end

			if string.find(steamid, "STEAM") then
				steamid = util.SteamIDTo64(steamid)
			end

			PLUGIN:AddDonateSubscription(steamid, (2592000 * addMonths), function(found, newTimestamp, oldTimestamp)
				local msg = found and "Подписка для указанного игрока была успешно изменена." or "Игрок с указанным SteamID не найден."

				if isConsole then
					if found then
						DiscordMessage({
							content = "",
							embeds = {
								{
									title = "Подписка была продлена",
									color = 0x00CBFF,
									fields = {
										{
											name = "Игрок",
											value = "https://steamcommunity.com/profiles/"..steamid,
											inline = true
										},
										{
											name = "Прежняя дата",
											value = string.format("<t:%s>", oldTimestamp),
											inline = true
										},
										{
											name = "Новая дата",
											value = string.format("<t:%s>", newTimestamp),
											inline = true
										}
									}
								}
							}
						})
					else
						DiscordMessage({
							content = "",
							embeds = {
								{
									title = "Ошибка",
									description = "Игрок с указанным SteamID не найден.",
									color = 0xFF0037
								}
							}
						})
					end
				else
					player:Notify(msg)
				end
			end)
		end
	end

	serverguard.command:Add(command)

	command = {}
	command.help	= ""
	command.command = "donateban"
	command.arguments = {"steamid"}
	command.permissions = {"Manage Donator Subscriptions"}

	function command:Execute(player, silent, arguments)
		local isConsole = !IsValid(player)
		local steamid = arguments[1]

		if steamid then
			if string.find(steamid, "ANON") then
				steamid = AnonIDToSteamID64(steamid)
			end

			if string.find(steamid, "STEAM") then
				steamid = util.SteamIDTo64(steamid)
			end

			PLUGIN:ResetDonateSubscription(steamid, function(found)
				local msg = found and "Подписка для указанного игрока была успешно аннулирована." or "Игрок с указанным SteamID не найден."

				if isConsole then
					if found then
						DiscordMessage({
							content = "",
							embeds = {
								{
									title = "Подписка была аннулирована",
									color = 0x00CBFF,
									fields = {
										{
											name = "Игрок",
											value = "https://steamcommunity.com/profiles/"..steamid,
											inline = true
										}
									}
								}
							}
						})
					else
						DiscordMessage({
							content = "",
							embeds = {
								{
									title = "Ошибка",
									description = "Игрок с указанным SteamID не найден.",
									color = 0xFF0037
								}
							}
						})
					end
				else
					player:Notify(msg)
				end
			end)
		end
	end

	serverguard.command:Add(command)
end
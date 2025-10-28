local PLUGIN = PLUGIN

util.AddNetworkString("civil.terminal.login")

net.Receive("civil.terminal.login", function(_, client)
	local character = client:GetCharacter()
	local terminal = net.ReadEntity()

	if !character or !IsValid(terminal) then return end
	if client:GetEyeTraceNoCursor().Entity != terminal then return end

	if character.noDatafile then
		ix.Datafile:Create(character, {}, function(datafile)
			ix.Datafile:Setup(client, character)

			PLUGIN:OpenTerminal(client, datafile)
		end)

		return
	end

	PLUGIN:OpenTerminal(client, character.datafile)
end)

netstream.Hook("civil.terminal.request", function(client, page)
	local character = client:GetCharacter()
	local id = character:GetID()

	if character.noDatafile then return end
	
	print("civil.terminal.request", page)

	if page <= 1 then return end
	
	if page == 3 then
		PLUGIN:TerminalShowCredits(client, id)
	elseif page == 6 then
		PLUGIN:TerminalShowMessages(client, id)
	end
end)

netstream.Hook("civil.terminal.transactions", function(client, targetPage)
	local character = client:GetCharacter()
	local id = character:GetID()

	if character.noDatafile then return end

	PLUGIN:TerminalFetchCredits(client, id, targetPage)
end)

netstream.Hook("civil.terminal.messages", function(client, targetPage)
	local character = client:GetCharacter()
	local id = character:GetID()

	if character.noDatafile then return end

	PLUGIN:TerminalFetchMessages(client, id, targetPage)
end)
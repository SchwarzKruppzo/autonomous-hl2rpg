local PLUGIN = PLUGIN

PLUGIN.MessagesPerPage = 5

local function Reply(receiver, datafile, messages, page)
	page = page or 1

	local maxPages = math.ceil(datafile.cachedMessagesCount / PLUGIN.MessagesPerPage)

	for k, v in ipairs(messages or {}) do
		if v.text and string.utf8len(v.text) >= 64 then
			v.text = string.utf8sub(v.text, 1, 61) .. "..."
		end
	end

	local data = {
		6,
		page,
		maxPages,
		messages
	}

	netstream.Start(receiver, "civil.terminal.request", data)
end

function PLUGIN:TerminalShowMessages(client, datafileID)
	local file = ix.Datafile:Get(datafileID)
	if !file then return end


	if file and !file.cachedMessagesCount then
		local query = mysql:Select("datafiles_messages")
			query.whereList[#query.whereList + 1] = "(`receiver_id` = '"..query:Escape(datafileID).."' OR `sender_id` = '"..query:Escape(datafileID).."' OR `receiver_id` = '0')"
			query:Select("id")
			query:Callback(function(result)
				file.cachedMessagesCount = istable(result) and #result or 0

				ix.Datafile:FetchMessages(client, "char", datafileID, PLUGIN.MessagesPerPage, 1, function(result)
					Reply(client, file, result)
				end)
			end)
		query:Execute()
		return
	end

	ix.Datafile:FetchMessages(client, "char", datafileID, PLUGIN.MessagesPerPage, 1, function(result)
		Reply(client, file, result)
	end)
end

function PLUGIN:TerminalFetchMessages(client, datafileID, targetPage)
	local file = ix.Datafile:Get(datafileID)
	if !file or !file.cachedMessagesCount then return end
	
	local maxPages = math.ceil(file.cachedMessagesCount / PLUGIN.MessagesPerPage)
	if targetPage > maxPages or targetPage <= 0 then return end
	
	ix.Datafile:FetchMessages(client, "char", datafileID, PLUGIN.MessagesPerPage, targetPage, function(result)
		Reply(client, file, result, targetPage)
	end)
end
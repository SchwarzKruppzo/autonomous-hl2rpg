local PLUGIN = PLUGIN

PLUGIN.TransactionsPerPage = 4

local function Reply(receiver, datafile, transactions, page)
	page = page or 1

	local maxPages = math.ceil(datafile.cachedTransactionCount / PLUGIN.TransactionsPerPage)
	local optimized = {}

	for k, v in ipairs(transactions or {}) do
		local isSender = datafile:CharacterID() == tonumber(v.sender_id)
		local name = isSender and v.receiver_name or v.sender_name

		optimized[#optimized + 1] = {
			v.amount,
			v.reason,
			name,
			isSender,
			v.timestamp
		}
	end

	local data = {
		3,
		page,
		maxPages,
		optimized
	}

	netstream.Start(receiver, "civil.terminal.request", data)
end

function PLUGIN:TerminalShowCredits(client, datafileID)
	local file = ix.Datafile:Get(datafileID)
	if !file then return end

	if file and !file.cachedTransactionCount then
		local query = mysql:Select("datafiles_transactions")
			query.whereList[#query.whereList + 1] = "(`receiver_id` = '"..query:Escape(datafileID).."' OR `sender_id` = '"..query:Escape(datafileID).."')"
			query:Select("id")
			query:Callback(function(result)
				file.cachedTransactionCount = istable(result) and #result or 0

				ix.Datafile:FetchTransactions(client, "char", datafileID, PLUGIN.TransactionsPerPage, 1, function(result)
					Reply(client, file, result)
				end)
			end)
		query:Execute()
		return
	end

	ix.Datafile:FetchTransactions(client, "char", datafileID, PLUGIN.TransactionsPerPage, 1, function(result)
		Reply(client, file, result)
	end)
end

function PLUGIN:TerminalFetchCredits(client, datafileID, targetPage)
	local file = ix.Datafile:Get(datafileID)
	if !file or !file.cachedTransactionCount then return end
	
	local maxPages = math.ceil(file.cachedTransactionCount / PLUGIN.TransactionsPerPage)
	if targetPage > maxPages or targetPage <= 0 then return end
	
	ix.Datafile:FetchTransactions(client, "char", datafileID, PLUGIN.TransactionsPerPage, targetPage, function(result)
		Reply(client, file, result, targetPage)
	end)
end
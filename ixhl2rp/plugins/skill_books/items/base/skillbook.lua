local PLUGIN = PLUGIN
local ItemSkillBook = class("ItemSkillBook"):implements("Item")

ix.Net:AddPlayerVar("reading", true, nil, ix.Net.Type.String)
ix.Net:AddPlayerVar("book_start", true, nil, ix.Net.Type.All)
ix.Net:AddPlayerVar("book_end", true, nil, ix.Net.Type.All)

function PLUGIN:PlayerLoadedCharacter(client, character, lastChar)
	if client.read_character and client.read_character == lastChar:GetID() then
		local info = lastChar:GetBookInfo()
		local skill = client.read_skill

		local bookInfo = info[skill] or {}
		bookInfo.time = ((client:GetLocalVar("book_start", 0) + client:GetLocalVar("book_end", 0)) - os.time())

		if bookInfo.time <= 0 then
			print("you read book", skill, bookInfo.lvl)
			bookInfo.read = true
			bookInfo.start = nil
			bookInfo.time = nil
		end

		info[skill] = bookInfo

		lastChar:SetBookInfo(info)

		client.read_character = nil
		client.read_skill = nil
		client.read_end = nil

		client:SetLocalVar("reading", nil)
		client:SetLocalVar("book_end", nil)
		client:SetLocalVar("book_start", nil)

		PrintTable(info)
	end

	local info = character:GetBookInfo()

	if info then
		local currentTime = os.time()
		local wasChanged = false

		for skill, bookInfo in pairs(info) do
			if bookInfo.read then continue end

			if currentTime >= (bookInfo.start + bookInfo.time) then
				print("you read book", skill, bookInfo.lvl)
				bookInfo.read = true
				bookInfo.start = nil
				bookInfo.time = nil
			end

			info[skill] = bookInfo
			wasChanged = true
		end

		if wasChanged then
			character:SetBookInfo(info)
		end
	end
	
end

function ItemSkillBook:Init()
	self.category = "Книги (навыки)"

	self.functions.read = {
		name = "Читать",
		OnRun = function(item)
			local client, character = item.player, item.player:GetCharacter()
			
			local info = character:GetBookInfo()
			local skill = item.book.skill[1]
			local bookInfo = info[skill] or {}

			bookInfo.lvl = bookInfo.lvl or 1
			
			local delta = (item.book.level - bookInfo.lvl)

			if delta == 1 and !bookInfo.read then
				print("not read previous")
				return
			elseif delta == 0 and bookInfo.read then
				print("already known")
				return
			elseif delta > 1 then
				print("too high")
				return
			elseif delta < 0 then
				print("too low")
				return
			end

			if character:GetID() == client.read_character and client:GetLocalVar("reading") == item.uniqueID then
				bookInfo.time = ((client:GetLocalVar("book_start", 0) + client:GetLocalVar("book_end", 0)) - os.time())

				if bookInfo.time < 0 then
					bookInfo.time = item.book.time
				end
			end

			local startTime = os.time()
			bookInfo.lvl = item.book.level
			bookInfo.read = nil
			bookInfo.start = startTime
			bookInfo.time = bookInfo.time or item.book.time

			info[skill] = bookInfo

			character:SetBookInfo(info)

			client.read_character = character:GetID()
			client.read_skill = skill
			client.read_end = startTime + bookInfo.time

			client:SetLocalVar("reading", item.uniqueID)
			client:SetLocalVar("book_end", bookInfo.time)
			client:SetLocalVar("book_start", startTime)

			return true
		end,
		OnCanRun = function(item) return true end
	}
	self.functions.reset = {
		name = "reset",
		OnRun = function(item)
			local client, character = item.player, item.player:GetCharacter()

			character:SetBookInfo({})

			client.read_character = nil
			client.read_skill = nil
			client.read_end = nil

			client:SetLocalVar("reading", nil)
			client:SetLocalVar("book_end", nil)
			client:SetLocalVar("book_start", nil)

			return true
		end,
		OnCanRun = function(item) return true end
	}
end

return ItemSkillBook

-- os.time: 5


-- os.time 20 - 5


/*

start_time = 5
end_time = 5 + 24


*/
local PLUGIN = PLUGIN
local ItemSkillBook = class("ItemSkillBook"):implements("Item")

ix.Net:AddPlayerVar("reading", true, nil, ix.Net.Type.String)
ix.Net:AddPlayerVar("book_start", true, nil, ix.Net.Type.All)
ix.Net:AddPlayerVar("book_end", true, nil, ix.Net.Type.All)

function PLUGIN:PlayerLoadedCharacter(client, character, lastChar)
	if client.read_character and client.read_character == lastChar:GetID() then
		local uniqueID = "ixReading"..client:UniqueID()
		timer.Remove(uniqueID)
		
		local item = client.read_item

		if !item then
			return
		end
		
		item:Interrupt(client, lastChar)
	end
end

function PLUGIN:PlayerDisconnected(client)
	if client.read_character then
		local uniqueID = "ixReading"..client:UniqueID()
		timer.Remove(uniqueID)

		local item = client.read_item

		if !item then
			return
		end
		
		item:Interrupt(client)
	end
end

do
	local PLAYER = FindMetaTable("Player")

	function PLAYER:SaveBookProgress(character)
		character = character or self:GetCharacter()
		local id = self:GetLocalVar("reading")

		if character and id then
			local info = character:GetBookInfo()
			local item = ix.Item.stored[id]

			if item then
				local remainingTime = (item.bookTime - (self:GetLocalVar("book_end", 0) - os.time()))

				info[id] = remainingTime

				--print("Time: ", remainingTime)

				character:SetBookInfo(info)
			end
		end
	end

	function PLAYER:BookCondition(character)
		if self:KeyDown(IN_RELOAD) or self:GetVelocity():LengthSqr() > 300 then
			return false
		end

		if self:Alive() and !IsValid(self.ixRagdoll) and self:GetCharacter() == character then --and !self:IsUnconscious() then
			return true
		end
	end

	function PLAYER:StartBookAction(time, character, callback)
		self:SetAction("@readingBook", time)

		local uniqueID = "ixReading"..self:UniqueID()
		timer.Create(uniqueID, 1, time, function()
			if IsValid(self) then
				if !self:BookCondition(character) then
					timer.Remove(uniqueID)

					callback(false)
				elseif (callback and timer.RepsLeft(uniqueID) == 0) then
					callback(true)
				end
			else
				timer.Remove(uniqueID)

				callback(false)
			end
		end)
	end
end

function ItemSkillBook:Interrupt(client, character)
	self.reading_by = nil

	if !IsValid(client) then
		return
	end

	client:SaveBookProgress(character)
	client:SetAction()

	client.read_item = nil
	client.read_character = nil

	client:SetLocalVar("reading", nil)
	client:SetLocalVar("book_start", nil)
	client:SetLocalVar("book_end", nil)

	--print("Debug interrupt", client, character)
end

function ItemSkillBook:Init()
	self.category = "Книги (навыки)"

	self.functions.read = {
		name = "Читать",
		OnRun = function(item)
			local id = item.uniqueID
			local client, character = item.player, item.player:GetCharacter()
			local info = character:GetBookInfo()
			
			if item.bookRequire and (info[item.bookRequire] != true) then
				-- cannot read
				client:Notify("Вам необходимо изучить предыдущую часть книги!")
				return
			end

			if info[id] == true then
				-- this book was read
				client:Notify("Вы уже читали эту книгу!")
				return
			end
			
			if character:GetID() == client.read_character and client:GetLocalVar("reading") == id then
				client:SaveBookProgress()
			end

			local startTime = os.time()

			info[id] = info[id] or 0

			character:SetBookInfo(info)

			local time = math.max(item.bookTime - info[id], 1)

			item.reading_by = character
			client.read_item = item
			client.read_character = character:GetID()
			client:SetLocalVar("reading", id)
			client:SetLocalVar("book_start", startTime)
			client:SetLocalVar("book_end", startTime + time)

			client:StartBookAction(time, character, function(result)
				if result then
					local info = character:GetBookInfo()
					info[id] = true
					character:SetBookInfo(info)

					--print("Book Read!", time, character:GetBookInfo()[id])
					if self.OnRead then
						self:OnRead(client)
					end

					item:Remove()
					return
				end

				item:Interrupt(client)
			end)

			return true
		end,
		OnCanRun = function(item) 
			return item.reading_by == nil 
		end
	}
	/*
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
	}*/
end

if CLIENT then
	function ItemSkillBook:PopulateTooltip(tooltip)
		local client = LocalPlayer()
		local character = client:GetCharacter()
		local info = character:GetBookInfo()

		local text = "Вы ещё не читали эту книгу."
		local result = info[self.uniqueID]

		if result and isnumber(result) then
			text = string.format("Прогресс изучения: %s%%", math.Round(100 * (result / self.bookTime)))
		elseif result and result == true then
			text = "Вы изучили эту книгу."
		end

		local size = tooltip:AddRowAfter("name")
		size:SetBackgroundColor(derma.GetColor("Success", tooltip))
		size:SetText(text)
	end
end


return ItemSkillBook

-- os.time: 5


-- os.time 20 - 5


/*

start_time = 5
end_time = 5 + 24


*/
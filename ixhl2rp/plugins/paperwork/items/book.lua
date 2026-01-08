local Books = ix.util.Lib("Books", {
	stored = {},
	loaded = false
})

function Books:Load()
	local data = ix.data.Get("books", {}, true, true)

	for k, v in pairs(data) do
		self.stored[k] = table.Copy(v)
	end

	self.loaded = true
end

function Books:Save()
	ix.data.Set("books", self.stored, true, true)
end

function Books:Register(data, owner)
	if !istable(data) then
		return
	end

	data.font = data.font or "BookAlegreya"
	data.createTime = os.time()
	data.owner = owner:SteamID64()

	local checksum = util.SHA1(util.TableToJSON(data.pages))
	data.checksum = checksum

	self.stored[checksum] = data

	self:Save()

	return checksum
end



ITEM.name = "item.book"
ITEM.model = "models/n_models/n_book.mdl"
ITEM.stackable = true
ITEM.max_stack = 5
ITEM.width = 2
ITEM.height = 1
ITEM.description = "item.book.desc"

ITEM:AddData("C", { -- title
	Transmit = ix.transmit.all,
})

ITEM:AddData("S", { -- skin
	Transmit = ix.transmit.all,
})

ITEM:AddData("checksum", {
	Transmit = ix.transmit.all,
})

ITEM.functions.View = {
	name = "use.read",
	OnRun = function(item)
		local checksum = item:GetData("checksum", "")
		local info = Books.stored[checksum]

		if info then
			item.player.book_read = item

			netstream.Start(item.player, "book.open", checksum, item:GetSkin())
		end

		return false
	end,

	OnCanRun = function(item)
		local sym = item:GetData("checksum", "")

		return sym != ""
	end
}

function ITEM:GetSkin()
	return tonumber(self:GetData("S", 0))
end

function ITEM:GetTitle()
	return self:GetData("C")
end

function ITEM:GetName()
	local title = self:GetTitle()

	if title then
		return string.format("\"%s\"", title)
	end
	
	return "Книга"
end

if CLIENT then
	netstream.Hook("book.open", function(checksum, skin)
		if !Books.loaded then
			Books:Load()
		end

		local info = Books.stored[checksum]

		if info then
			local book = vgui.Create("cellar.ui.book")
			book:OpenBook(info.pages, info.font, skin)
		else
			net.Start("book.request")
			net.SendToServer()
		end
	end)

	express.Receive("book.send", function(data)
		local checksum = data.checksum
		local font = data.font
		local pages = data.pages
		local skin = data.skin
		local title = data.title

		Books.stored[checksum] = {
			font = font,
			pages = pages,
			title = title
		}

		Books:Save()

		local book = vgui.Create("cellar.ui.book")
		book:OpenBook(pages, font, skin)
	end)
else
	util.AddNetworkString("book.request")

	net.Receive("book.request", function(_, client)
		local item = client.book_read

		if !item then
			return
		end

		local checksum = item:GetData("checksum", "")
		local info = Books.stored[checksum]

		local data = {
			checksum = checksum,
			font = info.font,
			pages = info.pages,
			skin = item:GetSkin(),
			title = item:GetTitle()
		}

		express.Send("book.send", data, client)
	end)
end

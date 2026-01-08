local Item = class("ItemBook"):implements("Item")

Item.model = "models/n_models/n_book.mdl"
Item.stackable = true
Item.max_stack = 8
Item.iconCam = {
	pos = Vector(70.421997070313, 0.21755240857601, 41.372787475586),
	ang = Angle(30.566345214844, 180.11782836914, 0),
	fov = 10.598704422945,
}

function Item:Init()
	self.category = "item.category.book"
	self.name = "item.emptybook"
	self.width = 2
	self.height = 1

	self.functions.Write = {
		name = "use.bookwrite",
		OnRun = function(item)
			local data = item:GetData("T") or {}

			if !table.IsEmpty(data) then
				local client = item.player

				express.Send("book.edit", data, client, function()
					item.isEditing = true
					client.book_edit = item
				end)
			else
				netstream.Start(item.player, "book.edit")

				item.isEditing = true
				item.player.book_edit = item
			end
		end,

		OnCanRun = function(item)
			return !item.isEditing
		end
	}

	self:AddData("T", { -- text
		Transmit = ix.transmit.none,
	})
end

if CLIENT then
	express.Receive("book.edit", function(data)
		local ui = vgui.Create("cellar.book.write")
		ui:SetFont(data[1])
		ui.data = table.Copy(data[2])
		ui:LoadPage(1)
	end)

	netstream.Hook("book.edit", function(data)
		local ui = vgui.Create("cellar.book.write")
		ui:LoadPage(1)
	end)
else
	express.Receive("book.save", function(client, data)
		local item = client.book_edit

		if item then
			if item.isEditing then
				item:SetData("T", data)
				item.isEditing = false

				client.book_edit = nil
			end
		end
	end)

	express.Receive("book.write", function(client, data)
		local title = data[1]
		local pages = data[2]
		local font = data[3]

		local item = client.book_edit

		if item then
			if item.isEditing then
				local skin = item:GetSkin()
				item:Remove()
				client.book_edit = nil

				local checksum = ix.Books:Register({title = title, pages = pages, font = font}, client)

				if checksum then
					local instance = ix.Item:Instance("book", {checksum = checksum, C = title, S = skin})
					instance:SetData("S", skin)
					instance:SetData("C", title)
					instance:SetData("checksum", checksum)

					ix.Item:Spawn(client, nil, instance)
				end
			end
		end
	end)
end

return Item
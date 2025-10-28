local PLUGIN = PLUGIN

ITEM.name = "Лист бумаги"
ITEM.model = "models/props_c17/paper01.mdl"
ITEM.stackable = true
ITEM.max_stack = 5
ITEM.width = 1
ITEM.height = 1
ITEM.description = "iPaperDesc"
ITEM.isPaper = true
ITEM.bAllowMultiCharacterInteraction = true

ITEM:AddData("O", { -- owner
	Transmit = ix.transmit.all,
})

ITEM:AddData("C", { -- title
	Transmit = ix.transmit.all,
})

ITEM:AddData("T", { -- text
	Transmit = ix.transmit.none,
})

ITEM:AddData("D", { -- can pickup
	Transmit = ix.transmit.none,
})

ITEM:AddData("canEdit", { -- timestamp
	Transmit = ix.transmit.all,
})

ITEM.functions.View = {
	name = "Прочитать",
	OnRun = function(item)
		local text = item:GetData("T", "")

		item.user = item.user or {}
		item.user[item.player] = true

		netstream.Start(item.player, "ixOpenPaper", item:GetID(), text, item:GetTitle(), false)
		return false
	end,

	OnCanRun = function(item)
		local owner = item:GetData("O", 0)

		return owner != 0
	end
}

ITEM.functions.Write = {
	name = "Написать",
	OnRun = function(item)
		local text = item:GetData("T", nil)

		item.user = item.user or {}
		item.user[item.player] = true

		netstream.Start(item.player, "ixOpenPaper", item:GetID(), text, item:GetData("C", nil), true)
		return false
	end,

	OnCanRun = function(item)
		local owner = item:GetData("O", 0)
		local time = item:GetData("canEdit", nil)

		return (time and time > os.time()) or owner == 0
	end
}

function ITEM:GetDescription()
	return self:GetData("O", 0) == 0 and L("iPaperDesc") or L("iPaperDesc2")
end

function ITEM:GetTitle()
	return self:GetData("C", "")
end

if CLIENT then
	function ITEM:PopulateTooltip(tooltip)
		local uses = tooltip:AddRowAfter("name")
		uses:SetText(L("iPaperTitle", self:GetTitle()))
	end
else
	function ITEM:Write(title, text, character)
		if title then
			title = tostring(title):sub(1, PLUGIN.maxTitleLength)

			self:SetData("C", title)
		end

		text = tostring(text):sub(1, PLUGIN.maxLength)
		
		self:SetData("T", text, false, false, true)

		if character then
			self:SetData("O", character and character:GetID() or 0)
		end
	end

	function ITEM:CanTake(client)
		local pickup = self:GetData("D", false)
		local owned = self:GetData("O", 0)

		if owned != 0 and pickup then
			local character = client:GetCharacter()

			if !client:IsAdmin() and character:GetID() != owned then
				return false
			end
		end
	end
end

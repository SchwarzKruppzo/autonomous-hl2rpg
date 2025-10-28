
local PLUGIN = PLUGIN

local icons = {
	["Инструменты"] = "wrench",
	["Одежда"] = "suit",
	["Одежда (MPF)"] = "user_gray",
	["Одежда (Броня)"] = "user_green",
	["Одежда (OTA)"] = "user_red",
	["Напитки"] = "drink",
	["Оружие"] = "gun",
	["Other"] = "brick",
	["Базовые компоненты"] = "cog",
	["Уникальное"] = "shield",
	["Еда"] = "cake",
	["Citizen ID"] = "vcard",
	["Патроны"] = "find",
	["Производные компоненты"] = "cog_add",
	["Радиация"] = "error",
	["Коммуникация"] = "feed",
	["Рационы"] = "page",
	["Купоны Альянса"] = "coins",
	["Книги"] = "book_addresses",
	["Книги (навыки)"] = "book_open",
	["Кулинарные компоненты"] = "cup",
	["Хлам"] = "bin",
	["Части оружия"] = "text_list_bullets",
	["Химические компоненты"] = "asterisk_orange",
	["Фильтры"] = "help",
	["Медицина"] = "pill",
	["Строительство - контейнеры"] = "box",
	["Части оружия"] = "link",
	["Повязки (MPF)"] = "status_busy",
	["Повязки (Лояльность)"] = "status_online",
}

spawnmenu.AddContentType("ixItem", function(container, data)
	if (!data.name) then return end

	local custom = data.checksum and true or false
	local icon = vgui.Create("ContentIcon", container)

	icon:SetContentType("ixItem")
	icon:SetSpawnName(data.uniqueID)
	icon:SetName(data.name)

	local mdl = data.GetModel and data:GetModel() or data.model

	if mdl then
		icon.model = vgui.Create("ModelImage", icon)
		icon.model:SetMouseInputEnabled(false)
		icon.model:SetKeyboardInputEnabled(false)
		icon.model:StretchToParent(16, 16, 16, 16)
		icon.model:SetModel(mdl, data.GetSkin and data:GetSkin() or (data.skin or 0), "000000000")
		icon.model:MoveToBefore(icon.Image)
	end

	function icon:DoClick()
		net.Start("MenuItemSpawn")
			net.WriteString(custom and data.checksum or data.uniqueID)
			net.WriteBool(custom)
		net.SendToServer()
		
		surface.PlaySound("ui/buttonclickrelease.wav")
	end

	function icon:OpenMenu()
		local menu = DermaMenu()
		menu:AddOption("Скопировать Item ID", function()
			SetClipboardText(data.uniqueID)
		end)

		menu:AddOption("Выдать себе", function()
			net.Start("MenuItemGive")
				net.WriteString(custom and data.checksum or data.uniqueID)
				net.WriteBool(custom)
			net.SendToServer()
		end)

		menu:Open()
	end

	if (IsValid(container)) then
		container:Add(icon)
	end
end)

local function CreateItemsPanel()
	local base = vgui.Create("SpawnmenuContentPanel")
	local tree = base.ContentNavBar.Tree
	local categories = {}

	vgui.Create("ItemSearchBar", base.ContentNavBar)

	local items = ix.Item:All()

	for k, v in SortedPairsByMemberValue(items, "category") do
		if (!categories[v.category] and !string.match(v.name, "Base")) then
			categories[v.category] = true

			local category = tree:AddNode(L(v.category), icons[v.category] and ("icon16/" .. icons[v.category] .. ".png") or "icon16/brick.png")

			function category:DoPopulate()
				if (self.Container) then return end

				self.Container = vgui.Create("ContentContainer", base)
				self.Container:SetVisible(false)
				self.Container:SetTriggerSpawnlistChange(false)


				for uniqueID, itemTable in SortedPairsByMemberValue(items, "name") do
					if (itemTable.category == v.category and not string.match( itemTable.name, "Base" )) then
						spawnmenu.CreateContentIcon("ixItem", self.Container, itemTable)
					end
				end
			end

			function category:DoClick()
				self:DoPopulate()
				base:SwitchPanel(self.Container)
			end
		end
	end

	local category = tree:AddNode("Кастомные Предметы", "icon16/heart.png")
	function category:DoPopulate()
		if (self.Container) then return end

		self.Container = vgui.Create("ContentContainer", base)
		self.Container:SetVisible(false)
		self.Container:SetTriggerSpawnlistChange(false)


		for checksum, itemTable in SortedPairsByMemberValue(ix.CustomItem.stored, "name") do
			spawnmenu.CreateContentIcon("ixItem", self.Container, itemTable, true)
		end
	end

	function category:DoClick()
		self:DoPopulate()
		base:SwitchPanel(self.Container)
	end



	local FirstNode = tree:Root():GetChildNode(0)

	if (IsValid(FirstNode)) then
		FirstNode:InternalDoClick()
	end

	PLUGIN:PopulateContent(base, tree, nil)

	return base
end

spawnmenu.AddCreationTab("Предметы", CreateItemsPanel, "icon16/script_key.png")

-- ensures the spawnmenu repopulates
timer.Simple(0, function()
	RunConsoleCommand("spawnmenu_reload")
end)

local PLUGIN = PLUGIN

netstream.Hook("QueryDeleteLanguageLearningProgress", function(languageName)
	Derma_Query("I am already learning "..languageName..", delete progress?", "Languages", "Yes", function()
		netstream.Start("QueryDeleteLanguageSuccess")
	end, "No")
end)

function PLUGIN:DoVortShout(speaker)
	netstream.Start("ForceShoutAnim", speaker)
end

function PLUGIN:ChatboxCreated()
	if !IsValid(self.panel) then
		self.panel = vgui.Create("ixLanguageChatButton")
	end
end

function PLUGIN:ChatboxPositionChanged(x, y, width, height)
	self.panel:CorrectPosition(x, y, width, height)
end

function PLUGIN:CharacterLoaded(character)
	self.panel:ChangeFlagIcon(LocalPlayer():GetLanguage())
end

function Derma_LanguageSelect(list, confirmCallback)
	local panel = vgui.Create("DFrame")
	panel:SetTitle("Дополнительный язык персонажа")
	panel:SetDraggable(false)
	panel:ShowCloseButton(false)
	panel:SetBackgroundBlur(true)
	panel:SetDrawOnTop(true)

	local sizeW, sizeH = ix.UI.Scale(500), ix.UI.Scale(720)

	panel:SetSize(sizeW, sizeH)

	local Scroll = vgui.Create("DScrollPanel", panel)
	Scroll:Dock(FILL)

	local layout = vgui.Create("DListLayout", Scroll)
	layout:Dock(FILL)

	table.SortByMember(list, "text", true)

	for k, v in pairs(list) do
		local btn = layout:Add( "DButton" )
		btn:SetText(v.text)
		btn:SetIcon(v.icon)
		btn.DoClick = function()
			Derma_Query(
			"Вы точно хотите выбрать язык "..v.text.." дополнительным?",
			"Подтверждение",
			"Да",
			function() 
				confirmCallback(v.value)

				panel:Close()
			end,
			"Нет",
			function() end
			)
		end
	end

	panel:Center()
	panel:MakePopup()
end

netstream.Hook("lang.select", function()
	local languages = {}

	for k, v in pairs(ix.languages.stored) do
		if v.notSelectable then continue end
		
		languages[#languages + 1] = {icon = v.icon, text = v.name, value = v.uniqueID}
	end

	Derma_LanguageSelect(languages, function(value) 
		netstream.Start("lang.select", value)
	end)
end)
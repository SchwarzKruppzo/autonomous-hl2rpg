local ix = ix

ix.quickmenu = {}
ix.quickmenu.stored = {}


function ix.quickmenu:AddCallback(name, icon, callback, shouldShow)
	self.stored[#ix.quickmenu.stored+1] = {
		shouldShow = shouldShow,
		callback = callback,
		name = name,
		icon = icon
	};
end;

ix.quickmenu:AddCallback(L("quickmenuPersonalNotes"), "icon16/note_edit.png", function()
	ix.command.Send("MyNotes")
end)

ix.quickmenu:AddCallback(L("quickmenuChangeDescription"), "icon16/note_edit.png", function()
	ix.command.Send("CharDesc")
end)

ix.quickmenu:AddCallback(L("quickmenuDropTokens"), "icon16/money_delete.png", function()
	local description = L("quickmenuDropTokensDesc", LocalPlayer():GetCharacter():GetMoney())

	Derma_StringRequest(L("quickmenuDropTokensTitle"), description, 20, function(text)
		ix.command.Send("DropTokens", text)
	end, nil, L("quickmenuDropTokensConfirm"), L("cancel"))
end)

ix.quickmenu:AddCallback(L("quickmenuFallOver"), "icon16/user.png", function()
	Derma_StringRequest(L("quickmenuFallOverTitle"), L("quickmenuFallOverPrompt"), 5, function(text)
		ix.command.Send("CharFallOver", math.Clamp(tonumber(text) or 60, 60, 120))
	end, nil, L("quickmenuFallOverConfirm"), L("cancel"))
end)

ix.quickmenu:AddCallback(L("quickmenuChangeWalkstyle"), "icon16/user.png", function()
	local menu = DermaMenu()
	local moods = ix.plugin.list["emotemoods"].MoodTextTable
	for i = 1, 4 do
		menu:AddOption(L(moods[i - 1]), function()
			ix.command.Send("CharSetMood", i - 1)
		end)
	end
	menu:Open()
end)

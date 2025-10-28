local PLUGIN = PLUGIN

function PLUGIN:CreateNotesTab(characterId, charNotes)
    local maxLen = ix.config.Get("notesMaxLen")
    local dataKey = "notes-"..string.gsub(game.GetIPAddress(), "%p", "").."-"..LocalPlayer():GetCharacter():GetID()

    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() * 0.4, ScrH() * 0.4)
    frame:SetTitle(characterId != nil and "Админ Записи" or "Личные Записи")
    frame:Center()
    frame:MakePopup()

    local textEntry = vgui.Create("DTextEntry", frame)
    textEntry:Dock(FILL)
    textEntry:SetMultiline(true)

    textEntry.OnTextChanged = function(self)
        local txt = self:GetValue()
        local amt = string.utf8len(txt)

        if amt > maxLen then
            self:SetText(self.oldText)
            self:SetValue(self.oldText)
        else
            self.oldText = txt
        end
    end

    local text

    if (characterId != nil) then
        text = charNotes
    else
        text = ix.data.Get(dataKey, "", true, true)
    end

    if (!text) then
        frame:Remove()
        LocalPlayer():Notify("Невозможно открыть записи персонажа.")
        return
    end
    
    textEntry:SetValue(text)

    local submitButton = vgui.Create("DButton", frame)
    submitButton:Dock(BOTTOM)
    submitButton:SetText("Submit")
    submitButton.DoClick = function(self)
        if (characterId) then
            netstream.Start("ixNotesSet", characterId, utf8.sub(textEntry:GetValue(), 1, maxLen))
        else
            ix.data.Set(dataKey, textEntry:GetValue(), true, true)
            LocalPlayer():Notify("Записи успешно сохранены.")
        end
    end
end

netstream.Hook("ixNotes", function(characterId, charNotes)
    PLUGIN:CreateNotesTab(characterId, charNotes)
end)

netstream.Hook("ixMyNotes", function()
    PLUGIN:CreateNotesTab(nil, nil)
end)

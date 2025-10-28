local PLUGIN = PLUGIN

netstream.Hook("ixNotesSet", function(client, characterId, text)
  if (CAMI.PlayerHasAccess(client, "Helix - Basic Admin Commands")) then
    local character = ix.char.loaded[characterId]

    if (character) then
      character:SetNotes(text)
      client:Notify("Запись успешно сохранена.")
    else
      client:Notify("Персонаж не найден.")
    end
  else
    client:Notify("У вас нет прав для этого.")
  end
end)

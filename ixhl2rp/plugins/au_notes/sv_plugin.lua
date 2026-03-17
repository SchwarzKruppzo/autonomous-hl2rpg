local PLUGIN = PLUGIN

netstream.Hook("ixNotesSet", function(client, characterId, text)
  if (CAMI.PlayerHasAccess(client, "Helix - Basic Admin Commands")) then
    local character = ix.char.loaded[characterId]

    if (character) then
      character:SetNotes(text)
      client:NotifyLocalized("notes.saved")
    else
      client:NotifyLocalized("notes.charNotFound")
    end
  else
    client:NotifyLocalized("notes.noPermission")
  end
end)

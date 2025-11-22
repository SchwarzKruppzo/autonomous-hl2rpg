local Popup = ix.util.Lib("Popup")

/* messageInfo = {
    anonymous
    chatType
    text
    player (костыль для корректной работы ix.chat.Send)
}
*/

function Popup:PopupPos(pos, messageInfo, duplicateToChat)
    if duplicateToChat then
        ix.chat.Send(messageInfo.player, messageInfo.chatType, messageInfo.text)
    end

    ix.plugin.list.displaychat:DisplayChatPopupPos(pos, messageInfo)
end

function Popup:PopupEntity(entity, vectorOffset, messageInfo, duplicateToChat)
    if (!IsValid(entity)) then
        return
    end

    local pos = entity:GetPos()
    pos = vectorOffset and pos + vectorOffset or pos
    
    self:PopupPos(pos, messageInfo, duplicateToChat)
end
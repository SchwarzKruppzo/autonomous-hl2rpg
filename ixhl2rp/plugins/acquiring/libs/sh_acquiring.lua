local Acquiring = ix.util.Lib("Acquiring", {
    LastAcquiringId = 0,
    soundDeny = "sk_terminal/deny.wav",
    soundAccept = "sk_terminal/terminal_prompt_confirm.wav"
})

function Acquiring:GetWorldPOSTerminals()
    local tbl = {}

    for k,v in pairs(ix.Item.entities)do
        local item = v:GetItem()
        if (item.isPosTerminal) then
            tbl[#tbl + 1] = item
        end
    end

    return tbl
end

function Acquiring:HasFullAccess(client)
    local res = client:HasIDAccess("EDIT_POS")
    if res then
        return true
    end

    return false, "Нет доступа!"
end

function Acquiring:HasLimitedAccess(client, terminal)
    local res, text = self:HasFullAccess(client)

    if res then
        return true
    end

    local cid = client:GetIDCard()
    if cid and cid:GetData("cid") == terminal:GetData("datafileId") then
        return true
    end

    return false, "Нет доступа!"
end

function Acquiring:CanEditDatafileId(client)
    return self:HasFullAccess(client)
end

function Acquiring:CanFreezeUnfreeze(client, terminal)
    return self:HasLimitedAccess(client, terminal)
end

function Acquiring:CanEnterSum(client, terminal, sum)
    local res, text = self:HasLimitedAccess(client, terminal)
    if !res then
        return res, text
    end

    if (isnumber(sum) && sum > 0) then
        return res, text
    end

    return false, "Некорректная сумма!"
end

function Acquiring:EnterSum(terminal, sum, save)
    terminal:SetData("enteredSum", sum)
    terminal:SetData("shouldSaveSum", save)
end

function Acquiring:CanPay(client, terminal)
    return !!client:GetIDCard()
end

function Acquiring:CanBindDatafileId(client, terminal, datafileId)
    if self:CanEditDatafileId(client) && terminal && terminal.id && #datafileId == 5 then
        local id = ix.plugin.list.datafile:GetDatafileCID(datafileId)
        if (id) then
            return true
        end
    end
end

function Acquiring:BindDatafileId(terminal, datafileId)
    terminal:SetData("datafileId", datafileId)
end

function Acquiring:Pay(client, terminal, callback)
    local enteredSum = terminal:GetData("enteredSum", 0)
    local proceedResult = false
    if self:CanPay(client, terminal) then
        proceedResult = true
    end

    if callback then
        callback(proceedResult, enteredSum)
    end
end

function Acquiring:ProcessPayment(client, terminal)
    self:Pay(client, terminal, function(result, sum, reason)
        local ent = terminal.entity
        local sound
        local message

        if (result) then
            sound = self.soundAccept
            message = Format("%s одобрительно прожужжал, что означало успех по операции на сумму %d жетонов", terminal:GetName(), sum)
        else
            sound = self.soundDeny
            message = Format("%s противно прожужжал, что означало отмену по операции на сумму %d жетонов", terminal:GetName(), sum)
        end

        ent:EmitSound(sound)
        ix.Popup:PopupEntity(ent, Vector(0, 5, 0), {
            anonymous = false,
            chatType = "it",
            text = message,
            player = client,
        }, true)
    end)
end
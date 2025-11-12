local Acquiring = ix.util.Lib("Acquiring", {
    LastAcquiringId = 0
})

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
    if self:CanPay(client, terminal) then
        if callback then
            callback(true, terminal:GetData("enteredSum", 0))
        end
    end
end

function Acquiring:ProcessPayment(client, terminal)
    self:Pay(client, terminal, function(result, sum, reason)
        local message = result
        && Format("%s одобрительно прожужжал, что означало успешность операции на сумму %d жетонов", terminal:GetName(), sum)
        || Format("%s противно прожужжал, что означало отмену операции на сумму %d жетонов", terminal:GetName(), sum)

        ix.Popup:PopupEntity(terminal.entity, Vector(0, 5, 0), {
            anonymous = false,
            chatType = "it",
            text = message,
            player = client,
        }, true)
    end)
end
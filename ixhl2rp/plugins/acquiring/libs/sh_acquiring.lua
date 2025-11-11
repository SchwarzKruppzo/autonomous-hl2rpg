local Acquiring = ix.util.Lib("Acquiring")

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

    self:SyncTerminal(terminal)
end

function Acquiring:CanPay(client, terminal)
    return true
end

function Acquiring:CanBindDatafileId(client, terminal, datafileId)
    if ix.Acquiring:CanEditDatafileId(client) && terminal && terminal.id && #datafileId == 5 then
        local id = ix.plugin.list.datafile:GetDatafileCID(datafileId)
        if (id) then
            return true
        end
    end
end

function Acquiring:SyncTerminal(terminal)
    if terminal and terminal.entity then
        for k,v in ipairs(ents.FindInSphere(terminal.entity:GetPos(), 1000)) do 
            if v:IsPlayer() then
                terminal:Sync(v)
            end
        end
    end
end

function Acquiring:BindDatafileId(terminal, datafileId)
    terminal:SetData("datafileId", datafileId)

    self:SyncTerminal(terminal)
end

function Acquiring:ProcessPayment(client, terminal)
    return true
end
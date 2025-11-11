local PLUGIN = PLUGIN

netstream.Hook("acquiringBindDatafile", function(client, datafileId)
    if ix.Acquiring:CanBindDatafileId(client, client.ixAcquiringTerminal, datafileId) then
        ix.Acquiring:BindDatafileId(client.ixAcquiringTerminal, datafileId)
        
        return client:Notify(Format("Вы привязали \"%s\" к терминалу", tostring(datafileId)))
    end

    client:Notify("Указан недоступный Datafile ID!")
end)

netstream.Hook("acquiringEnterSum", function(client, save, sum)
    sum = tonumber(sum)
    if (ix.Acquiring:CanEnterSum(client, client.ixAcquiringTerminal, sum)) then
        ix.Acquiring:EnterSum(client.ixAcquiringTerminal, sum, !!save)
        
        if (!client.ixAcquiringTerminal.entity) then
            client.ixAcquiringTerminal:Sync(client)
        end

        return client:Notify(Format("Выставлена оплата на %s жетонов", tostring(sum)))
    end

    return client:Notify("Не удалось выставить оплату!")
end)
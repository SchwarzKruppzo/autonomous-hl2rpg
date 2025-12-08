local PLUGIN = PLUGIN

local function proccessChangeAccess(client, combineLock, newAccess)
    if (!client:HasIDAccess(combineLock:GetAccess())) then
        return client:Notify("Необходим изначальный доступ этого замка!")
    end

    if (!client:HasIDAccess(newAccess)) then
        return client:Notify("Необходим выставляемый доступ!")
    end

    combineLock:SetAccess(newAccess)

    return true, client:Notify(Format("Доступ замка изменён на \"%s\"", newAccess))
end

netstream.Hook("ixOmniEditCombineLock", function(client, lookedUpEntity, newAccess)
    if (isentity(lookedUpEntity)
    && lookedUpEntity:GetClass() == "ix_combinelock"
    && isstring(newAccess)
    && #newAccess > 0
    && client:GetPos():DistToSqr(lookedUpEntity:GetPos()) < 360 * 360) then
        if (!proccessChangeAccess(client, lookedUpEntity, newAccess)) then
            return lookedUpEntity:DisplayError()
        end

        lookedUpEntity:EmitSound("buttons/combine_button7.wav")
    end
end)
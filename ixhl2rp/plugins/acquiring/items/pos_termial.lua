ITEM.name = "POS-терминал оплаты"
ITEM.description = "Кассовый аппарат, позволяющий проводить оплату при безналичном рассчёте."
ITEM.category = "Уникальное"
ITEM.rarity = 3
ITEM.model = "models/props_lab/keypad.mdl"
ITEM.width = 1
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(167.11221313477, 3.3529336452484, 39.273994445801),
	ang = Angle(13.264633178711, 181.15328979492, 0),
	fov = 2.1230087892101,
}

ITEM:AddData("acquiringId", {
	Transmit = ix.transmit.all,
})

ITEM:AddData("businessId", {
	Transmit = ix.transmit.all,
})

ITEM:AddData("datafileId", {
	Transmit = ix.transmit.all,
})

ITEM:AddData("enteredSum", {
	Transmit = ix.transmit.all,
})

ITEM:AddData("shouldSaveSum", {
	Transmit = ix.transmit.all,
})

-- fully works, but i want to players to steal them (всё работает, но я хочу чтобы игроки КРАЛИ ИХ)

-- ITEM:AddData("acquiringFrozen", {
-- 	Transmit = ix.transmit.all,
-- })
-- ITEM.functions.Freeze = {
-- 	name = "Закрепить",
--     icon = "icon16/page_white_freehand.png",
-- 	OnRun = function(item)
--         item.entity:GetPhysicsObject():Sleep()
--         item:SetData("acquiringFrozen", true)

-- 		return false
-- 	end,

-- 	OnCanRun = function(item)
-- 		return !!item.entity && !item:GetData("acquiringFrozen", false) && ix.Acquiring:CanFreezeUnfreeze(item.player, item);
-- 	end
-- }

-- ITEM.functions.UnFreeze = {
-- 	name = "Открепить",
--     icon = "icon16/page_white_freehand.png",
-- 	OnRun = function(item)
--         item.entity:GetPhysicsObject():Wake()
--         item:SetData("acquiringFrozen", false)

-- 		return false
-- 	end,

-- 	OnCanRun = function(item)
-- 		return !!item.entity && item:GetData("acquiringFrozen", false) && ix.Acquiring:CanFreezeUnfreeze(item.player, item);
-- 	end
-- }

ITEM.functions.BindDatafileId = {
	name = "Привязать Datafile ID",
    icon = "icon16/computer_edit.png",
    OnClick = function()
        Derma_StringRequest("Выставить Datafile ID", nil, "00000", function(enteredText) netstream.Start("acquiringBindDatafile", enteredText) end, nil, "Выставить", "Отменить")
    end,

	OnRun = function(item)
        item.player.ixAcquiringTerminal = item
		return false
	end,

	OnCanRun = function(item)
		return ix.Acquiring:CanEditDatafileId(item.player, item);
	end
}

ITEM.functions.EnterSum = {
	name = "Выставить оплату",
    icon = "icon16/application_xp_terminal.png",

    OnClick = function(item)
        vgui.Create("ixPosTerminalInput"):SetData({
            dismiss = item:GetData("shouldSaveSum", false),
            sum = item:GetData("enteredSum", 0),
        })
    end,
	OnRun = function(item)
        item.player.ixAcquiringTerminal = item
		return false
	end,

	OnCanRun = function(item)
		return ix.Acquiring:CanEnterSum(item.player, item, 100);
	end
}

ITEM.functions.Pay = {
	-- name = function(item)
    --     return Format("Оплатить", item:GetData("enteredSum", 0))
    -- end,
    name = "Оплатить",
    icon = "icon16/money.png",

	OnRun = function(item)
		return false
	end,

	OnCanRun = function(item)
		return !!item.entity && item:GetData("enteredSum", 0) > 0 && !!item.player:GetIDCard()
	end
}

function ITEM:PopulateTooltip(tooltip)
    local enteredSum = self:GetData("enteredSum", 0)
    local datafileId = self:GetData("datafileId", "")

    local paintFunction = function(_, width, height)
        surface.SetDrawColor(ColorAlpha(derma.GetColor("Error", tooltip), 11))
        surface.DrawRect(0, 0, width, height)
    end

    if datafileId != "" then
        local connectedTo = tooltip:AddRowAfter("description", "connectedTo")
        connectedTo:SetMinimalHidden(true)
        connectedTo:SetFont("ixMonoSmallFont")
        connectedTo:SetText(Format("POS-terminal connected to #%s Datafile ID.", datafileId))
        connectedTo.Paint = paintFunction
        connectedTo:SizeToContents()
    end

    if enteredSum > 0 then
        local enteredSumPanel = tooltip:AddRowAfter("description", "enteredSum")
        enteredSumPanel:SetMinimalHidden(true)
        enteredSumPanel:SetFont("ixMonoSmallFont")
        enteredSumPanel:SetText(Format("Their display tells you to pay %s tokens.", enteredSum))
        enteredSumPanel.Paint = paintFunction
        enteredSumPanel:SizeToContents()
    end
end

-- function ITEM:CanTake(client)
--     return !self:GetData("acquiringFrozen", false)
-- end
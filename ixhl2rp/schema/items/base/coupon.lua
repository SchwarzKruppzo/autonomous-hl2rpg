local Item = class("ItemCoupon"):implements("Item")

Item.model = "models/autonomous/citizen_coupon.mdl"
Item.iconCam = {
	pos = Vector(-2.3968870639801, -57.830913543701, 191.46466064453),
	ang = Angle(73.127899169922, 89.893287658691, 0),
	fov = 1.7308851081673,
}

function Item:Init()
	self.category = 'Купоны Альянса'

	self.stackable = true
	self.max_stack = 8

	self.functions.InsertCoupon = {
		name = "Вставить купон",
		OnRun = function(itemTable)
			local client = itemTable.player
			local data = {}
				data.start = client:GetShootPos()
				data.endpos = data.start + client:GetAimVector() * 96
				data.filter = client
			local target = util.TraceLine(data).Entity
			

			if IsValid(target) and target.IsRationDispenser then
				local display = target:GetDisplay()

				if display == 2 then
					target:StartDispense(client, 8, itemTable.uniqueID)
					target.nextUseTime = CurTime() + 2

					itemTable.bBeingUsed = true
					itemTable:Remove()
				end
			end

			return false
		end,
		OnCanRun = function(itemTable)
			local client = itemTable.player
			local entity

			if IsValid(client) then
				local target = client:GetEyeTrace().Entity

				if target and target.IsRationDispenser then
					entity = target
				end
			end

			return !itemTable.bBeingUsed and !IsValid(itemTable.entity) and IsValid(entity)
		end
	}
end

if CLIENT then
	local warning_text = "Данный купон - собственность Гражданской Обороны: при нахождении поддельной копии сообщите ближайшему патрулю. Попытка фальсификации является серьезным нарушением."
	
	function Item:PopulateTooltip(tooltip)
		local notice = tooltip:AddRowAfter("description", "notice")
		notice:SetMinimalHidden(true)
		notice:SetFont("ixMonoSmallFont")
		notice:SetText(warning_text)
		notice.Paint = function(_, width, height)
			surface.SetDrawColor(ColorAlpha(derma.GetColor("Error", tooltip), 11))
			surface.DrawRect(0, 0, width, height)
		end
		notice:SizeToContents()
	end
end

return Item
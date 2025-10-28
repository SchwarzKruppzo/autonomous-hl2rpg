local ItemMagazine = class("ItemMagazine"):implements("Item")

local function action(self, time, condition, callback)
	local uniqueID = "ixMagazine"..self:UniqueID()

	timer.Create(uniqueID, 0.1, time / 0.1, function()
		if (IsValid(self)) then
			if (condition and !condition()) then
				timer.Remove(uniqueID)

				if (callback) then
					callback(false)
				end
			elseif (callback and timer.RepsLeft(uniqueID) == 0) then
				callback(true)
			end
		else
			timer.Remove(uniqueID)

			if (callback) then
				callback(false)
			end
		end
	end)
end

function ItemMagazine:Init()
	self.category = "Журналы"

	self.functions.use = {
		name = "Прочитать",
		OnRun = function(item)
			local client, character = item.player, item.player:GetCharacter()

			item.isReading = client

			local time = 5

			client:SetAction("Вы читаете журнал...", time)

			action(client, time, function()
				if client:Alive() and !IsValid(client.ixRagdoll) and client:GetCharacter() == character then --and !client:IsUnconscious() then
					return true
				end
			end, function(success)
				item.isReading = nil

				if success then
					item:Remove()
				end

				local health = client:GetCharacter():Health()

				health:AddHediff("pornbuff", 0, {severity = 100, effect = 0, tended_start = os.time(), tended_time = 3600})
			end)
		end,
		OnCanRun = function(item)
			if IsValid(item:GetEntity()) then
				return false
			end
			
			return !item.isReading 
		end
	}
end

function ItemMagazine:CanTransfer(oldInventory, newInventory, x, y)
	if self.isReading and IsValid(self.isReading) then
		return false
	end
end

if CLIENT then
	function ItemMagazine:PopulateTooltip(tooltip)
		local uses = tooltip:AddRowAfter("name")
		uses:SetBackgroundColor(derma.GetColor("Success", tooltip))
		uses:SetText("Ускоряет время отдыха персонажа в 3 раза. Длительность эффекта - 1 час.")
	end
end

return ItemMagazine
local ItemRepairKit = class("ItemRepairKit"):implements("Item")

ItemRepairKit = ix.meta.ItemRepairKit

function ItemRepairKit:Init()
	self.category = 'Ремонтные наборы'

	self.stats = {
		uses = 5,
	}

	self.combine = self.combine or {}
	self.combine.repair = {
		name = "Отремонтировать",
		OnRun = function(item, targetItem, items)
			local client = item.player
			local character = client:GetCharacter()
			local uses = item:GetUses()

			local skill = character:GetSkillModified("guns")
			local chanceSkill = math.Remap(skill, 0, 10, 0, 1)
			local chance = (0.3 + (chanceSkill * 0.7)) * 100

			if math.random(0, 100) <= chance then
				targetItem:AddDurability(50)
				character:DoAction("repairSuccess")
			else
				client:Notify("Вам не удалось отремонитровать это!")
				character:DoAction("repairFailed")
			end

			client:EmitSound("lvs/tracks_break1.wav")

			if uses > 1 then
				item:SetData("uses", uses - 1)
			else
				item:Remove()
			end

			return
		end,
		OnCanRun = function(item, targetItem)
			if item == targetItem then
				return false
			end

			if targetItem.weaponCategory then
				return (targetItem:GetData("durability", 5) < 4)
			end
			
			return false
		end
	}

	self:AddData("uses", {
		Transmit = ix.transmit.owner,
	})
end

function ItemRepairKit:OnInstanced(isCreated)
	if isCreated then
		self:SetData("uses", self.stats.uses or 5)
	end
end

function ItemRepairKit:GetUses()
	return self:GetData("uses") or self.stats.uses
end

if CLIENT then
	function ItemRepairKit:PopulateTooltip(tooltip)
		if !self:GetEntity() then
			local uses = tooltip:AddRowAfter("name")
			uses:SetBackgroundColor(derma.GetColor("Success", tooltip))
			uses:SetText(L("usesDesc", self:GetUses(), self.stats.uses))
		end
	end
end

return ItemRepairKit
local ItemMedical = class("ItemMedical"):implements("Item")

ItemMedical.useSound = {"npc/barnacle/barnacle_gulp1.wav", "npc/barnacle/barnacle_gulp2.wav"}

local function action(self, time, condition, callback)
	local uniqueID = "ixMedical"..self:UniqueID()

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

function ItemMedical:Init()
	self.category = "item.category.medical"

	self.stats = {
		uses = 1,
		time = 10
	}

	self.functions.use = {
		name = "use.medicine",
		OnRun = function(item)
			local uses = item:GetUses()
			local client, character = item.player, item.player:GetCharacter()

			local medicineSkill = character:GetSkillModified("medicine")
			local medicineFactor = 0.5 * (medicineSkill * 0.1)
			local mod = 1 - medicineFactor

			if client.bUsingMedical then
				return
			end

			client.bUsingMedical = true
			item.inUse = client

			local time = item.stats.time or 10
			
			if (time > 0) then
    			time = time * (1 - (medicineSkill * 0.09))
			end

			client:SetAction("@medInject", time)

			action(client, time, function()
				if client:KeyDown(IN_RELOAD) then
					return false
				end

				if client:Alive() and !IsValid(client.ixRagdoll) and client:GetCharacter() == character then --and !client:IsUnconscious() then
					return true
				end
			end, function(success)
				item.inUse = nil

				if success then
					if item.useSound then
						if istable(item.useSound) then
							client:EmitSound(item.useSound[math.random(1, #item.useSound)])
						else
							client:EmitSound(item.useSound)
						end
					end

					local healData = item:OnConsume(client, nil, mod, character)
					character:DoAction("healing", healData)

					local uses = item:GetUses()

					if uses == 1 then
						local junk = item.junk
						local class = item.uniqueID
						item:Remove()

						if junk then
							local new_item = ix.Item:Instance(junk)
							new_item:SetData("class", class)
							client:AddItem(new_item)
						end
					else
						item:SetData("uses", uses - 1)
					end
				else
					client:SetAction()
				end

				client.bUsingMedical = false
			end)
		end,
		OnCanRun = function(item)
			if IsValid(item:GetEntity()) then
				return false
			end
			
			return !item.inUse 
		end
	}

	self.functions.inject = {
		name = "use.medicineOn",
		OnRun = function(item)
			local uses = item:GetUses()
			local client, character = item.player, item.player:GetCharacter()

			local data = {}
				data.start = client:GetShootPos()
				data.endpos = data.start + client:GetAimVector() * 96
				data.filter = client
			local targetEnt = util.TraceLine(data).Entity
			local target = targetEnt

			if IsValid(target.ixPlayer) then
				target = target.ixPlayer
			end

			if !IsValid(target) or !target:IsPlayer() then
				return
			end

			local medicineSkill = character:GetSkillModified("medicine")
			local medicineFactor = 0.5 * (medicineSkill * 0.1)
			local mod = 1 - medicineFactor

			if client.bUsingMedical then
				return
			end

			client.bUsingMedical = true
			item.inUse = client

			local time = (item.stats.time or 10) * .8 -- использование НА ком-то должно быть быстрее, чем использование на себе

			if (time > 0) then
    			time = time * (1 - (medicineSkill * 0.09))
			end

			client:SetAction("@medInject", time)
			
			action(client, time, function()
				if client:KeyDown(IN_RELOAD) then
					return false
				end

				if !target:Alive() then
					return false
				end

				return true
			end, function(success)
				item.inUse = nil

				if success then
					if item.useSound then
						if istable(item.useSound) then
							client:EmitSound(item.useSound[math.random(1, #item.useSound)])
						else
							client:EmitSound(item.useSound)
						end
					end

					local healData = item:OnConsume(target, client, mod, target:GetCharacter())
					character:DoAction("healingTarget", healData)

					local uses = item:GetUses()

					if uses == 1 then
						local junk = item.junk
						local class = item.uniqueID
						item:Remove()

						if junk then
							local new_item = ix.Item:Instance(junk)
							new_item:SetData("class", class)
							client:AddItem(new_item)
						end
					else
						item:SetData("uses", uses - 1)
					end
				else
					client:SetAction()
				end

				client.bUsingMedical = false
			end)
		end,
		OnCanRun = function(item)
			if IsValid(item:GetEntity()) then
				return false
			end
			
			local client = item.player

			local data = {}
				data.start = client:GetShootPos()
				data.endpos = data.start + client:GetAimVector() * 96
				data.filter = client
			local targetEnt = util.TraceLine(data).Entity
			local target = targetEnt

			if !IsValid(target) and (!target:IsPlayer() or !target:IsRagdoll()) then
				return false
			end

			return !item.inUse 
		end
	}

	self:AddData("uses", {
		Transmit = ix.transmit.owner,
	})

	self.combine = self.combine or {}
	self.combine.comb = {
		name = "combine.medicine",
		OnRun = function(item, targetItem, items)
			local uses = item:GetUses()
			local targetUses = targetItem:GetUses()
			local need = (item.stats.uses - targetUses)
			local destack = math.min(uses, need)

			targetItem:SetData("uses", targetUses + destack)

			if destack >= uses then
				item:Remove()
			else
				item:SetData("uses", uses - destack)
			end

			return
		end,
		OnCanRun = function(item, targetItem)
			if item.stats.uses <= 1 then
				return false
			end

			if targetItem.uniqueID != item.uniqueID then
				return false
			end
			
			if targetItem:GetUses() >= 5 then
				return false
			end

			if item:GetUses() >= 5 then
				return false
			end
			
			return true
		end
	}
end

function ItemMedical:GetUses()
	return self:GetData("uses")
end

function ItemMedical:OnInstanced(isCreated)
	if isCreated then
		self:SetData("uses", self.stats.uses or 1)
	end
end

function ItemMedical:CanTransfer(oldInventory, newInventory, x, y)
	if self.inUse and IsValid(self.inUse) then
		return false
	end
end

if CLIENT then
	function ItemMedical:PopulateTooltip(tooltip)
		if !self:GetEntity() then
			local uses = tooltip:AddRowAfter("name")
			uses:SetBackgroundColor(derma.GetColor("Success", tooltip))
			uses:SetText(L("usesDesc", self:GetUses(), self.stats.uses))
		end
	end
end

return ItemMedical
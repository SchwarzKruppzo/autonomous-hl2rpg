ITEM.name = "Пустой рацион"
ITEM.category = "Хлам"
ITEM.model = Model("models/weapons/w_packate.mdl")
ITEM.description = "Пустая упаковка из под рациона."

ITEM:AddData("A", {
	Transmit = ix.transmit.none,
})

ITEM:AddData("B", {
	Transmit = ix.transmit.none,
})

ITEM:AddData("T", {
	Transmit = ix.transmit.none,
})

if SERVER then
	local ITEM_A = "citizen_supplements"
	local ITEM_B = "breens_water"

	function ITEM:OnEntityCreated(ent)
		ent.Touch = function(ent, target)
			if self then
				self:Touch(ent, target)
			end
		end

		self:SetData("A", false)
		self:SetData("B", false)
	end

	function ITEM:Touch(itemEntity, ent)
		local factory = itemEntity:GetData("T", false)

		if !factory then
			return
		end

		if itemEntity.nextUse and itemEntity.nextUse > CurTime() then
			return
		end

		itemEntity.nextTick = CurTime() + 1

		if ent.GetItem then
			local item = ent:GetItem()

			if item then
				self.workers = self.workers or {}

				local hasItem1 = itemEntity:GetData("A", false)
				local hasItem2 = itemEntity:GetData("B", false)

				if item.uniqueID == ITEM_A and !hasItem1 then
					self:SetData("A", true)
					hasItem1 = itemEntity:GetData("A", false)

					ent:Remove()
					itemEntity:EmitSound("items/medshot4.wav")

					if IsValid(ent.ixHeldOwner) then
						self.workers[ent.ixHeldOwner:GetCharacter():GetID()] = true
					end
					
					if item.worker then
						self.workers[item.worker] = true
					end
					
				elseif item.uniqueID == ITEM_B and !hasItem2 then
					self:SetData("B", true)
					hasItem2 = itemEntity:GetData("B", false)

					ent:Remove()
					itemEntity:EmitSound("items/medshot4.wav")

					if IsValid(ent.ixHeldOwner) then
						self.workers[ent.ixHeldOwner:GetCharacter():GetID()] = true
					end
					
					if item.worker then
						self.workers[item.worker] = true
					end
				end

				local workers = self.workers

				if itemEntity:GetData("A", false) and itemEntity:GetData("B", false) and !itemEntity.isMerging then
					itemEntity.isMerging = true

					local pos, ang = itemEntity:GetPos(), itemEntity:GetAngles()
					itemEntity:Remove()

					timer.Simple(0, function()
						local instance = ix.Item:Instance("filled_ration")
						instance.workers = table.Copy(workers)

						ix.Item:Spawn(pos, ang, instance)
					end)

					return
				end
			end
		end
	end
end

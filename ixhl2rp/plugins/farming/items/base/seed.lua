local ItemSeed = class("ItemSeed")
implements("ItemBuildable", "ItemSeed")

ItemSeed = ix.meta.ItemSeed

function ItemSeed:Init()
	ix.meta.ItemBuildable.Init(self)

	self.category = 'Семена'

	self.functions.place = {
		name = "Посадить",
		OnRun = function(item)
			if item.preview_model then
				net.Start("build.place")
					net.WriteString(item.preview_model)
					net.WriteString(item.uniqueID)
				net.Send(item.player)

				item.player.build_item = item
				item.user = item.player
			end
		end,
		OnCanRun = function(item)
			return IsValid(item.player) and not IsValid(item.entity) and not item.player:IsRestricted() and not IsValid(item.user)
		end
	}
end

local validMatTypes = {
	MAT_DIRT,
	MAT_SAND,
	MAT_GRASS
}

function ItemSeed:CheckTrace(trace)
	local matType = trace.MatType

   	if !table.HasValue(validMatTypes, matType) then
   		return false
   	end
end

function ItemSeed:OnPlace(client, pos, angle)
	local trace = client:GetEyeTraceNoCursor()

	if self:CheckTrace(trace) == false then
		return
	end

	local ent = ents.Create("ix_plant")
	ent:SetPos(pos)
	ent:SetAngles(angle)
	ent:Spawn()
	ent:SetupPlant(self.plant, client)

	ent:SetNetVar("owner", client:GetCharacter():GetID())
end

return ItemSeed
local CHAR = ix.meta.character

function CHAR:IsDispatch()
	local faction = self:GetFaction()
	return faction == FACTION_OTA or Schema:IsPlayerCombineRank(self:GetPlayer(), "overseer")
end

local PLAYER = FindMetaTable("Player")

function PLAYER:IsDispatch()
	local faction = self:Team()
	return faction == FACTION_OTA or Schema:IsPlayerCombineRank(self, "overseer")
end

function PLAYER:GetIDCard()
	local itemID = self:GetFirstAtSlot(1, 1, "cid")

	return ix.Item.instances[itemID]
end

function PLAYER:GetIDData(data, default)
	local item = self:GetIDCard()

	if !item then 
		return false
	end

	return item:GetData(data, default)
end

function PLAYER:HasIDAccess(access)
	if self:IsOTA() then
		return true
	end
	
	local cid = self:GetIDCard()

	if !cid then 
		return false 
	end

	access = istable(access) and access or {access}

	local marks = {}
	for k, v in pairs(cid:GetData("access", {})) do
		if k:find("*") then
			marks[#marks + 1] = k
		else
			continue
		end
	end

	for k, v in ipairs(access) do
		if cid:GetData("access", {})[v] then
			continue
		else
			if #marks > 0 then
				local found = false
				for _, mark in ipairs(marks) do
					if v:match("^"..mark) then
						found = true
						break
					end
				end

				if found then continue end
			end

			return false
		end
	end

	return true
end
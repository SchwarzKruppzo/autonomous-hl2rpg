local PLUGIN = PLUGIN

PLUGIN.PassiveXPGain = 1
PLUGIN.MaxPassiveLevel = 3
PLUGIN.PassiveXPRate = 5 * 60 -- every 5 minutes

function PLUGIN:PostPlayerLoadout(client)
	local character = client:GetCharacter()
	local uniqueID = "ixLeveling" .. client:SteamID()
	timer.Remove(uniqueID)

	if character then
		timer.Create(uniqueID, self.PassiveXPRate, 0, function()
			if !IsValid(client) then
				timer.Remove(uniqueID)
				return
			end

			local character = client:GetCharacter()

			if !character then
				timer.Remove(uniqueID)
				return
			end

			local lvl = character:GetLevel()

			if lvl < 10 then
				local xpGain = math.max(self:GetRequiredLevelXP(lvl) * 0.01, 1)

				character:AddLevelXP(xpGain, 1)
			end
			
			local memory = character:GetSkillMemory() or 0
			local cost = 15

			if memory < character:GetMaxSkillMemory() then
				local drunkFactor = client:GetLocalVar("drunk", 0)
				local zone = client.inPropertyZone
				local hp = character:Health()

				if IsValid(zone) and zone.propertyID then
					local poi = ix.poi[zone.propertyID or ""]
					if poi and poi.active then
						cost = 30
					end
				end

				if drunkFactor > 0 then
					cost = cost + (cost * drunkFactor)
				end

				if hp then
					local hasBuff
					for k, v in hp:GetHediffs() do
						if v.uniqueID != "pornbuff" then continue end

						hasBuff = true
						break
					end

					if hasBuff then
						cost = cost * 3
					end
				end

				character:AddSkillMemory(cost)
			end
		end)
	end
end

function PLUGIN:CharacterRested(character, rate, timePassed)
	timePassed = timePassed or 1

	local restRate = math.min(2 * rate, 1)
	local ticksPassed = math.floor(timePassed / 300)
	local skillMemory = (30 * restRate) * ticksPassed

	character:AddSkillMemory(skillMemory)
end

function PLUGIN:OnCharacterCreated(client, character)
	local faction = ix.faction.indices[character:GetFaction()]

	if faction and faction.defaultLevel then
		character:SetLevel(faction.defaultLevel)
	end
end

function PLUGIN:PlayerMessageSend(speaker, chatType, text, bAnonymous, receivers, rawText)
	if IsValid(speaker) and !self.SocialXPConfig.blacklist[chatType] then
		-- lazy init
		if !self.socialXP then
			self.socialXP = ix.meta.ChatXPService:New(self.SocialXPConfig)
		end

		for _, client in pairs(receivers or {}) do
			if client == speaker then continue end

			local character = client:GetCharacter()
			if !character then continue end

			local xp = self.socialXP:Award(speaker, client, chatType, text)
			if xp and xp > 0 then
				character:AddLevelXP(xp, 2)
			end
		end
	end
end

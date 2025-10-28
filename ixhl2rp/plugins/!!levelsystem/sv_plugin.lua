local PLUGIN = PLUGIN

do
	local charMeta = ix.meta.character

	function charMeta:LevelUp(deltaXP)
		local nextLevel = self:GetLevel() + 1

		self:SetLevelXP(0)

		if nextLevel <= PLUGIN.maxLevel then
			self:SetSkillPoints(self:GetSkillPoints() + PLUGIN:GetPointsAtLevel(nextLevel))
			self:SetLevel(nextLevel)
			self:SetData("levelup", true)
			ix.chat.Send(nil, "level", "", nil, {self:GetPlayer()}, {
				t = 1,
			})
		end

		if deltaXP then
			self:AddLevelXP(deltaXP)
		end
	end

	function charMeta:LevelDown(deltaXP)
		local nextLevel = self:GetLevel() - 1

		self:SetLevelXP(0)
		
		if nextLevel > 0 then
			self:SetSkillPoints(self:GetSkillPoints() - PLUGIN:GetPointsAtLevel(nextLevel + 1))
			self:SetLevel(nextLevel)
			
			ix.chat.Send(nil, "level", "", nil, {self:GetPlayer()}, {
				t = 3,
			})
		end

		if deltaXP then
			self:AddLevelXP(deltaXP)
		end

		self:SetData("levelup", true)
	end

	function charMeta:AddLevelXP(xp, reasonType)
		xp = xp or 1

		local client = self:GetPlayer()

		if IsValid(client) and client:IsDonator() then
			xp = xp + (xp * 0.15)
		end

		local max = PLUGIN:GetRequiredLevelXP(self:GetLevel())
		local cur = (self:GetLevelXP() + xp)
		
		if cur >= max then
			local delta = (cur - max)
			self:LevelUp(delta)

			return
		elseif cur < 0 then
			max = PLUGIN:GetRequiredLevelXP(self:GetLevel() - 1)
			local delta = (max - cur)
			self:LevelDown(delta)

			return
		end

		self:SetLevelXP(cur)
	end

	local PLAYER = FindMetaTable("Player")

	function PLAYER:RewardXP(xp, text)
		local character = self:GetCharacter()
		
		if character then
			character:AddLevelXP(xp)

			self:NotifyLocalized("rewardXP", xp, text)
		end
	end
end
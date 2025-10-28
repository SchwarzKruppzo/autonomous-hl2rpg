local PLUGIN = PLUGIN

do
	local PLAYER = FindMetaTable("Player")

	function PLAYER:ProcessMeleeStamina(staminaUse, callbackFailed)
		local character = self:GetCharacter()
		local canAttack = true

		if staminaUse > 0 and character then
			local agility = character:GetSpecial("ag", 1)
			local LVL75 = agility >= 75
			local LVL50 = agility >= 50
			local LVL25 = agility >= 25
			local LVL5 = agility >= 5

			local agilityBuff = 0

			if LVL5 then
				agilityBuff = agilityBuff + 0.15
			end

			if LVL25 then
				agilityBuff = agilityBuff + 0.15
			end

			if LVL50 then
				agilityBuff = agilityBuff + 0.15
			end

			if LVL75 then
				agilityBuff = agilityBuff + 0.15
			end

			staminaUse = staminaUse - (staminaUse * agilityBuff)

			local value = self:GetLocalVar("stm", 0) - staminaUse

			if value < 0 then
				canAttack = false

				if callbackFailed then
					callbackFailed(self)
				end
			elseif SERVER then
				self:ConsumeStamina(staminaUse)
			end
		end

		return canAttack
	end
end
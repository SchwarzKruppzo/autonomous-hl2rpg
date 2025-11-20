ix.action = ix.action or {}
ix.action.list = ix.action.list or {}

function ix.action:Register(uniqueID, skill, data)
	if !uniqueID or !isstring(uniqueID) then
		return
	end

	data.uniqueID = uniqueID
	data.name = data.name or "Unknown"
	data.skill = skill

	if data.experience and istable(data.experience) and data.experience[1] then
		table.SortByMember(data.experience, "level", true)
		data.experience[#data.experience + 1] = {level = math.huge, xp = 0}
	end

	ix.action.list[uniqueID] = data
end

function ix.action:Get(id)
	return ix.action.list[id]
end

do
	local CHAR = ix.meta.character

	function CHAR:CanDoAction(actionID, ...)
		local action = ix.action:Get(actionID)

		if !action then
			return
		end

		if !action.CanDo then
			return true
		end

		if !isfunction(action.CanDo) then
			return self:GetSkill(action.skill) >= action.CanDo
		else
			return action:CanDo(self, self:GetSkill(action.skill), ...)
		end
	end

	function CHAR:GetMaxSkillMemory()
		return ix.config.Get("memoryXPDefault", 750) + ix.specials.list["in"]:CalculateBoostSkillMemory(self:GetSpecial("in"))
	end

	function CHAR:HasSkillMemory(xp)
		local memory = self:GetSkillMemory() or 0
		local afford = (memory - xp)
		local value = xp

		if afford < 0 then
			value = xp + afford
		end
		
		return afford >= 0, value
	end

	if SERVER then
		function CHAR:TakeSkillMemory(xp)
			local memory = self:GetSkillMemory() or 0

			memory = math.max(memory - xp, 0)

			if memory <= 0 then
				hook.Run("OnSkillMemoryDepleted", self)
			end

			self:SetSkillMemory(memory)
		end

		function CHAR:AddSkillMemory(xp)
			local oldMemory = self:GetSkillMemory() or 0
			local maxMemory = self:GetMaxSkillMemory()
			local memory = math.min(oldMemory + xp, maxMemory)

			if memory >= maxMemory then
				hook.Run("OnSkillMemoryRestored", self)
			end

			self:SetSkillMemory(memory)
		end

		function CHAR:XPStarvationMod(experience)
			local hunger = self:GetHunger()
			local thirst = self:GetThirst()
			local modA, modB = 0, 0

			if hunger < 50 and hunger >= 25 then
				modA = 0.25
			elseif hunger < 25 and hunger > 2 then
				modA = 0.35
			elseif hunger < 3 then
				modA = 0.5
			end

			if thirst < 50 and thirst >= 25 then
				modB = 0.25
			elseif thirst < 25 and thirst > 2 then
				modB = 0.35
			elseif thirst < 3 then
				modB = 0.5
			end

			local STARVATION_PERK = self:HasSpecialLevel("en", 75)

			if STARVATION_PERK then
				modB = modB * 0.5
			end


			return experience * (1 - (modA + modB))
		end

		function CHAR:DoAction(actionID, ...)
			local action = ix.action:Get(actionID)
			local result = self:GetActionResult(action, ...)

			if action.bonus then
				result = action:bonus(self, result)
			end
			
			local baseResult = result
			local starvationXP = (result - self:XPStarvationMod(result))
			local skillMemoryCost = result + starvationXP

			local canAfford, afford = self:HasSkillMemory(skillMemoryCost)

			result = math.min(result, (afford - starvationXP))

			if action.noSkillMemory then
				result = baseResult
			end
			
			if result and result > 0 then
				/*
				local int = self:GetSpecial("in")
				local intFactor = 0.15 + math.Clamp(math.Remap(int, 1, 5, 0, 0.85), 0, 0.85) + math.Clamp(math.Remap(int, 5, 10, 0, 0.5), 0, 0.5)

				result = self:XPStarvationMod(result * intFactor)*/
				
				if !action.noSkillMemory then
					self:TakeSkillMemory(afford)
				end
				
				self:UpdateSkillProgress(action.skill, result)

				if !action.noLogging then
					ix.log.Add(self:GetPlayer(), "skillAction", action.name, result, action.skill)
				end
			elseif action.alwaysLog then
				ix.log.Add(self:GetPlayer(), "skillActionNoExp", action.name)
			end
		end
	end

	local function GetXP(DoResult, skillLevel)
		for k, v in ipairs(DoResult) do
			if v.level > skillLevel then
				break
			elseif v.level <= skillLevel and skillLevel < DoResult[k + 1].level then
				return v.xp
			end
		end

		return 0
	end

	function CHAR:GetActionResult(action, ...)
		if !action.experience then
			return 0
		end

		local skill = self:GetSkill(action.skill)

		if isnumber(action.experience) then
			return action.experience
		elseif !isfunction(action.experience) then
			return GetXP(action.experience, skill)
		else
			return action:experience(self, skill, ...)
		end
	end
end

if SERVER then
	ix.log.AddType("skillAction", function(client, name, result, skill)
		return string.format("%s совершил '%s' действие, получив %d опыта в навыке %s.", client:GetName(), name, result, skill)
	end)

	ix.log.AddType("skillActionNoExp", function(client, name)
		return string.format("%s совершил '%s' действие.", client:GetName(), name)
	end)
end
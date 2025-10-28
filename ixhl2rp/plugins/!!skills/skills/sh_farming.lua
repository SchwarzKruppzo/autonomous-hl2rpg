SKILL.name = "Фермерство"
SKILL.description = "Навык, позволяющий выращивать различные агрокультуры."
SKILL.category = 4

function SKILL:GetRequiredXP(skills, level)
	return math.ceil(75 * (level ^ 1.525) + 100)
end

ix.action:Register("farming", "farming", {
	name = "Фермерство",
	experience = function(action, character, skill, price, plant)
		return price
	end
})

ix.action:Register("farmingWater", "farming", {
	name = "Уход за растением",
	experience = function(action, character, skill, price, plant)
		return price
	end
})

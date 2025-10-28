SKILL.name = "Ремесло"
SKILL.description = "Навык, позволяющий перерабатывать различные материалы."
SKILL.category = 4

function SKILL:GetRequiredXP(skills, level)
	return math.ceil(250 * (level ^ 1.3) + 75)
end

ix.action:Register("craft_crafting", "crafting", {
	name = "Крафт",
	experience = function(action, character, skill, price)
		if character:HasSpecialLevel("st", 25) then
			price = price + (price * 0.15)
		end
		
		return price
	end
})

ix.action:Register("craft_recycle", "crafting", {
	name = "Переработка мусора",
	experience = function(action, character, skill, price)
		if character:HasSpecialLevel("st", 25) then
			price = price + (price * 0.15)
		end

		return price
	end
})
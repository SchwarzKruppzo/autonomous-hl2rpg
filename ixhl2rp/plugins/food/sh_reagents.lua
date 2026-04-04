local Reagents = ix.Reagents

local function makeAlcoholConsume(perMl, time)
	return function(self, client, consumed)
		local character = client:GetCharacter()
		if !character then return end

		local health = character:Health()
		if !health then return end

		health:AddHediff("alcohol", 0, {severity = 0, effect = perMl * consumed, tended_start = os.time(), tended_time = time})
	end
end

-- Base liquids
Reagents:Register("water", {
	state = ix.Reagents.liquid,
	thirst = 0.15,
	hunger = 0,
})

Reagents:Register("dirty_water", {
	state = ix.Reagents.liquid,
	thirst = 0.061,
	hunger = 0,
	OnConsume = function(self, client, consumed)
		local character = client:GetCharacter()
		if !character or client:Team() == FACTION_VORTIGAUNT then return end

		local sipEquiv = consumed / 66
		local rad = 5 * sipEquiv

		if math.random(1, 10) == 1 then
			rad = rad + 15 * sipEquiv
		end

		character:SetRadLevel(character:GetRadLevel() + rad)
	end,
})

Reagents:Register("breens_water", {
	state = ix.Reagents.liquid,
	thirst = 0.152,
	hunger = 0,
})

Reagents:Register("smooth_breens_water", {
	state = ix.Reagents.liquid,
	thirst = 0.303,
	hunger = 0,
})

Reagents:Register("special_breens_water", {
	state = ix.Reagents.liquid,
	thirst = 0.303,
	hunger = 0,
})

-- Alcohol
Reagents:Register("vodka", {
	state = ix.Reagents.liquid,
	thirst = 0.093,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.267, 120),
})

Reagents:Register("whiskey", {
	state = ix.Reagents.liquid,
	thirst = 0.093,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.267, 120),
})

Reagents:Register("wine", {
	state = ix.Reagents.liquid,
	thirst = 0.133,
	hunger = 0.027,
	OnConsume = makeAlcoholConsume(0.333, 300),
})

Reagents:Register("old_wine", {
	state = ix.Reagents.liquid,
	thirst = 0.16,
	hunger = 0.04,
	OnConsume = makeAlcoholConsume(0.333, 300),
})

Reagents:Register("beer", {
	state = ix.Reagents.liquid,
	thirst = 0.212,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.303, 60),
})

Reagents:Register("spoiled_beer", {
	state = ix.Reagents.liquid,
	thirst = 0.091,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.076, 60),
})

Reagents:Register("spoiled_whiskey", {
	state = ix.Reagents.liquid,
	thirst = 0.18,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.1, 60),
})

Reagents:Register("rum", {
	state = ix.Reagents.liquid,
	thirst = 0.093,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.133, 120),
})

Reagents:Register("cognac", {
	state = ix.Reagents.liquid,
	thirst = 0.093,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.133, 120),
})

Reagents:Register("brandy", {
	state = ix.Reagents.liquid,
	thirst = 0.093,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.133, 60),
})

Reagents:Register("bourbon", {
	state = ix.Reagents.liquid,
	thirst = 0.093,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.133, 60),
})

Reagents:Register("tequila", {
	state = ix.Reagents.liquid,
	thirst = 0.093,
	hunger = 0,
})

Reagents:Register("champagne", {
	state = ix.Reagents.liquid,
	thirst = 0.133,
	hunger = 0.013,
	OnConsume = makeAlcoholConsume(0.067, 300),
})

Reagents:Register("moonshine", {
	state = ix.Reagents.liquid,
	thirst = 0.16,
	hunger = 0,
	OnConsume = makeAlcoholConsume(1.0, 120),
})

Reagents:Register("sake", {
	state = ix.Reagents.liquid,
	thirst = 0.139,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.174, 300),
})

Reagents:Register("hawthorn", {
	state = ix.Reagents.liquid,
	thirst = 0.182,
	hunger = 0,
})

-- Non-alcoholic
Reagents:Register("tea", {
	state = ix.Reagents.liquid,
	thirst = 0.34,
	hunger = 0,
})

Reagents:Register("green_tea", {
	state = ix.Reagents.liquid,
	thirst = 0.16,
	hunger = 0,
})

Reagents:Register("coffee", {
	state = ix.Reagents.liquid,
	thirst = 0.2,
	hunger = 0,
})

Reagents:Register("cream_coffee", {
	state = ix.Reagents.liquid,
	thirst = 0.24,
	hunger = 0,
})

Reagents:Register("milk", {
	state = ix.Reagents.liquid,
	thirst = 0.05,
	hunger = 0.01,
})

Reagents:Register("milk_tea", {
	state = ix.Reagents.liquid,
	thirst = 0.2,
	hunger = 0,
})

Reagents:Register("cola", {
	state = ix.Reagents.liquid,
	thirst = 0.182,
	hunger = 0,
})

Reagents:Register("old_soda", {
	state = ix.Reagents.liquid,
	thirst = 0.084,
	hunger = 0,
})

Reagents:Register("apple_juice", {
	state = ix.Reagents.liquid,
	thirst = 0.152,
	hunger = 0,
})

Reagents:Register("orange_juice", {
	state = ix.Reagents.liquid,
	thirst = 0.152,
	hunger = 0,
})

Reagents:Register("coconut_cocktail", {
	state = ix.Reagents.liquid,
	thirst = 0.364,
	hunger = 0.030,
})

Reagents:Register("pineapple_cocktail", {
	state = ix.Reagents.liquid,
	thirst = 0.364,
	hunger = 0.030,
})

Reagents:Register("energy_drink", {
	state = ix.Reagents.liquid,
	thirst = 0.333,
	hunger = -0.03,
})

Reagents:Register("juniper", {
	state = ix.Reagents.liquid,
	thirst = 0.152,
	hunger = 0,
})

Reagents:Register("olive_oil", {
	state = ix.Reagents.liquid,
	thirst = 0.02,
	hunger = 0.03,
})

Reagents:Register("quasi_cola", {
	state = ix.Reagents.liquid,
	thirst = 0.227,
	hunger = 0.076,
})

-- Solid food base reagent
Reagents:Register("food_matter", {
	state = ix.Reagents.solid,
	thirst = 0,
	hunger = 0,
})

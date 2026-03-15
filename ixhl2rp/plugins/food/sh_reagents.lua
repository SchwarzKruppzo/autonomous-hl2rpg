local Reagent = ix.meta.Reagent

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
Reagent:Register("water", {
	state = ix.Reagents.liquid,
	thirst = 0.15,
	hunger = 0,
})

Reagent:Register("dirty_water", {
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

Reagent:Register("breens_water", {
	state = ix.Reagents.liquid,
	thirst = 0.152,
	hunger = 0,
})

Reagent:Register("smooth_breens_water", {
	state = ix.Reagents.liquid,
	thirst = 0.303,
	hunger = 0,
})

Reagent:Register("special_breens_water", {
	state = ix.Reagents.liquid,
	thirst = 0.303,
	hunger = 0,
})

-- Alcohol
Reagent:Register("vodka", {
	state = ix.Reagents.liquid,
	thirst = 0.093,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.267, 120),
})

Reagent:Register("whiskey", {
	state = ix.Reagents.liquid,
	thirst = 0.093,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.267, 120),
})

Reagent:Register("wine", {
	state = ix.Reagents.liquid,
	thirst = 0.133,
	hunger = 0.027,
	OnConsume = makeAlcoholConsume(0.333, 300),
})

Reagent:Register("old_wine", {
	state = ix.Reagents.liquid,
	thirst = 0.16,
	hunger = 0.04,
	OnConsume = makeAlcoholConsume(0.333, 300),
})

Reagent:Register("beer", {
	state = ix.Reagents.liquid,
	thirst = 0.212,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.303, 60),
})

Reagent:Register("spoiled_beer", {
	state = ix.Reagents.liquid,
	thirst = 0.091,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.076, 60),
})

Reagent:Register("spoiled_whiskey", {
	state = ix.Reagents.liquid,
	thirst = 0.18,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.1, 60),
})

Reagent:Register("rum", {
	state = ix.Reagents.liquid,
	thirst = 0.093,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.133, 120),
})

Reagent:Register("cognac", {
	state = ix.Reagents.liquid,
	thirst = 0.093,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.133, 120),
})

Reagent:Register("brandy", {
	state = ix.Reagents.liquid,
	thirst = 0.093,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.133, 60),
})

Reagent:Register("bourbon", {
	state = ix.Reagents.liquid,
	thirst = 0.093,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.133, 60),
})

Reagent:Register("tequila", {
	state = ix.Reagents.liquid,
	thirst = 0.093,
	hunger = 0,
})

Reagent:Register("champagne", {
	state = ix.Reagents.liquid,
	thirst = 0.133,
	hunger = 0.013,
	OnConsume = makeAlcoholConsume(0.067, 300),
})

Reagent:Register("moonshine", {
	state = ix.Reagents.liquid,
	thirst = 0.16,
	hunger = 0,
	OnConsume = makeAlcoholConsume(1.0, 120),
})

Reagent:Register("sake", {
	state = ix.Reagents.liquid,
	thirst = 0.139,
	hunger = 0,
	OnConsume = makeAlcoholConsume(0.174, 300),
})

Reagent:Register("hawthorn", {
	state = ix.Reagents.liquid,
	thirst = 0.182,
	hunger = 0,
})

-- Non-alcoholic
Reagent:Register("tea", {
	state = ix.Reagents.liquid,
	thirst = 0.34,
	hunger = 0,
})

Reagent:Register("green_tea", {
	state = ix.Reagents.liquid,
	thirst = 0.16,
	hunger = 0,
})

Reagent:Register("coffee", {
	state = ix.Reagents.liquid,
	thirst = 0.2,
	hunger = 0,
})

Reagent:Register("cream_coffee", {
	state = ix.Reagents.liquid,
	thirst = 0.24,
	hunger = 0,
})

Reagent:Register("milk", {
	state = ix.Reagents.liquid,
	thirst = 0.05,
	hunger = 0.01,
})

Reagent:Register("milk_tea", {
	state = ix.Reagents.liquid,
	thirst = 0.2,
	hunger = 0,
})

Reagent:Register("cola", {
	state = ix.Reagents.liquid,
	thirst = 0.182,
	hunger = 0,
})

Reagent:Register("old_soda", {
	state = ix.Reagents.liquid,
	thirst = 0.084,
	hunger = 0,
})

Reagent:Register("apple_juice", {
	state = ix.Reagents.liquid,
	thirst = 0.152,
	hunger = 0,
})

Reagent:Register("orange_juice", {
	state = ix.Reagents.liquid,
	thirst = 0.152,
	hunger = 0,
})

Reagent:Register("coconut_cocktail", {
	state = ix.Reagents.liquid,
	thirst = 0.364,
	hunger = 0.030,
})

Reagent:Register("pineapple_cocktail", {
	state = ix.Reagents.liquid,
	thirst = 0.364,
	hunger = 0.030,
})

Reagent:Register("energy_drink", {
	state = ix.Reagents.liquid,
	thirst = 0.333,
	hunger = -0.03,
})

Reagent:Register("juniper", {
	state = ix.Reagents.liquid,
	thirst = 0.152,
	hunger = 0,
})

Reagent:Register("olive_oil", {
	state = ix.Reagents.liquid,
	thirst = 0.02,
	hunger = 0.03,
})

Reagent:Register("quasi_cola", {
	state = ix.Reagents.liquid,
	thirst = 0.227,
	hunger = 0.076,
})

-- Solid food base reagent
Reagent:Register("food_matter", {
	state = ix.Reagents.solid,
	thirst = 0,
	hunger = 0,
})

local Farming = ix.Farming

Farming:RegisterPlant("tomato", {
	Name = "plant.tomato",
	Description = "plant.tomato.desc",
	Model = "models/autonomous/farming/plant_tomato.mdl",
	Stages = {
		{
			Time = 600,
			Bodygroup = 0,
		},
		{
			Time = 900,
			HydrationCost = 60,
			Bodygroup = 1,
		},
		{
			Time = 1600,
			HydrationCost = 80,
			Bodygroup = 2,
		},
		{
			Time = 3600,
			RepeatTime = 1800,
			HydrationCost = 110,
			Bodygroup = 3,
			Harvest = true,
		}
	},
	MinCount = 3,
	MaxCount = 6,
	Result = "tomato",
	HarvestBodygroup = 2,
	RewardXP = 200,
	SkillXP = 30
})

Farming:RegisterPlant("potato", {
	Name = "plant.potato",
	Description = "plant.potato.desc",
	Model = "models/autonomous/farming/plant_potato.mdl",
	Stages = {
		{
			Time = 600,
			Bodygroup = 0,
		},
		{
			Time = 900,
			HydrationCost = 50,
			Bodygroup = 1,
		},
		{
			Time = 1600,
			HydrationCost = 60,
			Bodygroup = 2,
		},
		{
			Time = 3000,
			RepeatTime = 1600,
			HydrationCost = 90,
			Bodygroup = 3,
			Harvest = true,
		}
	},
	MinCount = 4,
	MaxCount = 6,
	Result = "union_branded_potato",
	HarvestBodygroup = 2,
	RewardXP = 100,
	SkillXP = 15
})
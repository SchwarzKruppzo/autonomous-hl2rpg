local Farming = ix.Farming

Farming:RegisterPlant("tomato", {
	Name = "Куст томата",
	Description = "Томат в процессе выращивания. Еще формируемые плоды томата уже свисают с растения, они явно меньше в размере нежели их довоенные аналоги - но выглядят как лучший ужин что вы можете себе позволить за пределами города.",
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
	Name = "Куст картофеля",
	Description = "Картофель в процессе выращивания. Еще формируемые клубни картофеля уже выглядывают из-под земли, они явно меньше в размере нежели их довоенные аналоги - но выглядят как лучший ужин что вы можете себе позволить за пределами города.",
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
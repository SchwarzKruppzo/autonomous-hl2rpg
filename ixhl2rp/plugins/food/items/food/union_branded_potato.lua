ITEM.name = "Сырой картофель"
ITEM.description = "Простая сырая картошка. Можно приготовить."
ITEM.model = "models/foodnhouseholditems/potato.mdl"
ITEM.iconCam = {
	pos = Vector(75.648536682129, 194.7908782959, 126.34627532959),
	ang = Angle(31.159410476685, 248.81175231934, 0),
	fov = 1.8642185963154,
}
ITEM.cost = 3
ITEM.width = 1
ITEM.height = 1

ITEM.stats.container = false
ITEM.stats.thirst = -5
ITEM.stats.hunger = 10
ITEM.stats.uses = 2
ITEM.stats.expireTime = 345600 -- 4 days

ITEM.seed = "seed_potato"
ITEM.functions.zfarm = {
	name = "Подготовить семена",
	OnRun = function(item)
		local client, character = item.player, item.player:GetCharacter()
		
		local skill = character:GetSkillModified("farming")
		local chanceSkill = math.Remap(skill, 0, 10, 0, 75)

		if skill <= 0 then
			client:Notify("Необходим навык фермерства 1 и выше!")
			return
		end
		
		item:Remove()

		if math.random(0, 100) <= chanceSkill then
			local new_item = ix.Item:Instance(item.seed)
				
			if !client:AddItem(new_item) then
				ix.Item:Spawn(client, nil, new_item)
			end
		else
			client:Notify("Вам не удалось подготовить семена!")
			return
		end

		return true
	end,
	OnCanRun = function(item) return !IsValid(item:GetEntity()) end
}
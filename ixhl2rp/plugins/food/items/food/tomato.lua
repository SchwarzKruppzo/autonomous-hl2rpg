ITEM.name = "Помидор"
ITEM.description = "Синтетический, а может и натуральный помидор, что внутри настолько сочный, что при укусе весь сок разлетается в разные стороны."
ITEM.model = "models/foodnhouseholditems/tomato.mdl"
ITEM.cost = 12
ITEM.width = 1
ITEM.height = 1

ITEM.iconCam = {
	pos = Vector(158.39688110352, 147.26866149902, 113.73490905762),
	ang = Angle(27.731882095337, 222.91452026367, 0),
	fov = 1.6628369578245,
}

ITEM.stats.container = false
ITEM.stats.hunger = 7
ITEM.stats.uses = 2
ITEM.stats.expireTime = 345600 -- 4 days

ITEM.seed = "seed_tomato"
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
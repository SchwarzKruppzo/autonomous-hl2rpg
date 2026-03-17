local PLUGIN = PLUGIN

PLUGIN.name = "Loot System"
PLUGIN.author = "SchwarzKruppzo"
PLUGIN.description = "Adds a enhanced loot system."

ix.util.Include("sv_loot.class.lua")
ix.util.Include("sh_lootcontainer.class.lua")

ix.util.Include("sh_definitions.lua")
ix.util.Include("sv_hooks.lua")
/*

local function rewardItem(client, item_id)
	local new_item = ix.Item:Instance(item_id)
	local success = client:AddItem(new_item)

	if !success then
		ix.Item:Spawn(client, nil, new_item)
	end
end


local entries = {
	{
		name = "торт",
		weight = 175, 
		reward = function(client)
			rewardItem(client, (math.random(1, 2) == 1 and "creampie_cake" or "chocolate_cake"))
			
			client:ChatNotify(L("loot.prizeCake", client))
		end
	},
	{ 
		name = "шампанское",
		weight = 80, 
		reward = function(client)	
			rewardItem(client, "champagne")
			
			client:ChatNotify(L("loot.prizeChampagne", client))
		end
	},
	{ 
		name = "загадочную монету",
		weight = 50, 
		reward = function(client)
			rewardItem(client, "procenko_coin")

			client:ChatNotify(L("loot.prizeCoin", client))
		end
	},
	{ 
		name = "200 токенов",
		weight = 35, 
		reward = function(client)
			client:GetCharacter():GiveMoney(200)

			client:ChatNotify(L("loot.prizeTokens", client))
		end
	},
	{ 
		name = "купон на стимуляцию",
		weight = 50, 
		reward = function(client)
			rewardItem(client, "coupon_resort")

			client:ChatNotify(L("loot.prizeCoupon", client))
		end
	},
	{ 
		name = "кольцо 2024",
		weight = 40, 
		reward = function(client)
			rewardItem(client, "ring2024")

			client:ChatNotify(L("loot.prizeRing", client))
		end
	},
	{ 
		name = "3000 опыта",
		weight = 30, 
		reward = function(client)
			local skills = table.GetKeys(ix.skills.list)
			local skill = skills[math.random(1, #skills)]
			local xp = 3000

			local tbl = ix.skills.list[skill]
			
			client:GetCharacter():IncreaseSkill(skill, xp)
			client:ChatNotify(L("loot.prizeXp", client, L(tbl.name, client)))
		end
	},
	{ 
		name = "15 дней подписки",
		weight = 20, 
		reward = function(client)
			if !client:IsDonator() then
				ix.plugin.list["subscription"]:SetDonateSubscription(client:SteamID64(), os.time() + 1296000)
				client:ChatNotify(L("loot.prizeSubscription", client))
			else
				ix.plugin.list["subscription"]:AddDonateSubscription(client:SteamID64(), 1296000)
				client:ChatNotify(L("loot.prizeSubscriptionExtend", client))
			end
		end
	},
	{ 
		name = "15 мегабайт кастомной модели",
		weight = 30, 
		reward = function(client)
			client:ChatNotify(L("loot.prizeCustomModel", client, client:SteamID64().."-"..util.CRC(client:SteamID64().."x")))
		end
	},
	{ 
		name = "7 дней с хедкрабом",
		weight = 10, 
		reward = function(client)
			client:ChatNotify(L("loot.prizeHeadcrab", client))
		end
	},
	{ 
		name = "тайную информацию",
		weight = 10, 
		reward = function(client)
			client:ChatNotify(L("loot.prizeSecret", client))
		end
	},
	{ 
		name = "фишку корпората",
		weight = 20, 
		reward = function(client)
			rewardItem(client, "corp2024")

			client:ChatNotify(L("loot.prizeCorp", client))
		end
	},
	{ 
		name = "надувного генерала гавса",
		weight = 20, 
		reward = function(client)
			rewardItem(client, "gavs2024")

			client:ChatNotify(L("loot.prizeGavs", client))
		end
	},
}

local group

if SERVER then
	group = ix.meta.LootGroup:New()

	for k, v in ipairs(entries) do
		group:Add(v)
	end
end

ix.command.Add("dr", {
	description = "",
	privilege = "CharDesc",
	OnRun = function(self, client)
		if !client:GetData("dr1", false) then
			math.randomseed(os.time())

			local entry = group:Roll(client)
			entry.reward(client)

			ix.log.AddRaw(client:Name() .. " использовал промокод и выиграл ".. entry.name .."!")
			client:SetData("dr1", true)
		end
	end
})*/
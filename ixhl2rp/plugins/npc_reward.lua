local PLUGIN = PLUGIN

PLUGIN.name = "NPC Reward"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

PLUGIN.NPCReward = {
	["npc_zombie"] = 50,
	["npc_headcrab"] = 100,
	["npc_headcrab_fast"] = 150,
	["npc_headcrab_black"] = 150,
	["npc_fastzombie"] = 150,
	["npc_poisonzombie"] = 100,
	["npc_zombine"] = 200,
	["npc_antlion"] = 150,
	["npc_antlion_grub"] = 10,
	["npc_antlionguard"] = 2000,
	["npc_antlionguardian"] = 2500,
	["npc_antlion_worker"] = 150
}

PLUGIN.NPCScale = {
	["npc_zombie"] = 2,
	["npc_headcrab"] = 1.5,
	["npc_headcrab_black"] = 1.25,
	["npc_zombine"] = 2,
	["npc_antlion"] = 1.75,
	["npc_antlion_worker"] = 1.5,
	["npc_antlionguard"] = 5,
	["npc_antlionguardian"] = 5,
}

function PLUGIN:PlayerSpawnedNPC(client, npc)
	local class = npc:GetClass()

	if self.NPCScale[class] then
		local maxHealth = npc:GetMaxHealth()

		npc:SetMaxHealth(maxHealth * self.NPCScale[class])
		npc:SetHealth(maxHealth)
	end
end

function PLUGIN:OnNPCKilled(entity, attacker, inflictor)
	local wasDamaged = entity.wasDamagedBy

	if wasDamaged and !table.IsEmpty(wasDamaged) then
		local maxDmg = entity.totalDmg

		for client, dmg in pairs(wasDamaged) do
			local percent = math.Clamp(dmg / maxDmg, 0, 1)

			if IsValid(client) then
				local xp = math.Round((self.NPCReward[entity:GetClass()] or 100) * percent)

				client:RewardXP(math.max(xp, 10), "убийство")
			end
		end
	end
end

function PLUGIN:EntityTakeDamage(entity, dmginfo)
	local attacker = dmginfo:GetAttacker()

	if IsValid(attacker) and attacker:IsPlayer() and entity:IsNPC() then
		local dmg = dmginfo:GetDamage()

		entity.totalDmg = entity.totalDmg or 0
		entity.wasDamagedBy = entity.wasDamagedBy or {}

		entity.wasDamagedBy[attacker] = (entity.wasDamagedBy[attacker] or 0) + dmg
		entity.totalDmg = entity.totalDmg + dmg
	end
end

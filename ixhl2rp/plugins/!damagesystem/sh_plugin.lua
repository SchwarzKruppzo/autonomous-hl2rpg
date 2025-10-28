local PLUGIN = PLUGIN

PLUGIN.name = "Damage System"
PLUGIN.author = "SchwarzKruppzo"
PLUGIN.description = ""

PLUGIN.RANGE_CLOSE = 1
PLUGIN.RANGE_MEDIUM = 2
PLUGIN.RANGE_LONG = 3
PLUGIN.RANGE_FAR = 4

ix.char.RegisterVar("shock", {
	field = "shock",
	fieldType = ix.type.number,
	default = 0,
	isLocal = true,
	Net = {
		Transmit = ix.transmit.owner
	},
	bNoDisplay = true
})

ix.char.RegisterVar("blood", {
	field = "blood",
	fieldType = ix.type.number,
	default = -1,
	isLocal = true,
	Net = {
		Transmit = ix.transmit.owner
	},
	bNoDisplay = true
})

ix.char.RegisterVar("dmgData", {
	field = "dmgData",
	fieldType = ix.type.string,
	default = {
		isBleeding = 0,
		isPain = false,
		bleedBone = 0,
		bleedDmg = 0
	},
	isLocal = true,
	Net = {
		Transmit = ix.transmit.owner
	},
	bNoDisplay = true
})

ix.Net:AddPlayerVar("knocked", true, nil, ix.Net.Type.Bool)
ix.Net:AddPlayerVar("doll", false, nil, ix.Net.Type.EntityIndex)
ix.Net:AddPlayerVar("crit", false, nil, ix.Net.Type.Bool)
ix.Net:AddPlayerVar("isBleeding", false, nil, ix.Net.Type.Bool)
ix.Net:AddPlayerVar("bleedingBone", false, nil, ix.Net.Type.EntityIndex)

do
	local PLAYER = FindMetaTable("Player")
	local CHAR = ix.meta.character

	function PLAYER:IsUnconscious()
		return self:GetLocalVar("knocked", false)
	end

	function CHAR:IsBleeding()
		return self:GetDmgData().isBleeding or false
	end

	function CHAR:IsFeelPain()
		return self:GetDmgData().isPain or false
	end

	function CHAR:GetBleedingBone()
		return self:GetDmgData().bleedBone or 0
	end
end

PLUGIN.hitBones = {
	[HITGROUP_HEAD] = {
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
	},
	[HITGROUP_CHEST] = {
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
	},
	[HITGROUP_STOMACH] = {
		"ValveBiped.Bip01_Spine1",
		"ValveBiped.Bip01_Spine",
	},
	[HITGROUP_LEFTARM] = {
		"ValveBiped.Bip01_L_UpperArm",
		"ValveBiped.Bip01_L_Forearm",
		"ValveBiped.Bip01_L_Hand",
	},
	[HITGROUP_RIGHTARM] = {
		"ValveBiped.Bip01_R_UpperArm",
		"ValveBiped.Bip01_R_Forearm",
		"ValveBiped.Bip01_R_Hand",
	},
	[HITGROUP_LEFTLEG] = {
		"ValveBiped.Bip01_L_Thigh",
		"ValveBiped.Bip01_L_Calf",
	},
	[HITGROUP_RIGHTLEG] = {
		"ValveBiped.Bip01_R_Thigh",
		"ValveBiped.Bip01_R_Calf",
	},
	[HITGROUP_GENERIC] = {
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
	},
}

do
	local clrRed = Color(255, 100, 100, 255)

	ix.chat.Register("dmgMsg", {
		OnCanHear = function(self, speaker, listener)
			return true
		end,
		CanSay = function(self, speaker)
			return !IsValid(speaker)
		end,
		OnChatAdd = function(self, speaker, text, bAnonymous, data)
			if data.t == 1 then
				chat.AddText(clrRed, string.format("Вас добивает игрок %s (%s)!", data.attacker:Name(), data.attacker:GetAnonID()))
			elseif data.t == 2 then
				chat.AddText(color_white, "После игровой смерти, Вы потеряли 50% своих вещей и жетонов.")
			elseif data.t == 3 then
				chat.AddText(color_white, "Вас прекратили добивать!")
			end
		end
	})

	ix.chat.Register("dmgAdminMsg", {
		OnCanHear = function(self, speaker, listener)
			if CAMI.PlayerHasAccess(listener, "Helix - Admin Chat", nil) then
				return true
			end

			return false
		end,
		CanSay = function(self, speaker)
			return !IsValid(speaker)
		end,
		OnChatAdd = function(self, speaker, text, bAnonymous, data)
			if !CAMI.PlayerHasAccess(LocalPlayer(), "Helix - Admin Chat", nil) then
				return
			end

			if data.t == 1 then
				chat.AddText(clrRed, string.format("Игрок %s (%s) пытается добить игрока %s (%s)!", data.attacker:Name(), data.attacker:GetAnonID(), data.crit:Name(), data.crit:GetAnonID()))
			elseif data.t == 2 then
				chat.AddText(clrRed, string.format("%s (%s) был добит игроком %s (%s)!", data.crit:Name(), data.crit:GetAnonID(), data.attacker:Name(), data.attacker:GetAnonID()))
			end
		end
	})
end

function PLUGIN:PlayerTraceAttack(client, dmgInfo, dir, trace)
	if dmgInfo:GetDamage() <= 0 then
		return true
	end

	if CLIENT then
		return true
	end
end

ix.util.Include("meta/sh_damage.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("sv_hooks.lua")

do
	local PLAYER = FindMetaTable("Player")

	function PLAYER:SetupDataTables()
		self:NetworkVar("Float", 0, "StopModifier")
		self:NetworkVar("Float", 1, "SprintSpeed")
		self:NetworkVar("Bool", 0, "RunFading")
		self:NetworkVar("Bool", 1, "SprintMove")
	end

	hook.Add("OnEntityCreated", "rp.damage.speed", function(ent)
	    if ent:IsPlayer() then
	        ent:InstallDataTable()
	        ent:SetupDataTables()
	    end
	end)

	hook.Add("NetworkEntityCreated", "rp.damage.speed", function(ent)
		if ent:IsPlayer() then
	        ent:InstallDataTable()
	        ent:SetupDataTables()
	    end
	end)
	
	hook.Add("StartCommand", "rp.damage.speed", function(ply, cmd)
		if cmd:KeyDown(IN_JUMP) and ply:GetMoveType() != MOVETYPE_NOCLIP and ply:GetNetVar("brth", false) then
			cmd:ClearButtons()
		end
	end)

	hook.Add("OnPlayerHitGround", "rp.damage.speed", function(ply, inWater, onFloater, speed)
		if inWater then
			return
		end

		ply:SetStopModifier(math.max(ply:GetStopModifier() - (speed * 0.0012), 0.2))
	end)

	local function CalcAthleticsSpeed(athletics)
		return 1 + (athletics * 0.1) * 0.15
	end

	local function CalcAthletics(ply)
		local character = ply:GetCharacter()

		if character then
			local id = character:GetID()

			if ply.speedCharID != id or ply.recalculateSpeed then
				ply.runSpeed = ix.config.Get("runSpeed") * CalcAthleticsSpeed(character:GetSkillModified("athletics"))
				ply.jumpPower = 130 * (1 + math.min(math.Remap(character:GetSkillModified("acrobatics"), 1, 10, 0, 0.7), 0.7))
				ply.speedCharID = id
				ply.recalculateSpeed = false
				ply:SetRunSpeed(ply.runSpeed)
				ply:SetJumpPower(ply.jumpPower)
			end
		end
	end

	local function CheckJump(ply, mv)
		local worldspawn = SERVER and game.GetWorld() or Entity(0)
		
		if !IsValid(ply:GetGroundEntity()) and ply:GetGroundEntity() != worldspawn then
			local buttons = bit.bor(mv:GetOldButtons(), IN_JUMP)
			mv:SetOldButtons(buttons)
			return
		end

		if bit.band(mv:GetOldButtons(), IN_JUMP) != 0 then
			return
		end

		if bit.band(ply:GetFlags(), FL_DUCKING) > 0 then
			return
		end

		if SERVER then
			if ply:OnGround() then
				local power = ply:GetJumpPower()

				ply:ConsumeStamina(power / 12)


				local ct = CurTime()
				if !ply.nextJumpTick or ct > ply.nextJumpTick then
					ply:GetCharacter():DoAction("jump")

					ply.nextJumpTick = ct + 0.24
				end
			end
		end
	end

	hook.Add("Move", "rp.damage.speed2", function(ply, mv, cmd)
		local mod = ply:GetStopModifier()
		local speedFactor = 1
		local speedx = ply:GetNWFloat("speed_debuff")

		if speedx <= 1 then
			speedFactor = speedx
		end

		if ply:OnGround() then
			if mod < 1 then
				mod = mod + 0.01

				ply:SetStopModifier(mod)

				local velocity = mv:GetVelocity()
				mv:SetVelocity(velocity * mod)
			elseif mod > 1 and mod != 1 then
				ply:SetStopModifier(1)
			end
		end
		
		speedFactor = speedFactor * mod


		
		local velLength = ply:GetVelocity():Length2DSqr()

		CalcAthletics(ply)

		if bit.band(mv:GetButtons(), IN_JUMP) != 0 then
			CheckJump(ply, mv )
		else
			local buttons = bit.band(mv:GetOldButtons(), bit.bnot(IN_JUMP))
			mv:SetOldButtons(buttons)
		end

		local faction = ply:Team()
		
		if (faction == FACTION_ZOMBIE or faction == FACTION_SYNTH) then
			mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * speedFactor)
			return
		end

		if ply:GetNetVar("brth", false) or bit.band(mv:GetButtons(), IN_DUCK) != 0 or ply:IsProne() then
			if ply:GetSprintMove() then
				ply:SetSprintMove(false)
				ply:SetSprintSpeed(0)
			end

			mv:SetMaxClientSpeed(ply:GetWalkSpeed())
			return
		end


		if mv:KeyReleased(IN_SPEED) or mv:KeyDown(IN_SPEED) and velLength < .25 then
			ply:SetRunFading(true)
		end

		if mv:KeyDown(IN_MOVELEFT) or mv:KeyDown(IN_MOVERIGHT) then
			ply:SetRunFading(true)
			mv:SetSideSpeed(mv:GetSideSpeed() * .35)
		end

		local speedx = FrameTime() * 128

		if mv:KeyDown(IN_SPEED) and velLength > .25 or ply:GetSprintMove() and !ply:GetRunFading() then
			if !ply:GetSprintMove() then
				ply:SetRunFading(false)
				ply:SetSprintMove(true)
				ply:SetSprintSpeed(ply:GetWalkSpeed())
			end

			ply:SetSprintSpeed(math.Approach(ply:GetSprintSpeed(), ply.runSpeed, speedx))

			local speed = ply:GetSprintSpeed()
			mv:SetMaxClientSpeed(speed)
			mv:SetMaxSpeed(speed)
		elseif ply:GetSprintMove() and ply:GetRunFading() then
			local walk_Speed = ply:GetWalkSpeed()

			ply:SetSprintSpeed(math.Approach(ply:GetSprintSpeed(), walk_Speed, speedx))

			local speed = ply:GetSprintSpeed()
			mv:SetMaxClientSpeed(speed)
			mv:SetMaxSpeed(speed)

			if speed == walk_Speed then
				ply:SetRunFading(false)
				ply:SetSprintMove(false)
				ply:SetSprintSpeed(0)
			end
		end

		mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * speedFactor)
	end)
end
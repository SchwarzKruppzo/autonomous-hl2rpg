local PLUGIN = PLUGIN

local PLAYER = FindMetaTable("Player")

function PLAYER:SetupDataTables()
	self:NetworkVar("Float", 0, "StopModifier")
	self:NetworkVar("Float", 1, "SprintSpeed")
	self:NetworkVar("Float", 2, "SpeedDeltaStart")
	self:NetworkVar("Float", 3, "SpeedDeltaEnd")
	self:NetworkVar("Bool", 0, "RunFading")
	self:NetworkVar("Bool", 1, "SprintMove")
end

function PLUGIN:OnEntityCreated(ent)
    if ent:IsPlayer() then
        ent:InstallDataTable()
        ent:SetupDataTables()
    end
end

function PLUGIN:NetworkEntityCreated(ent)
	if ent:IsPlayer() then
        ent:InstallDataTable()
        ent:SetupDataTables()
    end
end

function PLUGIN:StartCommand(ply, cmd)
	if cmd:KeyDown(IN_JUMP) and ply:GetMoveType() != MOVETYPE_NOCLIP and ply:GetNetVar("brth", false) then
		cmd:ClearButtons()
	end
end

function PLUGIN:OnPlayerHitGround(ply, inWater, onFloater, speed)
	if inWater then
		return
	end

	ply:SetStopModifier(math.max(ply:GetStopModifier() - (speed * 0.0012), 0.2))
end

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
/*
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
*/


function PLUGIN:SetupMove(ply, mv, cmd)
	local character = ply:GetCharacter()

	if !character then
		return
	end
	
	local speedx = ix.config.Get("walkSpeed")
	local hp = character:Health()

	ply.movementPenalty = ply.movementPenalty or 1
	ply.fracturedLegs = ply.fracturedLegs or false

	if hp.cachedMovement < 0 then
		hp.cachedMovement = 1

		local legs = {}
		local totalHP = 0
		local value = 0
		for k, v in hp:GetParts() do
			if !v.movement then continue end

			totalHP = totalHP + v.health
			value = value + hp:GetPartHealth(k)

			table.insert(legs, v.id)
		end

		local hasFracture
		for k, v in hp:GetHediffs() do
			if v.uniqueID != "fracture" then continue end
			if !table.HasValue(legs, v.part) then continue end

			hasFracture = true
			break
		end

		local fraction = 1 - (0.75 * (1 - math.Clamp(value / totalHP, 0, 1)))

		ply.movementPenalty = fraction
		ply.fracturedLegs = hasFracture
	end

	local mod = ply:GetStopModifier()
	local speedFactor = 1

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

	local isHoldingObject = ply:GetLocalVar("bIsHoldingObject")

	if isHoldingObject then
		local holdingObject = ply:GetLocalVar("holdingObject")

		if IsValid(holdingObject) then
			if holdingObject:IsRagdoll() then
				local strength = character:GetSpecial("st")
				local strengthFactor = 0.8 * math.Clamp(math.Remap(strength, 1, 50, 0, 1), 0, 1)

				speedFactor = speedFactor * (0.2 + strengthFactor)
			end
		end
	end
	
	speedFactor = speedFactor * mod * ply.movementPenalty

	local velLength = ply:GetVelocity():Length2DSqr()

	CalcAthletics(ply)

	if bit.band(mv:GetButtons(), IN_JUMP) != 0 then
		CheckJump(ply, mv)
	else
		local buttons = bit.band(mv:GetOldButtons(), bit.bnot(IN_JUMP))
		mv:SetOldButtons(buttons)
	end

	if ply:GetNetVar("brth", false) or bit.band(mv:GetButtons(), IN_DUCK) != 0 or ply:IsProne() then
		if ply:GetSprintMove() then
			ply:SetSprintMove(false)
			ply:SetSprintSpeed(0)
		end

		mv:SetMaxClientSpeed(speedx * speedFactor)
		return
	end

	if mv:KeyReleased(IN_SPEED) or mv:KeyDown(IN_SPEED) and velLength < .25 then
		ply:SetRunFading(true)
	end

	if mv:KeyDown(IN_MOVELEFT) or mv:KeyDown(IN_MOVERIGHT) then
		ply:SetRunFading(true)
		mv:SetSideSpeed(mv:GetSideSpeed() * .35)
	end



	/*local running = mv:KeyDown(IN_SPEED)
	local walking = mv:KeyDown(IN_FORWARD)

	if running && walking then 
		ply:SetNW2Int("Jumping_Combo", 0) 
	end*/

	//if ((mv:KeyDown(IN_BACK) || mv:KeyDown(IN_MOVELEFT) || mv:KeyDown(IN_MOVERIGHT)) && !mv:KeyDown(IN_FORWARD)) or ply.fracturedLegs then 

		//ply:SprintDisable() 
	//else 
	//	ply:SprintEnable() 
	//end

	local forward = math.Clamp(mv:GetForwardSpeed(), -speedx, speedx)
	local side =  math.Clamp(mv:GetSideSpeed(), -speedx, speedx)
	local vel = Vector(forward, side, 0)
	vel:Normalize()
	
	local ct = CurTime()

	if mv:KeyDown(IN_SPEED) and velLength > .25 or ply:GetSprintMove() and !ply:GetRunFading() then
		if !ply:GetSprintMove() then
			ply:SetRunFading(false)
			ply:SetSprintMove(true)

			ply:SetSpeedDeltaStart(ct)
			ply:SetSpeedDeltaEnd(ct + 10)
			
			ply:SetSprintSpeed(speedx)
		end

		local deltaEnd = ply:GetSpeedDeltaEnd()
		local delta = 1 - math.Clamp((deltaEnd - ct) / math.max(deltaEnd - ply:GetSpeedDeltaStart(), 1), 0, 1)

		local targetSpeed = Lerp(delta, ply:GetSprintSpeed(), ply.runSpeed)
		ply:SetSprintSpeed(targetSpeed)

		mv:SetMaxClientSpeed(targetSpeed)
		mv:SetMaxSpeed(targetSpeed)
	elseif ply:GetSprintMove() and ply:GetRunFading() then
		local deltaEnd = ply:GetSpeedDeltaEnd()
		local delta = 1 - math.Clamp((deltaEnd - ct) / math.max(deltaEnd - ply:GetSpeedDeltaStart(), 1), 0, 1)
		
		local targetSpeed = Lerp(delta, ply:GetSprintSpeed(), speedx)
		ply:SetSprintSpeed(targetSpeed)
		mv:SetMaxClientSpeed(targetSpeed)
		mv:SetMaxSpeed(targetSpeed)

		if delta >= 1 then
			ply:SetRunFading(false)
			ply:SetSprintMove(false)
			ply:SetSprintSpeed(speedx)
		end
	end

	mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * speedFactor)
end
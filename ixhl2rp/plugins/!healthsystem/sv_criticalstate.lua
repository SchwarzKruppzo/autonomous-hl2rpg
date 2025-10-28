local PLUGIN = PLUGIN
local PLAYER = FindMetaTable("Player")

function PLAYER:SetCriticalState(state)
	state = state or false

	local character = self:GetCharacter()

	if !character then
		return
	end

	if state then
		self:SetHealth(1)
		self:SetNetVar("crit", true)

		character:SetData("crit", true)
		character:SetData("critTime", os.time() + 600)

		if !IsValid(self.ixRagdoll) then
			self:SetRagdolled(true)
			self.ixRagdoll.ixGrace = nil
			self:SetLocalVar("knocked", true)
		end
	else
		self:SetHealth(100)
		self:SetNetVar("crit", nil)

		character:SetData("crit", nil)
		character:SetData("critTime", nil)
	end

	self.KilledByRP = nil
	self.KilledBySystem = true
end

function PLAYER:InCriticalState()
	return self:GetNetVar("crit")
end

function PLUGIN:OnCharacterFallover(client, ragdoll, state)
	if !state then
		client:SetCriticalState(false)
	end
end

local function DoAction(self, time, condition, callback)
	local uniqueID = "ixCritApply"..self:UniqueID()

	timer.Create(uniqueID, 0.1, time / 0.1, function()
		if IsValid(self) then
			if condition and !condition() then
				timer.Remove(uniqueID)

				if callback then
					callback(false)
				end
			elseif callback and timer.RepsLeft(uniqueID) == 0 then
				callback(true)
			end
		else
			timer.Remove(uniqueID)

			if callback then
				callback(false)
			end
		end
	end)
end

ix.log.AddType("crit_kill_start", function(client, target)
	return string.format("%s пытается добить персонажа %s.", client:GetName(), target:GetName())
end)

ix.log.AddType("crit_stopped", function(client, target)
	return string.format("%s перестал добивать персонажа %s.", client:GetName(), target:GetName())
end)

ix.log.AddType("crit_kill", function(client, target)
	return string.format("%s добил персонажа %s.", client:GetName(), target:GetName())
end)

ix.log.AddType("slay_kill_start", function(client, target)
	return string.format("%s пытается ограбить персонажа %s.", client:GetName(), target:GetName())
end)

ix.log.AddType("slay_stopped", function(client, target)
	return string.format("%s перестал грабить персонажа %s.", client:GetName(), target:GetName())
end)

ix.log.AddType("slay_kill", function(client, target)
	return string.format("%s ограбил персонажа %s.", client:GetName(), target:GetName())
end)

net.Receive("crit.apply", function(len, client)
	local state = net.ReadBool()
	local target = client.ixCritUsing

	if !IsValid(target) or target.ixCritUsedBy != client then
		return
	end

	local isSlay = client.ixCritIsSlay

	if state then
		ix.chat.Send(nil, "dmgMsg", "", nil, {target}, {t = 1, attacker = client, b = isSlay})
		ix.chat.Send(nil, "dmgAdminMsg", "", nil, nil, {
			t = 1,
			b = isSlay,
			attacker = client,
			crit = target
		})

		ix.log.Add(client, isSlay and "slay_kill_start" or "crit_kill_start", target)

		local time = isSlay and 10 or 30
		local character = client:GetCharacter()

		client:SetAction(isSlay and "Вы грабите персонажа..." or "Вы добиваете персонажа...", time)
		DoAction(client, time, function()
			if !client:Alive() or client:IsRestricted() or client:GetCharacter() != character then
				return false
			end

			local traceEnt = client:GetEyeTraceNoCursor().Entity

			if !target:Alive() or (traceEnt != (target.ixRagdoll and target.ixRagdoll or target)) then
				return false
			end

			return true
		end, function(success)
			if success then
				local character = target:GetCharacter()
				local targetLevel = character:GetLevel()
				local bonusXP = 0

				if targetLevel >= 20 then
					bonusXP = 50 * targetLevel
				end
				
				target.KilledByRP = !isSlay
				target.KilledBySystem = false
				target:Kill()

				client:RewardXP(((10 * targetLevel) + bonusXP) * (isSlay and 1 or 1.25), isSlay and "ограбление" or "убийство")

				ix.chat.Send(nil, "dmgAdminMsg", "", nil, nil, {
					t = 2,
					b = isSlay,
					attacker = client,
					crit = target
				})

				ix.log.Add(client, isSlay and "slay_kill" or "crit_kill", target)
			else
				if IsValid(target) then
					ix.chat.Send(nil, "dmgMsg", "", nil, {target}, {t = 3, b = isSlay})

					ix.log.Add(client, isSlay and "slay_stopped" or "crit_stopped", target)
				end
			end

			client:SetAction()
			client.ixCritIsSlay = nil
			client.ixCritUsing = nil
			target.ixCritUsedBy = nil
		end)
	else
		client.ixCritIsSlay = nil
		client.ixCritUsing = nil
		target.ixCritUsedBy = nil
	end
end)

net.Receive("crit.use", function(len, client)
	local target = net.ReadEntity()
	local isSlay = net.ReadBool()

	if !IsValid(target) or client:IsRestricted() then
		return
	end

	if client:GetPos():DistToSqr(target:GetPos()) > 4000 then
		return
	end

	if !IsValid(target.ixPlayer) then
		return
	end

	local admins = 0
	for k, v in ipairs(player.GetAll()) do
		if v:IsSuperAdmin() or CAMI.PlayerHasAccess(v, "Helix - Ban Character", nil) then
			admins = admins + 1
		end
	end

	if admins <= 0 then
		client:Notify("На сервере нет администраторов!")
		return
	end

	if client:GetCharacter():GetLevel() < 10 then
		client:Notify("Недостаточный уровень! Требуется 10-ый.")
		return
	end

	if !isSlay and client:GetCharacter():GetLevel() < 20 then
		client:Notify("Недостаточный уровен! Требуется 20-ый.")
		return
	end

	local curtime = CurTime()

	if client.ixNextCritUse and curtime < client.ixNextCritUse then
		return
	end

	client.ixNextCritUse = curtime + 0.5

	target = target.ixPlayer

	if IsValid(target.ixCritUsedBy) then
		return
	end

	net.Start("crit.use")
		net.WriteBool(isSlay)
	net.Send(client)

	client.ixCritIsSlay = isSlay
	client.ixCritUsing = target
	target.ixCritUsedBy = client
end)
local PLUGIN = PLUGIN

PLUGIN.name = "Phasing"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

CAMI.RegisterPrivilege({
	Name = "Phasing",
	MinAccess = "superadmin"
})

function Phase_CanSee(activator, target)
	local phaseA = activator.phase_id
	local phaseB = target.phase_id


	if phaseA and phaseB then
		print("phase_cansee", activator, target, phaseA == phaseB)

		return phaseA == phaseB
	end

	return true
end

ix.util.Include("sv_phase.class.lua")
ix.util.Include("cl_phase.lua")


ix.command.Add("PhaseCreate", {
	description = "",
	privilege = "Phasing",
	arguments = {
		ix.type.string
	},
	OnRun = function(self, client, id)
		if !phases[id] then
			local phase = New_Phase(id, client)
			client:ChatNotify("Created phase '"..id.."'.")
		end
	end
})

ix.command.Add("PhaseSet", {
	description = "",
	privilege = "Phasing",
	arguments = {
		ix.type.string,
		ix.type.character
	},
	OnRun = function(self, client, id, target)
		if phases[id] and target then
			local phase = phases[id]
			local ply = target:GetPlayer()

			if ply.phase then
				ply.phase:RemovePlayer(ply)
			end

			phase:AddPlayer(ply)

			client:ChatNotify("Phase set '"..id.."' character '"..target:GetName().."'.")
		end
	end
})

ix.command.Add("PhaseKick", {
	description = "",
	privilege = "Phasing",
	arguments = {
		ix.type.character
	},
	OnRun = function(self, client, target)
		local ply = target:GetPlayer()

		if ply.phase then
			if ply.phase.owner == ply then
				ply.phase:Destroy()
			else

				ply.phase:RemovePlayer(ply)

			end
		end

		client:ChatNotify("Phase kick character '"..target:GetName().."'.")
	end
})

if SERVER then
	function PLUGIN:PlayerDisconnected(client)
		if client.phase then
			if client.phase.owner == client then
				client.phase:Destroy()
			else
				client.phase:RemovePlayer(client)
			end
		end
	end

	function PLUGIN:PlayerLoadedCharacter(client, character, lastChar)
		if client.phase then
			if client.phase.owner == client then
				client.phase:Destroy()
			end
		end
	end

	function PLUGIN:PlayerFootstep(ply)
		if ply.phase then
			return false 
		end 
	end

	function PLUGIN:PlayerInitialSpawn(client)
		local entities = {}

		for k, phase in pairs(phases) do
			for entity, _ in pairs(phase.entities) do
				if !IsValid(entity) then continue end

				entity:SetPreventTransmit(client, !phase.players[client])

				if entity:IsPlayer() then
					client:SetPreventTransmit(entity, !phase.players[client])
				end

				entities[#entities + 1] = entity:EntIndex()
			end
		end

		if #entities > 0 then
			express.Send("phase.init", entities, client)
		end
	end

	function PLUGIN:OnEntityCreated(entity)
	
		entity:SetNoDraw(true)

		timer.Simple(0, function()
			if IsValid(entity) then
				local parent = entity:GetParent()

				if parent and parent.phase then
					parent.phase:AddEntity(entity)
				end

				entity:SetNoDraw(false)
			end
		end)

	end

	local GlobalChatTypes = {
		["looc"] = true,
		["pm"] = true,
		["adminchat"] = true
	}
	function ix.chat.Send(speaker, chatType, text, bAnonymous, receivers, data)
		if (!chatType) then
			return
		end

		data = data or {}
		chatType = string.lower(chatType)

		if (IsValid(speaker) and hook.Run("PrePlayerMessageSend", speaker, chatType, text, bAnonymous) == false) then
			return
		end

		local class = ix.chat.classes[chatType]

		if (class and class:CanSay(speaker, text, data) != false) then
			if (class.CanHear and !receivers) then
				receivers = {}

				for _, v in ipairs(player.GetAll()) do
					if (v:GetCharacter() and class:CanHear(speaker, v, data) != false) then
						if speaker then
							if !GlobalChatTypes[chatType] and speaker.phase_id == v.phase_id then
								receivers[#receivers + 1] = v
							elseif GlobalChatTypes[chatType] then
								receivers[#receivers + 1] = v
							end
						else
							receivers[#receivers + 1] = v
						end
					end
				end

				if (#receivers == 0) then
					return
				end
			end

			-- Format the message if needed before we run the hook.
			local rawText = text
			local maxLength = ix.config.Get("chatMax")

			local succ, err = pcall(string.utf8len, text)

			if !succ then
				return
			end
			
			if (err > maxLength) then
				text = text:utf8sub(0, maxLength)
			end

			if (ix.config.Get("chatAutoFormat") and hook.Run("CanAutoFormatMessage", speaker, chatType, text)) then
				text = ix.chat.Format(text)
			end

			text = hook.Run("PlayerMessageSend", speaker, chatType, text, bAnonymous, receivers, rawText) or text

			net.Start("ixChatMessage")
				net.WriteEntity(speaker)
				net.WriteString(chatType)
				net.WriteString(text)
				net.WriteBool(bAnonymous or false)
				net.WriteTable(data or {})
			net.Send(receivers)

			return text
		end
	end
end
local PLUGIN = PLUGIN

local notDrawn = {}
local function refreshVirtualEntity(entity)
	local clientSession = LocalPlayer().phase_id
	local entitySession = entity.phase_id

	if !IsValid(entity) then 
		return 
	end

	local canSee = Phase_CanSee(LocalPlayer(), entity)

	if !canSee and !notDrawn[entity] then
		if entity:IsPlayer() then
			timer.Simple(0, function()
				if IsValid(entity) then
					entity:SetPos(Vector())
				end
			end)
		end
		
		notDrawn[entity] = true

		if entity.RenderOverride then 
			entity.ogRO = entity.RenderOverride 
		end

		entity.RenderOverride = function() end
		
		//entity:SetCollisionGroup(10)
		entity:DestroyShadow()
		entity:DrawShadow(false)
	elseif notDrawn[entity] and canSee then
		if notDrawn[entity] then 
			notDrawn[entity] = nil 
		end

		entity.RenderOverride = entity.ogRO or nil

/*
		if entity.cg then 
			entity:SetCollisionGroup(entity.cg) 
		end*/
	end
end

function PLUGIN:EntityNetworkedVarChanged(entity, key, old_value, value)
	if key == "phase" then
		if value != "" then
			entity.phase_id = value
		else
			entity.phase_id = nil
		end

		refreshVirtualEntity(entity)

		if entity == LocalPlayer() then
			for k, v in ipairs(ents.GetAll()) do
				if v.phase_id then
					refreshVirtualEntity(v)
				end
			end
		end
	end
end

function PLUGIN:NotifyShouldTransmit(entity, should)
	/*
	if notDrawn[entity] and should then
		refreshVirtualEntity(entity)
	end*/
end

function PLUGIN:OnEntityCreated(entity)
	local phase = entity:GetNW2String("phase")

	if phase then
		entity.phase_id = (phase != "") and phase or nil

		refreshVirtualEntity(entity)
	end
end

function PLUGIN:PrePlayerDraw(client)
	local owner = LocalPlayer()

	if owner != client and !Phase_CanSee(owner, client) then
		return true 
	end 
end

function PLUGIN:PlayerFootstep(client, position, foot, soundName, volume)
	if LocalPlayer().phase_id then
		client:EmitSound(soundName)
		return true
	end
end

function PLUGIN:EntityEmitSound(data)
	if notDrawn[data.Entity] then
		return false
	end
end

function PLUGIN:GetTypingIndicatorPosition(client)
	if notDrawn[client] then
		return vector_origin
	end
end

express.Receive("phase.init", function(data)
	for _, id in ipairs(data) do
		local entity = Entity(id)
		if !IsValid(entity) then continue end
		
		local phase = entity:GetNW2String("phase")
		entity.phase_id = (phase != "") and phase or nil

		refreshVirtualEntity(entity)
	end
end)
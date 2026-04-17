local PLUGIN = PLUGIN

PLUGIN.name = "Anim Helper"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = "Adds a animation radial menu."

ix.Net:AddPlayerVar("sitHelperPos", false, nil, ix.Net.Type.Vector)

function PLUGIN:CanSit(client, pos, sequence)
	local eyePos = client:EyePos()
	local animGroup = client.ixAnimModelClass
	local info = ix.AnimHelper.anims[sequence]
	
	local bboxMin, bboxMax

	if info then
		local bbox = info.bbox[animGroup] or info.bbox[1]

		if bbox then
			bboxMin = bbox.mins
			bboxMax = bbox.maxs
		end
	end

	local sitTrace = util.TraceHull({
		start = pos + Vector(0, 0, 3),
		endpos = pos,
		filter = function(ent)
			if ent == client or ent:IsWeapon() then
				return false
			else
				return true
			end
		end,
		mins = bboxMin,
		maxs = bboxMax
	})

	if sitTrace.AllSolid then
		return false
	end

	local norm = (pos - client:EyePos()):GetNormalized()

	local visTrace = util.TraceLine({
		start = eyePos,
		endpos = pos - norm * 2,
		filter = client,
	});

	if visTrace.Hit then
		return false
	end

	if pos:Distance(eyePos) >= 100 then
		return false
	end

	return true
end

function PLUGIN:StartCommand(client, command)
	if !client:GetNetVar("sitHelperPos") then
		return
	end

	if command:KeyDown(IN_DUCK) then
		command:RemoveKey(IN_DUCK)
	end
end

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")

ix.util.Include("sh_definitions.lua")
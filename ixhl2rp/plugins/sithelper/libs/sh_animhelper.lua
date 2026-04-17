local PLUGIN = PLUGIN
local AnimHelper = ix.util.Lib("AnimHelper", {
	anims = {}
})

local defaultBBox = { mins = Vector(-5, -5, 0), maxs = Vector(5, 5, 2) }
function AnimHelper:Register(sequence, info)
	info = info or {}

	info.sequence = sequence
	info.label = info.label or "Unknown"
	info.bbox = { defaultBBox }
	info.offset = {}

	self.anims[sequence] = info
end

if SERVER then
	return
end

do
	local mat = Material("debug/debugdrawflat")
	local mdl, angle, sequence
	local preview = false
	local offsetZ = 0

	local function InputMouseApply(cmd)
		local scrollDelta = cmd:GetMouseWheel()

		if scrollDelta == 0 then return end

		local pos = cmd:GetMouseWheel() > 0

		if input.IsKeyDown(KEY_LSHIFT) then
			offsetZ = math.Clamp(offsetZ + (pos and 0.1 or -0.1), -2, 4)
		else
			angle.y = math.NormalizeAngle(angle.y + (pos and 1 or -1))
		end
	end

	local function PlayerBindPress(player, bind, bPressed)
		bind = bind:lower()

		if bind:find("invnext") or bind:find("invprev") then
			return true
		elseif bind:find("+attack2") and bPressed then
			ix.AnimHelper:BuildPreview(false)
			return true
		elseif bind:find("+attack") and bPressed then
			ix.AnimHelper:Select()
			return true
		end
	end

	local sitTraceInfo
	local downTraceInfo, downTrace
	local canSit
	local function PostDrawTranslucentRenderables()
		local info = ix.AnimHelper.anims[sequence]
		local anim = mdl:LookupSequence(sequence)
		local animGroup = LocalPlayer().ixAnimModelClass

		if anim <= -1 then
			return
		end

		local localPlayer = LocalPlayer()
		local eyePos = localPlayer:EyePos()
		local bboxMin, bboxMax

		if info then
			local bbox = info.bbox[animGroup] or info.bbox[1]

			if bbox then
				bboxMin = bbox.mins
				bboxMax = bbox.maxs
			end
		end

		sitTraceInfo = sitTraceInfo or {filter = localPlayer}
		sitTraceInfo.start = eyePos
		sitTraceInfo.endpos = eyePos + localPlayer:EyeAngles():Forward() * 60
		sitTraceInfo.mins = bboxMin
		sitTraceInfo.maxs = bboxMax

		local sitTrace = util.TraceHull(sitTraceInfo)

		downTraceInfo = downTraceeInfo or {filter = localPlayer}
		downTraceInfo.start = sitTrace.HitPos
		downTraceInfo.endpos = sitTrace.HitPos - Vector(0, 0, 100)
		downTraceInfo.mins = bboxMin
		downTraceInfo.maxs = bboxMax

		downTrace = util.TraceHull(downTraceInfo)
		canSit = PLUGIN:CanSit(localPlayer, downTrace.HitPos, sequence)

		if !downTrace.Hit or downTrace.HitNormal.z <= 0.75 then
			canSit = false
		end

		render.MaterialOverride(mat)

		local baseOffset = vector_origin

		if info then
			local offset = info.offset[animGroup] or info.offset[1]

			baseOffset = offset or vector_origin
		end

		local previewPos = (downTrace.Hit and downTrace.HitPos or sitTrace.HitPos)
		local previewOffsetPos = previewPos + angle:Forward() * baseOffset.x + Vector(0, 0, baseOffset.z + offsetZ)

		mdl:SetPos(previewOffsetPos)
		mdl:SetAngles(angle)
		mdl:SetSequence(anim)

		render.OverrideColorWriteEnable(true, false)
		mdl:DrawModel()
		render.OverrideColorWriteEnable(false, false)

		render.SetColorModulation(canSit and 0 or 1, canSit and 1 or 0, 0, 1)
		render.SetBlend(0.2)

		mdl:DrawModel()

		render.MaterialOverride(nil)
	end

	local lastY = 0
	local function drawHint(text, x, y, screenW, screenH)
		draw.DrawText(text, "ixMediumFont", screenW + 1 + x, screenH + 1 - y - lastY, color_black, TEXT_ALIGN_LEFT)
		draw.DrawText(text, "ixMediumFont", screenW + x, screenH - y - lastY, color_white, TEXT_ALIGN_LEFT)

		lastY = lastY + y
	end

	local function HUDPaint()
		local screenW, screenH = ScrW() * 0.5, ScrH() * 0.95

		lastY = 0

		drawHint("[ЛКМ/ПКМ] — применить анимацию / отмена", -200, 0, screenW, screenH)
		drawHint("[↕] — поворот", -200, 40, screenW, screenH)
		drawHint("[SHIFT + ↕] — поднять / опустить", -200, 25, screenW, screenH)
	end

	function ix.AnimHelper:Select()
		if !canSit then
			return
		end

		net.Start("animhelper.select")
			net.WriteVector(downTrace.HitPos)
			net.WriteAngle(angle)
			net.WriteString(sequence)
			net.WriteFloat(offsetZ)
		net.SendToServer()

		self:BuildPreview(false)
	end

	function ix.AnimHelper:BuildPreview(enable, selectedSequence)
		if enable and !preview then
			ix.gui.preventSelection = true
			preview = true

			mdl = ClientsideModel(LocalPlayer():GetModel(), RENDERGROUP_OPAQUE)
			mdl:SetNoDraw(true)

			angle = Angle(0, LocalPlayer():EyeAngles().y + 180, 0)
			sequence = selectedSequence

			hook.Add("PostDrawTranslucentRenderables", "animhelper.preview", PostDrawTranslucentRenderables)
			hook.Add("PlayerBindPress", "animhelper.preview", PlayerBindPress)
			hook.Add("InputMouseApply", "animhelper.preview", InputMouseApply)
			hook.Add("HUDPaint", "animhelper.preview", HUDPaint)
		elseif !enable then
			ix.gui.preventSelection = false

			hook.Remove("PostDrawTranslucentRenderables", "animhelper.preview")
			hook.Remove("PlayerBindPress", "animhelper.preview")
			hook.Remove("InputMouseApply", "animhelper.preview")
			hook.Remove("HUDPaint", "animhelper.preview")

			preview = false

			if IsValid(mdl) then
				mdl:Remove()
			end
		end
	end
end
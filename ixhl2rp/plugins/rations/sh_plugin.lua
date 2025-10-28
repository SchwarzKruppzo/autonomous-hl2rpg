local PLUGIN = PLUGIN

PLUGIN.name = "Rations"
PLUGIN.description = "Adds a ration items and factory."
PLUGIN.author = "SchwarzKruppzo"

ix.util.Include("sv_hooks.lua")

if CLIENT then
	do
		local mat = Material("debug/debugdrawflat")
		local preview = false
		local mdl = NULL
		local angle = Angle()

		local trace
		local data = {}
		local function PostDrawTranslucentRenderables(depth, sky)
			if depth or sky then
				return
			end

			if !preview then
				return
			end

			if !IsValid(mdl) then
				return
			end

			render.MaterialOverride(mat)

			trace = LocalPlayer():GetEyeTraceNoCursor()

			mdl:SetAngles(angle)

			local mins, maxs = mdl:GetModelBounds() 

			data.mins = mins
			data.maxs = maxs
			data.start = trace.StartPos
			data.endpos = trace.StartPos + trace.Normal * 86
			data.filter = LocalPlayer()

			local trace = util.TraceLine(data)

			local palette
			local ent = trace.Entity

			if IsValid(ent) then
				if ent.isPalette then
					palette = true
				elseif ent.isRationCrate and IsValid(ent:GetParent()) then
					palette = true
				end
			end

			local sitTrace = util.TraceHull({
				start = trace.HitPos + Vector(0, 0, 3),
				endpos = trace.HitPos,
				mins = mins,
				maxs = maxs
			})

			if sitTrace.AllSolid or !palette then
				render.SetColorModulation(1, 0, 0, 1)
			else
				render.SetColorModulation(0, 1, 0, 1)
			end
			
			render.SetBlend(0.2)

			mdl:SetPos(trace.HitPos)
			mdl.normal = trace.Normal
			mdl:DrawModel()

			render.MaterialOverride(nil)
		end

		local function HUDPaint()
			if !preview then
				return
			end

			
			draw.DrawText("[ЛКМ/ПКМ] — поставить/отменить", "ixMediumFont", ScrW() * 0.5 + 1, ScrH() * 0.95 + 1, color_black, TEXT_ALIGN_CENTER)
			draw.DrawText("[ЛКМ/ПКМ] — поставить/отменить", "ixMediumFont", ScrW() * 0.5, ScrH() * 0.95, color_white, TEXT_ALIGN_CENTER)
		end

		local crateCallback
		local function PlayerBindPress(player, bind, bPressed)
			if !preview then
				return
			end

			if ((bind:find("invnext") or bind:find("invprev")) and bPressed) then
				return true
			elseif (bind:find("attack2") and bPressed) then
				net.Start("crate.stop")
				net.SendToServer()

				ix.Item:CratePreview(false)

				return true
			elseif (bind:find("attack") and bPressed) then
				if crateCallback then
					crateCallback()
				end

				ix.Item:CratePreview(false)

				return true
			end
		end

		function InputMouseApply(cmd)
			if !preview then
				return
			end

			local scrollDelta = cmd:GetMouseWheel()

			if (scrollDelta == 0) then return end

			local pos = scrollDelta > 0

			angle.y = math.NormalizeAngle(angle.y + (pos and 1 or -1))
		end

		function ix.Item:CratePreview(enable)
			if enable and !preview then
				ix.gui.preventSelection = true
				preview = true

				mdl = ClientsideModel("models/Items/item_item_crate.mdl", RENDERGROUP_OPAQUE)
				mdl:SetNoDraw(true)

				angle = angle_zero

				hook.Add('PostDrawTranslucentRenderables', 'item.preview', PostDrawTranslucentRenderables)
				hook.Add('PlayerBindPress', 'item.preview', PlayerBindPress)
				hook.Add('InputMouseApply', 'item.preview', InputMouseApply)
				hook.Add('HUDPaint', 'item.preview', HUDPaint)
			elseif !enable then
				ix.gui.preventSelection = false

				hook.Remove('PostDrawTranslucentRenderables', 'item.preview')
				hook.Remove('PlayerBindPress', 'item.preview')
				hook.Remove('InputMouseApply', 'item.preview')
				hook.Remove('HUDPaint', 'item.preview')

				preview = false

				if IsValid(mdl) then
					mdl:Remove()
				end
			end
		end

		net.Receive("crate.take", function()
			local crate = net.ReadEntity()

			ix.Item:CratePreview(true)

			crateCallback = function()
				net.Start("crate.take")
					net.WriteAngle(angle)
				net.SendToServer()
			end
		end)
	end
end
local Item = class("ItemBuildable"):implements("Item")

Item.stackable = false

if CLIENT then
	do
		local mat = Material("debug/debugdrawflat")
		local preview = false
		local mdl = NULL
		local angle = Angle()

		local origin
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
			data.endpos = trace.StartPos + trace.Normal * 70
			data.filter = LocalPlayer()

			local trace = util.TraceLine(data)

			local sitTrace = util.TraceHull({
				start = trace.HitPos,
				endpos = trace.HitPos - Vector(0, 0, 70),
				mins = mins,
				maxs = maxs
			})

			if sitTrace.AllSolid or !sitTrace.Hit then
				render.SetColorModulation(1, 0, 0, 1)
			else
				render.SetColorModulation(0, 1, 0, 1)
			end
			
			render.SetBlend(0.2)

			origin = sitTrace.HitPos
			mdl:SetPos(sitTrace.HitPos)
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

		local buildCallback
		local function PlayerBindPress(player, bind, bPressed)
			if !preview then
				return
			end

			if ((bind:find("invnext") or bind:find("invprev")) and bPressed) then
				return true
			elseif (bind:find("attack2") and bPressed) then
				net.Start("build.stop")
				net.SendToServer()

				ix.Item:BuildPreview(false)

				return true
			elseif (bind:find("attack") and bPressed) then
				if buildCallback then
					buildCallback()
				end

				ix.Item:BuildPreview(false)

				return true
			end
		end

		local function InputMouseApply(cmd)
			if !preview then
				return
			end

			local scrollDelta = cmd:GetMouseWheel()
			
			if (scrollDelta == 0) then return end

			local pos = scrollDelta > 0

			angle.y = math.NormalizeAngle(angle.y + (pos and 1 or -1))
		end

		function ix.Item:BuildPreview(enable, path)
			if enable and !preview then
				ix.gui.preventSelection = true
				preview = true

				mdl = ClientsideModel(path, RENDERGROUP_OPAQUE)
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

		net.Receive("build.place", function()
			if IsValid(ix.gui.menu) then
				ix.gui.menu:Remove()
			end

			local mdl = net.ReadString()

			ix.Item:BuildPreview(true, mdl)

			buildCallback = function()
				net.Start("build.place")
					net.WriteAngle(angle)
					net.WriteVector(origin)
				net.SendToServer()
			end
		end)
	end
else
	util.AddNetworkString("build.place")
	util.AddNetworkString("build.stop")

	net.Receive("build.stop", function(len, client)
		local item = client.build_item

		if item and item.user == client then
			item.user = nil
		end
	end)

	net.Receive("build.place", function(len, client)
		local angle = net.ReadAngle()
		local item = client.build_item

		if item and item.user == client then
			local pos = net.ReadVector()
			local trace = client:GetEyeTraceNoCursor()

			local data = {}
			data.start = trace.StartPos
			data.endpos = trace.StartPos + trace.Normal * 70
			data.filter = client

			trace = util.TraceLine(data)

			local sitTrace = util.TraceLine({
				start = trace.HitPos,
				endpos = trace.HitPos - Vector(0, 0, 70)
			})

			if sitTrace.HitPos:Distance(pos) > 70 then
				item.user = nil
				return
			end

			item:OnPlace(client, pos, angle)

			item:Remove()
		end
	end)
end

function Item:Init()
	self.category = 'Строительство'

	self.preview_model = self.preview_model or ""

	self.functions.place = {
		name = "Разместить",
		OnRun = function(item)
			if item.preview_model then
				net.Start("build.place")
					net.WriteString(item.preview_model)
				net.Send(item.player)

				item.player.build_item = item
				item.user = item.player
			end
		end,
		OnCanRun = function(item)
			return IsValid(item.player) and !IsValid(item.entity) and !item.player:IsRestricted() and !IsValid(item.user)
		end
	}
end

function Item:OnPlace(client, pos, angle)
	local data = ix.container.stored[self.preview_model:lower()]

	if data then
		local container = ents.Create("ix_container")
		container:SetPos(pos)
		container:SetAngles(angle)
		container:SetModel(self.preview_model)
		container:Spawn()

		if IsValid(container) then
			container:SetNetVar("owner", client:GetCharacter():GetID())
			
			local phys = container:GetPhysicsObject()

			if IsValid(phys) then
				phys:EnableMotion(false)
			end
			
			container:CreateInventory(data)
		end
	end
end

if CLIENT then
	function Item:PopulateTooltip(tooltip)
		local data = ix.container.stored[self.preview_model:lower()]

		if data then
			local size = tooltip:AddRowAfter("name")
			size:SetBackgroundColor(derma.GetColor("Success", tooltip))
			size:SetText(string.format("Вместимость: %s", tostring(data.width).."x"..tostring(data.height)))
		end
	end
end

return Item
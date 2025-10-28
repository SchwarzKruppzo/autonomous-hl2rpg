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
		
		if !IsValid(ix.inventory_drag_slot) then
			ix.Item:DropPreview(false)
			hook.Remove('PostDrawTranslucentRenderables', 'item.preview')
			return
		end

		if !preview then
			return
		end

		if !IsValid(mdl) then
			return
		end

		render.MaterialOverride(mat)

		trace = ix.GetViewTrace()

		mdl:SetAngles(angle)

		local mins, maxs = mdl:GetModelBounds() 

		data.mins = mins
		data.maxs = maxs
		data.start = trace.StartPos
		data.endpos = trace.StartPos + trace.Normal * 86
		data.filter = LocalPlayer()

		local trace = util.TraceLine(data)

		render.SetColorModulation(0, 1, 0, 1)
		render.SetBlend(0.2)

		mdl:SetPos(trace.HitPos + Vector(0,0, math.abs(mins.z)))
		mdl.normal = trace.Normal
		mdl:DrawModel()

		render.MaterialOverride(nil)
	end

	function ix.Item:GetDropAngles()
		if IsValid(mdl) then
			return mdl.normal, mdl:GetAngles()
		end
	end

	function ix.Item:RotatePreview(scrolldelta)
		if !preview then
			return
		end
		
		local pos = scrolldelta > 0

		angle.y = math.NormalizeAngle(angle.y + (pos and 8 or -8))
	end

	function ix.Item:DropPreview(enable, item)
		if enable and !preview then
			preview = true

			mdl = ClientsideModel(item.model, RENDERGROUP_OPAQUE)
			mdl:SetNoDraw(true)

			angle = angle_zero

			hook.Add('PostDrawTranslucentRenderables', 'item.preview', PostDrawTranslucentRenderables)
		elseif !enable and preview then
			preview = false

			mdl:Remove()
		end
	end
end

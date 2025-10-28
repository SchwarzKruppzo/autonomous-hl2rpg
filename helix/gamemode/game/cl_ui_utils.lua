local UI = ix.util.Lib("UI")

function UI.Scale(px)
	return math.ceil(math.max(480, ScrH()) * (px / 1080))
end

do
	local rt_scanline = GetRenderTargetEx("ui_scanline_block", 2, 2, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SHARED, 1, 0, IMAGE_FORMAT_RGBA8888)
	local mat_scanline = CreateMaterial("ui_scanline_block", "UnlitGeneric",{
		["$basetexture"] = "ui_scanline_block",
		["$translucent"] = 1,
		["$vertexalpha"] = 1,
		["$vertexcolor"] = 1,
	})

	local black = Color(0, 0, 0, 255)
	local gray = Color(255, 255, 255, 75)
	local scanline = false

	hook.Add("PostRenderVGUI", "ui.scanlines", function()
		if !scanline or gui.IsGameUIVisible() then
			return
		end
		
		local w, h = ScrW(), ScrH()

		render.PushRenderTarget(rt_scanline)
			render.Clear(0, 0, 0, 0)

			cam.Start2D()
				surface.SetDrawColor(black)
				surface.DrawRect(0, 0, 2, 1)
			cam.End2D()
		render.PopRenderTarget()

		render.OverrideBlend(true, BLEND_DST_COLOR, BLEND_ONE_MINUS_SRC_ALPHA, BLENDFUNC_ADD)
			surface.SetMaterial(mat_scanline)
			surface.SetDrawColor(gray)
			surface.DrawTexturedRectUV(0, 0, w, h, 0, 0, 1, h)
		render.OverrideBlend(false)
	end)

	function UI:Scanline(bool)
		scanline = bool
	end
end

do
	local blur = Material("pp/blurscreen")

	function UI:DrawDark(panel, alpha)
		local x, y = panel:LocalToScreen(0, 0)

		surface.SetDrawColor(0, 0, 0, alpha)
		surface.DrawRect(x * -1, y * -1, ScrW(), ScrH())
	end

	function UI:DrawBlur(panel, amount, alpha)
		amount = amount or 5

		surface.SetMaterial(blur)
		surface.SetDrawColor(255, 255, 255, alpha or 255)

		local x, y = panel:LocalToScreen(0, 0)

		for i = 0.33, 1, 0.33 do
			blur:SetFloat("$blur", amount * i)
			blur:Recompute()

			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
		end
	end
end

function UI:OpenMessage(title, text, btnText, callback)
	return Derma_Query(text, title, btnText, callback)
end

do
	local model_panel = vgui.GetControlTable('DModelPanel')

	function model_panel:Paint(w, h)
		local ent = self.Entity

		if !IsValid(ent) then return end

		local x, y = self:LocalToScreen(0, 0)

		self:LayoutEntity(ent)

		local ang = self.aLookAngle

		if !ang then
			ang = (self.vLookatPos - self.vCamPos):Angle()
		end

		cam.Start3D(self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ)
			

			-- Fix for models being behind blur texture in Z-buffer.
			if ix.should_render_blur then cam.IgnoreZ(true) end

			render.SuppressEngineLighting(true)
			render.SetLightingOrigin(ent:GetPos())
			render.ResetModelLighting(self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255)
			render.SetColorModulation(self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255)
			render.SetBlend((self:GetAlpha() / 255) * (self.colColor.a / 255))

			for i = 0, 6 do
				local col = self.DirectionalLight[i]

				if col then
					render.SetModelLighting(i, col.r / 255, col.g / 255, col.b / 255)
				end
			end

			self:DrawModel()

			render.SuppressEngineLighting(false)

			-- End fix
			if ix.should_render_blur then cam.IgnoreZ(false) end

		cam.End3D()

		self.LastPaint = RealTime()
	end
end
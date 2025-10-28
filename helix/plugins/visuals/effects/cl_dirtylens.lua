local blur = 12
local blurpasses = 16
local lensMul = 0.7

local lens_texture = "dlenstexture/dlensdefault"
local mat_Downsample = Material("pp/downsample")
local mat_Bloom = Material("dlenstexture/dlensmat")

local OldRT = render.GetRenderTarget()	
local tex_Bloom0 = render.GetBloomTex0()

local w, h = ScrW(), ScrH()
local targetMultiply = 1
local multiply = 1

hook.Add("RenderScreenspaceEffects", "autonomous.dirtylens", function()
	if !render.SupportsPixelShaders_2_0() then return end

	local sun = util.GetSunInfo()
	if sun then
		if sun.obstruction != 0 then
			targetMultiply = lensMul + 0.5
		else
			targetMultiply = lensMul
		end	
	else
		targetMultiply = lensMul
	end

	multiply = Lerp(FrameTime() * 6, multiply, targetMultiply)

	mat_Downsample:SetFloat("$multiply", multiply)	
	mat_Downsample:SetFloat("$darken", 0.3)
	mat_Downsample:SetTexture("$fbtexture", render.GetScreenEffectTexture())

	render.SetViewPort(0, 0, w, h)
	render.SetRenderTarget(tex_Bloom0)
		render.SetBlend(1)
		render.SetMaterial(mat_Downsample)
		render.DrawScreenQuad()
		render.BlurRenderTarget(tex_Bloom0, blur, blur, blurpasses)
		render.ClearDepth()
	render.SetRenderTarget(OldRT)

	mat_Bloom:SetFloat("$levelr", 1)
	mat_Bloom:SetFloat("$levelg", 1)
	mat_Bloom:SetFloat("$levelb", 1)
	mat_Bloom:SetFloat("$colormul", 16)

	mat_Bloom:SetTexture("$basetexture", lens_texture)
	mat_Bloom:SetTexture("$dudvmap", lens_texture)
	mat_Bloom:SetTexture("$normalmap", lens_texture)
	mat_Bloom:SetTexture("$refracttinttexture", tex_Bloom0)

	render.SetMaterial(mat_Bloom)
	render.DrawScreenQuad()
end)
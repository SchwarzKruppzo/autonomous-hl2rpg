local SetMaterial, DrawScreenQuad, UpdateScreenEffectTexture = render.SetMaterial, render.DrawScreenQuad, render.UpdateScreenEffectTexture

local chroma = Material("effects/shaders/autonomous_chroma")
local firstDraw

hook.Add("RenderScreenspaceEffects", "autonomous.chroma", function()
	UpdateScreenEffectTexture()

	if !firstDraw then
		chroma:SetFloat("$c0_x", 0.020)
		chroma:SetFloat("$c0_y", 1)

		firstDraw = true
	end
	
	SetMaterial(chroma)
	DrawScreenQuad()
end)
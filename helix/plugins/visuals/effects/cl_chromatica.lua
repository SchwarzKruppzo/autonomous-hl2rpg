local SetMaterial, DrawScreenQuad, UpdateScreenEffectTexture = render.SetMaterial, render.DrawScreenQuad, render.UpdateScreenEffectTexture

local chroma = Material("effects/shaders/autonomous_chroma")
chroma:SetFloat("$c0_x", 0.020)
chroma:SetFloat("$c0_y", 1)

hook.Add("RenderScreenspaceEffects", "autonomous.chroma", function()
	UpdateScreenEffectTexture()

	SetMaterial(chroma)
	DrawScreenQuad()
end)
local SetMaterial, DrawScreenQuad, UpdateScreenEffectTexture = render.SetMaterial, render.DrawScreenQuad, render.UpdateScreenEffectTexture

local filmgrain = Material("effects/shaders/autonomous_filmgrain")
filmgrain:SetFloat("$c0_y", 2) //BLENDMODE
filmgrain:SetFloat("$c0_z", 0.5) //SPEED
filmgrain:SetFloat("$c0_w", 0.095) //INTENSITY
filmgrain:SetFloat("$c1_x", 0) //MEAN
filmgrain:SetFloat("$c1_y", 0.4) //VARIANCE

hook.Add("RenderScreenspaceEffects", "autonomous.filmgrain", function()
	UpdateScreenEffectTexture()
	
	SetMaterial(filmgrain)
	DrawScreenQuad()
end)
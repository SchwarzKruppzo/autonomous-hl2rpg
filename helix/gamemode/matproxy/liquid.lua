local nocolor = Vector()

matproxy.Add({
	name = "LiquidProx",
	init = function(self, mat, values)

	end,
	bind = function(self, mat, ent)
		if !IsValid(ent) then return end

		local targetColor = (ent.liquid_color or ent:GetNetVar("liquidColor"))

		mat:SetVector("$color2", targetColor and targetColor:ToVector() or nocolor)
	end 
})

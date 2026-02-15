local fullBright = Vector(1, 1, 1)

matproxy.Add({
	name = "AutonomousFace",
	init = function(self, mat, values)
		mat:SetVector("$color2", fullBright)
	end,
	bind = function(self, mat, ent)
		if !IsValid(ent) then return end

		if ent.ProxyOwner then
			if IsValid(ent.ProxyOwner) then
				ent = ent.ProxyOwner
			end
		end
		
		if ent:IsRagdoll() then
			local owner = ent:GetRagdollOwner()

			if IsValid(owner) then 
				ent = owner
			end
		end

		local face = ent.faceMap

		if face then
			if face.baked then
				mat:SetTexture("$basetexture", face.baked)
			end
		end

		if ent.PreviewFace then
			mat:SetTexture("$basetexture", ent.PreviewFace)
		end
	end 
})

local posL = Vector(0.05, 0, 0.125)
local posR = Vector(0.05, 0, -0.075)
matproxy.Add({
	name = "AutonomousEye",
	init = function(self, mat, values)
		
	end,
	bind = function(self, mat, ent)
		if !IsValid(ent) then return end

		if ent.ProxyOwner then
			if IsValid(ent.ProxyOwner) then
				ent = ent.ProxyOwner
			end
		end
		
		if ent:IsRagdoll() then
			local owner = ent:GetRagdollOwner()

			if IsValid(owner) then 
				ent = owner
			end
		end

		if IsValid(ent) and ent:IsPlayer() then
			local character = ent:GetCharacter()

			if character then
				local charGen = character:CharGen()

				if charGen._updateEyes then
					local b1 = ent:LookupBone("ValveBiped.Bip01_EyeL")
					local b2 = ent:LookupBone("ValveBiped.Bip01_EyeR")

					if b1 and b2 then
						ent:ManipulateBonePosition(b1, charGen._eyePos.left)
						ent:ManipulateBonePosition(b2, charGen._eyePos.right)
					end

					charGen._updateEyes = false
				end
			end
		end
	end 
})
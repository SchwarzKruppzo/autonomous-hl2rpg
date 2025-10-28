local PLUGIN = PLUGIN

function PLUGIN:RenderScreenspaceEffects()
	local client = LocalPlayer()

	if client and ix then
		local drunkFactor = client:GetLocalVar("drunk", 0)

		if drunkFactor > 0 then
			DrawMotionBlur(drunkFactor / 8, drunkFactor / 1.5, 0.01)
		end
	end
end

local Speedmul, SmoothHorizontal, SmoothVertical = 0,0,0
local count = 0
local swayspeed = 0.02

timer.Create("drunk_fx", 0.01, 0, function()
	local client = LocalPlayer()

	if IsValid(client) and ix then
		local drunkFactor = client:GetLocalVar("drunk", 0)

		if client:Alive() and drunkFactor > 0 then
			Speedmul = swayspeed * 8
			count = count + ( swayspeed * 11 ) * Speedmul

			SmoothHorizontal = -math.abs( math.sin(count) * 1 )
			SmoothVertical = math.sin(count)*1.5
		end
	end
end)

function PLUGIN:CalcView(ply, pos, ang, fov)
	local client = LocalPlayer()

	if IsValid(client) and ix then
		local drunkFactor = client:GetLocalVar("drunk", 0)

		if drunkFactor > 0 then
			local view = {}
			local ang = ang

			ang:RotateAroundAxis(ang:Right(), SmoothHorizontal * drunkFactor)
			ang:RotateAroundAxis(ang:Up(), (SmoothVertical * 0.5) * drunkFactor)
			ang:RotateAroundAxis(ang:Forward(), (SmoothVertical * 2) * drunkFactor)

			view.angles = ang
			view.fov = fov + (-SmoothVertical * 2) * drunkFactor

			return view
		end
	end
end
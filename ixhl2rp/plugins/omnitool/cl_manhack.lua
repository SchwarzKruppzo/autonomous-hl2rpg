local PLUGIN = PLUGIN

function PLUGIN:CalcView(client, origin, angles, fieldOfView)
	local controller = client:GetNWEntity("OmniManhackController")

	if (!IsValid(controller)) then
		return
	end

	local viewAngles = client:EyeAngles()
	viewAngles.y = viewAngles.y + controller:GetYawOffset()

	return {
		origin = controller:GetPos(),
		angles = viewAngles,
		fov = fieldOfView,
		drawviewer = false,
		znear = 1
	}
end

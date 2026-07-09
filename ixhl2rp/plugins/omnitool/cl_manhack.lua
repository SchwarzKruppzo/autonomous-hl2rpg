local PLUGIN = PLUGIN

function PLUGIN:CalcView(client, origin, angles, fieldOfView)
	local controller = client:GetNWEntity("OmniManhackController")

	if (!IsValid(controller)) then
		return
	end

	return {
		origin = controller:GetPos(),
		angles = client:EyeAngles(),
		fov = fieldOfView,
		drawviewer = false,
		znear = 1
	}
end

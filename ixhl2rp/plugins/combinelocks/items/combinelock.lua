ITEM.name = "item.combinelock"
ITEM.description = "item.combinelock.desc"
ITEM.model = Model("models/props_combine/combine_lock01.mdl")
ITEM.width = 1
ITEM.height = 2
ITEM.rarity = 2
ITEM.iconCam = {
	pos = Vector(-0.5, 50, 2),
	ang = Angle(0, 270, 0),
	fov = 25.29
}

ITEM.functions.Place = {
	name = "combinelockPlace",
	
	OnClick = function(item)
		Derma_StringRequest(L("combinelockAccessTitle"), L("combinelockAccessPrompt"), "cmbMpfAll", function(access)
			netstream.Start("ixCombineLockPlace", item:GetID(), access)
		end)
	end,

	OnRun = function(item)
		return false
	end
}

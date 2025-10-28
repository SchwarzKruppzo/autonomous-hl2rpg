PLUGIN.name = "Holstered Weapons"
PLUGIN.author = "Black Tea"
PLUGIN.description = "Shows holstered weapons on players."

if (SERVER) then return end

HOLSTER_DRAWINFO = HOLSTER_DRAWINFO or {}

HOLSTER_DRAWINFO["arccw_uspmatch"] = {
	pos = Vector(1, -8, -1),
	ang = Angle(0, 70, 0),
	bone = "ValveBiped.Bip01_Pelvis",
	model = "models/weapons/w_pistol.mdl"
}

HOLSTER_DRAWINFO["arccw_usp_mp443"] = {
	pos = Vector(1, -8, -1),
	ang = Angle(0, 70, 0),
	bone = "ValveBiped.Bip01_Pelvis",
	model = "models/weapons/tfa_ins2/mp443/w_mp443.mdl"
}

HOLSTER_DRAWINFO["arccw_357"] = {
	pos = Vector(-1, -7, -1),
	ang = Angle(0, 70, 0),
	bone = "ValveBiped.Bip01_Pelvis",
	model = "models/weapons/tfa_mmod/w_357.mdl"
}

HOLSTER_DRAWINFO["arccw_spas12"] = {
	pos = Vector(4, 5, -2),
	ang = Angle(-20, 8, 0),
	bone = "ValveBiped.Bip01_Spine1",
	model = "models/weapons/w_shotgun.mdl"
}

HOLSTER_DRAWINFO["arccw_smg1"] = {
	pos = Vector(3, 5, -2),
	ang = Angle(-170, -5, 180),
	bone = "ValveBiped.Bip01_Spine1",
	model = "models/weapons/w_smg1.mdl"
}

HOLSTER_DRAWINFO["arccw_m4a4"] = {
	pos = Vector(7, 20, 5),
	ang = Angle(0, 190, 0),
	bone = "ValveBiped.Bip01_Spine1",
	model = "models/weapons/arccw_go/v_rif_m4a1.mdl"
}

HOLSTER_DRAWINFO["arccw_crowbar"] = {
	pos = Vector(4, 6, 0),
	ang = Angle(30, 5, 0),
	bone = "ValveBiped.Bip01_Spine1",
	model = "models/weapons/w_crowbar.mdl"
}

HOLSTER_DRAWINFO["arccw_hatchet"] = {
	pos = Vector(5, -8, -1),
	ang = Angle(0, -90, 90),
	bone = "ValveBiped.Bip01_Pelvis",
	model = "models/weapons/tfa_nmrih/w_me_hatchet.mdl"
}

HOLSTER_DRAWINFO["arccw_knife"] = {
	pos = Vector(0, -8, 1),
	ang = Angle(0, -90, 90),
	bone = "ValveBiped.Bip01_Pelvis",
	model = "models/weapons/w_knife_ct.mdl"
}

HOLSTER_DRAWINFO["arccw_ar2"] = {
	pos = Vector(5, -4, -3),
	ang = Angle(0, 5, 0),
	bone = "ValveBiped.Bip01_Spine1",
	model = "models/weapons/w_IRifle.mdl"
}

HOLSTER_DRAWINFO["weapon_rpg"] = {
	pos = Vector(3, 20, 3),
	ang = Angle(-180, 5, 0),
	bone = "ValveBiped.Bip01_Spine1",
	model = "models/weapons/w_rocket_launcher.mdl"
}

HOLSTER_DRAWINFO["cellar_nade_flashbang"] = {
	pos = Vector(2, 8, 0),
	ang = Angle(15, 0, 270),
	bone = "ValveBiped.Bip01_Pelvis",
	model = "models/weapons/w_eq_flashbang.mdl"
}

HOLSTER_DRAWINFO["weapon_frag"] = {
	pos = Vector(2, 8, 0),
	ang = Angle(15, 0, 270),
	bone = "ValveBiped.Bip01_Pelvis",
	model = "models/items/grenadeammo.mdl"
}

HOLSTER_DRAWINFO["cellar_nade_m18"] = {
	pos = Vector(2, 8, 0),
	ang = Angle(15, 0, 270),
	bone = "ValveBiped.Bip01_Pelvis",
	model = "models/weapons/w_eq_smokegrenade_dropped.mdl"
}

HOLSTER_DRAWINFO["arccw_stunstick"] = {
	pos = Vector(4, 9, -2),
	ang = Angle(0, 100, 0),
	bone = "ValveBiped.Bip01_Pelvis",
	model = "models/weapons/w_stunbaton.mdl"
}

function PLUGIN:PostPlayerDraw(client)
	if (!client:GetCharacter()) then return end

	--if (client == LocalPlayer() and !client:ShouldDrawLocalPlayer()) then
	--	return
	--end

	local weapon = client:GetActiveWeapon()
	local curClass = ((weapon and weapon:IsValid()) and weapon:GetClass():lower() or "")

	client.holsteredWeapons = client.holsteredWeapons or {}

	-- Clean up old, invalid holstered weapon models.
	for k, v in pairs(client.holsteredWeapons) do
		local weapon = client:GetWeapon(k)

		if (!IsValid(weapon)) then
			v:Remove()
		end
	end

	-- Create holstered models for each weapon.
	for _, v in ipairs(client:GetWeapons()) do
		local class = v:GetClass():lower()
		local drawInfo = HOLSTER_DRAWINFO[class]

		if (!drawInfo or !drawInfo.model) then continue end

		if (!IsValid(client.holsteredWeapons[class])) then
			local model = ClientsideModel(drawInfo.model, RENDERGROUP_TRANSLUCENT)
			model:SetNoDraw(true)

			client.holsteredWeapons[class] = model
		end

		local drawModel = client.holsteredWeapons[class]
		local boneIndex = client:LookupBone(drawInfo.bone)

		if (!boneIndex or boneIndex < 0) then continue end

		local bonePos, boneAng = client:GetBonePosition(boneIndex)

		if (curClass != class and IsValid(drawModel)) then
			local right = boneAng:Right()
			local up = boneAng:Up()
			local forward = boneAng:Forward()	

			boneAng:RotateAroundAxis(right, drawInfo.ang[1])
			boneAng:RotateAroundAxis(up, drawInfo.ang[2])
			boneAng:RotateAroundAxis(forward, drawInfo.ang[3])

			bonePos = bonePos
				+ drawInfo.pos[1] * right
				+ drawInfo.pos[2] * forward
				+ drawInfo.pos[3] * up

			drawModel:SetRenderOrigin(bonePos)
			drawModel:SetRenderAngles(boneAng)
			drawModel:DrawModel()
		end
	end
end

function PLUGIN:EntityRemoved(entity)
	if (entity.holsteredWeapons) then
		for _, v in pairs(entity.holsteredWeapons) do
			v:Remove()
		end
	end
end

for _, v in ipairs(player.GetAll()) do
	for _, v2 in ipairs(v.holsteredWeapons or {}) do
		v2:Remove()
	end

	v.holsteredWeapons = nil
end
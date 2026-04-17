local PLUGIN = PLUGIN

local radialMenu
local precachedOptions
local lastAnimGroup

local function SelectAnimation(menu, option)
	ix.AnimHelper:BuildPreview(true, option.data[1])
end

local function BuildAnimOptions(sequences)
	local anims = {}

	for k, sequence in ipairs(sequences) do
		local info = ix.AnimHelper.anims[sequence]
		local isExist = LocalPlayer():LookupSequence(sequence)

		if (isExist > 0) and info then
			anims[#anims + 1] = {text = info.label, data = {sequence}, callback = SelectAnimation}
		end
	end

	return anims
end

local function RebuildOptions(animCategories)
	local options = {
		main = {}
	}

	for k, category in ipairs(animCategories) do
		local anims = BuildAnimOptions(category.options)

		if #anims > 0 then
			local categoryID = "list"..k

			options[categoryID] = anims
			options.main[#options.main + 1] = {text = category.label, callback = categoryID}
		end
	end

	precachedOptions = options
end

concommand.Add("+sit", function(client, cmd, args)
	if lastAnimGroup != client.ixAnimModelClass then
		RebuildOptions(PLUGIN.AnimOptions)

		lastAnimGroup = client.ixAnimModelClass
	end

	ix.AnimHelper:BuildPreview(false)
	
	radialMenu = vgui.Create("ui.radial.menu")
	radialMenu:SetMultiOptions(precachedOptions, "main")
	radialMenu:Open()

	local padding = ScrH() * 0.25
	local model = radialMenu:Add("DModelPanel")
	model:Dock(FILL)
	model:DockMargin(padding, padding, padding, padding)
	model:SetMouseInputEnabled(false)
	model:SetFOV(90)
	model:SetAlpha(255)
	model.LayoutEntity = function(self)
		local entity = self.Entity

		entity:SetIK(false)

		local bonePosition = entity:GetBonePosition(1)
		self:SetLookAt(bonePosition)
	end

	model:SetCamPos(Vector(180, 180, 50))
	model:SetModel(LocalPlayer():GetModel())
	model:SetPaintedManually(true)
	model.PreDrawModel = function(pnl, ent)
		render.OverrideColorWriteEnable(true, false)
		ent:DrawModel()
		render.OverrideColorWriteEnable(false, false)

		render.SetColorModulation(1, 1, 1)
		render.SetBlend(pnl:GetParent().alpha)
	end

	local selectedAnim

	radialMenu.OnOptionHovered = function(self, option)
		LocalPlayer():EmitSound("Helix.Rollover")

		local sequence = option.data[1]

		if sequence then
			model.Entity:SetSequence(model.Entity:LookupSequence(sequence))
		end

		selectedAnim = sequence
	end

	radialMenu.PrePaint = function(this, w, h, alpha)
		if selectedAnim then
			model:PaintManual()
		end
	end
end)

concommand.Add("-sit", function(player)
	if IsValid(radialMenu) then
		radialMenu:Close()
	end
end)
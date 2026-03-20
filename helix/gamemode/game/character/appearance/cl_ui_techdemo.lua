local CharGen = ix.CharGen
local PANEL = {}
PANEL.textClr = Color(0, 225, 255)

do
	local Scale = ix.UI.Scale
	surface.CreateFont('demo.title', {
		font = 'Blender Pro Book',
		extended = true,
		size = Scale(24),
		weight = 500,
		antialias = true,
	})
	surface.CreateFont('demo.title1', {
		font = 'Blender Pro Medium',
		extended = true,
		size = Scale(22),
		weight = 500,
		antialias = true,
	})

	surface.CreateFont('demo.selector', {
		font = 'Blender Pro Bold',
		extended = true,
		size = Scale(21),
		weight = 500,
		antialias = true,
	})
end



function PANEL:AddSelector(text, values, onSelect, default)
	local panel = self:Add("Panel")
	panel:Dock(TOP)

	local title = panel:Add("DLabel")
	title:Dock(LEFT)
	title:SetText(text and text or "PRIMARY MESH:")
	title:SetFont('demo.selector')
	title:SetTextColor(self.textClr)
	title:SizeToContents()

	local selection = panel:Add("DLabel")
	selection:Dock(FILL)
	selection:DockMargin(8, 0, 0, 0)
	selection:SetText("[ВЫБРАТЬ]")
	selection:SetFont('demo.selector')
	selection:SetTextColor(Color(255, 220, 0))
	selection:SetContentAlignment(4)
	selection:SetMouseInputEnabled(true)

	if default then
		if values[default] then
			selection:SetText(values[default].title:utf8upper())
		end
	end

	selection.DoClick = function()
		local menu = ix.SimpleMenu()

		for k, v in pairs(values) do
			menu:AddOption(v.title, function()
				selection:SetText(v.title:utf8upper())
				onSelect(v.id, v)
			end)
		end

		menu:Open()
	end

	panel:SizeToChildren(true, true)

	return panel, selection
end

function PANEL:AddValue(text, value, center)
	local panel = self:Add("Panel")
	panel:Dock(TOP)

	local title = panel:Add("DLabel")
	title:Dock(LEFT)
	title:SetText(text and text or "PRIMARY MESH:")
	title:SetFont('demo.selector')
	title:SetTextColor(self.textClr)
	title:SizeToContents()

	local selection = panel:Add("DLabel")
	selection:Dock(FILL)
	selection:DockMargin(8, 0, 0, 0)
	selection:SetText(value)
	selection:SetFont('demo.selector')
	selection:SetTextColor(Color(255, 220, 0))
	selection:SetContentAlignment(center and 5 or 4)

	panel:SizeToChildren(true, true)

	return panel, selection
end


function PANEL:AddTextureLayer(id, title, option)
	local options = CharGen:GetOptions(self.FaceMap.bundle, option)

	options[0] = {
		id = 0,
		title = "NO",
		tex = "",
	}

	if !self.FaceMap.layers[id] then
		self.FaceMap:SetLayer(id)
		self.FaceMap:SetLayerBlend(id, 0)
	end

	self.FaceMap:SetLayerColor(id)

	local tex1, sex1 = self:AddSelector(title, options, function(optionID, info) 
		
		if optionID <= 0 then
			self.FaceMap:SetLayer(id)
		else
			self.FaceMap:SetLayer(id, option, optionID)
		end

		self.FaceMap:Generate()
	end, self.FaceMap._layers[id] or 0)

	local panel, text = self:AddValue("СМЕШИВАНИЕ:", string.format("%s%%", 100 * self.FaceMap.blendLayers[id]))
	local slider = self:Add("ixSlider")
	slider:Dock(TOP)
	slider:SetTall(24)
	slider:DockMargin(0, 5, 0, 0)
	slider:SetMin(0)
	slider:SetMax(1)
	slider:SetDecimals(5)
	slider:SetValue(self.FaceMap.blendLayers[id])
	slider.OnValueUpdated = function(this)
		local delta = this:GetValue()
		local percent = 100 * delta

		text:SetText(percent .. "%")

		self.FaceMap:SetLayerBlend(id, delta)
		self.FaceMap:Generate()
	end

	return tex1
end

function PANEL:AddColor(text, value, changed, default)
	local panel = self:Add("Panel")
	panel:Dock(TOP)

	local title = panel:Add("DLabel")
	title:Dock(LEFT)
	title:SetText(text and text or "PRIMARY MESH:")
	title:SetFont('demo.selector')
	title:SetTextColor(self.textClr)
	title:SizeToContents()

	local picker = self:AddColorPicker(panel)
	picker.color = value or color_white
	picker:DockMargin(8, 0, 0, 0)
	picker:Dock(LEFT)
	picker.OnValueChanged = function(_, clr)
		changed(clr)
	end
	picker.OnValueUpdated = function(_, clr)
		changed(clr)
	end
	picker.color = default and default or picker.color
	panel:SizeToChildren(true, true)

	return panel, picker
end

function PANEL:CopyFacemap()
	local faceMap = self.FaceMap
	local original = LocalPlayer().faceMap 

	if !original then
		return
	end
	
	faceMap.bundle = original.bundle
	
	faceMap:SetPrimary(original:GetPrimary())
	faceMap:SetSecondary(original:GetSecondary())
	faceMap:SetMix(original.faceMix)
	faceMap:SetEyeColor(original.eyeColor)

	faceMap.layers = table.Copy(original.layers)
	faceMap._layers = table.Copy(original._layers)
	faceMap.colorLayers = table.Copy(original.colorLayers)
	faceMap.blendLayers = table.Copy(original.blendLayers)
end

function PANEL:Init()
	if IsValid(ix.gui.techdemo) then
		ix.gui.techdemo:Remove()
		ix.gui.techdemo = nil
	end
	
	ix.gui.techdemo = self


	self.CharGenData = LocalPlayer():GetCharacter():CharGen()
	self.FaceMap = ix.meta.FaceMap:New("local", "female")

	self:CopyFacemap()

	self.FaceMap.noSave = true
	
	self.FaceMap:Generate(function(tex)
		LocalPlayer().PreviewFace = tex
	end)

	self.FaceMap:GenerateEyes(function(tex)
		LocalPlayer().PreviewFaceEyes = tex
	end)

	self:SetSize(ScrW() * 0.3, ScrH() * 0.975)
	self:DockPadding(32, 16, 32, 16)
	local title = self:Add("DLabel")
	title:Dock(TOP)
	title:SetContentAlignment(5)
	title:SetText("FaceMorph Techdemo")
	title:SetFont('demo.title')
	title:SetAlpha(255)
	title:SetPos(0, 0)
	title:SetTall(22)
	title:SetTextColor(self.textClr)

	local title = self:Add("DLabel")
	title:Dock(TOP)
	title:SetContentAlignment(6)
	title:SetText("[X] — ПОКАЗАТЬ КУРСОР")
	title:SetFont('demo.title1')
	title:SetAlpha(255)
	title:SetTall(22)
	title:SetTextColor(ix.Palette.combineyellow)
	title:DockMargin(0, 8, 0, 0)

	local title = self:Add("DLabel")
	title:DockMargin(0, 16, 0, 0)
	title:Dock(TOP)
	title:SetContentAlignment(5)
	title:SetText("ФОРМА ЛИЦА")
	title:SetFont('demo.title1')
	title:SetAlpha(255)
	title:SetPos(0, 0)
	title:SetTall(22)
	title:SetTextColor(ix.Palette.combinegreen)

	local faces = CharGen:GetFaceMorphs(self.FaceMap.bundle)

	local mesh1 = self:AddSelector("ЛИЦО 1:", faces, function(id, info)
		self.CharGenData:SetFaceMorph(true, info.id)
		self.CharGenData:Update()
	end, self.CharGenData:GetFaceMorph(true))

	local mesh2 = self:AddSelector("ЛИЦО 2:", faces, function(id, info)
		self.CharGenData:SetFaceMorph(false, info.id)
		self.CharGenData:Update()
	end, self.CharGenData:GetFaceMorph(false))

	mesh1:DockMargin(0, 8, 0, 0)

	local meshMix = self.CharGenData:GetMorphDelta()
	local panel, text = self:AddValue("СМЕШИВАНИЕ:", string.format("%s%%", 100 * meshMix))

	local slider = self:Add("ixSlider")
	slider:Dock(TOP)
	slider:SetTall(24)
	slider:DockMargin(0, 5, 0, 0)
	slider:SetMin(0)
	slider:SetMax(1)
	slider:SetDecimals(5)
	slider:SetValue(meshMix)
	slider.OnValueUpdated = function(this)
		local delta = this:GetValue()
		local percent = 100 * delta

		text:SetText(percent .. "%")

		self.CharGenData:SetMorphDelta(delta)
		self.CharGenData:Update()
	end
	slider.OnValueChanged = function(this)
		
	end

	local title = self:Add("DLabel")
	title:DockMargin(0, 16, 0, 8)
	title:Dock(TOP)
	title:SetContentAlignment(5)
	title:SetText("ПАРАМЕТРЫ ВНЕШНОСТИ")
	title:SetFont('demo.title1')
	title:SetAlpha(255)
	title:SetPos(0, 0)
	title:SetTall(22)
	title:SetTextColor(ix.Palette.combinegreen)


	local eyeColor = self:AddColor("ЦВЕТ ГЛАЗ:", nil, function(newClr)
		self.FaceMap.eyeColor = newClr
		self.FaceMap:GenerateEyes()
	end, self.FaceMap.eyeColor)


	local bodygroups = CharGen:GetBodygroupCategories(self.FaceMap.bundle)

	for k, info in pairs(bodygroups) do
		local mesh1 = self:AddSelector(info.title:utf8upper()..":", info.options, function(selected, option)
			net.Start("techdemo.chargen.bg")
				net.WriteUInt(info.id, 4)
				net.WriteUInt(selected, 4)
			net.SendToServer()
		end, self.CharGenData:GetBodyGroup(k))
	end

	local title = self:Add("DLabel")
	title:DockMargin(0, 16, 0, 8)
	title:Dock(TOP)
	title:SetContentAlignment(5)
	title:SetText("ТЕКСТУРА ЛИЦА")
	title:SetFont('demo.title1')
	title:SetAlpha(255)
	title:SetPos(0, 0)
	title:SetTall(22)
	title:SetTextColor(ix.Palette.combinegreen)

	local faceMaps = CharGen:GetOptions(self.FaceMap.bundle, CharGen.Option.FaceMap)

	local tex1 = self:AddSelector("ТЕКСТУРА 1:", faceMaps, function(id, info)
		self.FaceMap:SetPrimary(info.id)

		self.FaceMap:Generate()
	end, self.FaceMap:GetPrimary())

	local tex2 = self:AddSelector("ТЕКСТУРА 2:", faceMaps, function(id, info)
		self.FaceMap:SetSecondary(info.id)

		self.FaceMap:Generate()
	end, self.FaceMap:GetSecondary())

	local panel, text = self:AddValue("СМЕШИВАНИЕ:", string.format("%s%%", 100 * self.FaceMap.faceMix))
	local slider = self:Add("ixSlider")
	slider:Dock(TOP)
	slider:SetTall(24)
	slider:DockMargin(0, 5, 0, 0)
	slider:SetMin(0)
	slider:SetMax(1)
	slider:SetDecimals(5)
	slider:SetValue(self.FaceMap.faceMix)
	slider.OnValueUpdated = function(this)
		local delta = this:GetValue()
		local percent = 100 * delta

		text:SetText(percent .. "%")

		self.FaceMap:SetMix(delta)
		self.FaceMap:Generate()
	end

	local title = self:Add("DLabel")
	title:DockMargin(0, 16, 0, 0)
	title:Dock(TOP)
	title:SetContentAlignment(5)
	title:SetText("ДЕТАЛИ ЛИЦА")
	title:SetFont('demo.title1')
	title:SetAlpha(255)
	title:SetPos(0, 0)
	title:SetTall(22)
	title:SetTextColor(ix.Palette.combinegreen)

	local textureLayers = CharGen:GetTextureLayers(self.FaceMap.bundle)

	for k, v in ipairs(textureLayers) do
		local panel = self:AddTextureLayer(k, v.title:utf8upper(), v.option)
		panel:DockMargin(0, 16, 0, 0)
	end

	--

	local confirm = self:Add("ui.craft.button")
	confirm:DockMargin(0, 16, 0, 0)
	confirm:Dock(BOTTOM)
	confirm:SetText("ПРИМЕНИТЬ")
	confirm:SetTall(32)
	confirm.DoClick = function()
		net.Start("techdemo.chargen")
			local primaryMorph = self.CharGenData.data[4]
			local secondaryMorph = self.CharGenData.data[5]
			local morphMix = self.CharGenData.data[6]

			net.WriteUInt(primaryMorph, 7)
			net.WriteUInt(secondaryMorph, 7)
			net.WriteFloat(morphMix)

			local primaryTex = self.FaceMap:GetPrimary()
			local secondaryTex = self.FaceMap:GetSecondary()
			local textureMix = self.FaceMap:GetMix()

			net.WriteUInt(primaryTex, 8)
			net.WriteUInt(secondaryTex, 8)
			net.WriteFloat(textureMix)

			local eyeColor = self.FaceMap.eyeColor
			net.WriteColor(eyeColor, false)

			local textureLayersCount = 0
			for layerID, _ in pairs(self.FaceMap._layers) do
				textureLayersCount = textureLayersCount + 1
			end

			net.WriteUInt(textureLayersCount, 4)

			if textureLayersCount > 0 then
				for layerID, layerTexture in pairs(self.FaceMap._layers) do
					--net.WriteUInt(layerID, 4)
					net.WriteUInt(layerTexture, 8)

					if layerTexture > 0 then
						local layerMix = self.FaceMap.blendLayers[layerID] or 0

						net.WriteFloat(layerMix)

						local customLayerColor = self.FaceMap.colorLayers[layerID]

						net.WriteBool((customLayerColor != nil))

						if customLayerColor then
							net.WriteColor(Color(customLayerColor.r, customLayerColor.g, customLayerColor.b), false)
						end
					end
				end
			end
		net.SendToServer()

		LocalPlayer().PreviewFace = nil
		LocalPlayer().PreviewFaceEyes = nil

		gui.EnableScreenClicker(false)
		self:Remove()
	end

	self:Center()
	self:AlignRight(32)
	--self:MakePopup()
end

function PANEL:AddColorPicker(parent)
	local panel = parent:Add("Panel")
	panel:SetCursor("hand")
	panel:SetMouseInputEnabled(true)
	panel.Paint = function(panel, width, height)
		surface.SetDrawColor(panel.color)
		surface.DrawRect(0, 0, width, height)
	end
	panel.OnMousePressed = function(panel, key)
		if key == MOUSE_LEFT then
			self:OpenPicker(panel)
		end
	end
	panel.color = table.Copy(color_white)

	return panel
end

function PANEL:OpenPicker(attach)
	if IsValid(self.picker) then
		self.picker:Remove()
		return
	end

	self.picker = vgui.Create("ixSettingsRowColorPicker")
	self.picker:Attach(attach)
	self.picker:SetValue(attach.color)

	self.picker.OnValueChanged = function(panel)
		local newColor = panel:GetValue()

		if newColor != attach.color then
			attach.color = newColor
			attach:OnValueChanged(newColor)
		end
	end

	self.picker.OnValueUpdated = function(panel)
		attach.color = panel:GetValue()
		attach:OnValueUpdated(attach.color)
	end
end

local shadow = Material('cellar/slot_shadow.png')
local clrBG = Color(16, 32, 48, 255 * 0.75)
local clrOutline = Color(0, 190 * 0.5, 128, 128)

local function DrawCorners(x, y, w, h, size)
	surface.SetDrawColor(0, 190, 255, 255)
	surface.DrawLine(x, y, x + size, y)
	surface.DrawLine(x, y, x, y + size)

	x, y = w - 1, y

	surface.DrawLine(x, y, x - size, y)
	surface.DrawLine(x, y, x, y + size)

	x, y = 0, h - 1

	surface.DrawLine(x, y, x + size, y)
	surface.DrawLine(x, y, x, y - size)

	x, y = w - 1, h - 1

	surface.DrawLine(x, y, x - size, y)
	surface.DrawLine(x, y, x, y - size)
end



function PANEL:Paint(w, h)
	if input.IsKeyDown(KEY_X) then
		self.active = true
		gui.EnableScreenClicker(true)
	elseif self.active and !input.IsKeyDown(KEY_X) then
		gui.EnableScreenClicker(false)
		self.active = false
	end
	
	ix.DX.Draw(0, 0, 0, w, h, nil, ix.DX.BLUR)

	surface.SetDrawColor(color_white)
	surface.SetMaterial(shadow)
	surface.DrawTexturedRect(0, 0, w, h)

	ix.DX.Draw(0, 0, 0, w, h, clrBG)

	DrawCorners(0, 0, w, h, 16)

	ix.DX.DrawOutlined(0, 0, 0, w, h, clrOutline, 2)
end

vgui.Register("techdemo.customize", PANEL, "EditablePanel")
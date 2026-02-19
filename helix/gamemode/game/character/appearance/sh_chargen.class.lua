local CharGenData = class "CharGenData"
local CharGen = ix.CharGen

function CharGenData:__tostring() return "chargendata["..tostring(self.character).."]" end
function CharGenData:GetCharacter() return self.character end
function CharGenData:GetPlayer()
	if !self.client then
		self.client = self.character and self.character:GetPlayer() or nil

		if !self.client then -- temporary hack
			for k, v in ipairs(player.GetAll()) do
				if v:GetCharacter() == self.character then
					self.client = v
					break
				end
			end
		end

	end
	
	return self.client
end

local Data = {
	PrimaryTexture = 1,
	SecondaryTexture = 2,
	TextureMix = 3,
	PrimaryMorph = 4,
	SecondaryMorph = 5,
	MorphMix = 6,
	TextureLayers = 7,
	EyeColor = 8,
	BodyGroups = 9
}

local Layer = {
	Id = 1,
	Texture = 2,
	Mix = 3,
	Color = 4
}

local UpdateSignal = {
	All = 1,
	Textures = 2,
	Morph = 3,
	BodyGroups = 4,
}

function CharGenData:Init(character, var, data)
	self.var = var
	self.character = character

	self.data = {
		[Data.PrimaryTexture] = 0,
		[Data.SecondaryTexture] = 0,
		[Data.TextureMix] = 0,
		[Data.PrimaryMorph] = 0,
		[Data.SecondaryMorph] = 0,
		[Data.MorphMix] = 0,
		[Data.TextureLayers] = {},
		[Data.EyeColor] = {255, 255, 255},
		[Data.BodyGroups] = {}
	}

	self._class = CharGen:GetModelClass(character:GetModel())
	self._eyePos = {
		left = vector_origin,
		right = vector_origin
	}

	self._flexes = {}
	self._updateEyes = false
	self._updateFlexes = false

	self:SetupBodyGroups()
end

function CharGenData:Load(vars)
	local isDefault = (vars.charGen == nil)
	local charGen = istable(vars.charGen) and vars.charGen or util.JSONToTable(vars.charGen or "[]")

	self.client = nil

	if isDefault then
		print("CharGenData::Default")
	else
		print("CharGenData::Load")

		for k, v in pairs(self.data) do
			local value = (charGen or {})[k]

			if k == Data.TextureLayers then
				for layerID, layer in pairs(value or {}) do
					local color = layer[Layer.Color]

					if color then
						value[layerID][Layer.Color] = Color(color.r, color.g, color.b)
					end
				end
			end
			
			self.data[k] = value and value or self.data[k]
		end
	end

	local faceMorphs = CharGen:GetFaceMorphs(self._class)

	if !faceMorphs then
		print("CharGenData::No FaceMorphs!")
	end

	self:CacheBodyGroups()
end

function CharGenData:SetupBodyGroups()
	local categories = CharGen:GetBodygroupCategories(self._class)

	self.data[Data.BodyGroups] = {}

	for categoryID, info in pairs(categories) do
		self.data[Data.BodyGroups][categoryID] = 1
	end

	self:CacheBodyGroups()
end

function CharGenData:GetBodyGroup(id) return self.data[Data.BodyGroups][id] end
function CharGenData:CacheBodyGroups()
	self._bodygroups = {}

	for categoryID, selected in pairs(self.data[Data.BodyGroups]) do
		local options = CharGen:GetBodygroupOptions(self._class, categoryID)
		local selectedInfo = options[selected]

		for g, v in pairs(selectedInfo.bodygroups) do
			self._bodygroups[g] = v
		end
	end
end

function CharGenData:GetFaceMorph(primaryOrSecondary) return self.data[primaryOrSecondary and Data.PrimaryMorph or Data.SecondaryMorph] end
function CharGenData:SetFaceMorph(primaryOrSecondary, face)
	local faceMorphs = CharGen:GetFaceMorphs(self._class)

	if !faceMorphs or !faceMorphs[face] then
		return
	end

	self.data[primaryOrSecondary and Data.PrimaryMorph or Data.SecondaryMorph] = face

	self._flexes = {}
	self._eyePos.left = vector_origin
	self._eyePos.right = vector_origin

	for k, v in pairs(faceMorphs) do
		self._flexes[v.flex] = (v.id == self.data[Data.PrimaryMorph]) and 1 or 0
	end
end

function CharGenData:GetMorphDelta() return self.data[Data.MorphMix] end
function CharGenData:SetMorphDelta(value) self.data[Data.MorphMix] = value end

local function VectorLerp(const, vec1, vec2)
    return vec1 + (vec2 - vec1) * const
end

function CharGenData:Update(reset)
	local client = self:GetPlayer()

	if !IsValid(client) then
		return
	end
	
	local faceMorphs = CharGen:GetFaceMorphs(self._class)

	if !faceMorphs or reset then
		for k, v in pairs(self._flexes) do
			self._flexes[k] = 0
		end

		return
	end

	local selectedPrimary = self.data[Data.PrimaryMorph]
	local selectedSecondary = self.data[Data.SecondaryMorph]

	local primaryFaceData = faceMorphs[selectedPrimary] or {}
	local secondaryFaceData = faceMorphs[selectedSecondary] or {}

	local primaryFlex = primaryFaceData.flex or -1
	local secondaryFlex = secondaryFaceData.flex or -1
	local eyeBase = primaryFaceData.eyes
	local eyeTarget = secondaryFaceData.eyes
	local delta = self.data[Data.MorphMix]

	-- primaryFace invalid & secondaryFace valid
	if (!primaryFlex or primaryFlex < 0) and secondaryFlex and secondaryFlex >= 0 then
		self._flexes[secondaryFlex] = delta
	-- secondaryFace invalid & primaryFace valid
	elseif (!secondaryFlex or secondaryFlex < 0) and primaryFlex and primaryFlex >= 0 then
		self._flexes[primaryFlex] = delta
	-- both valid: default mixing
	elseif primaryFlex and primaryFlex >= 0 and secondaryFlex and secondaryFlex >= 0 then
		self._flexes[primaryFlex] = 1 - delta
		self._flexes[secondaryFlex] = delta
	end

	self._eyePos.left = VectorLerp(delta, eyeBase and eyeBase.left or vector_origin, eyeTarget and eyeTarget.left or vector_origin)
	self._eyePos.right = VectorLerp(delta, eyeBase and eyeBase.right or vector_origin, eyeTarget and eyeTarget.right or vector_origin)
	self._updateEyes = true
	self._updateFlexes = true
end

function CharGenData:ToSaveable()
	return self.data
end

if SERVER then
	util.AddNetworkString("techdemo.chargen") -- temporary for testing
	util.AddNetworkString("techdemo.chargen.bg") -- temporary for testing
	
	function CharGenData:NetWriteMorph()
		net.WriteUInt(self.data[Data.PrimaryMorph], 7)
		net.WriteUInt(self.data[Data.SecondaryMorph], 7)
		net.WriteFloat(self.data[Data.MorphMix])
	end

	function CharGenData:NetWriteTextures()
		net.WriteUInt(self.data[Data.PrimaryTexture], 8)
		net.WriteUInt(self.data[Data.SecondaryTexture], 8)
		net.WriteFloat(self.data[Data.TextureMix])

		local eyeColor = self.data[Data.EyeColor]
		net.WriteColor(Color(eyeColor[1], eyeColor[2], eyeColor[3]), false)

		local validLayers = CharGen:GetTextureLayers(self._class)

		local textureLayers = self.data[Data.TextureLayers]
		local textureLayersCount = 0

		for layerID in next, validLayers do
			textureLayersCount = textureLayersCount + 1
		end

		net.WriteUInt(textureLayersCount, 4)

		if textureLayersCount > 0 then
			local layers = self.data[Data.TextureLayers]

			for layerID, info in ipairs(validLayers) do
				local layer = layers[layerID] or {}
				local selectedOption = layer[Layer.Texture] or 0

				net.WriteUInt(selectedOption, 8)

				if selectedOption > 0 then
					net.WriteFloat(layer[Layer.Mix] or 0)

					local hasCustomColor = layer[Layer.Color] != nil

					net.WriteBool(hasCustomColor)

					if hasCustomColor then
						net.WriteColor(layer[Layer.Color], false)
					end
				end
			end
		end
	end

	function CharGenData:NetWrite()
		net.WriteUInt(self.syncType, 2)

		if self.syncType == UpdateSignal.All or self.syncType == UpdateSignal.Morph then
			self:NetWriteMorph()
		end

		if self.syncType == UpdateSignal.All or self.syncType == UpdateSignal.Textures then
			self:NetWriteTextures()
		end

		if self.syncType == UpdateSignal.All or self.syncType == UpdateSignal.BodyGroups then
			local groups = self.data[Data.BodyGroups]
			local count = table.Count(groups)

			net.WriteUInt(count, 4)

			for k, v in pairs(groups) do
				net.WriteUInt(k, 4)
				net.WriteUInt(v, 4)
			end
		end
	end

	function CharGenData:Sync(receiver, broadcast)
		self:SendUpdate(UpdateSignal.All, receiver)
	end

	function CharGenData:SendUpdate(syncType, receiver)
		self.syncType = syncType

		net.Start("CharacterVarChanged")
			net.WriteUInt(self.character:GetID(), 32)
			net.WriteCharVar(self.character, self.var)
		if receiver then
			net.Send(receiver)
		else
			net.Broadcast()
		end
	end

	-- temporary for testing
	net.Receive("techdemo.chargen.bg", function(len, client)
		local character = client:GetCharacter()
		local charGen = character:CharGen()

		local category = net.ReadUInt(4)
		local selectedOption = net.ReadUInt(4)

		charGen.data[Data.BodyGroups][category] = selectedOption
		charGen:CacheBodyGroups()

		client.char_outfit:Update()
	end)

	net.Receive("techdemo.chargen", function(len, client)
		local character = client:GetCharacter()
		local charGen = character:CharGen()
		local class = charGen._class

		print("techdemo.chargen", len)

		local primaryMorph = net.ReadUInt(7)
		local secondaryMorph = net.ReadUInt(7)
		local morphMix = net.ReadFloat()

		charGen:SetFaceMorph(true, primaryMorph)
		charGen:SetFaceMorph(false, secondaryMorph)
		charGen:SetMorphDelta(morphMix)

		local primaryTex = net.ReadUInt(8)
		local secondaryTex = net.ReadUInt(8)
		local textureMix = net.ReadFloat()

		charGen.data[Data.PrimaryTexture] = primaryTex
		charGen.data[Data.SecondaryTexture] = secondaryTex
		charGen.data[Data.TextureMix] = math.Clamp(textureMix, 0, 1)

		local eyeColor = net.ReadColor(false)
		charGen.data[Data.EyeColor] = {eyeColor.r, eyeColor.g, eyeColor.b}

		local validLayers = CharGen:GetTextureLayers(class)
		local currentLayers = charGen.data[Data.TextureLayers]
		local textureLayersCount = net.ReadUInt(4)

		if textureLayersCount > 0 then
			for layerID, layerInfo in ipairs(validLayers) do
				local layerTexture = net.ReadUInt(8)

				local availableLayerOptions = CharGen:GetOptions(class, layerInfo.option)
				local selectedOption = availableLayerOptions[layerTexture]

				if !selectedOption then
					continue
				end

				local layerMix = 0
				local layerColor
				local hasCustomColor = false

				currentLayers[layerID] = currentLayers[layerID] or {}

				if layerTexture > 0 then
					layerMix = net.ReadFloat()
					hasCustomColor = net.ReadBool()

					currentLayers[layerID][Layer.Texture] = layerTexture
					currentLayers[layerID][Layer.Mix] = math.Clamp(layerMix, 0, 1)

					if hasCustomColor then
						layerColor = net.ReadColor(false)
					end

					currentLayers[layerID][Layer.Color] = layerColor and layerColor or selectedOption.color
				else
					currentLayers[layerID] = {
						[Layer.Texture] = 0,
					}
				end
			end
		end

		charGen:Update()
		charGen:Sync()

		if !character.vars.charGen then
			character.vars.charGen = {}
		end
	end)
else
	function CharGenData:NetRead()
		local syncType = net.ReadUInt(2)

		if syncType == UpdateSignal.All or syncType == UpdateSignal.Morph then
			self:SetFaceMorph(true, net.ReadUInt(7))
			self:SetFaceMorph(false, net.ReadUInt(7))
			self:SetMorphDelta(net.ReadFloat())
		end

		if syncType == UpdateSignal.All or syncType == UpdateSignal.Textures then
			local client = self:GetPlayer()
			local model = self:GetCharacter():GetModel()
			local class = CharGen:GetModelClass(model)
			local validLayers = CharGen:GetTextureLayers(class)

			local faceMap = ix.meta.FaceMap:New(self:GetCharacter():GetID(), class)

			local primaryTexture = net.ReadUInt(8)
			local secondaryTexture = net.ReadUInt(8)
			local textureMix = net.ReadFloat()

			local eyeColor = net.ReadColor(false)

			local textureLayersCount = net.ReadUInt(4)

			if textureLayersCount > 0 then
				for layerID, layerInfo in ipairs(validLayers) do
					local layerTexture = net.ReadUInt(8)

					if layerTexture > 0 then
						local layerMix = net.ReadFloat()
						local availableLayerOptions = CharGen:GetOptions(class, layerInfo.option)
						local selectedOption = availableLayerOptions[layerTexture]

						faceMap:SetLayer(layerID, layerInfo.option, layerTexture)
						faceMap:SetLayerBlend(layerID, layerMix)

						local hasCustomColor = net.ReadBool()
						local layerColor

						if hasCustomColor then
							layerColor = net.ReadColor(false)
						else
							layerColor = selectedOption.color and selectedOption.color or color_white
						end

						faceMap:SetLayerColor(layerID, layerColor)
					else
						faceMap:SetLayer(layerID)
						faceMap:SetLayerBlend(layerID, 0)
						faceMap:SetLayerColor(layerID)
					end
				end
			end

			faceMap:SetPrimary(primaryTexture)
			faceMap:SetSecondary(secondaryTexture)
			faceMap:SetMix(textureMix)

			faceMap:SetEyeColor(eyeColor)

			if IsValid(client) then
				faceMap:Generate(function(tex)
					faceMap.baked = tex
				end)

				faceMap:GenerateEyes(function(tex)
					faceMap.bakedEyes = tex
				end)

				client.faceMap = faceMap
			end
		end

		if syncType == UpdateSignal.All or syncType == UpdateSignal.BodyGroups then
			local bodyOptionsCount = net.ReadUInt(4)
			local groups = self.data[Data.BodyGroups]

			for i = 1, bodyOptionsCount do
				local id = net.ReadUInt(4)
				local selected = net.ReadUInt(4)

				groups[id] = selected
			end

			self.data[Data.BodyGroups] = groups
		end

		self:Update()
	end
end

ix.meta.CharGenData = CharGenData

if CLIENT then
	hook.Add("UpdateAnimation", "chargen.flexes", function(client)
		local character = client:GetCharacter()

		if character then
			local charGenData = character:CharGen()

			if charGenData and charGenData._flexes then
				for k, v in pairs(charGenData._flexes) do
					client:SetFlexWeight(k, v)
				end
			end
		end
	end)
end
